//
//  OpenIMModule.h
//  OpenIM SDK for UniApp
//
//  Created on 2024
//  Copyright © 2024 OpenIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUniModule.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * OpenIM SDK UniApp 模块 - iOS
 *
 * 使用方法：
 * const OpenIM = uni.requireNativePlugin('OpenIMModule');
 * OpenIM.initSDK(config, (result) => {
 *   console.log(result);
 * });
 */
@interface OpenIMModule : DCUniModule

/**
 * 初始化 SDK
 */
- (void)initSDK:(NSDictionary *)config callback:(UniModuleKeepAliveCallback)callback;

/**
 * 登录
 */
- (void)login:(NSDictionary *)params callback:(UniModuleKeepAliveCallback)callback;

/**
 * 登出
 */
- (void)logout:(UniModuleKeepAliveCallback)callback;

/**
 * 获取登录状态
 */
- (void)getLoginStatus:(UniModuleKeepAliveCallback)callback;

/**
 * 发送文本消息
 */
- (void)sendTextMessage:(NSDictionary *)params callback:(UniModuleKeepAliveCallback)callback;

/**
 * 获取会话列表
 */
- (void)getAllConversationList:(UniModuleKeepAliveCallback)callback;

@end

NS_ASSUME_NONNULL_END

