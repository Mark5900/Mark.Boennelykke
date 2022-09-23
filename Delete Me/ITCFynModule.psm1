#####################
# ITCFynModule.psm1 #
#####################
# Module storage: $env:PSModulePath
# Development module V 0.02

$global:ItcMessage = ""     # Used for mail message
$global:ItcFejl = 0         # Used for error check
$global:ItcLogfile = ""     # Path and name of the file where logging is stored
$global:ItcLogging = 0      # Test if logging is started
$global:ItcDirectory = ""   # Store the current scripts directory
$global:ItcFile = ""        # Short name of the script

Function ItcStart() {
    param (
        [Parameter(Mandatory=$True)][string]$directory,         # The directory of the powershell script. E.g. $PSScriptRoot
        [Parameter(Mandatory=$True)][string]$filename
    )
    $global:ItcDirectory = "$directory"   # Store the current scripts directory
    $global:ItcFile = "$filename"
}

###############
# ItcLogStart #
###############
Function ItcLogStart() {
    param (
    [Parameter(Mandatory=$false)][string]$directory,         # The directory of the powershell script. E.g. $PSScriptRoot
    [Parameter(Mandatory=$false)][string]$filename,          # Short name for log files E.g. "MyScript"
    [Parameter(Mandatory=$false)][string]$LogDaysBack       # How many days back of log files are needed. E.g. "-30"
    )
    if($directory -eq "" -or $directory -eq $null ){
        if($global:ItcDirectory -ne ""){
            $directory = $global:ItcDirectory
        }
        else {
            Write-Host "Error: Missing script directory! Exitting!" -ForegroundColor Red
            Exit -1
        }
    }
    else {
        $global:ItcDirectory = $directory
    }
    if((Test-Path $directory) -eq 0) {
        Write-Host "Error: Illegal path $directory" -ForegroundColor Red
        Write-Host "Exitting!" -ForegroundColor Red
        Exit -1
    }
    if($filename -eq "" -or $filename -eq $null ){
        if($global:ItcFile -ne ""){
            $filename = $global:ItcFile
        }
        else {
            $filename = "Log"
        }
    }
    else {
        $global:ItcFile = $filename
    }

    if(!($LogDaysBack)){
        $LogDaysBack = "-30"
    }
    $RunDate = Get-Date -format "yyyy-MM-dd"
    if ( !($directory.endswith("\")) ) {
        $directory = "$directory" + "\"
    }
    $LogPath = "$directory" + "Log\"
    if((Test-Path $LogPath) -eq 0) {
        write-host "Opretter biliotek $LogPath"
        mkdir $LogPath
    }
    $Today = Get-Date
    $DeleteFrom = $Today.AddDays($LogDaysBack)

    # Delete all Files in log-folder older than 30 day(s)
    Write-Host "deleting items from $LogPath."
    Get-ChildItem $LogPath | Where-Object { $_.LastWriteTime -lt $DeleteFrom } 
    #Get-ChildItem $LogPath | Where-Object { $_.LastWriteTime -lt $DeleteFrom } | Remove-Item       # CORRECT this! #############################################################
    $global:ItcLogfile = "$logpath" + "$filename_$(get-date -format `"dd-MM-yyyy`").log"
    Start-Transcript -Path $global:ItcLogfile -Append
    $global:ItcLogging = 1
}

#######################
# ItcLogStop          #
# Stop logging output #
#######################
Function ItcLogStop() {
    Stop-Transcript
    $global:ItcLogging = 10
}

#################################################################################
# ItcSetFejl                                                                    #
# Kør denne hvis der er fejl som der skal tages hånd om når der sendes mail.    #
#################################################################################
function ItcSetFejl() {
	$global:ItcFejl = 1
}

###########################################
# ItcSendMailOnError                      #
# Sender en mail hvis der er sket en fejl #
###########################################
function ItcSendMailOnError() {
    param (
    [Parameter(Mandatory=$true)][string]$overskrift,
    [Parameter(Mandatory=$true)][string]$indhold,
    [Parameter(Mandatory=$true)][string]$til,
    [Parameter(Mandatory=$false)][string]$fra,
    [Parameter(Mandatory=$false)][string]$smtpserver,
    [Parameter(Mandatory=$false)][string]$filepath      # Optional #
    )
    If($global:ItcFejl -ne 0){
        ItcSendMail $overskrift $indhold $til $fra $smtpserver $filepath
    }
}

########################################
# ItcGetUser                           #
# Get the current users SamAccountName #
########################################
Function ItcGetUser() {
    $user = $env:UserName
    return $user
}

##########################################
# ItcCreateCredentialfile                #
# Creates a Credentialfile for later use #
##########################################
Function ItcCreateCredentialfile() {
    param (
    [Parameter(Mandatory=$false)][string]$directory,    # Directory of the current script
    [Parameter(Mandatory=$false)][string]$filename      # Short filename of the credential file. E.g. "Credentials"
    )
    $user = $env:UserName
    if($directory -eq "" -or $directory -eq $null ){
        if($global:ItcDirectory -ne ""){
            $directory = $global:ItcDirectory
        }
        else {
            Write-Host "Error: Missing script directory! Exitting!" -ForegroundColor Red
            Exit -1
        }
    }
    else {
        $global:ItcDirectory = $directory
    }
    if((Test-Path $directory) -eq 0) {
        Write-Host "Error: Illegal path $directory" -ForegroundColor Red
        Write-Host "Exitting!" -ForegroundColor Red
        Exit -1
    }
    if(!($directory)){
        Write-Host "Error: Illegal path $directory" -ForegroundColor Red
        Write-Host "Exitting!" -ForegroundColor Red
        Exit -1
    }
    if ( !($directory.endswith("\")) ) {
        $directory = "$directory" + "\"
    }
    if(!($filename)){
        $filename = "Credentials"
    }
    $CREDENTIALFILE = "$directory" + "$user" + "$filename" + ".xml"

    $cred = Get-Credential          #Dan Credentials fil
    $cred | Export-Clixml $CREDENTIALFILE
}

####################
# ItcGetCredential #
####################
Function ItcGetCredential() {
    param (
    [Parameter(Mandatory=$True)][string]$directory,         # Directory of the current script
    [Parameter(Mandatory=$false)][string]$filename          # Short filename of the credential file. E.g. "Credentials"
    )
    $user = $env:UserName
    if($directory -eq "" -or $directory -eq $null ){
        if($global:ItcDirectory -ne ""){
            $directory = $global:ItcDirectory
        }
        else {
            Write-Host "Error: Missing script directory! Exitting!" -ForegroundColor Red
            Exit -1
        }
    }
    else {
        $global:ItcDirectory = $directory
    }
    if((Test-Path $directory) -eq 0) {
        Write-Host "Error: Illegal path $directory" -ForegroundColor Red
        Write-Host "Exitting!" -ForegroundColor Red
        Exit -1
    }
    if(!($directory)){
        Write-Host "Error: Illegal path $directory" -ForegroundColor Red
        Write-Host "Exitting!" -ForegroundColor Red
        Exit -1
    }
    if ( !($directory.endswith("\")) ) {
        $directory = "$directory" + "\"
    }
    if(!($filename)){
        $filename = "Credentials"
    }
    $CREDENTIALFILE = "$directory" + "$user" + "$filename" + ".xml"
    if((Test-Path $CREDENTIALFILE) -eq 0) {
        write-host "WARNING: Der mangler en credential fil. Opretter credential fil $CREDENTIALFILE" -ForegroundColor Yellow
        ItcCreateCredentialfile $directory $filename
    }
    $oCred = Import-Clixml $CREDENTIALFILE
    return $oCred
}

############################
# ItcGetCredentialFilename #
############################
Function ItcGetCredentialFilename() {
    param (
    [Parameter(Mandatory=$True)][string]$directory,     # Directory of the current script  
    [Parameter(Mandatory=$false)][string]$filename      # Short filename of the credential file. E.g. "Credentials"
    )
    $user = $env:UserName
    if($directory -eq "" -or $directory -eq $null ){
        if($global:ItcDirectory -ne ""){
            $directory = $global:ItcDirectory
        }
        else {
            Write-Host "Error: Missing script directory! Exitting!" -ForegroundColor Red
            Exit -1
        }
    }
    else {
        $global:ItcDirectory = $directory
    }
    if((Test-Path $directory) -eq 0) {
        Write-Host "Error: Illegal path $directory" -ForegroundColor Red
        Write-Host "Exitting!" -ForegroundColor Red
        Exit -1
    }
    if(!($directory)){
        Write-Host "Error: Illegal path $directory" -ForegroundColor Red
        Write-Host "Exitting!" -ForegroundColor Red
        Exit -1
    }
    if ( !($directory.endswith("\")) ) {
        $directory = "$directory" + "\"
    }
    if(!($filename)){
        $filename = "Credentials"
    }
    $CREDENTIALFILE = "$directory" + "$user" + "$filename" + ".xml"

    Write-Host "Filename: $CREDENTIALFILE"
    return $CREDENTIALFILE
}

#########################################################
# SendMail                                              #
# Sends a mail with a header on a body to a mail adress #
#########################################################
Function ItcSendMail() {
	param (
    [Parameter(Mandatory=$true)][string]$overskrift,
    [Parameter(Mandatory=$true)][string]$indhold,
    [Parameter(Mandatory=$true)][string]$til,
    [Parameter(Mandatory=$false)][string]$fra,
    [Parameter(Mandatory=$false)][string]$smtpserver,
    [Parameter(Mandatory=$false)][string]$filepath      # Optional #
    )
	#Opbyg og send mailen med de definerede indhold
	$mailbesked = new-object System.Net.Mail.MailMessage
    if(!($fra)){
        $fra = "powershell@itcfyn.dk"
    }
	$mailbesked.From = $fra
	$mailbesked.To.Add($til)
	$mailbesked.IsBodyHtml = $True
	$mailbesked.Subject = $overskrift
	$mailbesked.body = "<P>" + $indhold + "</P>"
    #if(!($filepath)){
    if(($filepath)){
        $vedhaeft = new-object Net.Mail.Attachment($filepath)
        $mailbesked.Attachments.Add($vedhaeft)
    }
    if(!($smtpserver)){
        $smtpserver = "itcsmtp01.itcfyn.adm"
    }
	$smtp = new-object Net.Mail.SmtpClient($smtpserver)
	$smtp.Send($mailbesked)
}

########################
# ItcTest              #
# Function for testing #
########################
Function ItcTest() {
    param (
    [Parameter(Mandatory=$false)][string]$directory,     # Directory of the current script  
    [Parameter(Mandatory=$false)][string]$filename      # Short filename of the credential file. E.g. "Credentials"
    )
    if($directory -eq "" -or $directory -eq $null ){
        if($global:ItcDirectory -ne ""){
            $directory = $global:ItcDirectory
        }
        else {
            Write-Host "Error: Missing script directory! Exitting!" -ForegroundColor Red
            Exit -1
        }
    }
    else {
        $global:ItcDirectory = $directory
    }
    if((Test-Path $directory) -eq 0) {
        Write-Host "Error: Illegal path $directory" -ForegroundColor Red
        Write-Host "Exitting!" -ForegroundColor Red
        Exit -1
    }
    if(!($directory)){
        Write-Host "Error: Illegal path $directory" -ForegroundColor Red
        Write-Host "Exitting!" -ForegroundColor Red
        Exit -1
    }
    Write-Host "Directory $directory"
}

Export-ModuleMember -Function ItcStart
Export-ModuleMember -Function ItcGetUser
Export-ModuleMember -Function ItcCreateCredentialfile
Export-ModuleMember -Function ItcGetCredential
Export-ModuleMember -Function ItcGetCredentialFilename
Export-ModuleMember -Function ItcSendMail
Export-ModuleMember -Function ItcLogStart
Export-ModuleMember -Function ItcLogStop
Export-ModuleMember -Function ItcSetFejl
Export-ModuleMember -Function ItcTest
