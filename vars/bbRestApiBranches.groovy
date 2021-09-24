
import groovy.json.JsonSlurperClassic

def call(Map config = [:]) {
   withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: config.creds, usernameVariable: 'username', passwordVariable: 'password']]) {
    if (isUnix()) {
      def uname = sh script: 'uname', returnStdout: true
      if (uname.startsWith("Darwin")) {
          return "Macos not supporting"
      }
      // Optionally add 'else if' for other Unix OS  
      else {
         sh script: "set +o history"
         def response 
         timeout(30){
            waitUntil {
                response =  sh script: "curl -u ${username}:${password} -o ${env.workspace}/temp.json ${config.branchListUrl}", returnStatus: true
                return (response == 0)
            }
         }
         if (response != 0 ){
            build.result = 'ERROR'
         }
         sleep(2)
         def json = sh script: "cat ${env.workspace}/temp.json", returnStdout: true
         scriptMap = new JsonSlurperClassic().parseText(json)
         writeFile file: config.txtFile, text:scriptMap.values*.displayId.sort().join('\r\n')
         def bCount = scriptMap['size']
         def dBranch = scriptMap.values.find{ map -> map.isDefault == true}.displayId
         sh script: "set -o history"
         return [ branchCount:bCount, defaultBranch:dBranch]
      }
    }
    else {
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
}
