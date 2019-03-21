# Build-deployment-automation in .NET websites

Developer Side Files:

	devConfig.json			Configuration file
	
	devUp.ps1				Read Config Files. 
							Update project from svn. 
							Publish the project.
							Zip the published folder. 
							Upload zipped folder to FTP server.
	
	ftpupload.ps1			Read Configuration file, Upload file to server.
	
	msPublish.ps1			Read Configuration file, Publish the project.
	
	SVNupdate.ps1			Read Configuration file, update project from svn.
	
	zipPub.ps1				Read Configuration file, Zip the published folder.

Server Side Files:

	serverConfig.json		Configuration file
	
	backupExclude.txt		Exclude the folder or files from moving into the virtual deploy directory
	
	SQLErrors.txt			All SQL query related 
	
	binExclude.txt			Exclude files (.config, .xml and 3rd party .dll files) from moving into the bin folder.
	
	serverDown.ps1			Read Config Files.
							Move deploy folder to backup folder.
							Move zipped folder from ftp folder to the backup folder. 
							Unzip the folder into the backup folder. 
							Move unzipped folder to the deploy folder.
							Update the bin folder. 
							Update and execute the SQL files on the database.
	
	runsql.ps1				Dependency for serverDown.ps1... Do not edit.
	
	binUpdate.ps1			Read Config Files.
							Update the bin folder. 
	
	deployToBackUp.ps1		Read Config Files.
							Move deploy folder to backup folder.
	
	freshToDeploy.ps1		Read Config Files.
							Move unzipped folder to the deploy folder.
	
	ftpToBackUp.ps1			Read Config Files.
							Move zipped folder from ftp folder to the backup folder.
	
	sqlUpdate.ps1			Read Config Files.
							Update and execute the SQL files on the database.
	
	unzip.ps1				Read Config Files.
							Unzip the folder into the backup folder. 

 
SQL Update Script Folder:

	sqlUpdate.ps1			Read Config Files.
							Update and execute the SQL files on the database.
	
	runsql.ps1				Dependency for sqlUpdate.ps1... Do not edit.
	
	sqlUpdateConfig.json	Config file for sqlUpdate.ps1.

General:

	•	All logs generated are stored in the Logs folder. If there is multiple runs of parent and child programs, it will be saved into only 1 log file 		with current date.

devConfig Parameters:

	•	Local
		a.	home: Path to the project you want to publish with the .sln file in this folder.
				(C:\\Users\\ Source\\")
		b.	zipFrom: path to the published folder to zip it.
				("C:\\Users \\Desktop\\testpublish")
		c.	zipTo: destination of the zipped folder along with zip folder name.
				(C:\\Users\\Desktop\\testPublish.zip) 
	•	SVNCredentials
		a.	svnUrl: url to the svn server for checking out our files.
		b.	LocalPath: local path to the svn files which are already registered to the svn network.
				(C:\\Users\\Desktop\\Source\\xyz.Dev) 
	•	LoginFTP
		a.	Hostname: destination FTP server address with port.
		b.	username: user name for the FTP server login.
		c.	password: FTP server password for username
		d.	fileUp: the path to zip folder to be uploaded to ftp server. 
	•	ms 
		a.	msBuild: path to the msbuild.exe file on the local system.
				(C:\\Program Files (x86)\\MSBuild\\12.0\\Bin\\MSBuild.exe)
		b.	intAddr: relative path from Local.home to portal.csproj 
				(Portal\\Portal.csproj)
		c.	profile: set a profile for build deployment after creating it from the UI of Microsoft visual studio, just mentioning the name of the 						profile is enough.
				(Test)

serverConfig Parameters:

	•	Local
		a.	mvZipFrom: ftp zipped folder absolute location with name ready for deployment.
				(C:\\Users\\Desktop\\testPublish.zip)
		b.	fileName: name to be given for the unzipped folder.
				(\\testPublish) 
		c.	unZipTo: unzip to the backup folder location. 
				(C:\\Users\\Desktop\\powershellScripts\\backup) 
	•	Old
		a.	fromAddr: virtual directory address to the deploy folder. Including “*” is important.
				(C:\\Users \\Desktop\\powershellScripts\\deploy\\testpublish\\*) 
		b.	toAddr:  Backup folder address.
				(C:\\Users\\Desktop\\powershellScripts\\backup\\Old) 
		c.	exclude: location of text file holding all the file names to exclude files if required. (disabled by default)
				(C:\\Users\\Desktop\\powershellScripts\\serverScript\\backupExclude.txt)
	•	New
		a.	fromAddr: location of unzipped folder in backup folder. Including “*” is important.
				(C:\\Users \\Desktop\\powershellScripts\\backup\\testpublish\\*)
		b.	toAddr: virtual directory address to the deploy folder.
				(C:\\Users\\Desktop\\powershellScripts\\deploy\\testpublish)
		c.	exclude: location of text file holding all the file names to exclude files if required. 
				(C:\\Users\\Desktop\\powershellScripts\\serverScript\\backupExclude.txt) 
	•	updateDll
		a.	fromAddr: new unzipped bin folder address.
				(C:\\Users\\Desktop\\powershellScripts\\backup\\testpublish\\bin)
		b.	toAddr: virtual directory address to the deploy folder’s bin.
				(C:\\Users\\Desktop\\powershellScripts\\deploy\\testpublish\\bin) 
		c.	exclude: location of text file holding all the file names to exclude files.
				(C:\\Users\\Desktop\\powershellScripts\\serverScript\\binExclude.txt) 
	•	dbUpdate
		a.	scriptFile: list (standard json array format) of stored update procedure file locations 
		b.	username: Database username credential.
		c.	password: Database password credential.
		d.	db: Database name to be accessed.
		e.	server: server IP address where the database is stored. 
		go:  set to “1” is the sql files contain “GO” statements in it. Set to “0” is there are no “GO” statements in the sql files.

	sqlUpdateConfig Parameters:
	•	dbUpdate
		f.	scriptFile: list (standard json array format) of stored update procedure file locations
		g.	username: Database username credential.
		h.	password: Database password credential.
		i.	db: Database name to be accessed.
		j.	server: server IP address where the database is stored. 
		k.	go:  set to “1” is the sql files contain “GO” statements in it. Set to “0” is there are no “GO” statements in the sql files.

Warnings:

	•	Do not edit runsql.ps1 file, it will not generate any error (has been tested for all cases).
	•	Do not use GO statements simultaneously after each other in the SQL file, will generate an SQL error.

Built using open-source code across the internet.