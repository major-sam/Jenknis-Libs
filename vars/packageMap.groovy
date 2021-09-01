def packageMap = {
   KRM:{
    name: "KRM SITE UNIRU"
    type: "IISSite"
    db: {
      dbName:"UniRu"
      backupFilePath: "fullFile.bak"
      dbFiles: false
      initScripts: "folderPath"
      }
    params: {
      siteName:"UniRu"
      bindings:[
        {
          proto: "https"
          port: 4443
          cert: "bb-webapps.com.cer"
          }
      envScripts: "folderPath"
      ]
    }
   }
   KRM:{
    name: "KRM SITE UNIRU"
    type: "IISSite"
    db: {
      dbName:"UniRu"
      backupFilePath: "fullFile.bak"
      dbFiles: false
      initScripts: "folderPath"
      }
    params: {
      siteName:"UniRu"
      bindings:[
        {
          proto: "https"
          port: 4443
          cert: "bb-webapps.com.cer"
          }
      envScripts: "folderPath"
      ]
    }
   }
   Kernel:{
    name: "Kernel"
    type: "Service"
    db: {
      dbName:"BaltBetM"
      backupFilePath: "fullFile.bak"
      dbFiles: {
        dataFiles:["BaltBetM","CoefFileGroup"]
        logFiles:["BaltBet"]
        }
      initScripts: "folderPath"
      }
    params: {
      path: "\\"
      envScripts: "folderPath"
    }
   }
   KernelWeb:{
    name: "KernelWeb"
    type: "Service"
    db: false 
    params: {
      path: "\\"
      envScripts: "folderPath"
    }
   }
}
call(name){
  return packageMap.name
}
