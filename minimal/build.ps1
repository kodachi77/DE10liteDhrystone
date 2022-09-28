$proj_name = 'Embed'
$part = '10M50DAF484C6GES'

$app_dir = "software\dhrystone"

$project_version = ""
$version_re = "QUARTUS_VERSION\s+=\s+`"(.+)`""
Get-Content "$proj_name.qpf" | Where-Object {$_ -match $version_re} | ForEach-Object {
	$project_version = $Matches[1]
}

$quartus_root_sys = [System.Environment]::GetEnvironmentVariable('QUARTUS_ROOTDIR', 'Machine')
$sopc_kit_sys = [System.Environment]::GetEnvironmentVariable('SOPC_KIT_NIOS2', 'Machine')
$qsys_root_sys = [System.Environment]::GetEnvironmentVariable('QSYS_ROOTDIR', 'Machine')

$quartus_root_usr = [System.Environment]::GetEnvironmentVariable('QUARTUS_ROOTDIR', 'User')
$sopc_kit_usr = [System.Environment]::GetEnvironmentVariable('SOPC_KIT_NIOS2', 'User')
$qsys_root_usr = [System.Environment]::GetEnvironmentVariable('QSYS_ROOTDIR', 'User')

$in = ''
if ($quartus_root_sys -and $quartus_root_usr) {
	if( $project_version ) {
		if( $quartus_root_usr -match $project_version ) {
			$in = '1'
		} 
		elseif( $quartus_root_sys -match $project_version ) {
			$in = '2'
		}
	}

	if( -not $in ) {
		Write-Output "More than 2 Quartus installations found."
		Write-Output "Please specify which one to use (q to exit):"
		Write-Output (" 1. {0}" -f $quartus_root_usr)
		Write-Output (" 2. {0}" -f $quartus_root_sys)

		while( ($in -ne '1') -and ($in -ne '2') -and ($in -ine 'q') ) {
			$in = Read-Host "> "
		}
		
		if($in -eq 'q') {
			Write-Output "Exiting..."
			Exit
		}
	}
}

if( ($quartus_root_usr -and (-not $quartus_root_sys)) -or ($in -eq "1") ) {
	$quartus_root = $quartus_root_usr
	$sopc_kit = $sopc_kit_usr
	if( $qsys_root_usr ) {
		$qsys_root = $qsys_root_usr
	}
}

if( ($quartus_root_sys -and (-not $quartus_root_usr)) -or ($in -eq "2") ) {
	$quartus_root = $quartus_root_sys
	$sopc_kit = $sopc_kit_sys
	if( $qsys_root_sys ) {
		$qsys_root = $qsys_root_sys
	}
}

if( (-not $quartus_root) -or (-not $sopc_kit) ) {
	Write-Error "Not all required environment variables are set. Please set QUARTUS_ROOTDIR and SOPC_KIT_NIOS2."
	Exit
}

if( -not ( $quartus_root -match $project_version ) ) {
	Write-Warning "Quartus installation version doesn't match project version."
	Write-Warning "Manual upgrade/downgrade may be required."
	Write-Warning "Command-line build is not guaranteed to work."
	
	while( ($in -ine 'y') -and ($in -ine 'n') ) {
		$in = Read-Host "Continue (y/N)> "
	}
	
	if( $in -eq 'n' ) {
		Write-Output "Exiting..."
		Exit
	}
}

if( -not $qsys_root ) {
	$qsys_root = $quartus_root + "\sopc_builder\bin"
	if( -not (Test-Path -Path $qsys_root -PathType Container) ) {
		Write-Error "Cannot find QSys (Platform Designer) installation folder."
		Exit
	}
}

[System.Environment]::SetEnvironmentVariable('QUARTUS_ROOTDIR', $quartus_root, 'Process')
[System.Environment]::SetEnvironmentVariable('SOPC_KIT_NIOS2', $sopc_kit, 'Process')
[System.Environment]::SetEnvironmentVariable('QSYS_ROOTDIR', $qsys_root, 'Process')

$quartus_bin = $quartus_root + "\bin"
if( -not (Test-Path -Path $quartus_bin -PathType Container) ) {
	$quartus_bin = $quartus_root + "\bin64"
}

$sopc_bin = ("{0}\sdk2\bin" -f $sopc_kit)

$path = [Environment]::GetEnvironmentVariable("PATH", 'Process')

if ( -not $path.Contains($quartus_bin) ) {
	$path += ";$quartus_bin"
}

if ( -not $path.Contains($qsys_root) ) {
	$path += ";$qsys_root"
}

if ( -not $path.Contains($sopc_bin) ) {
	$path += ";$sopc_bin"
}


[System.Environment]::SetEnvironmentVariable("PATH", $path, 'Process')

qsys-generate ("{0}.qsys" -f $proj_name)  --synthesis=VERILOG ("--part={0}" -f $part)

quartus_map --read_settings_files=on  --write_settings_files=off $proj_name -c $proj_name
quartus_fit --read_settings_files=off --write_settings_files=off $proj_name -c $proj_name
quartus_asm --read_settings_files=off --write_settings_files=off $proj_name -c $proj_name
quartus_sta $proj_name -c $proj_name
quartus_sta -t timing-report.tcl $proj_name
#quartus_eda --read_settings_files=on  --write_settings_files=off $proj_name -c $proj_name

$sof_file = ("output_files/{0}_time_limited.sof" -f $proj_name)
if( -not (Test-Path -Path $sof_file -PathType Leaf) ) {
	$sof_file = ("output_files/{0}.sof" -f $proj_name)
}

Copy-Item ($sof_file) -Destination "demo_batch" -Force

$bsp_dir = $app_dir + "_bsp"
$bsp_settings = "$bsp_dir\settings.bsp"

if( -not (Test-Path -Path $bsp_dir -PathType Container) ) {
	New-Item -Path $bsp_dir -ItemType Directory
}

nios2-bsp-create-settings --bsp-dir $bsp_dir --settings $bsp_settings  --sopc "$proj_name.sopcinfo"  --type "hal" --script "$sopc_bin\bsp-set-defaults.tcl" --cpu-name "nios2_gen2_0"
nios2-bsp-update-settings --bsp-dir $bsp_dir --settings $bsp_settings --script "bsp-update.tcl"
nios2-bsp-generate-files  --bsp-dir $bsp_dir --settings $bsp_settings

nios2-app-generate-makefile --bsp-dir $bsp_dir --app-dir $app_dir --elf-name "dhrystone.elf"  --src-files dhry_1.c dhry_2.c
nios2-app-update-makefile --app-dir $app_dir --set-optimization "-O3" --set-debug-level "-g0" --set-defined-symbols "-DREG"

[System.Environment]::SetEnvironmentVariable('CYGWIN', 'nodosfilewarning', 'Process')
[System.Environment]::SetEnvironmentVariable('SHELLOPTS', 'igncr', 'Process')

$tmp = $sopc_kit + "\nios2_command_shell.sh"
$command_shell_path = '/cygdrive/' + (Split-Path $tmp -Qualifier).ToLower()[0] + (Split-Path $tmp -NoQualifier) -replace '\\', '/'

Start-Process -FilePath "$quartus_bin\cygwin\bin\bash.exe" -ArgumentList @($command_shell_path, "make", "-C", "$app_dir") -NoNewWindow -Wait

Copy-Item "$app_dir\dhrystone.elf" -Destination "demo_batch" -Force
