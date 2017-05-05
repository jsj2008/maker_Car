//
//  ACSubscribeManager.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/6.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 推送连接状态
 */
typedef NS_ENUM(NSInteger, ACPushSessionEvent) {
    ACPushSessionEventConnectionEstablished = 1, //连接已建立
    ACPushSessionEventConnectingFailed, //连接建立错误
    ACPushSessionEventAuthenticationFailed, //登陆验证失败
    ACPushSessionEventConnectionClosed, //连接已断开
    ACPushSessionEventConnectionClosedByBroker //连接被服务端断开
};

/**
 * 取消订阅类型
 */
typedef NS_ENUM(NSInteger, ACUnSubscribeType) {
    ACUnSubscribeTypeDevicePropData = 1, //取消订阅所有设备属性数据
    ACUnSubscribeTypeDeviceOnlineStatus, //取消订阅所有设备上下线状态数据
    ACUnSubscribeTypeClassData, //取消订阅所有数据集数据
    ACUnSubscribeTypeCustomData, //取消订阅所有自定义数据
    ACUnSubscribeTypeAll //取消订阅所有数据
};

@class ACDeviceTopicMessage;
@class ACClassTopicMessage;
@class ACCustomTopicMessage;
@class ACTopic;

@interface ACSubscribeManager : NSObject

/**
 * 连接云端
 * 注意：连接状态的回调是在子线程当中，
 * 如果需要刷新UI请在回调中切换到主线程进行操作。
 * @param connectionHandler 用于回调连接状态
 */
+ (void)connect:(void(^)(ACPushSessionEvent event))connectionHandler;

/**
 * 同步订阅某种类型消息 
 * 注意：此方法会阻塞当前线程
 * @param topic 订阅的数据类型
 * @return NSError 订阅结果 为nil即为订阅成功
 */
+ (NSError *)subscribeSync:(ACTopic *)topic;

/**
 * 异步订阅某种类型消息
 * @param topic 订阅的数据类型
 * @param callback 订阅结果回调
 * @return NSError 订阅结果 为nil即为订阅成功
 */
+ (void)subscribeAsync:(ACTopic *)topic callback:(void(^)(NSError *error))callback;

/**
 * 同步取消订阅某种类型消息
 * 注意：此方法会阻塞当前线程
 * @param topic 订阅的数据类型
 * @return NSError 订阅结果 为nil即为订阅成功
 */
+ (NSError *)unSubscribeSync:(ACTopic *)topic;

/**
 * 异步取消订阅某种类型消息
 * @param topic 订阅的数据类型
 * @param callback 订阅结果回调
 * @return NSError 订阅结果 为nil即为订阅成功
 */
+ (void)unSubscribeAsync:(ACTopic *)topic callback:(void(^)(NSError *error))callback;

/**
 * 设置设备类型信息接收回调
 * @param messageHandler 用于回调消息
 */
+ (void)setDeviceTopicMessageHandler:(void(^)(ACDeviceTopicMessage *message))messageHandler;

/**
 * 设置数据集类型信息接收回调
 * @param messageHandler 用于回调消息
 */
+ (void)setClassTopicMessageHandler:(void(^)(ACClassTopicMessage *message))messageHandler;

/**
 * 设置自定义类型信息接收回调
 * @param messageHandler 用于回调消息
 */
+ (void)setCustomTopicMessageHandler:(void(^)(ACCustomTopicMessage *message))messageHandler;

/**
 * 取消订阅所有消息
 */
+ (void)unSubscribeAll:(ACUnSubscribeType)type;

/**
 * 断开连接
 */
+ (void)disconnect;

@end
