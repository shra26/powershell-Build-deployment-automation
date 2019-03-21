$ErrorActionPreference = "Stop"
#----------------Configs Download------------#
$Global:BaseDirectory = "C:\Users\sgowda\Desktop\powershellScripts\"
$Global:BaseConfig = "config.json"
try {
$Global:Config = Get-Content "$BaseDirectory$BaseConfig" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
Write-Host "Config File Loading Successful"
$LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" #  Log file time stamp
Write-Host "$LogTime -----config file Loaded" #|Out-File $Config.log.logAddr -Append -Force
} catch {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" #  Log file time stamp
    Write-Host "$LogTime -----config file doesn't exist" #|Out-File $Config.log.logAddr -Append -Force
}
if (!($Config)) {
    $LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss" 
    Write-Host "$LogTime -----config file empty" # |Out-File $Config.log.logAddr -Append -Force
}
$LogTime = Get-Date -Format "dd-MM-yyyy" #  Log file time stamp
Start-Transcript -Append -Path "logs/log_$LogTime.txt"

#----------------FTP Upload------------------#
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
#--------------------------------------------#
Stop-Transcript