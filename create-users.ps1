<#
.SYNOPSIS
    Creates and verifies users based on the configuration created by Terraform.

.DESCRIPTION
    Chain: Terraform creates output/config/users.json -> this script reads the file,
    creates the users, verifies that they exist and logs everything.

.EXAMPLE
    sudo pwsh -File ./create-users.ps1            # create users
    sudo pwsh -File ./create-users.ps1 -Remove    # clean up (remove them again)
#>

param(
    [string]$ConfigPath = "$PSScriptRoot/output/config/users.json",
    [string]$LogPath    = "$PSScriptRoot/output/logs/create-users.log",
    [switch]$Remove
)

# ---------- Functions ----------

# Function 1: writes a message to the screen and to the log file
function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [string]$Level = "INFO"
    )
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$time] [$Level] $Message"
    Write-Host $line
    if (Test-Path (Split-Path $LogPath)) {
        Add-Content -Path $LogPath -Value $line
    }
}

# Function 2: reads the user list from the JSON file that Terraform created
function Get-UserList {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Config file not found: $Path. Run 'terraform apply' first."
    }
    $config = Get-Content -Path $Path -Raw | ConvertFrom-Json
    return @($config.users)
}

# Function 3: checks whether a user already exists (true/false)
function Test-UserExists {
    param([Parameter(Mandatory)][string]$Name)

    & id -u $Name 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

# Function 4: creates a user with a home directory
function New-SystemUser {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Description = "Created by script"
    )

    if (Test-UserExists -Name $Name) {
        Write-Log "User '$Name' already exists, skipping" "WARN"
        return
    }

    $output = & useradd -m -s /bin/bash -c $Description $Name 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "useradd failed for '$Name': $output"
    }
    Write-Log "Created user '$Name'"
}

# Function 5: verifies that the user and the home directory exist
function Verify-User {
    param([Parameter(Mandatory)][string]$Name)

    $exists     = Test-UserExists -Name $Name
    $homeExists = Test-Path "/home/$Name"

    if ($exists -and $homeExists) {
        Write-Log "OK: '$Name' exists and has home directory /home/$Name"
        return $true
    }
    else {
        Write-Log "FAIL: '$Name' is missing or has no home directory" "ERROR"
        return $false
    }
}

# Function 6: removes a user (for cleanup)
function Remove-SystemUser {
    param([Parameter(Mandatory)][string]$Name)

    if (-not (Test-UserExists -Name $Name)) {
        Write-Log "User '$Name' does not exist, nothing to remove" "WARN"
        return
    }
    $output = & userdel -r $Name 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "userdel failed for '$Name': $output"
    }
    Write-Log "Removed user '$Name'"
}

# ---------- Main program ----------

# Root privileges are required to create users
if ([int](& id -u) -ne 0) {
    Write-Host "This script must be run as root. Run: sudo pwsh -File ./create-users.ps1"
    exit 1
}

try {
    $users = Get-UserList -Path $ConfigPath
    Write-Log "Found $($users.Count) users in the configuration"

    if ($Remove) {
        foreach ($u in $users) {
            try { Remove-SystemUser -Name $u.name }
            catch { Write-Log $_.Exception.Message "ERROR" }
        }
    }
    else {
        # Step 1: create
        foreach ($u in $users) {
            try { New-SystemUser -Name $u.name -Description $u.description }
            catch { Write-Log $_.Exception.Message "ERROR" }
        }

        # Step 2: verify
        $succeeded = 0
        foreach ($u in $users) {
            if (Verify-User -Name $u.name) { $succeeded++ }
        }
        Write-Log "Verification done: $succeeded of $($users.Count) users OK"

        if ($succeeded -ne $users.Count) { exit 1 }
    }
}
catch {
    Write-Log "Script aborted: $($_.Exception.Message)" "ERROR"
    exit 1
}