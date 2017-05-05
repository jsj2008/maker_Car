//
//  ACServiceClient+Private.h
//  AbleCloudLib
//
//  Created by fariel huang on 2017/3/7.
//  Copyright © 2017年 ACloud. All rights reserved.
//

#import "ACServiceClient.h"

@interface ACServiceClient (private)

+ (void)setRefreshTokenInvalid:(void (^)(NSError *))callback;

+ (void (^)(NSError *))refreshTokenInvalid;

@end
