//
//  ACCache.h
//  AbleCloud
//
//  Created by zhourx5211 on 1/17/15.
//  Copyright (c) 2015 ACloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACCache : NSObject


/**
 * 升级设备信息缓存
 * @param devices 设备数组
 */
+ (void)updateDevices:(NSArray *)devices;

/**
 * 获取设备缓存数组
 * @return 设备缓存数组
 */
+ (NSArray *)getDevicesCache;

@end
