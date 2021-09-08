###vars
$WebSiteName = "UniruWebApi"
$targetDir = "C:\inetpub\$WebSiteName"
$sourceDir = "$env:nugettemp\$WebSiteName"
$webConfig = "$targetDir\Web.config"
### copy files

write-host "Copy-Item -Path "$sourceDir"  -Destination $targetDir -Recurse -Exclude "*.nupkg
Copy-Item -Path "$sourceDir"  -Destination $targetDir -Recurse -Exclude "*.nupkg" 

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
