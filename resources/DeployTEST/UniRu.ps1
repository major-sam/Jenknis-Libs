###vars
$WebSiteName = "UniRu"
$targetDir = "C:\inetpub\$WebSiteName"
$sourceDir = "$env:nugettemp\$WebSiteName"

## TODO!!!
$sourceFile = Get-item -Path "\\dev-comp49\share\UniRu.sql"
$file = ".\UniRu.sql"
$oldIp = '172.16.1.217'
$oldHostname = 'VM1APKTEST-P1'
$IPAddress = (Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4).IPAddress.trim()
$ProgressPreference = 'SilentlyContinue'
$RuntimeVersion ='v4.0'
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
$srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" "."
$MssqlVersion = "MSSQL" + $srv.Version.major
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

### copy files

write-host "Copy-Item -Path "$sourceDir"  -Destination $targetDir -Recurse -Exclude "*.nupkg" "
Copy-Item -Path "$sourceDir"  -Destination $targetDir -Recurse -Exclude "*.nupkg" 


(Get-Content -Encoding UTF8 -LiteralPath $sourceFile.Fullname)|Foreach-Object {
    $_ -replace $oldIp,  $IPAddress `
        -replace $oldHostname, $env:COMPUTERNAME`
    } | Set-Content -Encoding UTF8 $file

$sFile = Get-item -Path "\\dev-comp49\share\UniRu.sql"
Invoke-Sqlcmd -verbose -ServerInstance $env:COMPUTERNAME -Database $dbs[0].DbName -InputFile $sFile.Fullname -ErrorAction Stop
Set-Location C:\
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

