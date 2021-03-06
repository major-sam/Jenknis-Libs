#cleanup Nuget cache
nuget locals all -clear


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
  USE [msdb]
  GO
  DECLARE @Delete_Date [datetime]
  SET @Delete_Date = GETDATE()
  exec sp_delete_backuphistory @Delete_Date 
  GO
  "
invoke-sqlcmd -ServerInstance $sqlInstanceName -Query $rQuery

## cleanup services
#### service stop & remove
Stop-Service BaltBet.MessageService.Host
#### proc kill   
$procs = @("BaltBet.MessageService.Host")
foreach($proc in $procs){
	$pr = Get-Process $proc -ErrorAction SilentlyContinue
	if ($pr) {
	  # try gracefully first
	  $pr.CloseMainWindow()
	  # kill after five seconds
	  Sleep 5
	  if (!$pr.HasExited) {
		$pr | Stop-Process -Force
	  }
	}
	Remove-Variable pr
}
#### cleanup folders
sleep 10
Remove-Item -Path C:\Services\* -Force -Recurse

## cleanup kernel
#### service stop & remove
Stop-Service kernel, kernelweb
#### proc kill   

$procs = @("Kernel", "KernelWeb")
foreach($proc in $procs){
	$pr = Get-Process $proc -ErrorAction SilentlyContinue
	if ($pr) {
	  # try gracefully first
	  $pr.CloseMainWindow()
	  # kill after five seconds
	  Sleep 5
	  if (!$pr.HasExited) {
		$pr | Stop-Process -Force
	  }
	}
	Remove-Variable pr
}

sleep 10
#### cleanup folders
Remove-Item -Path C:\Kernel, C:\KernelWeb -Force -Recurse
