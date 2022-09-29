param(
	[Parameter(Mandatory=$true)]
	[string]$proj_name
)

Write-Output "**** Running setup-environment.ps1 ****"

$project_file = "$proj_name.qpf"
if( -not (Test-Path -Path "$project_file" -PathType Leaf) ) {
	$project_file = "..\$proj_name.qpf"
}

$project_version = "16.1"
if( Test-Path -Path "$project_file" -PathType Leaf ) {
	$version_re = "QUARTUS_VERSION\s+=\s+`"(.+)`""
	Get-Content "$project_file" | Where-Object {$_ -match $version_re} | ForEach-Object {
		$project_version = $Matches[1]
	}
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
		Write-Output "More than 1 Quartus installation found."
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

if( ($quartus_root_usr -and (-not $quartus_root_sys)) -or ($in -eq '1') ) {
	$quartus_root = $quartus_root_usr
	$sopc_kit = $sopc_kit_usr
	if( $qsys_root_usr ) {
		$qsys_root = $qsys_root_usr
	}
}

if( ($quartus_root_sys -and (-not $quartus_root_usr)) -or ($in -eq '2') ) {
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

[System.Environment]::SetEnvironmentVariable('QUARTUS_ROOTDIR', $quartus_root, 'Process')
[System.Environment]::SetEnvironmentVariable('SOPC_KIT_NIOS2', $sopc_kit, 'Process')

if( -not $qsys_root ) {
	$qsys_root = $quartus_root + "\sopc_builder\bin"
	if( Test-Path -Path $qsys_root -PathType Container ) {
		[System.Environment]::SetEnvironmentVariable('QSYS_ROOTDIR', $qsys_root, 'Process')
	}
	else {
		Write-Error "Cannot find QSys (Platform Designer) installation folder."
		Exit
	}
}

$quartus_bin = $quartus_root + "\bin"
if( -not (Test-Path -Path $quartus_bin -PathType Container) ) {
	$quartus_bin = $quartus_root + "\bin64"
}

$sopc_bin = ("{0}\sdk2\bin" -f $sopc_kit)

[System.Environment]::SetEnvironmentVariable('_QUARTUS_BIN', $quartus_bin, 'Process')
[System.Environment]::SetEnvironmentVariable('_SOPC_BIN', $sopc_bin, 'Process')

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

[System.Environment]::SetEnvironmentVariable('CYGWIN', 'nodosfilewarning', 'Process')
[System.Environment]::SetEnvironmentVariable('SHELLOPTS', 'igncr', 'Process')
	