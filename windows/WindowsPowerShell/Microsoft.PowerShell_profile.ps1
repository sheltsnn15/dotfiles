# Define ANSI escape codes for colors
$ansiReset = [char]27 + '[0m'
$ansiRed = [char]27 + '[31m'
$ansiGreen = [char]27 + '[32m'
$ansiYellow = [char]27 + '[33m'
$ansiBlue = [char]27 + '[34m'

# Example usage of ANSI colors
Write-Host "${ansiRed}Error: Something went wrong.${ansiReset}"
Write-Host "${ansiGreen}Success: Operation completed.${ansiReset}"
Write-Host "${ansiYellow}Warning: Proceed with caution.${ansiReset}"

# Enhance the built-in history feature
function gh {
    if ($args.Count -eq 0) {
        Get-History
    } else {
        Get-History | Where-Object { $_.CommandLine -like "*$args*" }
    }
}

# Custom 'ls' function to mimic Bash's 'ls' command with basic colorization
function ls {
    Get-ChildItem @args | ForEach-Object {
        if ($_.PSIsContainer) {
            Write-Host "${ansiBlue}$($_.Name)${ansiReset}"
        } else {
            Write-Host $_.Name
        }
    }
}
Set-Alias ll ls -Option AllScope

# Custom 'cd' override to include 'cd -' functionality and support for '~'
function cd {
    param(
        [string]$path = $HOME
    )
    
    if ($path -eq '~') {
        $path = $HOME
    } elseif ($path -eq '-') {
        $path = $env:OLDPWD
    }
    
    $env:OLDPWD = Get-Location
    Set-Location $path
}

# 'grep' functionality using Select-String
function grep {
    Select-String @args
}
Set-Alias grep Select-String -Option AllScope

# Exit PowerShell session with Ctrl+D if PSReadLine module is available
if ($null -ne (Get-Module -ListAvailable PSReadLine)) {
    Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function DeleteCharOrExit
}

# Enhance tab completion to be more Bash-like
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# Custom prompt
function prompt {
    $path = $ExecutionContext.SessionState.Path.CurrentLocation.Path.Replace($HOME, '~')
    "$path$('>' * ($nestedPromptLevel + 1)) "
}

# Alias for common commands
Set-Alias cat Get-Content -Option AllScope
Set-Alias mkdir New-Item -Option AllScope
Set-Alias rm Remove-Item -Option AllScope
Set-Alias touch touch -Option AllScope

# Custom 'cp' function with error handling
function cp {
    param(
        [Parameter(Mandatory = $true)]
        [string]$source,
        [Parameter(Mandatory = $true)]
        [string]$destination
    )
    
    try {
        Copy-Item -Path $source -Destination $destination -ErrorAction Stop
    }
    catch {
        Write-Host "${ansiRed}Error copying file: $_${ansiReset}"
    }
}

# Custom 'mv' function
function mv {
    param(
        [Parameter(Mandatory = $true)]
        [string]$source,
        [Parameter(Mandatory = $true)]
        [string]$destination
    )
    
    Move-Item -Path $source -Destination $destination
}

# Custom 'touch' function to mimic Bash's 'touch' command
function touch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$filename
    )
    
    if (-not (Test-Path $filename)) {
        New-Item -ItemType File -Path $filename -Force
    } else {
        (Get-Item $filename).LastWriteTime = Get-Date
    }
}

# Environment Variables Management
function setenv {
    param(
        [string]$name,
        [string]$value
    )
    [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::User)
}

function unsetenv {
    param([string]$name)
    [System.Environment]::SetEnvironmentVariable($name, $null, [System.EnvironmentVariableTarget]::User)
}

function getenv {
    Get-ChildItem env:
}

# Networking command aliases
Set-Alias ifconfig Get-NetIPAddress -Option AllScope
Set-Alias ping Test-Connection -Option AllScope
Set-Alias netstat Get-NetTCPConnection -Option AllScope

# Functionality to work with archives
function tar {
    param(
        [string]$action,
        [string]$archivePath,
        [string]$sourcePath
    )
    
    if ($action -eq 'c') {
        Compress-Archive -Path $sourcePath -DestinationPath $archivePath
    } elseif ($action -eq 'x') {
        Expand-Archive -Path $archivePath -DestinationPath $sourcePath
    }
}

# Interactive Help or Documentation
function custom-help {
    param([string]$command)

    $helpText = @{
        'cp' = 'Copies a file from source to destination. Usage: cp <source> <destination>'
        'mv' = 'Moves a file from source to destination. Usage: mv <source> <destination>'
        'touch' = 'Creates a new file or updates the timestamp of an existing file. Usage: touch <filename>'
        # Add more help texts for other functions
    }

    if ($helpText.ContainsKey($command)) {
        Write-Host $helpText[$command]
    } else {
        Write-Host "No custom help available for $command"
    }
}

