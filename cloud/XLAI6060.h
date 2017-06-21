//
//  XLAI6060.h
//  XLKJCloudSDK
//
//  Created by Apple on 17/4/27.
//  Copyright © 2017年 XLKJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLAI6060 : NSObject
/**
 *  wifi密码
 */
@property (nonatomic, strong) NSString *passText;

/**
 *  初始化配网模块
 */
- (void)setUp;

/**
 第一调用开始配网，再次调用停止配网
 */
- (void)config;

/**
 *  配网
 *
 *  @param timeOut 超时时间
 */
- (void)configWithTimeOut:(NSTimeInterval)timeOut;

- (NSString *)getWiFiAddress;

@end
