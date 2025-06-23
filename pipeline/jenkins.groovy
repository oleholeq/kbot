pipeline {
    agent any

    parameters {
        choice(
            name: 'OS',
            choices: ['linux', 'darwin', 'windows'],
            description: 'Target operating system'
        )
        choice(
            name: 'ARCH',
            choices: ['amd64', 'arm64'],
            description: 'Target architecture'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip running tests'
        )
        booleanParam(
            name: 'SKIP_LINT',
            defaultValue: false,
            description: 'Skip running linter'
        )
    }

    environment {
        TARGETOS = "${params.TARGETOS}"
        TARGETARCH = "${params.TARGETARCH}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Lint') {
            when {
                expression { return !params.SKIP_LINT }
            }
            steps {
                sh 'echo "Running linter..."'
                sh 'make lint'
            }
        }

        stage('Test') {
            when {
                expression { return !params.SKIP_TESTS }
            }
            steps {
                sh 'echo "Running tests..."'
                sh 'make test' 
            }
        }

        stage('Build') {
            steps {
                sh 'echo "Building for $TARGETOS/$TARGETARCH..."'
                sh 'make build TARGETOS=$TARGETOS TARGETARCH=$TARGETARCH'
            }
        }
    }
}