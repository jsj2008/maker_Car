//
//  UserDefaultUtils.h
//  ac-service-ios-Demo
//
//  Created by fariel huang on 2017/1/5.
//  Copyright © 2017年 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultUtils : NSObject

/* 设置主域及id */
+ (void)setMajorDomain:(NSString *)domain domainId:(NSInteger)domainId;
/* 获取主域 */
+ (NSString *)getMajorDomain;
/* 获取主域id */
+ (NSInteger)getMajorDomainId;
/* 获取子域 */
+ (NSString *)getSubDomain;
/* 设置子域 */
+ (void)setSubDomain:(NSString *)subDomain;
/* 获取wifi型号 */
+ (NSString *)getWifiMode;
/* 设置wifi型号 */
+ (void)setWifiMode:(NSString *)wifiMode;

@end
