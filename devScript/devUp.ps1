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
$LogTime = Get-Date -Format "dd-MM-yyyy" #  Log file time stamp
Start-Transcript -Append -Path "logs/log_$LogTime.txt"

#--------------------------------------------#

#----------------SVN Download----------------#
#& ((Split-Path $MyInvocation.InvocationName) + "\SVNupdate.ps1")

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


#----------------Project Publish-------------#
#& ((Split-Path $MyInvocation.InvocationName) + "\msPublish.ps1")

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



#----------------File Zip--------------------#
#& ((Split-Path $MyInvocation.InvocationName) + "\zipPub.ps1")

try{
    Write-Host "Zipping File"
    Compress-Archive -Path $Config.Local.zipFrom -DestinationPath $Config.Local.zipTo -Force
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Write-Host "$LogTime -----File Zip Success" #|Out-File $Config.log.logAddr -Append -Force
} catch{
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Throw "$LogTime -----compression failure" #|Out-File $Config.log.logAddr -Append -Force
}
#--------------------------------------------#

#-----------------FTP Upload--------------------#
#& ((Split-Path $MyInvocation.InvocationName) + "\ftpupload.ps1")   #try this if below function is hanging up in between FTP upload
try {
    # create the FtpWebRequest and configure it
    Write-Host "Starting FTP connection"
    $Username = $Config.LoginFTP.username
    $Password = $Config.LoginFTP.password
    $bufSize = 25mb
    $ftp = [System.Net.FtpWebRequest]::Create($Config.LoginFTP.hostname)
    $ftp = [System.Net.FtpWebRequest]$ftp
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftp.Credentials = new-object System.Net.NetworkCredential($Username,$Password)
    $ftp.Timeout = -1 #infinite timeout 
    $ftp.ReadWriteTimeout = -1 #infinite timeout
    $ftp.UseBinary = $true
    $ftp.UsePassive = $true
    $requestStream = $ftp.GetRequestStream()
    Write-Host "FTP Connected"
    $fileStream = [System.IO.File]::OpenRead($Config.LoginFTP.fileUp) 
    $chunk = New-Object byte[] $bufSize 
    while ( $bytesRead = $fileStream.Read($chunk, 0, $bufsize) ){ 
        Write-Host "FTP Uploading..."
        $requestStream.write($chunk, 0, $bytesRead) 
        $requestStream.Flush() 
    } 
    # clean up after 
    $fileStream.Close()
    $requestStream.Close()
    $requestStream.Dispose()
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Write-Host "$LogTime -----FTP Successful" #|Out-File $Config.log.logAddr -Append -Force
}
catch {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
    Throw "$LogTime -----FTP failure" #|Out-File $Config.log.logAddr -Append -Force
}
#------------------------------------------------#
Stop-Transcript