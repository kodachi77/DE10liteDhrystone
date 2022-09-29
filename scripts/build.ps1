$in = ''
Write-Output "Please select design to build (q to exit):"
Write-Output " 1. minimal"
Write-Output " 2. default"

while( ($in -ne '1') -and ($in -ne '2') -and ($in -ine 'q') ) {
	$in = Read-Host "> "
}
        
if($in -eq 'q') {
	Write-Output "Exiting..."
    Exit
}

$cwd_old = Get-Location

if( $in -eq '1' ) {
	$cwd_new = Convert-Path -Path '.\minimal'
	Set-Location -Path $cwd_new
	
	& ($PSScriptRoot + '\setup-environment.ps1') -proj_name Embed
	& ($PSScriptRoot + '\build-hardware.ps1') -proj_name Embed
	& ($PSScriptRoot + '\build-software.ps1') -proj_name Embed -user_defines "-DREG"
}

if( $in -eq '2' ) {
	$cwd_new = Convert-Path -Path '.\default'
	Set-Location -Path $cwd_new
	
	& ($PSScriptRoot + '\setup-environment.ps1') -proj_name Embed
	& ($PSScriptRoot + '\build-hardware.ps1') -proj_name Embed
	& ($PSScriptRoot + '\build-software.ps1') -proj_name Embed
}

Set-Location -Path $cwd_old