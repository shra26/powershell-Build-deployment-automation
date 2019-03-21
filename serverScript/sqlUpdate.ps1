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

#---------------------SQL Update--------------------------#


$array =$Config.dbUpdate.scriptFile
$uid = $Config.dbUpdate.username
$pswd = $Config.dbUpdate.password
try {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Write-Host "$LogTime -----SQL update Started" #|Out-File $Config.log.logAddr -Append -Force
    if ($Config.dbUpdate.go -ne 0) {
        foreach ($item in $array) {
            & ((Split-Path $MyInvocation.InvocationName) + "\runsql.ps1") -server $Config.dbUpdate.server -dbname $Config.dbUpdate.db -file $item -go -u $uid -p $pswd
        }
    }
    else {
        foreach ($item in $array) {
            & ((Split-Path $MyInvocation.InvocationName) + "\runsql.ps1") -server $Config.dbUpdate.server -dbname $Config.dbUpdate.db -file $item -u $uid -p $pswd
        }
    }
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Write-Host "$LogTime -----SQL update Successful" #|Out-File $Config.log.logAddr -Append -Force
}
catch {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Throw "$LogTime -----SQL update Failed" #|Out-File $Config.log.logAddr -Append -Force
}

#---------------------------------------------------------#
Stop-Transcript