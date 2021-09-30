def call(Map config = [:]){
        if (config.release){
	    nugetVersion = (env.build_number)
        }else{
	    nugetVersion = (env.build_number + "-" + config.branch).replace("/","-")
	}
	url = env.nexusBrowse + env.nexusNugetHosted + config.buildname + '%2F' +  "1.0.${nugetVersion}"
	jiraComment issueKey: config.issueKey ,body: """(/)
h1. {color:#00875A}BUILD ${config.buildName} SUCCSESFULL{color}
h2. Jenkins build ${env.BUILD_NUMBER}
[link |${env.BUILD_URL}]
----
h2. Artifact link
[link |${url}]
"""  
}
