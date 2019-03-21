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

#----------------Project Publish-------------#

$msbuild = $Config.ms.msBuild                      # Reference to the MSBuild.exe for whichever .NET we are using
$path = $Config.Local.home                         # Path to the project you want to publish with the .sln file in this folder.
try {
    Write-Host "Cleaning Solution"
    # Clean the solution
    & $msbuild ($path + $Config.ms.intAddr) /target:clean /p:Configuration=Release
    Write-Host "Building and Publishing Solution"
    # Package the solution
    & $msbuild ($path + $Config.ms.intAddr) /p:DeployOnBuild=true /p:PublishProfile=$Config.ms.profile  #Test profile has to be built once on each system using UI after that this script will work fine.
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Write-Host "$LogTime -----Publishing Successful" #|Out-File $Config.log.logAddr -Append -Force
}
catch {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Throw "$LogTime -----Error in Publishing the Solution" #|Out-File $Config.log.logAddr -Append -Force
}

#--------------------------------------------#
Stop-Transcript