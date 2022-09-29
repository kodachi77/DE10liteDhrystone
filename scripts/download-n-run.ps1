param(
	[Parameter(Mandatory=$true)]
	[string]$proj_name
)

$sopc_kit = [System.Environment]::GetEnvironmentVariable('SOPC_KIT_NIOS2', 'Process')
$quartus_bin = [System.Environment]::GetEnvironmentVariable('_QUARTUS_BIN', 'Process')

if( Test-Path -Path "$proj_name.sof" -PathType Leaf ) {
	& $quartus_bin\quartus_pgm.exe -m jtag -c 1 -o "p;$proj_name.sof"
} else {
	& $quartus_bin\quartus_pgmw.exe ("{0}_time_limited.sof" -f $proj_name)
	Write-Output "Press (c) when design has been uploaded to the device"
	$in = ''
	while( $in -ine 'c' ) {
		$in = Read-Host ">"
	}
}

$tmp = $sopc_kit + "\nios2_command_shell.sh"
$command_shell_path = '/cygdrive/' + (Split-Path $tmp -Qualifier).ToLower()[0] + (Split-Path $tmp -NoQualifier) -replace '\\', '/'

Start-Process -FilePath "$quartus_bin\cygwin\bin\bash.exe" -ArgumentList @($command_shell_path, "nios2-download", "dhrystone.elf", "-c", "1", "-r", "-g") -NoNewWindow -Wait
Start-Process -FilePath "$quartus_bin\cygwin\bin\bash.exe" -ArgumentList @($command_shell_path, "nios2-terminal", "-c", "1") -NoNewWindow -Wait