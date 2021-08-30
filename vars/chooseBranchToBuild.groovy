def call(Map config = [:]) {
  branchList = readFile ( file:"${env.workspace}/${config.txtFile}", encoding: "UTF-8")
  echo "please click on the link here to chose the branch to build"
  BRANCH = input message: 'Please choose the branch to build ', ok: 'Build!',
      parameters: [choice (name: 'BRANCH_NAME', choices: "${branchList}", description: 'Branch to build?')]
  BRANCH = BRANCH.replaceAll("[\\s ,\\p{Z}, \\p{C}]+", "").trim()
  if((BRANCH ==~ env.BRANCH_REGEX )||(BRANCH in env.DEFAULT_BRANCHES)){
  	echo "valid branch naming ${BRANCH} "
  }else{			
  	echo "invalid branch naming ${BRANCH} BUILD WILL BE FAILED IN POST!"
  }
  return BRANCH
}
