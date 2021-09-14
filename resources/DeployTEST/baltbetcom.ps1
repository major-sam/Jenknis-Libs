$sourceDir = "$env:nugettemp\BALTBETCOM-RU"
$targetDir  = 'C:\inetpub\baltbetcom'
$ProgressPreference = 'SilentlyContinue'
$webConfig = "$targetDir\Web.config"
$CurrentIpAddr =(Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias Ethernet).IPAddress.trim()
$MssqlVersion = "MSSQL15"
### !!! TRAILING SLASHES !!!
$release_bak_folder = "\\dev-comp49\share\DBs\"
$MSSQLDataPath = "C:\Program Files\Microsoft SQL Server\$MssqlVersion.MSSQLSERVER\MSSQL\DATA\"
$queryTimeout = 720
### IIS PART MOVED TO ISSconfig.ps1

### copy files

write-host "Copy-Item -Path "$sourceDir"  -Destination $targetDir -Recurse -Exclude "*.nupkg
Copy-Item -Path "$sourceDir"  -Destination $targetDir -Recurse -Exclude "*.nupkg" 


###
#XML values replace
####
$webdoc = [Xml](Get-Content -Encoding UTF8 $webConfig)
$obj = $webdoc.configuration.appSettings.add | where {$_.key -like "ServerAddress" }
$obj.value = $CurrentIpAddr+":8082"
$obj = $webdoc.configuration.appSettings.add | where {$_.key -eq "SiteServerAddress" -and $_.value -like '172*'} 
$webdoc.Save($webConfig)
