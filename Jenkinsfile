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
       deploy_ip = "95.216.214.186"
       deploy_port = "80"
       deploy_project = "test"
       
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
      
      stage('Deploying the selected version'){
	steps{
	    script{
                currentBuild.displayName = "Deploying the ${version} version"
	        sh "ansible-playbook -i hosts -e version=${image}:${version} main.yml"
	    }
	}
      }
 
      stage ('Testing a Deploy the selected version:'){
	steps{
               script{ 
                 currentBuild.displayName = "Testing a Deploy the ${version} version."
	         sh "curl http://${deploy_ip}:${deploy_port}/${deploy_project}/ | grep ${version}"
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
