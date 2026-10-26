extends SceneTree

func _initialize() -> void:
    var settings := EditorInterface.get_editor_settings()
    settings.set_setting("export/android/java_sdk_path", OS.get_environment("JAVA_HOME"))
    settings.set_setting("export/android/android_sdk_path", OS.get_environment("ANDROID_SDK_ROOT"))
    print("Android SDK path: ", settings.get_setting("export/android/android_sdk_path"))
    print("Java SDK path: ", settings.get_setting("export/android/java_sdk_path"))
    call_deferred("quit", 0)
