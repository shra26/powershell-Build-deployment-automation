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

#----------------File Unzip------------------#
try{   
    if (Test-Path "$cc$bb") {
        Write-Host "Cleaning Existing Copy"
        Remove-Item -Path $cc$bb -Recurse
        Write-Host "copy Cleansed"
    }
    Write-Host "Unzipping File"
    Expand-Archive -Path "$cc$xx" -DestinationPath $cc
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Write-Host "$LogTime -----File Unzip Success" #|Out-File $Config.log.logAddr -Append -Force
} catch{
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Throw "$LogTime -----expansion failure" #|Out-File $Config.log.logAddr -Append -Force
}
#--------------------------------------------#
Stop-Transcript