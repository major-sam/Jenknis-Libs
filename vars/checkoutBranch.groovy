def call(Map config = [:]){
  echo ("Это костыльный шаг - вложенный чекаут для выбранной ранее ветки. Следует пулить всю ветку с Jenkinsfile  ")
  echo "You choose ${config.branch} branch, checkout"
  withCredentials([gitUsernamePassword(credentialsId: config.creds)]) {
  	if (config.branch.contains (config.defaultBranch)) {
          powershell ( encoding:"UTF8", script: "git clone ${config.gitUrl} ${config.cloneFolder}")
  	}
  	else {
          powershell ( encoding:"UTF8", script: "git clone --single-branch --branch ${config.branch} ${config.gitUrl} ${config.cloneFolder}")
  	}
  }
}
