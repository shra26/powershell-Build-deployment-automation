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
#& ((Split-Path $MyInvocation.InvocationName) + "\deployToBackUp.ps1")
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



#-----------Configs---------------------#
    $cc = $Config.Local.unZipTo
    $xx = $Config.Local.fileName+".zip"
    $bb = $Config.Local.fileName
#---------------------------------------#    
#------------move zipped file from ftp to dated folder---------# 
#& ((Split-Path $MyInvocation.InvocationName) + "\ftpToBackUp.ps1")

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

#----------------File Unzip------------------#
#& ((Split-Path $MyInvocation.InvocationName) + "\unZip.ps1")

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

#----------------move New copy(backup folder) to Deploy folder------------------#
#& ((Split-Path $MyInvocation.InvocationName) + "\freshToDeploy.ps1")

try {
    Write-Host "New files move started"
    $gg=$Config.New.exclude
    xcopy.exe $Config.New.fromAddr $Config.New.toAddr /EXCLUDE:$gg /E /C /I /R /Y 
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Write-Host "$LogTime -----New files move Successful" #|Out-File $Config.log.logAddr -Append -Force
}
catch  {     
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Throw "$LogTime -----New files move Failed" #|Out-File $Config.log.logAddr -Append -Force
}

#---------------------------------------------------------#

#-------------------bin folder update---------------------#
#& ((Split-Path $MyInvocation.InvocationName) + "\binUpdate.ps1")

try {
    Write-Host "Bin folder updating"
    $d=$Config.updateDll.exclude
    xcopy.exe $Config.updateDll.fromAddr $Config.updateDll.toAddr /EXCLUDE:$d /E /C /I /R /Y 
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Write-Host "$LogTime -----Bin folder update Successful" #|Out-File $Config.log.logAddr -Append -Force
}
catch  {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Throw "$LogTime -----Bin folder update Failed" #|Out-File $Config.log.logAddr -Append -Force
}


#---------------------------------------------------------#

#---------------------SQL Update--------------------------#
#& ((Split-Path $MyInvocation.InvocationName) + "\SVNupdate.ps1")

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

