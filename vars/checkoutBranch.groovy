def call(Map config = [:]){
  echo ("Это костыльный шаг - вложенный чекаут для выбранной ранее ветки. Следует пулить всю ветку с Jenkinsfile  ")
  echo "You choose ${config.branch} branch, checkout"
  withCredentials([gitUsernamePassword(credentialsId: config.creds)]) {
    if (isUnix()) {
      def uname = sh script: 'uname', returnStdout: true
      if (uname.startsWith("Darwin")) {
          return "Macos not supporting"
      }
      // Optionally add 'else if' for other Unix OS  
      else {
         sh script: "set +o history"
         sh script: "git clone --single-branch --branch ${config.branch} ${config.gitUrl} ${config.cloneFolder}"
         sh script: "set -o history"
         return [ branchCount:bCount, defaultBranch:dBranch]
      }
    }
    else {
  	if (config.branch.contains (config.defaultBranch)) {
          powershell ( encoding:"UTF8", script: "git clone ${config.gitUrl} ${config.cloneFolder}")
  	}
  	else {
          powershell ( encoding:"UTF8", script: "git clone --single-branch --branch ${config.branch} ${config.gitUrl} ${config.cloneFolder}")
  	}
    }
  }
}
