# OpenIM SDK UniApp 原生插件模板

这是一个 OpenIM SDK 的 UniApp 原生插件模板，帮助您快速将编译好的 AAR 和 XCFramework 集成到 UniApp 项目中。

## 📁 目录结构

```
uniapp_plugin_template/
├── package.json                  # 插件配置文件
├── android/                      # Android 平台
│   ├── build.gradle              # Gradle 构建配置
│   ├── AndroidManifest.xml       # Android 清单文件
│   ├── libs/
│   │   └── open_im_sdk.aar       ← 将编译好的 AAR 放这里
│   └── src/main/java/io/openim/uniapp/
│       └── OpenIMModule.java     # Java 模块实现
└── ios/                          # iOS 平台
    ├── OpenIMModule.h            # Objective-C 头文件
    ├── OpenIMModule.m            # Objective-C 实现
    └── Frameworks/
        └── OpenIMCore.xcframework ← 将编译好的 XCFramework 放这里
```

## 🚀 快速开始

### 1. 编译 AAR 和 XCFramework

**Android AAR:**
```bash
# 在 openim-sdk-core 项目根目录执行
cd E:\openim-sdk-core
build_android.bat
```

**iOS XCFramework (需要 macOS):**
```bash
cd /path/to/openim-sdk-core
make ios
```

### 2. 复制编译产物

**Android:**
```bash
# 复制 AAR 到插件目录
copy open_im_sdk.aar uniapp_plugin_template\android\libs\
```

**iOS:**
```bash
# 复制 XCFramework 到插件目录
cp -r build/OpenIMCore.xcframework uniapp_plugin_template/ios/Frameworks/
```

### 3. 在 UniApp 项目中使用

#### 方式一：本地插件（开发调试）

1. 将 `uniapp_plugin_template` 目录复制到你的 UniApp 项目的 `nativeplugins` 目录下
2. 在 `manifest.json` 中配置：

```json
{
  "nativePlugins": {
    "openim-sdk": {
      "android": {},
      "ios": {}
    }
  }
}
```

#### 方式二：云端插件（发布使用）

1. 将插件上传到 DCloud 插件市场
2. 在 HBuilderX 中通过插件市场安装

### 4. 在代码中调用

```javascript
// 引入原生插件
const OpenIM = uni.requireNativePlugin('OpenIMModule');

// 初始化 SDK
OpenIM.initSDK({
  apiAddr: "http://your-server/api",
  wsAddr: "ws://your-server/msg_gateway",
  dataDir: "", // Android/iOS 会自动使用默认路径
  logLevel: 5,
  isLogStandardOutput: true,
  platformID: 2  // 1:iOS, 2:Android
}, (result) => {
  if (result.code === 0) {
    console.log('SDK 初始化成功');
  } else {
    console.error('SDK 初始化失败:', result.message);
  }
});

// 登录
OpenIM.login({
  userID: 'your_user_id',
  token: 'your_token'
}, (result) => {
  if (result.code === 0) {
    console.log('登录成功');
  } else {
    console.error('登录失败:', result.message);
  }
});

// 发送文本消息
OpenIM.sendTextMessage({
  text: 'Hello, World!',
  recvID: 'receiver_user_id',
  groupID: ''  // 单聊时为空
}, (result) => {
  if (result.code === 0) {
    console.log('消息发送成功:', result.data);
  } else {
    console.error('消息发送失败:', result.message);
  }
});

// 获取会话列表
OpenIM.getAllConversationList((result) => {
  if (result.code === 0) {
    const conversations = JSON.parse(result.data);
    console.log('会话列表:', conversations);
  } else {
    console.error('获取会话列表失败:', result.message);
  }
});
```

## 📱 API 说明

### initSDK(config, callback)

初始化 SDK

**参数:**
- `config`: 配置对象
  - `apiAddr`: API 服务器地址
  - `wsAddr`: WebSocket 地址
  - `dataDir`: 数据存储目录（可选，默认使用应用数据目录）
  - `logLevel`: 日志级别（1-6，默认 5）
  - `isLogStandardOutput`: 是否输出到控制台
  - `platformID`: 平台 ID（1:iOS, 2:Android）
- `callback`: 回调函数

### login(params, callback)

登录

**参数:**
- `params`: 登录参数
  - `userID`: 用户 ID
  - `token`: 登录 token
- `callback`: 回调函数

### logout(callback)

登出

**参数:**
- `callback`: 回调函数

### getLoginStatus(callback)

获取登录状态

**参数:**
- `callback`: 回调函数

**返回值:**
- `1`: 未登录
- `2`: 登录中
- `3`: 已登录
- `4`: 登录失败

### sendTextMessage(params, callback)

发送文本消息

**参数:**
- `params`: 消息参数
  - `text`: 消息内容
  - `recvID`: 接收者 ID（单聊）
  - `groupID`: 群组 ID（群聊）
- `callback`: 回调函数

### getAllConversationList(callback)

获取所有会话列表

**参数:**
- `callback`: 回调函数

## 🔧 自定义扩展

### 添加新的 API

**Android (OpenIMModule.java):**

```java
@UniJSMethod(uiThread = false)
public void yourNewMethod(JSONObject params, UniJSCallback callback) {
    try {
        // 调用 OpenIM SDK 方法
        Open_im_sdk.yourMethod(...);
        
        // 返回结果
        JSONObject ret = new JSONObject();
        ret.put("code", 0);
        ret.put("message", "success");
        callback.invoke(ret);
        
    } catch (Exception e) {
        JSONObject ret = new JSONObject();
        ret.put("code", -1);
        ret.put("message", e.getMessage());
        callback.invoke(ret);
    }
}
```

**iOS (OpenIMModule.m):**

```objc
// 在 @implementation OpenIMModule 中添加
UNI_EXPORT_METHOD(@selector(yourNewMethod:callback:))

- (void)yourNewMethod:(NSDictionary *)params callback:(UniModuleKeepAliveCallback)callback {
    @try {
        // 调用 OpenIM SDK 方法
        Open_im_sdkYourMethod(...);
        
        // 返回结果
        callback(@{@"code": @(0), @"message": @"success"}, NO);
        
    } @catch (NSException *exception) {
        callback(@{@"code": @(-1), @"message": exception.reason}, NO);
    }
}
```

## 📝 注意事项

1. **Android 权限**: 确保在 `AndroidManifest.xml` 中添加必要的权限
2. **iOS 隐私权限**: 在 `Info.plist` 中添加相应的权限说明
3. **线程安全**: 网络请求等耗时操作使用 `uiThread = false`
4. **错误处理**: 所有方法都应该有完善的错误处理
5. **内存管理**: iOS 要注意 block 循环引用问题

## 🐛 调试

### Android 调试

```bash
# 查看日志
adb logcat | grep OpenIMModule
```

### iOS 调试

在 Xcode 中查看控制台输出

## 📚 更多资源

- [OpenIM SDK Core](https://github.com/openimsdk/openim-sdk-core)
- [UniApp 原生插件开发文档](https://uniapp.dcloud.net.cn/plugin/native-plugin.html)
- [gomobile 文档](https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile)

## 📄 License

Apache-2.0 License

