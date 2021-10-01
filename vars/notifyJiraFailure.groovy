def call(Map config  = [:]){
	jiraAddComment idOrKey:config.issueKey ,input : [ body: """(x)
h1. {color:#FF0000}BUILD ${config.buildName} FAILURE{color}
h2. Jenkins build ${env.BUILD_NUMBER}
[link |${env.BUILD_url}]
----
"""    ]
}
