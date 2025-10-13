plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream


val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.koralabs.mira"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    // Determine if a valid keystore file is present
    val hasKeystoreProps = keystorePropertiesFile.exists()
    val storeFilePropForCheck: String? = keystoreProperties.getProperty("storeFile")
    val resolvedStoreFileForCheck = if (!storeFilePropForCheck.isNullOrBlank()) file(storeFilePropForCheck) else null
    val hasValidKeystore = hasKeystoreProps && (resolvedStoreFileForCheck?.exists() == true)

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.koralabs.mira"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Only create the release signing config when a VALID keystore file is present to avoid errors.
        if (hasValidKeystore) {
            create("release") {
                val keyAliasProp: String? = keystoreProperties.getProperty("keyAlias")
                val keyPasswordProp: String? = keystoreProperties.getProperty("keyPassword")
                val storeFileProp: String? = keystoreProperties.getProperty("storeFile")
                val storePasswordProp: String? = keystoreProperties.getProperty("storePassword")

                if (!keyAliasProp.isNullOrBlank()) keyAlias = keyAliasProp
                if (!keyPasswordProp.isNullOrBlank()) keyPassword = keyPasswordProp
                if (!storeFileProp.isNullOrBlank()) storeFile = file(storeFileProp)
                if (!storePasswordProp.isNullOrBlank()) storePassword = storePasswordProp
            }
        }
    }
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now,
            // so `flutter run --release` works.
            signingConfig = if (hasValidKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("com.google.android.material:material:1.11.0")
    // Google Play Billing library (required for Play Billing operations)
    implementation("com.android.billingclient:billing:6.0.1")
}
