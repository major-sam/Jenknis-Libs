def call(Map config = [:]){
        if (config.release){
	    nugetVersion = (env.build_number)
        }else{
	    nugetVersion = (env.build_number + "-" +config.branch).replace("/","-")
	}
	jiraComment issueKey: config.issueKey ,body: """(/)
h1. {color:#00875A}BUILD ${config.buildName} SUCCSESFULL{color}
h2. Jenkins build ${env.BUILD_NUMBER}
[link |${env.BUILD_URL}]
----
h2. Nuget artifact
[link |${config.nugetRepo}packages/${config.buildName}/1.0.${nugetVersion}]
"""  
}
