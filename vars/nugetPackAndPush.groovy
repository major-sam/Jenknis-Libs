def call(Map config = [:]){				
// INTENDED FOR TESTS ONLY
// INTENDED FOR TESTS ONLY
	taglist = ['NWP-147','NWP-145','NWP-133','NWP-108','NWP-144','NWP-143']
	Collections.shuffle(taglist)
	testTag = taglist.first() + " " + taglist.last()
// INTENDED FOR TESTS ONLY
// INTENDED FOR TESTS ONLY
        if (config.release){
	    nugetVersion = (env.build_number)
        }else{
	    nugetVersion = (env.build_number + "-" + config.branch).replace("/","-")
	}
	commitMsg = (powershell ( encoding:"UTF8", returnStdout: 'true', script:"git log -1 --pretty=%B | ? {\$_.trim() -ne ''}")).trim()
	commitHash = (powershell ( encoding:"UTF8", returnStdout: 'true', script:"git log -1 --pretty=%H | ? {\$_.trim() -ne ''}")).trim()
	build_trigger_by = ("${currentBuild.getBuildCauses ()[0].shortDescription} / ${currentBuild.getBuildCauses ()[0].userId}").replace("Started by user ","").replace("\\s*","\\")
	dir (config.dir){
		writeFile ( file: "nuget.nuspec", encoding:"UTF8", text: """<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
  <metadata>
	<id>${config.buildname}</id>
	<version>1.0.${nugetVersion}</version>
	<description>
	  ${commitMsg}. 
	  Git hash: ${commitHash}
	</description>
	<authors>${build_trigger_by} by jenkins</authors>
	<repository type="git" url="${config.git_url}" branch="${config.branch}" commit="${commitHash}" />
		<frameworkAssemblies>
	  <frameworkAssembly assemblyName="System.Web" targetFramework="net40" />
	  <frameworkAssembly assemblyName="System.Net" targetFramework="netcoreapp3.1" />
	</frameworkAssemblies>
	<tags>${config.branch} ${commitHash} ${config.issue} ${testTag}</tags>
  </metadata>
</package>""")
		powershell ( encoding:"UTF8", script:"nuget pack")
		if(( config.branch ==~ env.BRANCH_REGEX )||( config.branch in config.default_branches)){
			powershell ( encoding:"UTF8", script:"nuget push *.nupkg -Source ${config.nuget_repo} -ApiKey ${env.NuggetGalleryApiKey}")
			url = 'https://dev-comp49/packages/' +  config.buildname + '/' +  "1.0.${nugetVersion}"
			currentBuild.description = currentBuild.description + "<br>${config.buildname}"+' <a href="' +url + '">link</a>  to artifact in nuget gallery'
		}else{
			currentBuild.description = currentBuild.description + "<br>BUILD FAILED"
			catchError(message: "Invalid branch naming ${config.branch}. NO NUGET PUSH, NO JIRA PUSH", buildResult: 'UNSTABLE', stageResult: 'UNSTABLE'){
			error ("Invalid branch naming ${config.branch}. NO NUGET PUSH, NO JIRA PUSH")  }
		}
	}
}
