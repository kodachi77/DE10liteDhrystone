$proj_name = "Embed"

$quartus_root_sys = [System.Environment]::GetEnvironmentVariable('QUARTUS_ROOTDIR', 'Machine')
$sopc_kit_sys = [System.Environment]::GetEnvironmentVariable('SOPC_KIT_NIOS2', 'Machine')
$qsys_root_sys = [System.Environment]::GetEnvironmentVariable('QSYS_ROOTDIR', 'Machine')

$quartus_root_usr = [System.Environment]::GetEnvironmentVariable('QUARTUS_ROOTDIR', 'User')
$sopc_kit_usr = [System.Environment]::GetEnvironmentVariable('SOPC_KIT_NIOS2', 'User')
$qsys_root_usr = [System.Environment]::GetEnvironmentVariable('QSYS_ROOTDIR', 'User')

$in = ""
if ($quartus_root_sys -and $quartus_root_usr) {
	Write-Output "More than 2 Quartus installations found."
	Write-Output "Please specify which one to use (q to exit):"
	Write-Output (" 1. {0}" -f $quartus_root_sys)
	Write-Output (" 2. {0}" -f $quartus_root_usr)

	while( ($in -ne "1") -and ($in -ne "2") -and ($in -ine "q")) {
		$in = Read-Host "> "
	}
	
	if($in -eq "q") {
		Write-Output "Exiting..."
		Exit
	}
}

if( ($quartus_root_sys -and (-not $quartus_root_usr)) -or ($in -eq "1") ) {
	$quartus_root = $quartus_root_sys
	$sopc_kit = $sopc_kit_sys
	if( $qsys_root_sys ) {
		$qsys_root = $qsys_root_sys
	}
}
	
if( ($quartus_root_usr -and (-not $quartus_root_sys)) -or ($in -eq "2") ) {
	$quartus_root = $quartus_root_usr
	$sopc_kit = $sopc_kit_usr
	if( $qsys_root_usr ) {
		$qsys_root = $qsys_root_usr
	}
}

if( (-not $quartus_root) -or (-not $sopc_kit) ) {
	Write-Output "Not all environment variables are set. Please set QUARTUS_ROOTDIR and SOPC_KIT_NIOS2."
	Exit
}

if( -not $qsys_root ) {
	$qsys_root = $quartus_root + "\sopc_builder\bin"
	if( -not (Test-Path -Path $qsys_root -PathType Container) ) {
		Write-Output "Cannot find QSys (Platform Designer) installation folder."
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

$path = [Environment]::GetEnvironmentVariable("PATH", 'Process')


if ( -not $path.Contains($quartus_bin) ) {
	$path += ";$quartus_bin"
}

if ( -not $path.Contains($qsys_root) ) {
	$path += ";$qsys_root"
}

[System.Environment]::SetEnvironmentVariable("PATH", $path, 'Process')

qsys-generate ("{0}.qsys" -f $proj_name)  --synthesis=VERILOG --part=10M50DAF484C6GES

quartus_map --read_settings_files=on  --write_settings_files=off $proj_name -c $proj_name
quartus_fit --read_settings_files=off --write_settings_files=off $proj_name -c $proj_name
quartus_asm --read_settings_files=off --write_settings_files=off $proj_name -c $proj_name
quartus_sta $proj_name -c $proj_name
quartus_eda --read_settings_files=on  --write_settings_files=off $proj_name -c $proj_name

$sof_file = ("output_files/{0}_time_limited.sof" -f $proj_name)
if( -not (Test-Path -Path $sof_file -PathType Leaf) ) {
	$sof_file = ("output_files/{0}.sof" -f $proj_name)
}

Copy-Item ($sof_file, $proj_name) -Destination "demo_batch" -Force

