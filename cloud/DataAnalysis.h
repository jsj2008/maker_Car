//
//  DataAnalysis.h
//  swift-smartlink
//
//  Created by Computer on 17/1/17.
//  Copyright © 2017年 thinker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataAnalysis : NSObject
//十进制转换成十六进制
-(NSString *)ToHex:(long long int)tmpid;
//计算校验码
-(NSString *)calCode:(NSString *)contentStr withLen:(NSInteger)length;

@end
