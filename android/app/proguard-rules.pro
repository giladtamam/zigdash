# R8/ProGuard rules for ZigDash release builds.
# Flutter's engine keep-rules are applied automatically by the Flutter Gradle
# plugin; most plugins ship their own consumer rules. These are defensive keeps.

# Flutter embedding / plugin registrant.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep JNI native method names (sqlite3_flutter_libs and other native plugins).
-keepclasseswithmembernames class * {
    native <methods>;
}
