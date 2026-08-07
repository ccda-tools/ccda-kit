plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("maven-publish")
    signing
}

val javadocJar by tasks.registering(Jar::class) {
    archiveClassifier.set("javadoc")
    from(rootProject.file("README.md"))
}

android {
    namespace = "com.ccdakit.engine"
    compileSdk = 35

    defaultConfig {
        minSdk = 26
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    publishing {
        singleVariant("release") {
            withSourcesJar()
        }
    }
}

dependencies {
    testImplementation("junit:junit:4.13.2")
    testImplementation("net.sf.kxml:kxml2:2.3.0")
    testImplementation("org.json:json:20240303")
}

afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("release") {
                from(components["release"])
                artifact(javadocJar)
                groupId = "io.github.shahzaibiqbal.ccdakit"
                artifactId = "ccda-engine"
                version = findProperty("VERSION_NAME")?.toString() ?: "0.0.0-SNAPSHOT"

                pom {
                    name.set("ccda-kit Android Engine")
                    description.set("Native Kotlin parser and normalized C-CDA model layer.")
                    url.set("https://github.com/shahzaibiqbal/ccda-kit")
                    licenses {
                        license {
                            name.set("MIT License")
                            url.set("https://opensource.org/licenses/MIT")
                        }
                    }
                    developers {
                        developer {
                            id.set("shahzaibiqbal")
                            name.set("Shahzaib Iqbal")
                        }
                    }
                    scm {
                        connection.set("scm:git:https://github.com/shahzaibiqbal/ccda-kit.git")
                        developerConnection.set("scm:git:ssh://git@github.com/shahzaibiqbal/ccda-kit.git")
                        url.set("https://github.com/shahzaibiqbal/ccda-kit")
                    }
                }
            }
        }

        repositories {
            maven {
                name = "LocalRelease"
                url = layout.buildDirectory.dir("maven-releases").get().asFile.toURI()
            }
        }
    }
}

val signingKey = providers.environmentVariable("MAVEN_SIGNING_KEY")
val signingPassword = providers.environmentVariable("MAVEN_SIGNING_PASSWORD")

afterEvaluate {
    signing {
        if (signingKey.isPresent && signingPassword.isPresent) {
            useInMemoryPgpKeys(signingKey.get(), signingPassword.get())
            sign(publishing.publications["release"])
        }
    }
}
