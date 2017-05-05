//
//  ACloudLibConst.h
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/7/15.
//  Copyright © 2016年 OK. All rights reserved.
//

#ifndef ACloudLibConst_h
#define ACloudLibConst_h

// 过期
#define ACDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

#import <UIKit/UIKit.h>
#import "ACLoudLib.h"

//自定义打印
#define ACLog(format, ...) {\
if ([ACloudLib logEnable]) {\
NSLog(@"[Ablecloud]: %s():%d " format, __func__, __LINE__, ##__VA_ARGS__);\
}\
}\


#endif /* ACloudLibConst_h */
