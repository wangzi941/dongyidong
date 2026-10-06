# 动一动 · 久坐提醒（Flutter 原生 App）

每 40 分钟提醒你站起来活动一下。支持 Android / iOS，本地通知、离线可用。

## 功能

- **计时提醒**：圆形进度环倒计时，到点弹系统通知（App 在后台也能收到）+ 全屏提醒页
- **灵活节奏**：间隔 20/30/40/50/60 分钟可选，支持暂停、推迟 5 分钟、提前完成
- **打卡记录**：今日起身次数、连续达标天数、本周柱状图
- **动作库**：6 个办公室拉伸动作（颈部环绕、肩部环绕、站立伸展等）
- **免打扰**：自定义免打扰时段；铃声 / 震动 / 强提醒模式开关
- **状态恢复**：App 被杀掉后重开，计时接着算，不丢进度

## 拿到 APK 的两种方式（都免费）

### 方式一：GitHub Actions 云端构建（推荐，无需安装任何东西）

1. 在 GitHub 新建一个仓库，把本文件夹内容推上去（`main` 分支）
2. 进入仓库的 **Actions** 标签页，运行 **构建 APK** 工作流（或直接 push 触发）
3. 等 5–10 分钟，在工作流运行页的 **Artifacts** 里下载 `dongyidong-release-apk`，里面的 `app-release.apk` 就是安装包
4. 把 APK 传到手机（微信文件传输 / 邮件 / 数据线均可），点击安装
   - Android 8+ 首次安装需允许「安装未知来源应用」
   - Android 13+ 首次打开请允许通知权限，否则收不到提醒

### 方式二：本地构建（需要电脑）

```bash
# 先装好 Flutter SDK：https://docs.flutter.dev/get-started/install
git clone <你的仓库地址>
cd dongyidong
flutter create --org com.dongyidong --project-name dongyidong --platforms=android .
flutter pub get
python3 patch_android.py        # 补通知权限与 desugaring 配置
flutter build apk --release     # 产物在 build/app/outputs/flutter-apk/app-release.apk
```

### iOS 说明

iOS 打包需要 macOS + Xcode + 开发者证书，流程较长。如需 iOS 版，建议本地执行：

```bash
flutter create --platforms=ios .
flutter pub get
cd ios && pod install
# 用 Xcode 打开 ios/Runner.xcworkspace 签名后构建
```

## 项目结构

```
lib/
  main.dart                      # 入口 + 计时引擎 + 底部导航
  services/
    storage.dart                 # 设置与打卡记录（shared_preferences）
    notification_service.dart    # 本地定时通知（flutter_local_notifications）
  screens/
    home_screen.dart             # 计时主页（进度环）
    stats_screen.dart            # 活动记录
    exercises_screen.dart        # 拉伸动作库
    settings_screen.dart         # 提醒设置
    reminder_screen.dart         # 全屏提醒页
  widgets/
    ring_painter.dart            # 进度环绘制 + 颜色常量
.github/workflows/build-apk.yml  # 云端自动构建 APK
patch_android.py                 # Android 权限/desugaring 补丁（构建时自动执行）
```

## 技术说明

- 计时截止时间戳持久化在本地，App 重启后按剩余秒数恢复
- 通知采用 `inexactAllowWhileIdle` 调度，兼容 Android 各版本，无需用户额外授予“精确闹钟”权限
- 所有数据仅保存在手机本地，不上传任何服务器
