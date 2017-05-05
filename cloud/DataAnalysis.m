//
//  DataAnalysis.m
//  swift-smartlink
//
//  Created by Computer on 17/1/17.
//  Copyright © 2017年 thinker. All rights reserved.
//

#import "DataAnalysis.h"

@implementation DataAnalysis

//计算校验码
-(NSString *)calCode:(NSString *)contentStr withLen:(NSInteger)length {
    NSInteger dataLen = [self payload:contentStr withLen:length];
    //255 - data之和 ＋ 1
    NSInteger  jsLen = 255 - dataLen + 1;
    NSLog(@"jsLen = %ld", jsLen);
    NSString *binaryString = [[NSString alloc]init];
    NSString *hexString = [[NSString alloc]init];
    if (jsLen >= 0) {
        binaryString =  [self toBinarySystemWithDecimalSystem:jsLen];
        hexString = [self getBinaryByhex:binaryString];
    }
    if (jsLen < 0) {
        jsLen = labs(jsLen);
        binaryString = [self toBinarySystemWithDecimalSystem1:jsLen];
        hexString = [self getBinaryByhex:binaryString];
        if (hexString.length > 2) {
            hexString = [hexString substringWithRange:NSMakeRange(hexString.length -2, 2)];
        }
        
    }
    if (hexString.length > 2) {
        hexString = [hexString substringWithRange:NSMakeRange(hexString.length - 2, 2)];
    }
    return hexString;
}
//负数十进制转换成二进制
- (NSString *)toBinarySystemWithDecimalSystem1:(NSInteger)decimal
{
    NSInteger num = decimal;//[decimal intValue];
    NSInteger remainder = 0; //余数
    NSInteger divisor = 0; //除数
    NSString * prepare = @"";
    
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%ld",remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    
    NSString * result = @"";
    for (NSInteger i = prepare.length - 1; i >= 0; i--)
    {
        result = [result stringByAppendingFormat:@"%@",
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
    }

    if (result.length < 8) {
        if (result.length%8 == 1) {
            result = [NSString stringWithFormat:@"000000%@", result];
        }
        if (result.length%8 == 2) {
            result = [NSString stringWithFormat:@"00000%@", result];
        }
        if (result.length%8 == 3) {
            result = [NSString stringWithFormat:@"0000%@", result];
        }
        if (result.length%8 == 4) {
            result = [NSString stringWithFormat:@"000%@", result];
        }
        if (result.length%8 == 5) {
            result = [NSString stringWithFormat:@"00%@", result];
        }
        if (result.length%8 == 6) {
            result = [NSString stringWithFormat:@"0%@", result];
        }
        if (result.length%8 == 7) {
            result = [NSString stringWithFormat:@"%@", result];
        }
    }
    //取反
    NSString *qfString = [[NSString alloc]init];
    for (int i = 0; i < result.length; i++) {
        NSString *eveString = [result substringWithRange:NSMakeRange(i, 1)];
        if ([eveString isEqualToString:@"0"]) {
            qfString = [qfString stringByAppendingString:@"1"];
        }
        if ([eveString isEqualToString:@"1"]) {
            qfString = [qfString stringByAppendingString:@"0"];
        }
    }
    if (qfString.length == 7) {
        qfString = [NSString stringWithFormat:@"1%@", qfString];
    }    //+1
    NSString *pjString = [[NSString alloc]init];
    NSString *hxString = [[NSString alloc]init];
    for (NSInteger j = qfString.length - 1; j >= 0; j--) {
        NSString *eveString = [qfString substringWithRange:NSMakeRange(j, 1)];
        NSString *myString = [qfString substringWithRange:NSMakeRange(0, j)];
        if ([eveString isEqualToString:@"0"]) {
            pjString = [NSString stringWithFormat:@"1%@",pjString];
            hxString = [myString stringByAppendingString:pjString];
            break;
        }
        if ([eveString isEqualToString:@"1"]) {
            pjString = [NSString stringWithFormat:@"0%@",pjString];
        }
    }

    /////
    if (hxString.length%4 == 0) {
        hxString = [NSString stringWithFormat:@"0001%@", hxString];
        return hxString;
    }
    if (hxString.length%4 == 1) {
        hxString = [NSString stringWithFormat:@"001%@", hxString];
        return hxString;
    }
    if (hxString.length%4 == 2) {
        hxString = [NSString stringWithFormat:@"01%@", hxString];
        return hxString;
    }
    //    if (hxString.length%4 == 3) {
    hxString = [NSString stringWithFormat:@"1%@", hxString];
    //        return hxString;
    //    }
    return hxString;
}


//十进制转换成二进制（正数）
- (NSString *)toBinarySystemWithDecimalSystem:(NSInteger)decimal
{
    NSInteger num = decimal;//[decimal intValue];
    NSInteger remainder = 0; //余数
    NSInteger divisor = 0; //除数
    NSString * prepare = @"";
    
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%ld",remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    
    NSString * result = @"";
    for (NSInteger i = prepare.length - 1; i >= 0; i--)
    {
        result = [result stringByAppendingFormat:@"%@",
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    //确定二进制的位数保证在8位，大于八位的截取后八位，小于八位的补位0
    if (result.length%4 == 1) {
        result = [NSString stringWithFormat:@"000%@", result];
        return result;
    }
    if (result.length%4 == 2) {
        result = [NSString stringWithFormat:@"00%@", result];
        return result;
    }
    if (result.length%4 == 3) {
        result = [NSString stringWithFormat:@"0%@", result];
        return result;
    }
    
    return result;
}
//二进制转换成十六进制
-(NSString *)getBinaryByhex:(NSString *)hex {
    NSMutableDictionary *hexDic = [[NSMutableDictionary alloc]init];
    [hexDic setObject:@"0" forKey:@"0000"];
    [hexDic setObject:@"1" forKey:@"0001"];
    [hexDic setObject:@"2" forKey:@"0010"];
    [hexDic setObject:@"3" forKey:@"0011"];
    [hexDic setObject:@"4" forKey:@"0100"];
    [hexDic setObject:@"5" forKey:@"0101"];
    [hexDic setObject:@"6" forKey:@"0110"];
    [hexDic setObject:@"7" forKey:@"0111"];
    [hexDic setObject:@"8" forKey:@"1000"];
    [hexDic setObject:@"9" forKey:@"1001"];
    [hexDic setObject:@"A" forKey:@"1010"];
    [hexDic setObject:@"B" forKey:@"1011"];
    [hexDic setObject:@"C" forKey:@"1100"];
    [hexDic setObject:@"D" forKey:@"1101"];
    [hexDic setObject:@"E" forKey:@"1110"];
    [hexDic setObject:@"F" forKey:@"1111"];
    NSMutableString *binaryString = [[NSMutableString alloc]init];
    for (int i = 0; i < hex.length/4; i++) {
        NSString *key = [hex substringWithRange:NSMakeRange(4*i, 4)];
        binaryString = [NSMutableString stringWithFormat:@"%@%@",binaryString,[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
    }
    return binaryString;
}

-(NSInteger)payload:(NSString *)contentStr withLen:(NSInteger)length {
    NSInteger resiveLen = 0;
    for (int i = 0; i < length/2; i++) {
        NSString *eveStr = [contentStr substringWithRange:NSMakeRange(2*i, 2)];
        NSInteger len = strtoul([eveStr UTF8String], 0, 16);
        resiveLen += len;
    }
    
    return resiveLen;
}

//十进制转换成十六进制
-(NSString *)ToHex:(long long int)tmpid

{
    
    NSString *nLetterValue;
    
    NSString *str =@"";
    
    long long int ttmpig;
    
    for (int i = 0; i<9; i++) {
        
        ttmpig=tmpid%16;
        
        tmpid=tmpid/16;
        
        switch (ttmpig)
        
        {
                
            case 10:
                
                nLetterValue =@"A";break;
                
            case 11:
                
                nLetterValue =@"B";break;
                
            case 12:
                
                nLetterValue =@"C";break;
                
            case 13:
                
                nLetterValue =@"D";break;
                
            case 14:
                
                nLetterValue =@"E";break;
                
            case 15:
                
                nLetterValue =@"F";break;
                
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
        }
        
        str = [nLetterValue stringByAppendingString:str];
        
        if (tmpid == 0) {
            
            break;
            
        }
    }
    //确定是2bytes
    long long int stringLen = str.length;
    if (stringLen < 4) {
        for (int i = 0; i < (4 - stringLen); i++) {
            str = [NSString stringWithFormat:@"0%@", str];
        }
    }
    
    return str;
}


@end
