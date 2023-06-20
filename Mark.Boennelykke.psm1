function Start-MBScriptLogging {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [ValidateSet('True', 'False')]
        [string]$UseDateInFileName = $true,
        [ValidateSet('True', 'False')]
        [string]$UseTimeInFileName = $true,
        [ValidateSet('True', 'False')]
        [string]$UseStopwatch = $true,
        [int]$DeleteDaysOldLogs,
        [Parameter(Mandatory = $false)]
        [string]$LogName,
        [ValidateSet('True', 'False')]
        [string]$DeleteAllLogs = $false
    )
    $FunctionName = 'Start-MBScriptLogging'
	
    function Get-LogFilePath ($LogPath, $LogName) {
        $Run = $true
        $i = 1
		
        $Path = "$LogPath\$LogName.log"
		
        While ($Run -eq $true) {
            if ((Test-Path -Path $Path) -eq $true) {
                # TODO #6 Ændre på dette for den kan ikke håndtere navne
                $Path = "$LogPath\$($LogName)_$($i).log"
                $i++
            } else {
                $Run = $false
            }
        }
		
        return $Path
    }
	
    # Start transcript.
    try {
        $LogFolderPath = "$Path\\Logs_$LogName"
        New-Item -Path $LogFolderPath -ItemType Directory -Force | Out-Null
		
        if ($UseTimeInFileName -eq $true -and $UseDateInFileName -eq $true) {
            $LogFilePath = Get-LogFilePath -LogPath $LogFolderPath -LogName "$LogName-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-s')"
        } elseif ($UseDateInFileName -eq $true) {
            $LogFilePath = Get-LogFilePath -LogPath $LogFolderPath -LogName "$LogName-$(Get-Date -Format 'yyyy-MM-dd')"
        } else {
            $LogFilePath = Get-LogFilePath -LogPath $LogFolderPath -LogName $LogName
        }
        Start-Transcript -Path $LogFilePath
		
        Write-Output (''); # Insert line break just after starting the transcript (for readability).
		
        # Used to stop all transcripts that are started 
        $Script:TranscriptSesions++
        # Used to store path to current logfile
        $global:ItcLogfile = $LogFilePath
    } catch { }
	
    if ($UseStopwatch -eq $true) {
        # Start a new stopwatch for measuring elapsed time for the script.
        $Script:ItcStopwatch = [Diagnostics.Stopwatch]::StartNew()
    }
	
    if ($DeleteDaysOldLogs -or $DeleteAllLogs -eq $true) {
        $LogFiles = Get-ChildItem -Path $LogFolderPath
		
        foreach ($LogFile in $LogFiles) {
            If ($LogFile.CreationTime.Date -le ((Get-Date).AddDays(-$DeleteDaysOldLogs).ToString('yyyy-MM-dd'))) {
                Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
                Write-MBLogLine -ScriptPart $FunctionName -Text "Deleting $LogFile"
            }
        }
    }
}


<#
	.SYNOPSIS
		Stops logging of a script.
	
	.DESCRIPTION
		Stops all started logging sesion started by running ITCE-StartScriptLoggin.
	
	.EXAMPLE
		PS C:\> ITCE-StopScriptLoggin
	
	.NOTES
		Additional information about the function.
#>
function Stop-MBScriptLogging {
    [CmdletBinding()]
    param ()
    $FunctionName = 'Stop-MBScriptLogging'
	
    if ($Script:Stopwatch) {
        # Display elapsed time from stopwatch.
        $Script:Stopwatch.Stop()
        Write-Output ("`nElapsed time: {0} day(s) {1} hour(s) {2} minute(s) {3} seconds {4} millisecond(s)" -f $Stopwatch.Elapsed.Days, $Stopwatch.Elapsed.Hours, $Stopwatch.Elapsed.Minutes, $Stopwatch.Elapsed.Seconds, $Stopwatch.Elapsed.Milliseconds);
        $Script:Stopwatch = $null
    }
	
    Write-Output (''); # Insert line break just before stopping the transcript (for readability).
	
    try {
        While ($i -lt $Script:TranscriptSesions) {
            Write-MBLogLine -ScriptPart $FunctionName -Text "Stopping sesion $($Script:TranscriptSesions - $i) of $Script:TranscriptSesions"
            Stop-Transcript | Out-Null
            $i++
        }
		
        $Script:TranscriptSesions = $null
    } catch { }
}


<#
	.SYNOPSIS
		Use to write a line to the log file.
	
	.DESCRIPTION
		Used to write a  pretty line to the log file indstead of using Write-Host or Write-Output.
	
	.PARAMETER Text
		The text to write to the log file.
	
	.PARAMETER ScriptPart
		The part of the script that is writing to the log file.
		Default value is 'Main'.
	
	.PARAMETER ForegroundColor
		The color of the text.
		Only usable to see in the console.
	
	.EXAMPLE
		PS C:\> Write-MBLogLine -Text 'value1'

	.EXAMPLE
		PS C:\> Write-MBLogLine -Text 'value1' -ScriptPart 'Function1'

	.EXAMPLE
		PS C:\> Write-MBLogLine -Text 'value1' -ScriptPart 'Function1' -ForegroundColor 'Red'
	
	.NOTES
		Additional information about the function.
#>
function Write-MBLogLine {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [string]$ScriptPart = 'Main',
        [ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', ' DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]
        $ForegroundColor = (Get-Host).ui.rawui.ForegroundColor
    )
	
    Write-Host "$(Get-Date -Format HH:mm:ss) : $($ScriptPart) : $Text" -ForegroundColor $ForegroundColor
}