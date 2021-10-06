def call(Map config = [:]){
        commentBody = """{panel}
(/) {color:#00875A}+_Build *${config.buildName}* completed successfully_+{color}
----"""
	artifactUrl= 'Artifacts in Nexus Repository:<br>'
	for (url in config.browseUrl){
	   link = """
[Artifact link |${env.nexusBrowse}${url}]
"""
	   	
           currentBuild.description = currentBuild.description + "<a href=${env.nexusBrowse}${url}>Nexus Artifact </a> <br>"
	   artifactUrl = artifactUrl + "<a href=${env.nexusBrowse}${url}>Nexus Artifact </a> <br>"
           commentBody = commentBody.concat(link).concat("{panel}")

	}
	jiraAddComment idOrKey: config.issueKey , input: [ body: commentBody]
	writeFile file: 'link.html', text: artifactUrl
	archiveArtifacts allowEmptyArchive: true, artifacts: 'link.html', caseSensitive: false, followSymlinks: false
}
