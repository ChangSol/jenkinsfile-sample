pipeline {
    agent any
    
    // 환경 설정 정의
    environment {
        projectName="${JOB_NAME}"
        buildNumber="${BUILD_NUMBER}"
        buildUrl="${BUILD_URL}"

        deployFile="../${projectName}-prd-deploy.sh"

        // 원격지정보
        remoteUser='ubuntu'
        remoteHost='0.0.0.0'
        remoteHost2='0.0.0.0'
        remoteDir='/home/ubuntu/sample'

        sshCredentialsId='Sample.pem' // 원격지 credentialsId

        mailFrom='ckdwnsla12@gmail.com'
        mailTo='ckdwnsla12@gmail.com'
    }
    
    // 파이프라인 옵션 정의
    options { 
        timestamps() // 각 빌드 단계의 시작 시간을 기록
        parallelsAlwaysFailFast() // 병렬 빌드 중 하나가 실패하면 나머지 병렬 빌드를 즉시 중지
        disableConcurrentBuilds() // 파이프 라인의 동시 실행을 허용하지 않는다
    }
    
    // 빌드 도구 정의
    tools {
        gradle 'GRADLE_7_2' // 빌드시 사용 할 Gradle
    }
    
    stages {
         stage('Deploy File Keep Move') {
            steps {
              sh 'chmod +x ./prd-deploy.sh'
              sh "mv ./prd-deploy.sh ${deployFile}"
            }
        }

        stage('Print Environment Variables') {
            steps {
                script {
                    sh 'printenv'
                }
            }
        }

        stage('Git Checkout') {
            steps {
                git credentialsId: 'git_jenkins',
                    url: 'https://github.com/ChangSol/sample.git',
                    branch: 'prd'
            }
        }

        stage('Build') {
            steps {
//                 sh 'chmod +x gradlew'
//                 sh 'gradlew clean build'
              sh 'gradle clean build' // jenkins tools gradle 사용
            }
        }

//         stage('Test') {
//             steps {
//                 echo 'Running tests...'
//                 // Running unit tests
//                 // sh 'mvn test'
//             }
//         }

        stage('Approval') {
            steps {
                script {
                    // email notification
                    def title = "[Jenkins CI/CD] ${projectName} - Deploy - Approval"

                    def body = """
                        <p>Hello,</p>
                        <p>Please review and approve the deployment for ${projectName}.</p>
                        <p>Build Number: ${buildNumber}</p>
                        <p>Thank you!</p>
                    """

                    emailext subject: title,
                             body: body,
                             from: "${mailFrom}",
                             to: "${mailTo}",
                             mimeType: 'text/html'

                    // approve input
                    def input = input id: 'userInput',
                            message: 'Deploy to production?',
                            submitterParameter: 'submitter',
                            submitter: 'admin',
                            parameters: [
                                    [$class: 'TextParameterDefinition', defaultValue: '', description: 'Reason for distribution', name: 'reason']
                            ]

                    echo "reason : " + input['reason']
                    echo "submitted by : " + input['submitter']
                }
            }
        }

        stage('Deploy-1') {
            steps {
                script {
                    def timestamp = new Date().format('yyyyMMddHHmmss')
                    sshagent (credentials: [sshCredentialsId]) {
                      sh "ssh ${remoteUser}@${remoteHost} 'mv ${remoteDir}/jenkins-sample-*.jar ${remoteDir}/baks/jenkins-sample.jar.${timestamp}'"
                      sh "scp ./build/libs/jenkins-sample-*.jar ${remoteUser}@${remoteHost}:${remoteDir}/jenkins-sample.jar"
                      sh "scp ${deployFile} ${remoteUser}@${remoteHost}:${remoteDir}/deploy.sh"

                      sh "ssh ${remoteUser}@${remoteHost} 'bash ${remoteDir}/deploy.sh'"

                      sh "ssh ${remoteUser}@${remoteHost} 'rm ${remoteDir}/deploy.sh'"
                    }
                }
            }
        }

        stage('Deploy-2') {
            steps {
                script {
                    def timestamp = new Date().format('yyyyMMddHHmmss')
                    sshagent (credentials: [sshCredentialsId]) {
                      sh "ssh ${remoteUser}@${remoteHost2} 'mv ${remoteDir}/jenkins-sample-*.jar ${remoteDir}/baks/jenkins-sample.jar.${timestamp}'"
                      sh "scp ./build/libs/jenkins-sample-*.jar ${remoteUser}@${remoteHost2}:${remoteDir}/jenkins-sample.jar"
                      sh "scp ${deployFile} ${remoteUser}@${remoteHost2}:${remoteDir}/deploy.sh"

                      sh "ssh ${remoteUser}@${remoteHost2} 'bash ${remoteDir}/deploy.sh'"

                      sh "ssh ${remoteUser}@${remoteHost2} 'rm ${remoteDir}/deploy.sh'"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh "rm -rf ${deployFile}"
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
            script {
                // email notification
                def title = "[Jenkins CI/CD] ${projectName} - Deploy Success"

                def body = """
                    <p>Hello,</p>
                    <p>Build Number: ${buildNumber}</p>
                    <p>Deployment has completed successfully for ${projectName}.</p>
                    <p>Thank you!</p>
                """

                emailext subject: title,
                         body: body,
                         from: "${mailFrom}",
                         to: "${mailTo}",
                         mimeType: 'text/html'
            }
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
            script {
                // email notification
                def title = "[Jenkins CI/CD] ${projectName} - Deploy Fail"

                def body = """
                    <p>Hello,</p>
                    <p>Build Number: ${buildNumber}</p>
                    <p>Deployment has completed failed for ${projectName}.</p>
                    <p>Please check the logs.</p>
                """

                emailext subject: title,
                         body: body,
                         from: "${mailFrom}",
                         to: "${mailTo}",
                         mimeType: 'text/html'
            }
        }
    }
}