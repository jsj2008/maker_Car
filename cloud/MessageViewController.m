//
//  MessageViewController.m
//  cloud
//
//  Created by 朱帅 on 2017/3/21.
//  Copyright © 2017年 朱帅. All rights reserved.
//

#import "MessageViewController.h"
#import "ACBindManager.h"
#import "DataAnalysis.h"

@interface MessageViewController ()
@property(nonatomic,strong)UITextView *content;
@property (nonatomic, strong) NSString *typeStr;
@property (nonatomic, strong) NSString *lenStr;

@property (nonatomic, strong) NSString *dataStr;

@property (nonatomic, strong) DataAnalysis *dataAnl;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 50, 100, 100, 100)];
    btn1.layer.cornerRadius = 50;
    btn1.backgroundColor = [UIColor redColor];
    btn1.tag = 10001;
    btn1.titleLabel.textColor = [UIColor whiteColor];
    btn1.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn1 setTitle:@"前进" forState:UIControlStateNormal];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 50, 210, 100, 100)];
    btn2.layer.cornerRadius = 50;
    btn2.tag = 10002;
    btn2.backgroundColor = [UIColor orangeColor];
    btn2.titleLabel.textColor = [UIColor whiteColor];
    btn2.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn2 setTitle:@"后退" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    
    UIButton *btn3 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 50, 320, 100, 100)];
    btn3.layer.cornerRadius = 50;
    btn3.tag = 10003;
    btn3.backgroundColor = [UIColor blueColor];
    btn3.titleLabel.textColor = [UIColor whiteColor];
    btn3.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn3 setTitle:@"停止" forState:UIControlStateNormal];
    [self.view addSubview:btn3];
    
    NSLog(@"deviceid = %@",self.physicalDeviceId);
    
    [btn1 addTarget:self action:@selector(Getmeesage:) forControlEvents:UIControlEventTouchUpInside];
   [btn2 addTarget:self action:@selector(Getmeesage:) forControlEvents:UIControlEventTouchUpInside];
    [btn3 addTarget:self action:@selector(Getmeesage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *remove = [[UIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 75, self.view.frame.size.height - 200, 100, 100)];
    remove.backgroundColor = [UIColor lightGrayColor];
    [remove setTitle:@"返回" forState:UIControlStateNormal];
    remove.titleLabel.textColor = [UIColor whiteColor];
    [remove addTarget:self action:@selector(BackVieW) forControlEvents:UIControlEventTouchUpInside];
    remove.layer.cornerRadius = 50;
    [self.view addSubview:remove];
    
    
}

-(void)BackVieW{
    [self.view removeFromSuperview];
}

-(void)Getmeesage:(UIButton *)sender{
    if (sender.tag == 10001) {
        NSString *string1 = @"6974637a004300070c77f11946200c3";
        NSString *s2 = [self mosaicData:string1];
        NSLog(@"%@",s2);

    }else if(sender.tag == 10002){
        NSString *string1 = @"6602000080800099";
       
        [self SenMesage:string1];
    }else{
        NSString *string1 = @"6602808080800099";
        
        [self SenMesage:string1];

    }

}
-(void)SenMesage:(NSString *)packge{
    NSData *data = [self convertHexStrToData:packge];
    ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:89 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:@"xinlian01" physicalDeviceId:self.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        if (!error) {
            NSString *s = [[NSString alloc]initWithData:responseMsg.payload encoding:NSUTF8StringEncoding];
            if (s != nil) {
                self.content.text = s;
            }else{
                
            }
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
}
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    //    LEDEBUG(@"hexdata: %@", hexData);
    return hexData;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -- 数据拼接
-(NSString *)mosaicData:(NSString *)sendString {
    NSString *resiveSteing = sendString;
    NSString *typeString  = [resiveSteing substringWithRange:NSMakeRange(10, 2)];
    NSLog(@"resive = %@",resiveSteing);
    _typeStr = typeString;
    //计算数据的长度，十进制（计算出来的数据是bytes的个数）
    NSInteger len = strtoul([[resiveSteing substringWithRange:NSMakeRange(12, 4)] UTF8String], 0, 16);
    _lenStr = [resiveSteing substringWithRange:NSMakeRange(12, 4)];
    NSLog(@"lenstr = %@",_lenStr);
    //在string中获取发送内容的长度
    NSInteger length = 2 *len;
    NSLog(@"%ld",length);
    NSString *contentStr = [resiveSteing substringWithRange:NSMakeRange(16, length)];
    NSLog(@"Contentstr = %@",contentStr);
    _dataStr = contentStr;
    self.dataAnl = [[DataAnalysis alloc]init];
    NSString *xyStr = [self.dataAnl calCode:contentStr withLen:length];
    NSLog(@"Xystr = %@",xyStr);
    return xyStr;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
