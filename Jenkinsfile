properties([disableConcurrentBuilds()])

pipeline {
  agent any
  options{
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
  }
  environment{
        github_repo = "github.com/rgsx/ep"
        github_branch = "task6"

        docker_replicas = "1"
		docker_port_target = "8080"
 		docker_port_published = "10000"
	    docker_ip = "192.168.56.110"			
        
		
    
        nexus_path = "95.217.238.44:8083"
		docker_registry = "95.217.238.44:15000"
        nexus_repo_name = "snapshots"
        file_path = "build/libs/test.war"
        project_name = "test"
        version = ""
  }

  stages {
        stage ('git checkout'){
            steps{
                sh 'ls -A1 | xargs rm -rf'
                git branch: "${github_branch}",
                            changelog: false,
                            credentialsId: 'github',
                            poll: false,
                            url: "https://${github_repo}"
            }
        }

        stage ('build'){
            steps{
                sh 'gradle clean'
                sh 'gradle incrementVersion'
                sh 'gradle build'
                    }
        }

        stage ('get current version'){
            steps{
                    script{
                        version = sh(script: 'cat build/resources/main/greeting.txt', , returnStdout: true).trim()
                    }
                }
        }

        stage ('upload_to_nexus'){
            steps{
                nexusArtifactUploader artifacts: [[
                    artifactId: "${project_name}",
                    classifier: '',
                    file: "${file_path}",
                    type: 'war'
                ]],
                credentialsId: 'Nexus',
                groupId: "${project_name}",
                nexusUrl: "${nexus_path}",
                nexusVersion: 'nexus3',
                protocol: 'http',
                repository: "${nexus_repo_name}",
                version: "${version}"
            }
          }
		  
		stage ('build docker-image'){
			steps{
				sh "docker build . -t ${docker_registry}/${github_branch}:${version} --build-arg WAR_NAME=${project_name}.war --build-arg WAR_LINK=http://${nexus_path}/repository/${nexus_repo_name}/${project_name}/${project_name}/${version}/${project_name}-${version}.war"
				sh "docker push ${docker_registry}/${github_branch}:${version}"
			}
		}
		
		stage('update docker service') {
			when {
				expression {
					return sh(script: "docker service ls --quiet  --filter name=${github_branch}", returnStdout: true).trim() != "";
				}
			}
			steps {
				sh "docker service update  --replicas ${docker_replicas} --image ${docker_registry}/${github_branch}:${version} ${github_branch}"
			}
		}
		
		stage('start docker service') 
		{
			when {
				expression {
					return sh(script: "docker service ls --quiet  --filter name=${github_branch}", returnStdout: true).trim() == "";
				}
			}
    		steps {
				sh "docker service create --name ${github_branch} --replicas ${docker_replicas} --publish ${docker_port_published}:${docker_port_target} ${docker_registry}/${github_branch}:${version}"
				
			}
		}
      
		
		
		stage ('test docker-image'){
			steps{
				sh "curl http://${docker_ip}:${docker_port_published}/${project_name}/ | grep ${version}"
			}
		}

        stage ('git push'){
            steps{
                sh """
                    git add .
                    git commit -m version:${version}
                   # git checkout master
                   # git merge ${github_branch}
                   # git tag ${version}
                """

                withCredentials([usernamePassword(  credentialsId: 'github',
                                                    usernameVariable: 'username',
                                                    passwordVariable: 'password')
                                ]){
                 //   sh("git push https://$username:$password@${github_repo} --tags")
                   sh("git push https://$username:$password@${github_repo} ${github_branch}")
                }
                sh 'ls -A1 | xargs rm -rf'
            }
        }
  }
}
