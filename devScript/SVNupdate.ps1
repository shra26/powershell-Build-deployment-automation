$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | Out-Null
$ErrorActionPreference = "Stop"
#----------------Configs Download------------#

$Global:BaseDirectory = $PWD
$Global:BaseConfig = "\devConfig.json"
try {
    Write-Host "Loading Config File"
    $Global:Config = Get-Content "$BaseDirectory$BaseConfig" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" #  Log file time stamp
    Write-Host "$LogTime -----config file Loaded" #|Out-File $Config.log.logAddr -Append -Force
} catch {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" #  Log file time stamp
    Throw "$LogTime -----config file doesn'y exist" #|Out-File $Config.log.logAddr -Append -Force
}
if (!($Config)) {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" 
    Throw "$LogTime -----config file empty" #|Out-File $Config.log.logAddr -Append -Force
}
#--------------------------------------------#
$LogTime = Get-Date -Format "dd-MM-yyyy" #  Log file time stamp
Start-Transcript -Append -Path "logs/log_$LogTime.txt"

#----------------SVN Download----------------#

 try {
     Write-Host "Checking out SVN"
    #  svn checkout  $Config.SVNCredentials.svnUrl $Config.SVNCredentials.LocalPath  # for checkout only
     svn update $Config.SVNCredentials.LocalPath   #Updating 
     $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
     Write-Host "$LogTime -----SVN checkout Success" #|Out-File $Config.log.logAddr -Append -Force     
 }
 catch{
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Throw "$LogTime -----Error in SVN checkout" #|Out-File $Config.log.logAddr -Append -Force
 }
#--------------------------------------------#
Stop-Transcript