allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Ensure all Java/Kotlin compile tasks use Java 11 to avoid warnings about -source 8
// coming from third-party plugins or libraries that don't declare newer compatibility.

// Workaround: some third-party plugins may lack a namespace in their Android
// library module build file when using newer AGP versions. Configure it here.

// Workaround: some third-party plugins may lack a namespace in their Android
// library module build file when using newer AGP versions. Configure it here.


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
