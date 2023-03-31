param(
  [string]$python_installer,
  [string]$vscode_installer
)

$ErrorActionPreference = "Stop"

Invoke-WebRequest -Uri $python_installer -OutFile python.exe
Start-Process "python.exe" -argumentlist "/passive InstallAllUsers=1 PrependPath=1 Include_test=0" -wait
Remove-Item python.exe
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
pip install mypy pytest numpy matplotlib

Invoke-WebRequest -Uri $vscode_installer -OutFile vscode.exe
Start-Process "vscode.exe" -argumentlist "/verysilent /mergetasks=!runcode" -wait
Remove-Item vscode.exe
