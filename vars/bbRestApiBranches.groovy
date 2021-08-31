def call(Map config = [:]) {
   withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: config.creds, usernameVariable: 'username', passwordVariable: 'password']]) {
     powershell ( encoding: 'UTF8', script:"""
       \$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "$username","$password")))
       \$requestHeaders = @{
         "content-length" = 0
         "Authorization" = ('Basic {0}' -f \$base64AuthInfo)
       }
       \$endpointUri = '$config.branchListUrl'
       \$json = Invoke-RestMethod -Method get -Uri \$endpointUri -Headers \$requestHeaders -ContentType "application/json"
       \$json.values.displayId | Sort-Object | set-content -Encoding "utf8" $config.txtFile
     """)
     lst =(powershell ( encoding: 'UTF8', returnStdout: 'true', script:"""
       \$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "$username","$password")))
       \$requestHeaders = @{
         "content-length" = 0
         "Authorization" = ('Basic {0}' -f \$base64AuthInfo)
       }
       \$endpointUri = '$config.branchListUrl'
       \$json = Invoke-RestMethod -Method get -Uri \$endpointUri -Headers \$requestHeaders -ContentType "application/json"
       \$defaultBranch = \$json.values | where { \$_.isDefault -eq "true" } 
       \$branch = \$defaultBranch.displayId.trim()
       \$size = \$json.size
       return ("\$size,\$branch")
     """)).split(',')
    return [ branchCount:lst[0], defaultBranch:(lst[1]).trim().toString().replaceAll("\\s","") ]
    }
}
