# 🚀 OpenIM SDK - UniApp 快速开始指南

> 将 OpenIM SDK Core 编译成 AAR 和 XCFramework，并集成到 UniApp 原生插件

---

## 📋 第一步：安装 Android NDK

### 当前状态
- ✅ Go 1.24.5 已安装
- ✅ gomobile 已安装
- ✅ Android SDK 已安装
- ❌ **Android NDK 需要安装**

### 安装 NDK（选择其一）

#### 方法一：Android Studio 安装（推荐）⭐

1. 打开 **Android Studio**
2. `File` → `Settings` → `Android SDK`
3. 切换到 `SDK Tools` 标签
4. 勾选 `☑ NDK (Side by side)`
5. 勾选 `☑ CMake`
6. 在版本列表中选择 **20.1.5948944** (r20b)
7. 点击 `Apply` 开始安装
8. 等待安装完成

#### 方法二：手动下载安装

```bash
# 下载地址
https://dl.google.com/android/repository/android-ndk-r20b-windows-x86_64.zip

# 解压到（任选其一）：
C:\Users\yu142\AppData\Local\Android\Sdk\ndk-bundle
或
C:\Users\yu142\AppData\Local\Android\Sdk\ndk\20.1.5948944
```

---

## 📦 第二步：编译 AAR

### 运行环境检查脚本

```bash
# 在项目根目录运行
setup_environment.bat
```

这会检查所有必需的环境，并提示缺少什么。

### 开始编译

**确保 NDK 安装完成后**，运行：

```bash
# 方式 1：使用编译脚本（推荐）
build_android.bat

# 方式 2：直接使用 gomobile 命令
cd E:\openim-sdk-core
gomobile bind -v -trimpath -ldflags="-s -w" -o ./open_im_sdk.aar -target=android ./open_im_sdk/ ./open_im_sdk_callback/
```

**编译时间：** 首次编译约 5-15 分钟（需要下载 Go 依赖包）

**编译产物：** `E:\openim-sdk-core\open_im_sdk.aar`

---

## 📱 第三步：集成到 UniApp

### 1. 复制 AAR 文件

```bash
# 将编译好的 AAR 复制到插件模板
copy open_im_sdk.aar uniapp_plugin_template\android\libs\
```

### 2. 复制插件到 UniApp 项目

```bash
# 将整个插件目录复制到你的 UniApp 项目
xcopy /E /I uniapp_plugin_template "你的UniApp项目\nativeplugins\openim-sdk"
```

### 3. 配置 manifest.json

在 UniApp 项目的 `manifest.json` 中添加：

```json
{
  "App-plus": {
    "nativePlugins": {
      "openim-sdk": {
        "android": {},
        "ios": {}
      }
    }
  }
}
```

### 4. 在代码中使用

```javascript
// pages/index/index.vue

<script>
export default {
  data() {
    return {
      OpenIM: null
    }
  },
  
  onLoad() {
    // 加载原生插件
    this.OpenIM = uni.requireNativePlugin('OpenIMModule');
    
    // 初始化 SDK
    this.initSDK();
  },
  
  methods: {
    initSDK() {
      this.OpenIM.initSDK({
        apiAddr: "http://your-server/api",
        wsAddr: "ws://your-server/msg_gateway",
        dataDir: "",
        logLevel: 5,
        isLogStandardOutput: true,
        platformID: 2  // Android
      }, (result) => {
        if (result.code === 0) {
          console.log('✅ SDK 初始化成功');
          this.login();
        } else {
          console.error('❌ SDK 初始化失败:', result.message);
        }
      });
    },
    
    login() {
      this.OpenIM.login({
        userID: 'test_user_001',
        token: 'your_token_here'
      }, (result) => {
        if (result.code === 0) {
          console.log('✅ 登录成功');
          this.getConversations();
        } else {
          console.error('❌ 登录失败:', result.message);
        }
      });
    },
    
    getConversations() {
      this.OpenIM.getAllConversationList((result) => {
        if (result.code === 0) {
          const conversations = JSON.parse(result.data);
          console.log('📋 会话列表:', conversations);
        }
      });
    },
    
    sendMessage() {
      this.OpenIM.sendTextMessage({
        text: 'Hello from UniApp!',
        recvID: 'receiver_user_id',
        groupID: ''
      }, (result) => {
        if (result.code === 0) {
          console.log('✅ 消息发送成功');
        } else {
          console.error('❌ 消息发送失败:', result.message);
        }
      });
    }
  }
}
</script>
```

---

## 🍎 iOS 编译（仅限 macOS）

如果你需要 iOS 支持，需要在 **macOS** 系统上编译：

```bash
# 在 macOS 上运行
cd /path/to/openim-sdk-core
make ios

# 编译完成后，复制 XCFramework
cp -r build/OpenIMCore.xcframework uniapp_plugin_template/ios/Frameworks/
```

---

## 🐛 常见问题

### 1. NDK 未找到错误

**错误信息：**
```
no usable NDK in C:\Users\...\Android\Sdk
```

**解决方案：**
- 通过 Android Studio 安装 NDK（见第一步）
- 确保 NDK 版本为 20.1.5948944 或更高

### 2. 编译卡在下载依赖

**解决方案：**
```bash
# 设置国内 Go 代理
go env -w GOPROXY=https://goproxy.cn,direct
```

### 3. gomobile 命令未找到

**解决方案：**
```bash
# 将 Go bin 目录添加到 PATH
# 路径：C:\Users\yu142\go\bin

# 或者重新安装
go install golang.org/x/mobile/cmd/gomobile@latest
go install golang.org/x/mobile/cmd/gobind@latest
gomobile init
```

### 4. UniApp 找不到插件

**检查清单：**
- [ ] AAR 文件已复制到 `android/libs/` 目录
- [ ] 插件目录名称正确（与 package.json 中 id 一致）
- [ ] manifest.json 中已配置 nativePlugins
- [ ] 已重新编译 UniApp 项目（不是热更新）

---

## 📁 文件清单

编译完成后，你应该有以下文件：

```
E:\openim-sdk-core\
├── open_im_sdk.aar                    ✅ Android 编译产物
├── open_im_sdk-sources.jar            
├── BUILD_UNIAPP_GUIDE.md              📖 详细指南
├── QUICK_START_UNIAPP.md              📖 本文件
├── build_android.bat                  🔧 编译脚本
├── setup_environment.bat              🔧 环境检查脚本
└── uniapp_plugin_template/            📦 插件模板
    ├── package.json
    ├── android/
    │   ├── libs/
    │   │   └── open_im_sdk.aar        ← 复制 AAR 到这里
    │   └── src/.../OpenIMModule.java
    └── ios/
        └── Frameworks/
            └── OpenIMCore.xcframework ← iOS framework
```

---

## ✅ 完整流程检查表

### 环境准备
- [x] Go 1.18+ 已安装
- [x] gomobile 已安装并初始化
- [x] Android SDK 已安装
- [ ] **Android NDK 已安装** ← 当前需要完成

### 编译步骤
- [ ] 运行 `setup_environment.bat` 检查环境
- [ ] 运行 `build_android.bat` 编译 AAR
- [ ] 确认生成 `open_im_sdk.aar` 文件

### 集成步骤
- [ ] 复制 AAR 到插件模板 `android/libs/` 目录
- [ ] 复制插件到 UniApp 项目 `nativeplugins/` 目录
- [ ] 配置 `manifest.json` 添加原生插件
- [ ] 在代码中引入并使用插件
- [ ] 使用云打包或本地打包测试

---

## 📞 获取帮助

- **详细文档**: [BUILD_UNIAPP_GUIDE.md](./BUILD_UNIAPP_GUIDE.md)
- **插件示例**: [uniapp_plugin_template/README.md](./uniapp_plugin_template/README.md)
- **OpenIM 文档**: https://doc.rentsoft.cn/
- **gomobile 文档**: https://pkg.go.dev/golang.org/x/mobile

---

## 🎯 下一步

**当前需要：**
1. 安装 Android NDK（通过 Android Studio）
2. 运行 `build_android.bat` 编译 AAR
3. 将 AAR 集成到 UniApp 项目

**立即开始：**
```bash
# 1. 检查环境
setup_environment.bat

# 2. 打开 Android Studio 安装 NDK

# 3. 编译 AAR
build_android.bat
```

祝编译顺利！ 🎉

