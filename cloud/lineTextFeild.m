 //
//  lineTextFeild.m
//  cloud
//
//  Created by 朱帅 on 2017/3/14.
//  Copyright © 2017年 朱帅. All rights reserved.
//

#import "lineTextFeild.h"

@implementation lineTextFeild

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5));
}

@end
