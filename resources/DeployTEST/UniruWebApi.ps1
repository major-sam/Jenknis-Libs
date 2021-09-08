###vars
$WebSiteName = "UniruWebApi"
$targetDir = "C:\inetpub\$WebSiteName"
$sourceDir = "C:\temp\$WebSiteName"
$webConfig = "$sourceDir\Web.config"
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