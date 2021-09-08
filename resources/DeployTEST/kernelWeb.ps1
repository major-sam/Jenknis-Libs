# vars
$targetDir = 'C:\KernelWeb'
$sourceDir = "$env:nugettemp\KernelWeb"
$CurrentIpAddr =(Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias Ethernet).IPAddress.trim()
$transformFiles = @("$targetDir\settings.OctopusTestVM.xml","$targetDir\App.OctopusTestVM.config")

$FILES= @(
      @{
        transf = "$targetDir\App.OctopusTestVM.config"
        target = "$targetDir\KernelWeb.exe.config"
      }
      @{
        transf = "$targetDir\settings.OctopusTestVM.xml"
        target = "$targetDir\settings.xml"
      }
)
###  side functions 

function Format-Json {
    <#
    .SYNOPSIS
        Prettifies JSON output.
    .DESCRIPTION
        Reformats a JSON string so the output looks better than what ConvertTo-Json outputs.
    .PARAMETER Json
        Required: [string] The JSON text to prettify.
    .PARAMETER Minify
        Optional: Returns the json string compressed.
    .PARAMETER Indentation
        Optional: The number of spaces (1..1024) to use for indentation. Defaults to 4.
    .PARAMETER AsArray
        Optional: If set, the output will be in the form of a string array, otherwise a single string is output.
    .EXAMPLE
        $json | ConvertTo-Json  | Format-Json -Indentation 2
    #>
    [CmdletBinding(DefaultParameterSetName = 'Prettify')]
    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Json,

        [Parameter(ParameterSetName = 'Minify')]
        [switch]$Minify,

        [Parameter(ParameterSetName = 'Prettify')]
        [ValidateRange(1, 1024)]
        [int]$Indentation = 4,

        [Parameter(ParameterSetName = 'Prettify')]
        [switch]$AsArray
    )

    if ($PSCmdlet.ParameterSetName -eq 'Minify') {
        return ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 -Compress
    }

    # If the input JSON text has been created with ConvertTo-Json -Compress
    # then we first need to reconvert it without compression
    if ($Json -notmatch '\r?\n') {
        $Json = ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100
    }

    $indent = 0
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)'

    $result = $Json -split '\r?\n' |
        ForEach-Object {
            # If the line contains a ] or } character, 
            # we need to decrement the indentation level unless it is inside quotes.
            if ($_ -match "[}\]]$regexUnlessQuoted") {
                $indent = [Math]::Max($indent - $Indentation, 0)
            }

            # Replace all colon-space combinations by ": " unless it is inside quotes.
            $line = (' ' * $indent) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ')

            # If the line contains a [ or { character, 
            # we need to increment the indentation level unless it is inside quotes.
            if ($_ -match "[\{\[]$regexUnlessQuoted") {
                $indent += $Indentation
            }

            $line
        }

    if ($AsArray) { return $result }
    return $result -Join [Environment]::NewLine
}

function XmlDocTransform($xml, $xdt){
    
    if (!$xml -or !(Test-Path -path $xml -PathType Leaf)) {
        throw "File not found. $xml";
    }
    if (!$xdt -or !(Test-Path -path $xdt -PathType Leaf)) {
        throw "File not found. $xdt";
    }

    #$scriptPath = (Get-Variable MyInvocation -Scope 1).Value.InvocationName | split-path -parent
    Add-Type -LiteralPath "C:\temp\Microsoft.Web.XmlTransform.dll"

    $xmldoc = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument;
    $xmldoc.PreserveWhitespace = $true
    $xmldoc.Load($xml);

    $transf = New-Object Microsoft.Web.XmlTransform.XmlTransformation($xdt);
    if ($transf.Apply($xmldoc) -eq $false)
    {
        throw "Transformation failed."
    }
    $xmldoc.Save($xml);
}


### copy files

write-host "Copy-Item -Path "$sourceDir"  -Destination $targetDir -Recurse -Exclude "*.nupkg" -verbouse"
Copy-Item -Path "$sourceDir"  -Destination $targetDir -Recurse -Exclude "*.nupkg" 


### set vm related values for transformation files

##### raw replace
foreach($transformFile in $transformFiles){
    (Get-Content -Encoding UTF8 $transformFile) | Foreach-Object {
        $_ -replace '#{VM[#{VMName}].ServerIp}',  $CurrentIpAddr `
           -replace '#{KernelWeb_apconf_AddressSlotService}', 'localhost'`
           -replace '#{KernelWeb_apconf_CertSubjectName}', 'VM1APKTEST-P0.gkbaltbet.local' 
        } | Set-Content -Encoding UTF8 $transformFile
        Write-Host -ForegroundColor Green "$transformFile renewed"
    }


##### apply xml transformation
foreach($item in $FILES){
 try{
    XmlDocTransform -xml $item.target -xdt  $item.transf
    Write-Host -ForegroundColor Green " $item.target renewed with transformation $item.transf"}
 catch{
 
    Write-Host -ForegroundColor Red " $item.target FAIL renew with transformation $item.transf"}
}
