<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.207
	 Created on:   	02/06/2022 18:01
	 Created by:   	Mark5900
	 Organization: 	
	 Filename:     	Mark.Boennelykke.psm1
	-------------------------------------------------------------------------
	 Module Name: Mark.Boennelykke
	===========================================================================
#>

#TODO: Write command description
<#
	.SYNOPSIS
		A short one-line action-based description, e.g. 'Tests if a function is valid'
	
	.DESCRIPTION
		A longer description of the function, its purpose, common use cases, etc.
	
	.PARAMETER Path
		= ("{0}\Logs_{1}" -f ($MyInvocation.InvocationName -replace '(.*)\\.*', '$1'), ($MyInvocation.InvocationName -replace '.*\\(.+?)\..*', '$1'))
	
	.PARAMETER UseDateInFileName
		A description of the UseDateInFileName parameter.
	
	.PARAMETER UseTimeInFileName
		A description of the UseTimeInFileName parameter.
	
	.PARAMETER UseStopwatch
		A description of the UseStopwatch parameter.
	
	.PARAMETER DeleteDaysOldLogs
		A description of the DeleteDaysOldLogs parameter.
	
	.PARAMETER LogName
		A description of the LogName parameter.
	
	.EXAMPLE
		Test-MyTestFunction -Verbose
		Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
	
	.NOTES
		Information or caveats about the function e.g. 'This function is not supported in Linux'
	
	.LINK
		Specify a URI to a help page, this will show when Get-Help -Online is used.
#>
function Start-MBScriptLoggin
{
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Path = $PSScriptRoot,
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
	
	function Get-LogFilePath ($LogPath, $LogName) {
		$Run = $true
		$i = 1
		
		$Path = "$LogPath\$LogName.log"
		
		While ( $Run -eq $true ) {
			if ((Test-Path -Path $Path) -eq $true)
			{
				# TODO ændre på dette for den kan ikke håndtere navne
				$Path = $Path = "$LogPath\$($LogName)_$($i).log"
				$i++
			}
			else
			{
				$Run = $false
			}
		}
		
		return $Path
	}
	
	# Start transcript.
	try
	{
		$LogFolderPath = "$Path\\Logs_$LogName"
		New-Item -Path $LogFolderPath -ItemType Directory -Force | Out-Null
		
		if ($UseTimeInFileName -eq $true -and $UseDateInFileName -eq $true)
		{
			$LogFilePath = Get-LogFilePath -LogPath $LogFolderPath -LogName "$LogName-$(Get-Date -Format "yyyy-MM-dd_HH-mm-s")"
		}
		elseif ($UseDateInFileName -eq $true)
		{
			$LogFilePath = Get-LogFilePath -LogPath $LogFolderPath -LogName "$LogName-$(Get-Date -Format "yyyy-MM-dd")"
		}
		else
		{
			$LogFilePath = Get-LogFilePath -LogPath $LogFolderPath -LogName $LogName
		}
		Start-Transcript -Path $LogFilePath
		
		Write-Output (""); # Insert line break just after starting the transcript (for readability).
		
		# Used to stop all transcript that are started 
		$Script:TranscriptSesions++
	}
	catch { }
	
	if ($UseStopwatch -eq $true)
	{
		# Start a new stopwatch for measuring elapsed time for the script.
		$Script:Stopwatch = [Diagnostics.Stopwatch]::StartNew()
	}
	
	if ($DeleteDaysOldLogs -or $DeleteAllLogs -eq $true)
	{
		$LogFiles = Get-ChildItem -Path $LogFolderPath
		
		foreach ($LogFile in $LogFiles) {
			If ($LogFile.CreationTime.Date -le ((get-date).AddDays(-$DeleteDaysOldLogs).ToString("yyyy-MM-dd")))
			{
				Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
				Write-MBLogLine -ScriptPart "Start-MBScriptLoggin" -Text "Deleting $LogFile"
			}
		}
	}
}

#TODO: Write command description
function Stop-MBScriptLoggin
{
	[CmdletBinding()]
	param ()
	
	if ($Script:Stopwatch) {
		# Display elapsed time from stopwatch.
		$Script:Stopwatch.Stop()
		Write-Output ("`nElapsed time: {0} day(s) {1} hour(s) {2} minute(s) {3} seconds {4} millisecond(s)" -f $Stopwatch.Elapsed.Days, $Stopwatch.Elapsed.Hours, $Stopwatch.Elapsed.Minutes, $Stopwatch.Elapsed.Seconds, $Stopwatch.Elapsed.Milliseconds);
		$Script:Stopwatch = $null
	}
	
	Write-Output (""); # Insert line break just before stopping the transcript (for readability).
	
	try
	{
		While ($i -lt $Script:TranscriptSesions)
		{
			Write-MBLogLine -ScriptPart "Stop-MBScriptLoggin" -Text "Stopping sesion $($Script:TranscriptSesions - $i) of $Script:TranscriptSesions"
			Stop-Transcript | Out-Null
			$i++
		}
		
		$Script:TranscriptSesions = $null
	}
	catch { }
}

#TODO: Write command description
function Write-MBLogLine
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Text,
		[string]$ScriptPart = "Main"
	)
	
	Write-Host "$(Get-Date -Format HH:mm:ss) : $($ScriptPart) : $Text"
}