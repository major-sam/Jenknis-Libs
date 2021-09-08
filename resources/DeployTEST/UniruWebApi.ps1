###vars
$WebSiteName = "UniruWebApi"
$targetDir = "C:\inetpub\$WebSiteName"
$sourceDir = "C:\temp\$WebSiteName"
$username ="GKBALTBET\TestKernel_svc"
$pass = "GldycLIFKM2018"
$webConfig = "$targetDir\Web.config"
$IISPools = @( 
    @{
        SiteName = 'UniruWebApi'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='https';bindingInformation="*:4449:"}
            )
    }
) 
### copy files

Copy-Item -Path "$sourceDir\"  -Destination $targetDir -Recurse -Exclude "*.nupkg" 

### create sites 
Import-Module  -Force WebAdministration
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
    $webServerCert = get-item Cert:\LocalMachine\My\660a619045cf9a3117671c9a6804e17cbf9587fe
    $bind = Get-WebBinding -Name $name -Protocol https
    $bind.AddSslCertificate($webServerCert.GetCertHashString(), "my")
    Start-WebSite -Name "$name"
}


###
#XML values replace
####
$webdoc = [Xml](Get-Content $webConfig)
$obj = $webdoc.configuration.connectionStrings.add | where {$_.name -eq 'DataContext' }
$obj.connectionString = "data source=localhost;initial catalog=UniRu;Integrated Security=true;MultipleActiveResultSets=True;"
$obj = $webdoc.configuration.cache.db
$obj.connection = "data source=localhost;initial catalog=UniRu;Integrated Security=true;MultipleActiveResultSets=True;"
$webdoc.Save($webConfig)