###vars
$WebSiteName = "ClientWorkSpace"
$targetDir = "C:\inetpub\$WebSiteName"
$sourceDir = "C:\temp\krm"
$ProgressPreference = 'SilentlyContinue'
$MssqlVersion = "MSSQL15"
### !!! TRAILING SLASHES !!!
$release_bak_folder = "\\dev-comp49\share\DBs\"
$MSSQLDataPath = "C:\Program Files\Microsoft SQL Server\$MssqlVersion.MSSQLSERVER\MSSQL\DATA\"
$queryTimeout = 720
$username ="GKBALTBET\TestKernel_svc"
$pass = "GldycLIFKM2018"
$IISPools = @( 
    @{
        SiteName = 'ClientWorkSpace'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:8080:"}
            )
    }
)  

$dbs = @(
	@{
		DbName = "CWS_ScreenSaversTempDB"
		BackupFile = "CWS_ScreenSaversTempDB.bak"
        RelocateFiles = @(
			@{
				SourceName = "CWS_ScreenSaversTempDB"
				FileName = "CWS_ScreenSaversTempDB.mdf"
			}
			@{
				SourceName = "CWS_ScreenSaversTempDB_log"
				FileName = "CWS_ScreenSaversTempDB_log.ldf"
			}
		)
	}
)

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
RestoreSqlDb($dbs)

### copy files

Copy-Item -Path "$sourceDir"  -Destination $targetDir -Recurse -Exclude "*.nupkg" 

### create sites
Import-Module  -Force WebAdministration
$RuntimeVersion ='v4.0'
foreach($site in $IISPools ){
    $name =  $site.SiteName
    New-Item –Path IIS:\AppPools\$name -force
    Set-ItemProperty –Path IIS:\AppPools\$name -Name managedRuntimeVersion -Value 'v4.0'
    Set-ItemProperty –Path IIS:\AppPools\$name -Name startMode -Value 'AlwaysRunning'
    if ($site.DomainAuth){
       Set-ItemProperty IIS:\AppPools\$name -name processModel -value $site.DomainAuth
    }
    Start-WebAppPool -Name $name
    New-Website -Name "$name" -ApplicationPool "$name" -PhysicalPath $targetDir -Force
    $IISSite = "IIS:\Sites\$name"
    Set-ItemProperty $IISSite -name  Bindings -value $site.Bindings
   # $webServerCert = get-item Cert:\LocalMachine\My\660a619045cf9a3117671c9a6804e17cbf9587fe
    #$bind = Get-WebBinding -Name $name -Protocol https
   # $bind.AddSslCertificate($webServerCert.GetCertHashString(), "my")
    Start-WebSite -Name "$name"
}