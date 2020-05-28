pipeline {
  agent any

  stages {
        stage ('git checkout'){
            steps{
                git branch: 'task5', changelog: false, credentialsId: 'github', poll: false, url: 'https://github.com/rgsx/t5_test'
            }
        }
        stage ('build'){
            steps{
             sh 'echo "stage build"'
             sh 'gradle clean'
             sh 'gradle incrementVersion'
             sh 'gradle build'
            }
        }
         
        stage ('upload_to_nexus'){
            
            environment{
                version = sh(script: 'cat build/resources/main/greeting.txt', , returnStdout: true).trim()
            }
            
			steps{
			    sh 'echo "stage upload"'
				nexusArtifactUploader artifacts: [[artifactId: 'test', classifier: '', file: 'build/libs/test.war', type: 'war']], credentialsId: 'Nexus', groupId: 'test', nexusUrl: '10.0.0.27:8082', nexusVersion: 'nexus3', protocol: 'http', repository: 'snapshots', version: "${version}" 
            }
          }
          
		stage('ssh connect'){
		    environment{
                version = sh(script: 'cat build/resources/main/greeting.txt', , returnStdout: true).trim()
            }
            steps{
                sh """
                ssh root@tomcat1 \
                    'curl http://192.168.56.110:8081/repository/snapshots/test/test/${version}/test-${version}.war -o /tmp/test.war ; 
                    systemctl stop tomcat.service ; 
                    rm -r /opt/tomcat/webapps/test ;  
                    cp /tmp/test.war /opt/tomcat/webapps ; 
                    systemctl start tomcat.service'
               """
            }
        }
        
        stage('test deploy'){
            environment{
                version = sh(script: 'cat build/resources/main/greeting.txt', , returnStdout: true).trim()
            }
            steps{
                sleep(time:3,unit:"SECONDS")
                sh 'curl http://tomcat1:8080/test/ | grep "${version}"'
            }
        }
        
		stage ('git push'){
		    
		    environment{
                version = sh(script: 'cat build/resources/main/greeting.txt', , returnStdout: true).trim()
            }
            
         	steps{
				sh '''
				git add gradle.properties
			    git commit -m version:"${version}"
			    git checkout master
			    git merge task5
			    git tag ${version}
			    '''
			   sh 'echo "stage push"'	
				withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'username', passwordVariable: 'password')]){
                                    sh("git push https://$username:$password@github.com/rgsx/t5_test --tags")
									sh("git push https://$username:$password@github.com/rgsx/t5_test --all")
                }
                sh 'ls -A1 | xargs rm -rf'
            }
          }
  }
}
