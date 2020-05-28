properties([disableConcurrentBuilds()])

pipeline {
  agent any
  options{
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
        timestamps()
  }
  environment{
        github_repo = "github.com/rgsx/ep"
        github_branch = "task5"

        tomcat_path = "/opt/tomcat"
        tomcat_server_name_1 = "tomcat1"
        tomcat_server_name_2 = "tomcat2"
        tomcat_server_port= "8080"
        tomcat_user = "root"
        seconds_to_wait= "3"

        nexus_path = "192.168.56.110:8081"
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

        stage ('deploy'){
            parallel{
                stage('deploy tomcat1'){
                    steps{
                        sh """
                            ssh ${tomcat_user}@${tomcat_server_name_1} \
                            'curl http://${nexus_path}/repository/${nexus_repo_name}/${project_name}/${project_name}/${version}/${project_name}-${version}.war -o /tmp/${project_name}.war ;
                            systemctl stop tomcat.service ;
                            rm -r ${tomcat_path}/webapps/${project_name} ;
                            cp /tmp/${project_name}.war ${tomcat_path}/webapps ;
                            systemctl start tomcat.service'
                        """
                                        }
                            }

                stage('deploy tomcat2'){
                        steps{
                            sh """
                            ssh ${tomcat_user}@${tomcat_server_name_2} \
                            'curl http://${nexus_path}/repository/${nexus_repo_name}/${project_name}/${project_name}/${version}/${project_name}-${version}.war -o /tmp/${project_name}.war ;
                            systemctl stop tomcat.service ;
                            rm -r ${tomcat_path}/webapps/${project_name} ;
                            cp /tmp/${project_name}.war ${tomcat_path}/webapps ;
                            systemctl start tomcat.service'
                            """
                        }
                }
            }
        }

        stage ('test'){
            parallel{
                stage('test deploy tomcat1'){
                    steps{
                        sleep(time:"${seconds_to_wait}",unit:"SECONDS")
                        sh "curl http://${tomcat_server_name_1}:${tomcat_server_port}/${project_name}/ | grep ${version}"
                    }
                }

                stage('test deploy tomcat2'){
                    steps{
                        sleep(time:"${seconds_to_wait}",unit:"SECONDS")
                        sh "curl http://${tomcat_server_name_2}:${tomcat_server_port}/${project_name}/ | grep ${version}"
                    }
                }
            }
        }

        stage ('git push'){
            steps{
                sh """
                    git add .
                    git commit -m version:${version}
                    git checkout master
                    git merge ${github_branch}
                    git tag ${version}
                """
               
                withCredentials([usernamePassword(  credentialsId: 'github',
                                                    usernameVariable: 'username',
                                                    passwordVariable: 'password')
                                ]){
                    sh("git push https://$username:$password@${github_repo} --tags")
                    sh("git push https://$username:$password@${github_repo} --all")
                }
                sh 'ls -A1 | xargs rm -rf'
            }
        }
  }
}
