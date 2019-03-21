$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | Out-Null
$ErrorActionPreference = "Stop"
#----------------Configs Download------------#

$Global:BaseDirectory = $PWD
$Global:BaseConfig = "\serverConfig.json"
try {
    $Global:Config = Get-Content "$BaseDirectory$BaseConfig" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
    # Write-Host "Config File Loading Successful"
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" #  Log file time stamp
    Write-Host "$LogTime -----config file Loaded" #|Out-File $Config.log.logAddr -Append -Force
} catch {
    Throw "Config File Doesn't exist"
}
if (!($Config)) {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" 
    Write-Host "$LogTime -----config file empty" #|Out-File $Config.log.logAddr -Append -Force
    Stop-Transcript
    exit 
}
#--------------------------------------------#
$LogTime = Get-Date -Format "dd-MM-yyyy" #  Log file time stamp
Start-Transcript -Append -Path "logs/log_$LogTime.txt"

#-----------Configs---------------------#
$cc = $Config.Local.unZipTo
$xx = $Config.Local.fileName+".zip"
$bb = $Config.Local.fileName
#---------------------------------------#    
#------------move zipped file from ftp to dated folder---------# 
try {
Move-Item $Config.Local.mvZipFrom $cc -Force
$LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" #  Log file time stamp
Write-Host "$LogTime -----FTP Zip move to backup folder Successful" #|Out-File $Config.log.logAddr -Append -Force    
}
catch {
$LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" #  Log file time stamp
Throw "$LogTime -----FTP Zip move to backup folder Failed" #|Out-File $Config.log.logAddr -Append -Force    
}

#--------------------------------------------------------------#    
Stop-Transcript