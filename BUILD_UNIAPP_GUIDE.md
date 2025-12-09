# OpenIM SDK Core 编译指南 - 用于 UniApp 原生插件

## 📦 编译产物

- **Android**: `open_im_sdk.aar`
- **iOS**: `build/OpenIMCore.xcframework`

---

## 🔧 一、环境配置

### 1. Go 环境（已完成 ✅）

- 当前版本：go1.24.5
- gomobile 和 gobind 已安装

### 2. Android NDK 配置（需要完成）

#### 方法一：通过 Android Studio 安装（推荐）

1. 打开 Android Studio
2. 进入 `File -> Settings -> Appearance & Behavior -> System Settings -> Android SDK`
3. 切换到 `SDK Tools` 标签
4. 勾选 `NDK (Side by side)` 和 `CMake`
5. 推荐安装 NDK 版本：`20.1.5948944` (r20b)
6. 点击 `Apply` 进行安装

#### 方法二：手动下载安装

1. 下载 NDK r20b（Windows 版本）

   ```
   https://dl.google.com/android/repository/android-ndk-r20b-windows-x86_64.zip
   ```

2. 解压到 Android SDK 目录：

   ```
   C:\Users\yu142\AppData\Local\Android\Sdk\ndk\20.1.5948944
   ```

   或

   ```
   C:\Users\yu142\AppData\Local\Android\Sdk\ndk-bundle
   ```

3. 设置环境变量（可选）：
   ```
   ANDROID_NDK_HOME=C:\Users\yu142\AppData\Local\Android\Sdk\ndk\20.1.5948944
   ```

### 3. 验证环境

打开命令行执行：

```bash
# 验证 Go
go version

# 验证 gomobile
gomobile version

# 验证 Android SDK
echo %ANDROID_HOME%

# 验证 NDK（安装后）
dir "C:\Users\yu142\AppData\Local\Android\Sdk\ndk"
```

---

## 🚀 二、编译命令

### 编译 Android AAR

#### 方式 1：直接使用 gomobile 命令

```bash
cd E:\openim-sdk-core
gomobile bind -v -trimpath -ldflags="-s -w" -o ./open_im_sdk.aar -target=android ./open_im_sdk/ ./open_im_sdk_callback/
```

#### 方式 2：使用 Makefile（需要安装 MinGW）

```bash
# 如果安装了 MinGW
mingw32-make android

# 如果使用 Git Bash
make android
```

**编译时间**：首次编译约 5-15 分钟（需要下载依赖）

**编译产物**：`open_im_sdk.aar`（约 30-50MB）

### 编译 iOS XCFramework（仅限 macOS）

```bash
make ios
```

**编译产物**：`build/OpenIMCore.xcframework`

---

## 📱 三、集成到 UniApp 原生插件

### Android 集成步骤

1. **创建 UniApp 原生插件目录结构**：

   ```
   nativeplugins/
   └── YourPlugin/
       └── android/
           ├── libs/
           │   └── open_im_sdk.aar          ← 放置 AAR 文件
           ├── src/
           └── build.gradle
   ```

2. **配置 build.gradle**：

   ```gradle
   dependencies {
       implementation fileTree(dir: 'libs', include: ['*.aar'])
       // 或者
       implementation(name: 'open_im_sdk', ext: 'aar')
   }

   repositories {
       flatDir {
           dirs 'libs'
       }
   }
   ```

3. **创建 Java/Kotlin 桥接类**：

   ```java
   import open_im_sdk.OpenIMSDK;
   import open_im_sdk_callback.OpenIMSDKCallback;

   public class OpenIMModule extends WXModule {
       @JSMethod
       public void initSDK(JSONObject options, JSCallback callback) {
           // 调用 OpenIM SDK 方法
           OpenIMSDK.InitSDK(...);
       }
   }
   ```

### iOS 集成步骤

1. **创建 UniApp 原生插件目录结构**：

   ```
   nativeplugins/
   └── YourPlugin/
       └── ios/
           ├── Frameworks/
           │   └── OpenIMCore.xcframework   ← 放置 XCFramework
           └── YourPlugin.podspec
   ```

2. **配置 podspec**：

   ```ruby
   Pod::Spec.new do |s|
     s.name         = "YourPlugin"
     s.version      = "1.0.0"

     s.vendored_frameworks = 'Frameworks/OpenIMCore.xcframework'

     s.dependency 'DCloudBase'
   end
   ```

3. **创建 Objective-C/Swift 桥接类**：

   ```objc
   #import <OpenIMCore/OpenIMCore.h>

   @implementation OpenIMModule

   - (void)initSDK:(NSDictionary *)options callback:(WXModuleCallback)callback {
       // 调用 OpenIM SDK 方法
       [Open_im_sdkInitSDK:...];
   }

   @end
   ```

---

## 🐛 四、常见问题解决

### 1. NDK 未找到

**错误**：`no usable NDK in C:\Users\...\Android\Sdk`

**解决方案**：

- 安装 NDK（推荐版本：20.1.5948944 或 21.x）
- 确保 NDK 路径正确

### 2. 编译卡在下载依赖

**解决方案**：设置 Go 代理

```bash
go env -w GOPROXY=https://goproxy.cn,direct
```

### 3. 找不到 gomobile 命令

**解决方案**：确保 GOPATH/bin 在系统 PATH 中

```bash
# Windows（管理员权限 PowerShell）
$env:Path += ";$env:USERPROFILE\go\bin"

# 或者手动添加到系统环境变量：
# C:\Users\yu142\go\bin
```

### 4. AAR 包过大

**解决方案**：已使用 `-trimpath -ldflags="-s -w"` 进行优化

- `-trimpath`: 移除文件路径信息
- `-s`: 去除符号表
- `-w`: 去除 DWARF 调试信息

### 5. 编译时内存不足

**解决方案**：

```bash
# 设置 Go 编译环境变量
set GOGC=50
```

---

## 📝 五、编译脚本

### Windows 一键编译脚本（build_android.bat）

```batch
@echo off
echo ========================================
echo OpenIM SDK Core - Android AAR 编译
echo ========================================

echo.
echo [1/4] 检查环境...
go version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Go 未安装或未配置到 PATH
    pause
    exit /b 1
)

gomobile version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] gomobile 未安装
    echo 正在安装 gomobile...
    go install golang.org/x/mobile/cmd/gomobile@latest
    go install golang.org/x/mobile/cmd/gobind@latest
    gomobile init
)

echo [✓] 环境检查完成

echo.
echo [2/4] 清理旧文件...
if exist open_im_sdk.aar del /f /q open_im_sdk.aar
if exist open_im_sdk-sources.jar del /f /q open_im_sdk-sources.jar

echo.
echo [3/4] 开始编译 AAR...
echo 注意：首次编译可能需要 5-15 分钟
cd /d E:\openim-sdk-core
gomobile bind -v -trimpath -ldflags="-s -w" -o ./open_im_sdk.aar -target=android ./open_im_sdk/ ./open_im_sdk_callback/

if %errorlevel% neq 0 (
    echo.
    echo [错误] 编译失败！
    echo.
    echo 可能的原因：
    echo 1. Android NDK 未安装或配置不正确
    echo 2. 网络问题导致依赖下载失败
    echo.
    echo 解决方法：
    echo 1. 通过 Android Studio 安装 NDK（推荐版本 20.1.5948944）
    echo 2. 设置 Go 代理：go env -w GOPROXY=https://goproxy.cn,direct
    echo.
    pause
    exit /b 1
)

echo.
echo [4/4] 编译完成！
echo.
echo 生成的文件：
dir /b open_im_sdk.aar 2>nul
dir /b open_im_sdk-sources.jar 2>nul
echo.
echo 文件位置：E:\openim-sdk-core\
echo.
echo ========================================
echo 编译成功完成！
echo ========================================
pause
```

保存为 `build_android.bat`，双击运行即可。

---

## 📊 六、编译产物说明

### Android AAR 结构

```
open_im_sdk.aar
├── AndroidManifest.xml
├── classes.jar              # Java 包装类
├── jni/
│   ├── armeabi-v7a/
│   │   └── libgojni.so     # 32位 ARM
│   ├── arm64-v8a/
│   │   └── libgojni.so     # 64位 ARM
│   ├── x86/
│   │   └── libgojni.so     # 32位 x86
│   └── x86_64/
│       └── libgojni.so     # 64位 x86
└── R.txt
```

### iOS XCFramework 结构

```
OpenIMCore.xcframework/
├── Info.plist
├── ios-arm64/              # 真机（iPhone/iPad）
│   └── OpenIMCore.framework
└── ios-arm64-simulator/    # 模拟器
    └── OpenIMCore.framework
```

---

## 🔗 七、相关资源

- **OpenIM SDK Core**: https://github.com/openimsdk/openim-sdk-core
- **UniApp 原生插件开发**: https://uniapp.dcloud.net.cn/plugin/native-plugin.html
- **gomobile 文档**: https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile
- **Android NDK 下载**: https://developer.android.com/ndk/downloads

---

## ✅ 八、编译检查清单

编译前请确认：

- [x] Go 1.18+ 已安装
- [x] gomobile 和 gobind 已安装
- [x] gomobile init 已执行
- [ ] Android NDK 已安装（r20b 或更高）
- [ ] Android SDK 路径正确
- [ ] 网络畅通（或已配置 Go 代理）

---

**编译完成后**，您将得到：

1. `open_im_sdk.aar` - 可直接集成到 UniApp Android 原生插件
2. `build/OpenIMCore.xcframework` - 可直接集成到 UniApp iOS 原生插件

祝编译顺利！🎉
