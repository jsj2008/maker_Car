
//
//  UserDefaultUtils.m
//  ac-service-ios-Demo
//
//  Created by fariel huang on 2017/1/5.
//  Copyright © 2017年 OK. All rights reserved.
//

#import "UserDefaultUtils.h"

static NSString *const kUserDefaultDomainKey = @"kUserDefaultDomainKey"; //Domain键
static NSString *const kUserDefaultSubDomainKey = @"kUserDefaultSubDomainKey"; //subDomain键
static NSString *const kUserDefaultWifiModeKey = @"kUserDefaultWifiModeKey"; //wifi模块型号键

@implementation UserDefaultUtils

#pragma mark - subDomain

+ (NSString *)getSubDomain {
    return [[NSUserDefaults standardUserDefaults]
            valueForKey:kUserDefaultSubDomainKey] ? : @"";
}

+ (void)setSubDomain:(NSString *)subDomain {
    return [[NSUserDefaults standardUserDefaults]
            setObject:subDomain forKey:kUserDefaultSubDomainKey];
}

#pragma mark - majorDomain

+ (void)setMajorDomain:(NSString *)domain domainId:(NSInteger)domainId {
    return [[NSUserDefaults standardUserDefaults]
            setObject:@[domain ? : @"", @(domainId)] forKey:kUserDefaultDomainKey];
}

+ (NSString *)getMajorDomain {
    NSArray *value = [[NSUserDefaults standardUserDefaults]
                      valueForKey:kUserDefaultDomainKey];
    return value ? value[0] : @"";
}

+ (NSInteger)getMajorDomainId {
    NSArray *value = [[NSUserDefaults standardUserDefaults]
                      valueForKey:kUserDefaultDomainKey];
    return value ? [value[1] integerValue] : 0;
}

#pragma mark - wifi模块型号

+ (NSString *)getWifiMode {
    return [[NSUserDefaults standardUserDefaults]
            valueForKey:kUserDefaultWifiModeKey] ? : @"选择型号";
}

+ (void)setWifiMode:(NSString *)wifiMode {
    return [[NSUserDefaults standardUserDefaults]
            setObject:wifiMode forKey:kUserDefaultWifiModeKey];
}


@end
