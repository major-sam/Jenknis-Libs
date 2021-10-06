def call(Map config  = [:]){
	jiraAddComment idOrKey:config.issueKey ,input : [ body: """{panel}
	(x){color:#FF0000}BUILD *${config.buildName}* failed{color}
{panel}"""    ]
}
