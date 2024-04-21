#!/usr/bin/env bash
# Author: pra_m

set -e

function generateModule() {
	MODULE_NAME=${1}
	echo "Generating module: ${MODULE_NAME}..."

	groupName=$(grep "groupName" gradle.properties | cut -d'=' -f2 | tr '.' '/')
	artifactName=$(pwd | rev | cut -d'/' -f1 | rev)
	artifactName="$(echo ${artifactName,,} | tr -d '[\-\_\ ]')"
	mkdir -p ${WORK_DIR}/${MODULE_NAME}/src/{main,test}/{java,resources}
	mkdir -p ${WORK_DIR}/${MODULE_NAME}/src/{main,test}/java/${groupName}/${artifactName}/"$(echo ${MODULE_NAME,,} | tr -d '[\-\_\ ]')"
	echo "Generating build.gradle..."
echo \
"jar {
	archiveBaseName = project.name
}

buildscript {
    dependencies {
        classpath (\"org.springframework.boot:spring-boot-gradle-plugin:\${project.property(\"springBootVersion\")}\")
    }
}

dependencies {
	// ${MODULE_NAME} Module specific dependencies
}

sourceSets {
    main {
        java.srcDirs += 'build/generated/sources/annotationProcessor/java/main'
    }
    test {
    	java.srcDirs += 'build/generated/sources/annotationProcessor/java/test'
    }
}" > ${WORK_DIR}/${MODULE_NAME}/build.gradle

	echo "Generating gradle.properties..."
	echo \
"
# Submodule Version
module.version=1.0.0

# Dependencies version
" > ${WORK_DIR}/${MODULE_NAME}/gradle.properties

echo "Generating settings.gradle..."
echo "rootProject.name=${MODULE_NAME}" > ${WORK_DIR}/${MODULE_NAME}/settings.gradle

echo \
"# Sonar Configuration
sonar.projectKey=${MODULE_NAME}
sonar.projectName=
sonar.projectDescription=
sonar.language=java
sonar.java.sources=17
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.sourceEncoding=UTF-8
sonar.java.binaries=build/classes/java/main
sonar.test.binaries=build/classes/java/test
sonar.java.libraries=build/libs/*.jar
sonar.java.test.binaries=build/classes/java/test
sonar.coverage.jacoco.xmlReportPaths=build/reports/jacoco/test/jacocoTestReport.xml
sonar.junit.reportPaths=build/test-results/test
sonar.scm.disabled=true
sonar.exclusions=
sonar.qualitygate.wait=false" > ${WORK_DIR}/${MODULE_NAME}/sonar.properties

	echo "Attaching ${MODULE_NAME} in root module..."
	echo "include '${MODULE_NAME}'" >> ${WORK_DIR}/settings.gradle

	echo "${MODULE_NAME} module generated."
	echo ""
}

WORK_DIR=$(pwd)
while [[ $# -gt 0 ]]; do
	generateModule $1
	shift 1
done
