param(
	[Parameter(Mandatory=$true)]
	[string]$proj_name
)

Write-Output "**** Running build-software.ps1 ****"

$app_dir = "software\dhrystone"
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

$sopc_kit = [System.Environment]::GetEnvironmentVariable('SOPC_KIT_NIOS2', 'Process')
$quartus_root = [System.Environment]::GetEnvironmentVariable('QUARTUS_ROOTDIR', 'Process')

$tmp = $sopc_kit + "\nios2_command_shell.sh"
$command_shell_path = '/cygdrive/' + (Split-Path $tmp -Qualifier).ToLower()[0] + (Split-Path $tmp -NoQualifier) -replace '\\', '/'

$quartus_bin = $quartus_root + "\bin"
if( -not (Test-Path -Path $quartus_bin -PathType Container) ) {
	$quartus_bin = $quartus_root + "\bin64"
}
Start-Process -FilePath "$quartus_bin\cygwin\bin\bash.exe" -ArgumentList @($command_shell_path, "make", "-C", "$app_dir") -NoNewWindow -Wait

Copy-Item "$app_dir\dhrystone.elf" -Destination "demo_batch" -Force
