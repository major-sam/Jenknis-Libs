def call(Map config [:]){
	jiraComment issueKey:issueKey ,body: """(x)
h1. {color:#FF0000}BUILD ${buildname} FAILURE{color}
h2. Jenkins build ${env.BUILD_NUMBER}
[link |${env.BUILD_url}]
----
"""    
}
