###vars
$WebSiteName = "UniRu"
$targetDir = "C:\inetpub\$WebSiteName"
$sourceDir = "C:\temp\$WebSiteName"

## TODO!!!
$file = Get-item -Path "C:\Users\vrebyachih\Desktop\UniRu.sql"
$oldIp = '172.16.1.217'
$oldHostname = 'VM1APKTEST-P1'
$IPAddress = (Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4).IPAddress.trim()
$ProgressPreference = 'SilentlyContinue'
$RuntimeVersion ='v4.0'
$MssqlVersion = "MSSQL15"
### !!! TRAILING SLASHES !!!
$release_bak_folder = "\\dev-comp49\share\DBs\"
$MSSQLDataPath = "C:\Program Files\Microsoft SQL Server\$MssqlVersion.MSSQLSERVER\MSSQL\DATA\"
$queryTimeout = 720
$webConfig = "$targetDir\Web.config"

$dbs = @(
	@{
		DbName = "UniRu"
		BackupFile = "UniRu.bak"
        RelocateFiles = @(
			@{
				SourceName = "UniCps"
				FileName = "UniRu.mdf"
			}
			@{
				SourceName = "UniCps_log"
				FileName = "UniRu.ldf"
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

(Get-Content -Encoding UTF8 -LiteralPath $file.Fullname)|Foreach-Object {
    $_ -replace $oldIp,  $IPAddress `
        -replace $oldHostname, $env:COMPUTERNAME`
    } | Set-Content -Encoding UTF8 -LiteralPath $file.Fullname
Invoke-Sqlcmd -verbose -ServerInstance $env:COMPUTERNAME -Database "master" -InputFile $file.Fullname -ErrorAction Stop
Set-Location C:\
### copy files

Copy-Item -Path "$sourceDir\"  -Destination $targetDir -Recurse -Exclude "*.nupkg" 


### IIS PART MOVED TO ISSconfig.ps1


###
#XML values replace
####
$webdoc = [Xml](Get-Content $webConfig)
$obj = $webdoc.configuration.connectionStrings.add | where {$_.name -eq 'DataContext' }
$obj.connectionString = "data source=localhost;initial catalog=UniRu;Integrated Security=true;MultipleActiveResultSets=True;"
$obj = $webdoc.configuration.cache.db
$obj.connection = "data source=localhost;initial catalog=UniRu;Integrated Security=true;MultipleActiveResultSets=True;"
$webdoc.Save($webConfig)

