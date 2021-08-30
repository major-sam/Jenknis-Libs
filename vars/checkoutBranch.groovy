def call(Map config = [:]){
  echo ("Это костыльный шаг - вложенный чекаут для выбранной ранее ветки. Следует пулить всю ветку с Jenkinsfile  и параметрзовать сборку от типа ветки")
  echo "You choose ${config.BRANCH} branch, checkout"
  BRANCH = config.BRANCH.trim().toString().replaceAll("\\s","")
  env.DEFAULT_BRANCH = env.DEFAULT_BRANCH.trim().toString().replaceAll("\\s","")
  withCredentials([gitUsernamePassword(credentialsId: config.creds)]) {
  	if (BRANCH.contains (env.DEFAULT_BRANCH)) {
    	  powershell ( encoding:"UTF8", script: "git clone ${config.GIT_URL} ${config.CLONE_FOLDER}")
  	}
  	else {
  	  powershell ( encoding:"UTF8", script: "git clone --single-branch --branch ${config.BRANCH} ${config.GIT_URL} ${config.CLONE_FOLDER}")
  	}
  }
}
