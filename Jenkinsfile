pipeline {
    agent none
    stages {
        stage('container') {
            agent {
                dockerfile {
                    args '-v ${HOME}/.m2:/home/builder/.m2 -v ${HOME}/.grails:/home/builder/.grails'
                    additionalBuildArgs '--build-arg BUILDER_UID=$(id -u)'
                }
            }
            stages {
                stage('set_version') {
                    when { not { branch "angus_test" } }
                    steps {
                        sh 'echo ${GIT_COMMITTER_NAME}'
                        sh './bumpversion.sh build'
                    }
                }
                stage('release') {
                    when { branch 'angus_test' }
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'github-ci', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                            sh './bumpversion.sh release'
                        }
                    }
                }
                stage('grails_clean') {
                    steps {
                        sh 'grails -DARTIFACT_BUILD_NUMBER=${BUILD_NUMBER} -Dgrails.work.dir=${WORKSPACE}//target clean --non-interactive --plain-output'
                    }
                }
                stage('test') {
                    steps {
                        sh 'grails -DARTIFACT_BUILD_NUMBER=${BUILD_NUMBER} -Dgrails.work.dir=${WORKSPACE}//target test-app --non-interactive --plain-output'
                    }
                }
                stage('package') {
                    steps {
                        sh 'grails -DARTIFACT_BUILD_NUMBER=${BUILD_NUMBER} -Dgrails.work.dir=${WORKSPACE}//target prod war --non-interactive --plain-output'
                    }

                }
            }
            post {
                success {
                    archiveArtifacts artifacts: '**/*.war', fingerprint: true, onlyIfSuccessful: true
                }
            }
        }
    }
}
