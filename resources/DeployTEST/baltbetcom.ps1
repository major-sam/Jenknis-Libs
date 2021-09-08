$sourceDir = 'C:\temp\BALTBETCOM-RU'
$targetDir  = 'C:\inetpub\baltbetcom'
$ProgressPreference = 'SilentlyContinue'
$CurrentIpAddr =(Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias Ethernet).IPAddress.trim()
$MssqlVersion = "MSSQL15"
### !!! TRAILING SLASHES !!!
$release_bak_folder = "\\dev-comp49\share\DBs\"
$MSSQLDataPath = "C:\Program Files\Microsoft SQL Server\$MssqlVersion.MSSQLSERVER\MSSQL\DATA\"
$queryTimeout = 720
$username ="GKBALTBET\TestKernel_svc"
$pass = "GldycLIFKM2018"
$webConfig = "$sourceDir\Web.config"
$RuntimeVersion ='v4.0'
$IISPools = @( 
    @{
        SiteName = 'baltbetcom'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:84:"}
                @{protocol='https';;bindingInformation="*:4444:"}
            )
    }
)  
### copy files

Copy-Item -Path "$sourceDir\"  -Destination $targetDir -Recurse -Exclude "*.nupkg" 


### create sites

Import-Module -Force WebAdministration
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
$webdoc = [Xml](Get-Content -Encoding UTF8 $webConfig)
$obj = $webdoc.configuration.appSettings.add | where {$_.key -like "ServerAddress" }
$obj.value = $CurrentIpAddr+":8082"
$obj = $webdoc.configuration.appSettings.add | where {$_.key -eq "SiteServerAddress" -and $_.value -like '172*'} 
$webdoc.Save($webConfig)