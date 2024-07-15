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

# Check if Remove-Alias cmdlet is available
if (Get-Command -Name Remove-Alias -ErrorAction SilentlyContinue) {
    $commands = "awk", "emacs", "grep", "head", "less", "ls", "man", "sed", "seq", "ssh", "tail", "vim"

    foreach ($command in $commands) {
        Remove-Alias $command -Force -ErrorAction Ignore
    }
} else {
    Write-Host "${ansiYellow}Remove-Alias cmdlet not available. Skipping alias removal.${ansiReset}"
}

# Define the commands to import
$commands = "awk", "emacs", "grep", "head", "less", "ls", "man", "sed", "seq", "ssh", "tail", "vim"

# Helper function to escape characters in arguments passed to WSL that would otherwise be misinterpreted
function global:Format-WslArgument([string]$arg, [bool]$interactive) {
    if ($interactive -and $arg.Contains(" ")) {
        return "'$arg'"
    } else {
        return ($arg -replace " ", "\ ") -replace "([()|])", ('\$1', '`$1')[$interactive]
    }
}

# Register a function for each command
$commands | ForEach-Object { Invoke-Expression @"
function global:$_() {
    for (`$i = 0; `$i -lt `$args.Count; `$i++) {
        if (Split-Path `$args[`$i] -IsAbsolute -ErrorAction Ignore) {
            `$args[`$i] = Format-WslArgument (wsl.exe wslpath (`$args[`$i] -replace '\\', '/'))
        } elseif (Test-Path `$args[`$i] -ErrorAction Ignore) {
            `$args[`$i] = Format-WslArgument (`$args[`$i] -replace '\\', '/')
        }
    }

    `$defaultArgs = ((`$WslDefaultParameterValues.$_ -split ' '), "")[`$WslDefaultParameterValues.Disabled -eq `$true]
    if (`$input.MoveNext()) {
        `$input.Reset()
        `$input | wsl.exe $_ `$defaultArgs (`$args -split ' ')
    } else {
        wsl.exe $_ `$defaultArgs (`$args -split ' ')
    }
}
"@
}

# Argument Completion
Register-ArgumentCompleter -CommandName $commands -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $F = switch ($commandAst.CommandElements[0].Value) {
        {$_ -in "awk", "grep", "head", "less", "ls", "sed", "seq", "tail"} { "_longopt" }
        "man" { "_man" }
        "ssh" { "_ssh" }
        Default { "_minimal" }
    }

    $COMP_LINE = "`"$commandAst`""
    $COMP_WORDS = "('$($commandAst.CommandElements.Extent.Text -join "' '")')" -replace "''", "'"
    for ($i = 1; $i -lt $commandAst.CommandElements.Count; $i++) {
        $extent = $commandAst.CommandElements[$i].Extent
        if ($cursorPosition -lt $extent.EndColumnNumber) {
            $previousWord = $commandAst.CommandElements[$i - 1].Extent.Text
            $COMP_CWORD = $i
            break
        } elseif ($cursorPosition -eq $extent.EndColumnNumber) {
            $previousWord = $extent.Text
            $COMP_CWORD = $i + 1
            break
        } elseif ($cursorPosition -lt $extent.StartColumnNumber) {
            $previousWord = $commandAst.CommandElements[$i - 1].Extent.Text
            $COMP_CWORD = $i
            break
        } elseif ($i -eq $commandAst.CommandElements.Count - 1 -and $cursorPosition -gt $extent.EndColumnNumber) {
            $previousWord = $extent.Text
            $COMP_CWORD = $i + 1
            break
        }
    }

    $currentExtent = $commandAst.CommandElements[$COMP_CWORD].Extent
    $previousExtent = $commandAst.CommandElements[$COMP_CWORD - 1].Extent
    if ($currentExtent.Text -like "/*" -and $currentExtent.StartColumnNumber -eq $previousExtent.EndColumnNumber) {
        $COMP_LINE = $COMP_LINE -replace "$($previousExtent.Text)$($currentExtent.Text)", $wordToComplete
        $COMP_WORDS = $COMP_WORDS -replace "$($previousExtent.Text) '$($currentExtent.Text)'", $wordToComplete
        $previousWord = $commandAst.CommandElements[$COMP_CWORD - 2].Extent.Text
        $COMP_CWORD -= 1
    }

    $command = $commandAst.CommandElements[0].Value
    $bashCompletion = ". /usr/share/bash-completion/bash_completion 2> /dev/null"
    $commandCompletion = ". /usr/share/bash-completion/completions/$command 2> /dev/null"
    $COMPINPUT = "COMP_LINE=$COMP_LINE; COMP_WORDS=$COMP_WORDS; COMP_CWORD=$COMP_CWORD; COMP_POINT=$cursorPosition"
    $COMPGEN = "bind `"set completion-ignore-case on`" 2> /dev/null; $F `"$command`" `"$wordToComplete`" `"$previousWord`" 2> /dev/null"
    $COMPREPLY = "IFS=`$'\n'; echo `"`${COMPREPLY[*]}`""
    $commandLine = "$bashCompletion; $commandCompletion; $COMPINPUT; $COMPGEN; $COMPREPLY" -split ' '

    $previousCompletionText = ""
    (wsl.exe $commandLine) -split '\n' |
    Sort-Object -Unique -CaseSensitive |
    ForEach-Object {
        if ($wordToComplete -match "(.*=).*") {
            $completionText = Format-WslArgument ($Matches[1] + $_) $true
            $listItemText = $_
        } else {
            $completionText = Format-WslArgument $_ $true
            $listItemText = $completionText
        }

        if ($completionText -eq $previousCompletionText) {
            $listItemText += ' '
        }

        $previousCompletionText = $completionText
        [System.Management.Automation.CompletionResult]::new($completionText, $listItemText, 'ParameterName', $completionText)
    }
}

# Hash table for default parameter values
$global:WslDefaultParameterValues = @{}

# Example default parameters
$WslDefaultParameterValues["grep"] = "-E"
$WslDefaultParameterValues["less"] = "-i"
$WslDefaultParameterValues["ls"] = "-AFh --group-directories-first"
