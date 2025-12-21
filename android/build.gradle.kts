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

// Ensure all Java/Kotlin compile tasks use Java 17 to avoid warnings about -source 8
// coming from third-party plugins or libraries that don't declare newer compatibility.
// This config forces JavaCompile and KotlinCompile tasks across subprojects to
// use Java 17 source/target and sets Kotlin jvmTarget to 17 where applicable.
subprojects {
    // Configure Java compile tasks across all subprojects
    tasks.withType(org.gradle.api.tasks.compile.JavaCompile::class.java).configureEach {
        options.compilerArgs.add("-Xlint:-options")
        options.compilerArgs.add("-Xlint:deprecation")
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }
    // Note: Kotlin jvmTarget is set in the app module. If needed later,
    // we can add a plugin-aware configuration here without reflection.
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}