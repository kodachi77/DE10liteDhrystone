param(
	[Parameter(Mandatory=$true)]
	[string]$proj_name
)

Write-Output "**** Running build-hardware.ps1 ****"

$part = '10M50DAF484C6GES'

qsys-generate ("{0}.qsys" -f $proj_name)  --synthesis=VERILOG ("--part={0}" -f $part)

for( $i=0; $i -lt 2; $i++ ) {
	quartus_map --read_settings_files=on  --write_settings_files=off $proj_name -c $proj_name
	quartus_fit --read_settings_files=off --write_settings_files=off $proj_name -c $proj_name
	quartus_asm --read_settings_files=off --write_settings_files=off $proj_name -c $proj_name
	quartus_sta $proj_name -c $proj_name
}

quartus_sta -t ..\scripts\timing-report.tcl $proj_name

$sof_file = ("output_files/{0}_time_limited.sof" -f $proj_name)
if( -not (Test-Path -Path $sof_file -PathType Leaf) ) {
	$sof_file = ("output_files/{0}.sof" -f $proj_name)
}
if( Test-Path -Path $sof_file -PathType Leaf ) {
	Copy-Item ($sof_file) -Destination "demo" -Force
}