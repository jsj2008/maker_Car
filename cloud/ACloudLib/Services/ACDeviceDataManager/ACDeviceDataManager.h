//
//  ACDeviceDataManager.h
//  AbleCloudLib
//
//  Created by fariel huang on 2016/12/19.
//  Copyright © 2016年 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACDeviceTopicMessage.h"

@class ACObject;
@class ACDevicePropertySearchOption;

@interface ACDeviceDataManager : NSObject

/**
 * 订阅设备属性推送消息
 * @param subDomain 订阅设备的子域
 * @param deviceId 订阅设备的逻辑id
 */
+ (void)subscribePropDataWithSubDomain:(NSString *)subDomain
                              deviceId:(NSInteger)deviceId
                              callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅设备属性推送消息
 * @param subDomain 订阅设备的子域
 * @param deviceId 订阅设备的逻辑id
 */
+ (void)unSubscribePropDataWithSubDomain:(NSString *)subDomain
                                deviceId:(NSInteger)deviceId
                                callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅所有设备属性推送消息
 */
+ (void)unSubscribeAllDevicePropData;

/**
 * 设置设备类型信息接收回调
 * @param handler 用于回调消息
 */
+ (void)setPropertyMessageHandler:(void(^)(NSString *subDomain,
                                           NSInteger deviceId,
                                           ACObject *properties))handler;

/**
 * 订阅设备上下线状态推送消息
 * @param subDomain 订阅设备的子域
 * @param deviceId 订阅设备的逻辑id
 */
+ (void)subscribeOnlineStatusWithSubDomain:(NSString *)subDomain
                                  deviceId:(NSInteger)deviceId
                                  callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅设备上下线状态推送消息
 * @param subDomain 订阅设备的子域
 * @param deviceId 订阅设备的逻辑id
 */
+ (void)unSubscribeOnlineStatusWithSubDomain:(NSString *)subDomain
                                    deviceId:(NSInteger)deviceId
                                    callback:(void(^)(NSError *error))callback;

/**
 * 取消订阅所有设备上下线状态推送消息
 */
+ (void)unSubscribeAllDeviceOnlineStatus;

/**
 * 设置设备上下线状态回调
 * @param handler 用于回调消息
 */
+ (void)setOnlineStatusHandler:(void(^)(NSString *subDomain,
                                        NSInteger deviceId,
                                        ACDeviceOnlineStatus status))handler;

/**
 * 拉取设备历史属性记录
 * @param option 查询条件
 * @param callback 查询结果回调
 */
+ (void)fetchHistoryPropDataWithOption:(ACDevicePropertySearchOption *)option
                              callback:(void(^)(NSArray<ACDevicePropertyMessage *> *records,
                                                NSError *error))callback;

/**
 * 拉取设备当前所有属性值
 * @param subDomain 设备子域
 * @param deviceId 设备逻辑id
 * @param callback 返回查询结果
 */
+ (void)fetchCurrentPropDataWithSubDomain:(NSString *)subDomain
                                 deviceId:(NSInteger)deviceId
                                 callback:(void(^)(ACDevicePropertyMessage *result, NSError *error))callback;

@end
