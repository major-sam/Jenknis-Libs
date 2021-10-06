def call(Map config = [:]){          
        echo "Build must be manualy enabled in Jira>Manage Apps>Jenkins Integration>Manage Sites>Jenkins>Search Job>${config.job} "
        step([$class: 'DeploymentBuildMarker', environmentType: 'production' , environmentName: 'testing'])
        println config.branch
        if (!((config.branch ==~ env.BRANCH_REGEX )||(config.branch in config.default_branches))){
          catchError(message: "Invalid branch naming ${config.branch}. NO NUGET PUSH, NO JIRA PUSH", buildResult: 'UNSTABLE', stageResult: 'UNSTABLE'){
		error ("Invalid branch naming ${config.branch}. NO NUGET PUSH, NO JIRA PUSH")  }
        }  
	dir("${workspace}@tmp") {
          deleteDir()
        }
      }	
