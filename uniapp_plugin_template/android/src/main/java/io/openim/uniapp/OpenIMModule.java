package io.openim.uniapp;

import android.util.Log;
import com.alibaba.fastjson.JSONObject;
import io.dcloud.feature.uniapp.annotation.UniJSMethod;
import io.dcloud.feature.uniapp.bridge.UniJSCallback;
import io.dcloud.feature.uniapp.common.UniModule;

import open_im_sdk.Open_im_sdk;
import open_im_sdk_callback.Base;
import open_im_sdk_callback.OnConnListener;
import open_im_sdk_callback.OnConversationListener;

/**
 * OpenIM SDK UniApp 模块
 * 
 * 使用方法：
 * const OpenIM = uni.requireNativePlugin('OpenIMModule');
 * OpenIM.initSDK(config, (result) => {
 *   console.log(result);
 * });
 */
public class OpenIMModule extends UniModule {
    
    private static final String TAG = "OpenIMModule";
    
    /**
     * 初始化 SDK
     * 
     * @param config JSON 配置
     *   {
     *     "apiAddr": "http://your-server/api",
     *     "wsAddr": "ws://your-server/msg_gateway",
     *     "dataDir": "/data/user/0/your.package/files/",
     *     "logLevel": 5,
     *     "isLogStandardOutput": true,
     *     "logFilePath": "/storage/emulated/0/Android/data/your.package/files/logs/",
     *     "platformID": 2
     *   }
     * @param callback 回调函数
     */
    @UniJSMethod(uiThread = false)
    public void initSDK(JSONObject config, UniJSCallback callback) {
        try {
            String configStr = config.toJSONString();
            
            // 初始化 SDK
            boolean result = Open_im_sdk.initSDK(
                new BaseCallback(callback), 
                configStr
            );
            
            if (result) {
                JSONObject ret = new JSONObject();
                ret.put("code", 0);
                ret.put("message", "SDK 初始化成功");
                callback.invoke(ret);
            } else {
                JSONObject ret = new JSONObject();
                ret.put("code", -1);
                ret.put("message", "SDK 初始化失败");
                callback.invoke(ret);
            }
            
        } catch (Exception e) {
            Log.e(TAG, "initSDK error", e);
            JSONObject ret = new JSONObject();
            ret.put("code", -1);
            ret.put("message", "初始化异常: " + e.getMessage());
            callback.invoke(ret);
        }
    }
    
    /**
     * 登录
     * 
     * @param params {userID: string, token: string}
     * @param callback 回调函数
     */
    @UniJSMethod(uiThread = false)
    public void login(JSONObject params, UniJSCallback callback) {
        try {
            String userID = params.getString("userID");
            String token = params.getString("token");
            
            Open_im_sdk.login(
                new BaseCallback(callback),
                userID,
                token
            );
            
        } catch (Exception e) {
            Log.e(TAG, "login error", e);
            JSONObject ret = new JSONObject();
            ret.put("code", -1);
            ret.put("message", "登录异常: " + e.getMessage());
            callback.invoke(ret);
        }
    }
    
    /**
     * 登出
     * 
     * @param callback 回调函数
     */
    @UniJSMethod(uiThread = false)
    public void logout(UniJSCallback callback) {
        try {
            Open_im_sdk.logout(new BaseCallback(callback));
        } catch (Exception e) {
            Log.e(TAG, "logout error", e);
            JSONObject ret = new JSONObject();
            ret.put("code", -1);
            ret.put("message", "登出异常: " + e.getMessage());
            callback.invoke(ret);
        }
    }
    
    /**
     * 获取登录状态
     * 
     * @param callback 回调函数
     */
    @UniJSMethod(uiThread = true)
    public void getLoginStatus(UniJSCallback callback) {
        try {
            long status = Open_im_sdk.getLoginStatus();
            
            JSONObject ret = new JSONObject();
            ret.put("code", 0);
            ret.put("data", status);
            ret.put("message", "success");
            callback.invoke(ret);
            
        } catch (Exception e) {
            Log.e(TAG, "getLoginStatus error", e);
            JSONObject ret = new JSONObject();
            ret.put("code", -1);
            ret.put("message", "获取状态异常: " + e.getMessage());
            callback.invoke(ret);
        }
    }
    
    /**
     * 发送文本消息
     * 
     * @param params {recvID: string, groupID: string, text: string}
     * @param callback 回调函数
     */
    @UniJSMethod(uiThread = false)
    public void sendTextMessage(JSONObject params, UniJSCallback callback) {
        try {
            String text = params.getString("text");
            String recvID = params.getString("recvID");
            String groupID = params.getString("groupID");
            
            // 创建文本消息
            String message = Open_im_sdk.createTextMessage(text);
            
            // 发送消息
            Open_im_sdk.sendMessage(
                new SendMessageCallback(callback),
                message,
                recvID,
                groupID,
                null
            );
            
        } catch (Exception e) {
            Log.e(TAG, "sendTextMessage error", e);
            JSONObject ret = new JSONObject();
            ret.put("code", -1);
            ret.put("message", "发送消息异常: " + e.getMessage());
            callback.invoke(ret);
        }
    }
    
    /**
     * 获取会话列表
     * 
     * @param callback 回调函数
     */
    @UniJSMethod(uiThread = false)
    public void getAllConversationList(UniJSCallback callback) {
        try {
            Open_im_sdk.getAllConversationList(new BaseCallback(callback));
        } catch (Exception e) {
            Log.e(TAG, "getAllConversationList error", e);
            JSONObject ret = new JSONObject();
            ret.put("code", -1);
            ret.put("message", "获取会话列表异常: " + e.getMessage());
            callback.invoke(ret);
        }
    }
    
    // ========================================
    // 回调类
    // ========================================
    
    /**
     * 基础回调
     */
    private static class BaseCallback implements Base {
        private UniJSCallback callback;
        
        public BaseCallback(UniJSCallback callback) {
            this.callback = callback;
        }
        
        @Override
        public void onError(long code, String msg) {
            JSONObject ret = new JSONObject();
            ret.put("code", code);
            ret.put("message", msg);
            callback.invoke(ret);
        }
        
        @Override
        public void onSuccess(String data) {
            JSONObject ret = new JSONObject();
            ret.put("code", 0);
            ret.put("data", data);
            ret.put("message", "success");
            callback.invoke(ret);
        }
    }
    
    /**
     * 发送消息回调
     */
    private static class SendMessageCallback implements open_im_sdk_callback.SendMsgCallBack {
        private UniJSCallback callback;
        
        public SendMessageCallback(UniJSCallback callback) {
            this.callback = callback;
        }
        
        @Override
        public void onError(long code, String msg) {
            JSONObject ret = new JSONObject();
            ret.put("code", code);
            ret.put("message", msg);
            callback.invoke(ret);
        }
        
        @Override
        public void onSuccess(String data) {
            JSONObject ret = new JSONObject();
            ret.put("code", 0);
            ret.put("data", data);
            ret.put("message", "success");
            callback.invoke(ret);
        }
        
        @Override
        public void onProgress(long progress) {
            // 上传进度回调
            Log.d(TAG, "onProgress: " + progress);
        }
    }
}

