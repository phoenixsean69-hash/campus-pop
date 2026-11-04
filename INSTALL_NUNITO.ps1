# Downloads Nunito from the official Google Fonts repository onto YOUR PC.
# The font is distributed by its authors under the SIL Open Font License 1.1.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force -Path 'assets\fonts' | Out-Null
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/google/fonts/main/ofl/nunito/Nunito%5Bwght%5D.ttf' -OutFile 'assets\fonts\Nunito.ttf'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/google/fonts/main/ofl/nunito/OFL.txt' -OutFile 'assets\fonts\OFL-Nunito.txt'
Write-Host 'Nunito installed for StudySpace. Restart the app.' -ForegroundColor Green
