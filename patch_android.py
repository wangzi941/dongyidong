#!/usr/bin/env python3
"""为 flutter create 生成的 Android 工程打补丁：
1. AndroidManifest.xml 增加通知/定时/震动权限
2. app/build.gradle(.kts) 开启 core library desugaring（定时本地通知必需）
在 GitHub Actions 的「打 Android 补丁」步骤中运行。
"""
import re
from pathlib import Path

MANIFEST = Path("android/app/src/main/AndroidManifest.xml")

PERMS = """    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
"""

def patch_manifest():
    text = MANIFEST.read_text(encoding="utf-8")
    if "POST_NOTIFICATIONS" in text:
        print("manifest 已包含权限，跳过")
        return
    if "<application" not in text:
        raise SystemExit("未找到 <application> 标签，manifest 结构不符合预期")
    text = text.replace("<application", PERMS + "    <application", 1)
    MANIFEST.write_text(text, encoding="utf-8")
    print("manifest 权限补丁完成")

DESUGAR_DEP_KTS = '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n'
DESUGAR_DEP_GROOVY = "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n"

def patch_gradle(path: Path, kts: bool):
    if not path.exists():
        return False
    text = path.read_text(encoding="utf-8")
    if "coreLibraryDesugaring" in text:
        print(f"{path} 已开启 desugaring，跳过")
        return True
    if kts:
        text = text.replace(
            "compileOptions {",
            "compileOptions {\n        isCoreLibraryDesugaringEnabled = true",
            1,
        )
        dep = DESUGAR_DEP_KTS
    else:
        text = text.replace(
            "compileOptions {",
            "compileOptions {\n        coreLibraryDesugaringEnabled true",
            1,
        )
        dep = DESUGAR_DEP_GROOVY
    if "dependencies {" not in text:
        raise SystemExit(f"{path} 中未找到 dependencies 块")
    text = text.replace("dependencies {", "dependencies {\n" + dep, 1)
    path.write_text(text, encoding="utf-8")
    print(f"{path} desugaring 补丁完成")
    return True

def patch_build_gradle():
    for path, kts in [
        (Path("android/app/build.gradle.kts"), True),
        (Path("android/app/build.gradle"), False),
    ]:
        if patch_gradle(path, kts):
            return
    raise SystemExit("未找到 android/app/build.gradle(.kts)")

if __name__ == "__main__":
    patch_manifest()
    patch_build_gradle()
    print("Android 补丁全部完成")
