def call(Map config = [:]){
        commentBody = """(/)
h1. {color:#00875A}BUILD ${config.buildName} SUCCSESFULL{color}
h2. Jenkins build ${env.BUILD_NUMBER}
[link |${env.BUILD_URL}]
"""
	for (url in config.browseUrl){
	   link = """----
h2. Artifact link
[link |${env.nexusBrowse}${url}]
"""
           commentBody = commentBody.concat(link)
	   println link
	}
	println commentBody
	jiraAddComment idOrKey: config.issueKey , input: [ body: commentBody]
}
