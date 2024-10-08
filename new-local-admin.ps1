# PowerShell script to disable the default local admin and create a new one

# Name of the new admin account
[string]$newAdmin = "new-admin"
# Password for the new admin account, passed as an environment variable
[string]$newPassword = $env:ADMIN_PASSWORD

# Ensure that the environment variable for the password is not empty
if (-not $newPassword) {
    Write-Error "The ADMIN_PASSWORD environment variable is not set. Exiting script."
    exit 1
}

# Disable the default local administrator account if it exists
$defaultAdmin = Get-LocalUser -Name "avd-local-admin" -ErrorAction SilentlyContinue
if ($defaultAdmin) {
    Disable-LocalUser -Name "avd-local-admin"
}

# Create a new local admin if it does not already exist
if (-not (Get-LocalUser -Name $newAdmin -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name $newAdmin -Password (ConvertTo-SecureString -String $newPassword -AsPlainText -Force) -FullName "New Local Admin" -Description "Admin account created by Terraform"
    Add-LocalGroupMember -Group "Administrators" -Member $newAdmin
} else {
    Write-Host "User $newAdmin already exists."
}