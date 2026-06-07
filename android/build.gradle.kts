allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force every module (app + plugins, e.g. :jni) onto the NDK that is actually
// installed and intact (r27d). Flutter's default (28.2.13676358) and 30.x are
// corrupt on this machine, and plugins ignore the app-level ndkVersion pin — so
// override the Android extension reflectively for all subprojects.
subprojects {
    val pinNdk = {
        extensions.findByName("android")?.let { androidExt ->
            runCatching {
                androidExt.javaClass.getMethod("setNdkVersion", String::class.java)
                    .invoke(androidExt, "27.3.13750724")
            }
        }
        Unit
    }
    // :app is already evaluated (evaluationDependsOn above) → apply now; other
    // modules → apply after their own android{} block sets flutter.ndkVersion.
    if (state.executed) pinNdk() else afterEvaluate { pinNdk() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
