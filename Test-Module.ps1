<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2022 v5.8.207
	 Created on:   	02/06/2022 18:01
	 Created by:   	Mark5900
	 Organization: 	
	 Filename:     	Test-Module.ps1
	===========================================================================
	.DESCRIPTION
	The Test-Module.ps1 script lets you test the functions and other features of
	your module in your PowerShell Studio module project. It's part of your project,
	but it is not included in your module.

	In this test script, import the module (be careful to import the correct version)
	and write commands that test the module features. You can include Pester
	tests, too.

	To run the script, click Run or Run in Console. Or, when working on any file
	in the project, click Home\Run or Home\Run in Console, or in the Project pane, 
	right-click the project name, and then click Run Project.
#>


#Explicitly import the module for testing
Import-Module 'Mark.Boennelykke'

#Run each module function
Start-MBScriptLoggin -Path $PSScriptRoot -LogName "Test-Module"
Write-MBLogLine -Text "Sesion 1"
Start-MBScriptLoggin -Path $PSScriptRoot -LogName "Test-Module"
Write-Output "Test 1"
Start-Sleep -Seconds 5
Stop-MBScriptLoggin

Start-MBScriptLoggin -Path $PSScriptRoot -LogName "Test-Module" -UseDateInFileName False
Write-Output "Test 2"
Start-Sleep -Seconds 5
Stop-MBScriptLoggin

Start-MBScriptLoggin -Path $PSScriptRoot -LogName "Test-Module" -UseTimeInFileName False
Write-Output "Test 3"
Start-Sleep -Seconds 5
Stop-MBScriptLoggin

Start-MBScriptLoggin -Path $PSScriptRoot -LogName "Test-Module" -UseStopwatch False
Write-Output "Test 4"
Start-Sleep -Seconds 5
Stop-MBScriptLoggin

Start-MBScriptLoggin -Path $PSScriptRoot -LogName "Test-Module" -DeleteDaysOldLogs 1
Write-Output "Test 5"
Start-Sleep -Seconds 5
Stop-MBScriptLoggin