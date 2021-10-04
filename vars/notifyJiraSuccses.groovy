def call(Map config = [:]){
        commentBody = """(/)
h1. {color:#00875A}BUILD ${config.buildName} SUCCSESFULL{color}
h2. Jenkins build ${env.BUILD_NUMBER}
[link |${env.BUILD_URL}]
"""
	artifactUrl= 'Artifacts in Nexus Repository:<br>'
	for (url in config.browseUrl){
	   link = """----
h2. Artifact link
[link |${env.nexusBrowse}${url}]
"""
	   	
           currentBuild.description = currentBuild.description + "<a href=${env.nexusBrowse}${url}>Nexus Artifact</a> <br>"
	   artifactUrl = artifactUrl + "<a href=${env.nexusBrowse}${url}>Nexus Artifact</a> <br>"
           commentBody = commentBody.concat(link)

	}
	jiraAddComment idOrKey: config.issueKey , input: [ body: commentBody]
	writeFile file: 'link.html', text: artifactUrl
	archiveArtifacts allowEmptyArchive: true, artifacts: 'link.html', caseSensitive: false, followSymlinks: false
}
