//
//  OpenIMModule.m
//  OpenIM SDK for UniApp
//
//  Created on 2024
//  Copyright © 2024 OpenIM. All rights reserved.
//

#import "OpenIMModule.h"
#import <OpenIMCore/OpenIMCore.h>

@implementation OpenIMModule

// 导出模块方法
UNI_EXPORT_METHOD(@selector(initSDK:callback:))
UNI_EXPORT_METHOD(@selector(login:callback:))
UNI_EXPORT_METHOD(@selector(logout:))
UNI_EXPORT_METHOD(@selector(getLoginStatus:))
UNI_EXPORT_METHOD(@selector(sendTextMessage:callback:))
UNI_EXPORT_METHOD(@selector(getAllConversationList:))

/**
 * 初始化 SDK
 */
- (void)initSDK:(NSDictionary *)config callback:(UniModuleKeepAliveCallback)callback {
    @try {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:config options:0 error:&error];
        if (error) {
            callback(@{@"code": @(-1), @"message": @"配置参数格式错误"}, NO);
            return;
        }
        
        NSString *configStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // 初始化 SDK
        BOOL result = Open_im_sdkInitSDK(nil, configStr);
        
        if (result) {
            callback(@{@"code": @(0), @"message": @"SDK 初始化成功"}, NO);
        } else {
            callback(@{@"code": @(-1), @"message": @"SDK 初始化失败"}, NO);
        }
        
    } @catch (NSException *exception) {
        callback(@{@"code": @(-1), @"message": [NSString stringWithFormat:@"初始化异常: %@", exception.reason]}, NO);
    }
}

/**
 * 登录
 */
- (void)login:(NSDictionary *)params callback:(UniModuleKeepAliveCallback)callback {
    @try {
        NSString *userID = params[@"userID"];
        NSString *token = params[@"token"];
        
        if (!userID || !token) {
            callback(@{@"code": @(-1), @"message": @"userID 和 token 不能为空"}, NO);
            return;
        }
        
        // 创建回调处理器
        id<Open_im_sdk_callbackBase> callbackHandler = [[OpenIMCallback alloc] initWithCallback:callback];
        
        // 登录
        Open_im_sdkLogin(callbackHandler, userID, token);
        
    } @catch (NSException *exception) {
        callback(@{@"code": @(-1), @"message": [NSString stringWithFormat:@"登录异常: %@", exception.reason]}, NO);
    }
}

/**
 * 登出
 */
- (void)logout:(UniModuleKeepAliveCallback)callback {
    @try {
        id<Open_im_sdk_callbackBase> callbackHandler = [[OpenIMCallback alloc] initWithCallback:callback];
        Open_im_sdkLogout(callbackHandler);
    } @catch (NSException *exception) {
        callback(@{@"code": @(-1), @"message": [NSString stringWithFormat:@"登出异常: %@", exception.reason]}, NO);
    }
}

/**
 * 获取登录状态
 */
- (void)getLoginStatus:(UniModuleKeepAliveCallback)callback {
    @try {
        long status = Open_im_sdkGetLoginStatus();
        callback(@{@"code": @(0), @"data": @(status), @"message": @"success"}, NO);
    } @catch (NSException *exception) {
        callback(@{@"code": @(-1), @"message": [NSString stringWithFormat:@"获取状态异常: %@", exception.reason]}, NO);
    }
}

/**
 * 发送文本消息
 */
- (void)sendTextMessage:(NSDictionary *)params callback:(UniModuleKeepAliveCallback)callback {
    @try {
        NSString *text = params[@"text"];
        NSString *recvID = params[@"recvID"] ?: @"";
        NSString *groupID = params[@"groupID"] ?: @"";
        
        if (!text) {
            callback(@{@"code": @(-1), @"message": @"消息内容不能为空"}, NO);
            return;
        }
        
        // 创建文本消息
        NSString *message = Open_im_sdkCreateTextMessage(text);
        
        // 创建发送消息回调
        id<Open_im_sdk_callbackSendMsgCallBack> sendCallback = [[OpenIMSendMessageCallback alloc] initWithCallback:callback];
        
        // 发送消息
        Open_im_sdkSendMessage(sendCallback, message, recvID, groupID, nil);
        
    } @catch (NSException *exception) {
        callback(@{@"code": @(-1), @"message": [NSString stringWithFormat:@"发送消息异常: %@", exception.reason]}, NO);
    }
}

/**
 * 获取会话列表
 */
- (void)getAllConversationList:(UniModuleKeepAliveCallback)callback {
    @try {
        id<Open_im_sdk_callbackBase> callbackHandler = [[OpenIMCallback alloc] initWithCallback:callback];
        Open_im_sdkGetAllConversationList(callbackHandler);
    } @catch (NSException *exception) {
        callback(@{@"code": @(-1), @"message": [NSString stringWithFormat:@"获取会话列表异常: %@", exception.reason]}, NO);
    }
}

@end

// ========================================
// 回调实现
// ========================================

/**
 * 基础回调
 */
@interface OpenIMCallback : NSObject <Open_im_sdk_callbackBase>
@property (nonatomic, copy) UniModuleKeepAliveCallback callback;
@end

@implementation OpenIMCallback

- (instancetype)initWithCallback:(UniModuleKeepAliveCallback)callback {
    if (self = [super init]) {
        _callback = callback;
    }
    return self;
}

- (void)onError:(long)code errMsg:(NSString *)errMsg {
    if (self.callback) {
        self.callback(@{@"code": @(code), @"message": errMsg ?: @""}, NO);
    }
}

- (void)onSuccess:(NSString *)data {
    if (self.callback) {
        self.callback(@{@"code": @(0), @"data": data ?: @"", @"message": @"success"}, NO);
    }
}

@end

/**
 * 发送消息回调
 */
@interface OpenIMSendMessageCallback : NSObject <Open_im_sdk_callbackSendMsgCallBack>
@property (nonatomic, copy) UniModuleKeepAliveCallback callback;
@end

@implementation OpenIMSendMessageCallback

- (instancetype)initWithCallback:(UniModuleKeepAliveCallback)callback {
    if (self = [super init]) {
        _callback = callback;
    }
    return self;
}

- (void)onError:(long)code errMsg:(NSString *)errMsg {
    if (self.callback) {
        self.callback(@{@"code": @(code), @"message": errMsg ?: @""}, NO);
    }
}

- (void)onSuccess:(NSString *)data {
    if (self.callback) {
        self.callback(@{@"code": @(0), @"data": data ?: @"", @"message": @"success"}, NO);
    }
}

- (void)onProgress:(long)progress {
    NSLog(@"Upload progress: %ld", progress);
}

@end

