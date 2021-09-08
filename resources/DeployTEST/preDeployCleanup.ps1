# cleanup inetpub and IIS
Import-Module  -Force WebAdministration
Remove-Website -Name *
Remove-WebAppPool -name *
Stop-Service W3SVC
Get-ChildItem 'C:\inetpub'  -Exclude custerr, history, logs, temp, wwwroot  | Remove-Item -Force -Recurse 
Start-Service W3SVC
## cleanup DB
$sqlInstanceName = (Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias Ethernet).IPAddress.trim()

$rQuery =" EXEC sp_MSforeachdb
  'IF DB_ID(''?'') > 4
  BEGIN
    EXEC (''ALTER DATABASE [?] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [?]'' )
  END'
  "
invoke-sqlcmd -ServerInstance $sqlInstanceName -Query $rQuery

## cleanup services
#### service stop & remove
Stop-Service BaltBet.MessageService.Host
#### proc kill   
Stop-Process -Name BaltBet.MessageService.Host -Force 
#### cleanup folders
sleep 10
Remove-Item -Path C:\Services\* -Force -Recurse

## cleanup kernel
#### service stop & remove
Stop-Service kernel, kernelweb
#### proc kill   
Stop-Process -Name Kernel, KernelWeb -Force

sleep 10
#### cleanup folders
Remove-Item -Path C:\Kernel, C:\KernelWeb -Force -Recurse
