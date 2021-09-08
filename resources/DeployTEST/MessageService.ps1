## vars
$sourceDir = 'C:\temp\MessageService'
$targetDir  = 'C:\Services'
$release_bak_folder = 'C:\temp\'

$dbs = @(
	@{
		DbName = "MessageService"
		BackupFile = "MessageService.bak"
        RelocateFiles = @(
			@{
				SourceName = "MessageService"
				FileName = "MessageService.mdf"
			}
			@{
				SourceName = "MessageService_log"
				FileName = "MessageService.ldf"
			}
        )
	}
)
### side functions
function RestoreSqlDb($db_params) {
	foreach ($db in $db_params){
		$RelocateFile = @() 
        $dbname = $db.DbName
		$KillConnectionsSql=
			"
			USE master
            IF EXISTS(select * from sys.databases where name='"+$dbname+"')
            BEGIN
			    ALTER DATABASE [$dbname] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
			    DROP DATABASE [$dbname]
			END;
			"
		Invoke-Sqlcmd -Verbose -ServerInstance $env:COMPUTERNAME -Query $KillConnectionsSql -ErrorAction continue
		$dbBackupFile = $release_bak_folder + $db.BackupFile
		if ($db.ContainsKey('RelocateFiles')){
			foreach ($dbFile in $db.RelocateFiles) {
				$RelocateFile += New-Object Microsoft.SqlServer.Management.Smo.RelocateFile($dbFile.SourceName, ("{0}{1}" -f $MSSQLDataPath, $dbFile.FileName))
			}
            write-host -ForegroundColor DarkGreen $dbBackupFile
			Restore-SqlDatabase -Verbose -ServerInstance $env:COMPUTERNAME -Database $db.DbName -BackupFile  $dbBackupFile -RelocateFile $RelocateFile -ReplaceDatabase
			Push-Location C:\Windows
		}else{
			Restore-SqlDatabase -Verbose -ServerInstance $env:COMPUTERNAME -Database $db.DbName -BackupFile  $dbBackupFile -ReplaceDatabase
			Push-Location C:\Windows			
		}
	}
}

###restore DB
RestoreSqlDb($dbs)

### copy files
Copy-Item -Path "$sourceDir"  -Destination $targetDir -Recurse -Exclude *.nupkg  -Force