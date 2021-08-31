def call(Map config = [:]) {
  branchList = readFile ( file:"${env.workspace}/${config.txtFile}", encoding: "UTF-8")
  echo "please click on the link here to chose the branch to build"
  branch = input message: 'Please choose the branch to build ', ok: 'Build!',
      parameters: [choice (name: 'BRANCH_NAME', choices: "${branchList}", description: "Total branches:${config.branchCount}. Choose branch to build")]
  branch = branch.replaceAll("[\\s ,\\p{Z}, \\p{C}]+", "").trim().replaceAll("\\s","")
  if((branch ==~ env.BRANCH_REGEX )||(branch in config.defaultBranches)){
  	echo "valid branch naming ${branch} "
  }else{			
  	echo "invalid branch naming ${branch} BUILD WILL BE FAILED IN POST!"
  }
  return branch
}
