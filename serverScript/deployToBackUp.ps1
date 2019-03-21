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

#----------------Move deploy folder (old copy) to backup repository------------------#

try {
    Write-Host "backup of old files started"
    # $hh=$Config.Old.exclude
    xcopy.exe $Config.Old.fromAddr $Config.Old.toAddr  /E /C /I /R /Y #/EXCLUDE:$hh
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" #  Log file time stamp
    Write-Host "$LogTime -----backup of old files Successful" #|Out-File $Config.log.logAddr -Append -Force
}
catch {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" #  Log file time stamp
    Throw "$LogTime -----backup of old files Failed" #|Out-File $Config.log.logAddr -Append -Force
}

#-------------------------------------------------------------#
Stop-Transcript