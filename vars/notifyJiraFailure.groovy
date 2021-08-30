def call(Map config  = [:]){
	jiraComment issueKey:config.issueKey ,body: """(x)
h1. {color:#FF0000}BUILD ${config.buildName} FAILURE{color}
h2. Jenkins build ${env.BUILD_NUMBER}
[link |${env.BUILD_url}]
----
"""    
}
