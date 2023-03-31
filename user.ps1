param(
  [string]$username,
  [string]$password,
  [string]$userfull
)

$ErrorActionPreference = "Stop"

$password_ss = ConvertTo-SecureString -String $password -AsPlainText -Force
New-LocalUser $username -Password $password_ss -FullName $userfull -AccountNeverExpires
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $username
