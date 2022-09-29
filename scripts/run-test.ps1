$in = ''
Write-Output "Please select design to run (q to exit):"
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
    $cwd_new = Convert-Path -Path '.\minimal\demo'
}

if( $in -eq '2' ) {
    $cwd_new = Convert-Path -Path '.\default\demo'
}

Set-Location -Path $cwd_new

& ($PSScriptRoot + '\setup-environment.ps1') -proj_name Embed
& ($PSScriptRoot + '\download-n-run.ps1') -proj_name Embed

Set-Location -Path $cwd_old