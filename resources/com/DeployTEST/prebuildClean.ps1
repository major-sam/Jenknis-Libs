<#
Билд для сборки окружения под проекты



prerequsites:
  	Базовые
	!AD domain
	!Set AD users\groups
	!PS 5
	
	
	Дженкинс
	!jenkins node registration
	
	
	
	
	


$IISPools - переменная для создания пулов и сайтов в иис - лист хэштаблиц
    @{
        SiteName = 'AdminMessageApp'  --- ИМЯ САЙТА и ПУЛА
        DomainAuth =  @{ - БЛОК АВТОРИЗАЦИИ ДЛЯ ПУЛА И САЙТА
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @( -ЛИСТ ДЛЯ Bindings САЙТА.
                @{protocol='https';bindingInformation="*:44307:"}				
                @{protocol='http';bindingInformation="*:8007:"}
                @{protocol='https';bindingInformation="*:13443:vm4apktest-p3.gkbaltbet.local"}
            )		 протокол^  || порт и hostname ^
    }    

:TODO 

Часть iis скрипта необходимо вынести в деплой приложения

пока не реализованы:
sslFlags 
Подстановка сертификатов
	Вариант с запуском с аргументами и генережкой сертификатов с Microsoft SDK
	>.\SSLIISBinding.ps1 "test.west-wind.com" "Default Web Site" "LocalMachine" $cert
	
	$hostname = "test.west-wind.com"
	$iisSite = "Default Web Site"
	$machine = "LocalMachine"

	if ($args[0]) 
	{     
		$hostname = $args[0]
	}
	if($args[1])
	{
		$iisSite = $args[1]
	}
	if ($args[2])
	{
		$machine = $args[2]
	}
	if ($args[3])
	{
		$cert = $args[3]
	}
	"Host Name: " + $hostname
	"Site Name: " + $iisSite
	"  Machine: " + $machine
	if (-not $cert) {
		# Create a certificate
		& "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Bin\x64\makecert" -r -pe -n "CN=${hostname}" -b 06/01/2016 -e 06/01/2020 -eku 1.3.6.1.5.5.7.3.1 -ss my -sr localMachine  -sky exchange  -sp "Microsoft RSA SChannel Cryptographic Provider" -sy 12

		dir cert:\localmachine\my
		$cert = (Get-ChildItem cert:\LocalMachine\My | where-object { $_.Subject -like "*$hostname*" } | Select-Object -First 1).Thumbprint
		$cert
	}
	"Cert Hash: " + $cert

	# http.sys mapping of ip/hostheader to cert
	$guid = [guid]::NewGuid().ToString("B")
	netsh http add sslcert hostnameport="${hostname}:443" certhash=$cert certstorename=MY appid="$guid"
#>
## Disable firewall 
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
## Disable Wdefender
Set-MpPreference -DisableRealtimeMonitoring $true 
## Allow long path
Set-ItemProperty 'HKLM:\System\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -value 1
# iis

[Net.ServicePointManager]::SecurityProtocol = "tls12"
Install-WindowsFeature -name Web-Server -IncludeManagementTools 
Register-PackageSource -provider NuGet -name nugetRepository -location https://www.nuget.org/api/v2
Install-Module  -Force -Name IISAdministration 

Import-Module WebAdministration
Remove-Website -Name *
Remove-WebAppPool -name *
$username ="GKBALTBET\TestKernel_svc"
$pass = "GldycLIFKM2018"

<# $IISPools = @( 
    @{
        SiteName = 'AdminMessageApp'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='https';bindingInformation="*:44307:"}
            )
    }    
    @{
        SiteName = 'auth_aouth'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }        
        Bindings= @(
                @{protocol='https';bindingInformation="*:449:"}
            )
    }    
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
    @{
        SiteName = 'baltbetru'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:81:"}
                @{protocol='https';;bindingInformation="*:4445:"}
            )
    }
    @{
        SiteName = 'baltplaymobile'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:82:"}
                @{protocol='https';;bindingInformation="*:4447:"}
            )
    }
    @{
        SiteName = 'ClientWorkSpace'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:8080:"}
            )
    }
    @{
        SiteName = 'images'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='https';bindingInformation="*:443:"}
            )
    }
    @{
        SiteName = 'Mobile'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:83:"}
                @{protocol='https';bindingInformation="*:446:"}
            )
    }
    @{
        SiteName = 'paysys'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Port = 88
        proto = "http"
        Header = ""
        Bindings= @(
                @{protocol='http';bindingInformation="*:88:"}
            )
    }
    @{
        SiteName = 'TimeBookingHost'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:63298:"}
            )
    }    
    @{
        SiteName = 'UniRu'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='https';bindingInformation="*:4443:"}
            )
    }    
    @{
        SiteName = 'UniRuWebApi'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='https';bindingInformation="*:4449:"}
            )
    }
)   #>
$RuntimeVersion ='v4.0'
<# foreach($site in $IISPools ){
    $name =  $site.SiteName
    New-Item –Path IIS:\AppPools\$name -force
    Set-ItemProperty –Path IIS:\AppPools\$name -Name managedRuntimeVersion -Value 'v4.0'
    Set-ItemProperty –Path IIS:\AppPools\$name -Name startMode -Value 'AlwaysRunning'
    if ($site.DomainAuth){
       Set-ItemProperty IIS:\AppPools\$name -name processModel -value $site.DomainAuth
    }
    Start-WebAppPool -Name $name
    New-Website -Name "$name" -ApplicationPool "$name" -PhysicalPath "c:\inetpub\$name" -Force
    $IISSite = "IIS:\Sites\$name"
    Set-ItemProperty $IISSite -name  Bindings -value $site.Bindings
    Start-WebSite -Name "$name"
}
 #>

##mssql


$isoLocation = "\\server\Soft\Microsoft\ISO\SQL 2019 Enterprice\en_sql_server_2019_enterprise_x64_dvd_c7d70add.iso"
$pathToConfigurationFile = "\\server\tcbuild$\Testers\_VM Update Instructions\Jenkins\mssql19\ConfigurationFile.ini"
$copyFileLocation = "C:\Temp\ConfigurationFile.ini"
$errorOutputFile = "C:\Temp\ErrorOutput.txt"
$standardOutputFile = "C:\Temp\StandardOutput.txt"

Write-Host "Copying the ini file."

New-Item "C:\Temp" -ItemType "Directory" -Force
Remove-Item $errorOutputFile -Force
Remove-Item $standardOutputFile -Force
Copy-Item $pathToConfigurationFile $copyFileLocation -Force
# legacy mssql server statement
#$user = "$env:UserDomain\$env:USERNAME"

#write-host $user
##
#Write-Host "Replacing the placeholder user name with your username"
#$replaceText = (Get-Content -path $copyFileLocation -Raw) -replace "##MyUser##", $user
#Set-Content $copyFileLocation $replaceText

Write-Host "Mounting SQL Server Image"
$drive = Mount-DiskImage -ImagePath $isoLocation

Write-Host "Getting Disk drive of the mounted image"
$disks = Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '5'"

foreach ($disk in $disks){
 $driveLetter = $disk.DeviceID
}

if ($driveLetter)
{
 Write-Host "Starting the install of SQL Server"
Start-Process $driveLetter\Setup.exe "/ConfigurationFile=$copyFileLocation  /IAcceptSQLServerLicenseTerms" -Wait -RedirectStandardOutput $standardOutputFile -RedirectStandardError $errorOutputFile
}

$standardOutput = Get-Content $standardOutputFile -Delimiter "\r\n"

Write-Host $standardOutput

$errorOutput = Get-Content $errorOutputFile -Delimiter "\r\n"

Write-Host $errorOutput

Write-Host "Dismounting the drive."

Dismount-DiskImage -InputObject $drive

Remove-Item "c:\temp" -Recurse -force




#CHOCOLATEY install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# renew env:PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
choco install -y notepadplusplus  `
	googlechrome  `
	ssms `
	git `
	nuget.commandline `
	dotnet-sdk `
	redis `
	rabbitmq `
	dotnetcore-3.0-runtime `
	dotnet-5.0-aspnetruntime --version=5.0.6 `
	dotnet-runtime	--version=5.0.6 `
	dotnetcore-aspnetruntime --version=3.0.3 `
	dotnet-5.0-desktopruntime --version=5.0.8 `
	dotnet-runtime	--version=5.0.8 `
	dotnetcore-runtime.install --version=3.1.17 `
	dotnetcore	--version=5.0.6 `
	visualstudio2019buildtools  `
	visualstudio2019-workload-netcorebuildtools `
	visualstudio2019-workload-visualstudioextensionbuildtools `
	visualstudio2019-workload-databuildtools  `
	visualstudio2019-workload-nodebuildtools `
	visualstudio2019-workload-universalbuildtools `
	visualstudio2019-workload-webbuildtools `
	nodejs `
	python `
	python2
npm install --global windows-build-tools