properties([disableConcurrentBuilds()])

pipeline {
  agent any
  
  options{
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
  }
   
   environment{
       image = "task6"
       url = "http://95.217.182.68:15000/v2/${image}/tags/list"
       version = ""
   }

   stages {
      stage('Select Version') {
         steps {
           script{
		def list = getDockerImageTags(url)
		list = sortReverse(list)
		def versions = list.join("\n")
		version = input(
				    id: 'userInput', message: 'Select version:', parameters: [
				    [$class: 'ChoiceParameterDefinition', choices: versions, description: 'Versions', name: 'version']
				    ]    
				)
            }
         }
      }
      
      stage('Deploy the selected Version'){
	steps{
	    script{
	        sh "echo ansible-playbook -i hosts -e version=${image}:${version} main.yml"
	    }
	}
      }
   }
}

@NonCPS
def sortReverse(list) {
    list.reverse()
}

def getDockerImageTags(url) {
    def myjson = getUrl(url)
    def json = jsonParse(myjson);
    def tags = json.tags
    tags
}

def jsonParse(json) {
    new groovy.json.JsonSlurper().parseText(json)
}

def getUrl(url) {
    sh(returnStdout: true, script: "curl -s ${url} 2>&1 | tee result.json")
    def data = readFile('result.json').trim()
    data
}
