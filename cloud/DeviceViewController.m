//
//  DeviceViewController.m
//  cloud
//
//  Created by 朱帅 on 2017/3/13.
//  Copyright © 2017年 朱帅. All rights reserved.
//

#import "DeviceViewController.h"
#import "ACloudLib.h"
#import "ACWifiLinkManager.h"
#import "lineTextFeild.h"
#import "UserDefaultUtils.h"
#import "SVProgressHUD.h"
#import "ACLocalDevice.h"
#import "ACBindManager.h"
#import "ACUserDevice.h"
#import "ACDeviceMsg.h"
#import "DataAnalysis.h"
#import "ACCustomDataManager.h"
#import "ACKeyChain.h"
#import "ACMsg.h"
#import "MessageViewController.h"
#import "XLAI6060.h"
@interface DeviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *list;
@property(nonatomic,strong)NSMutableArray<ACLocalDevice *> *devices;
@property(nonatomic,strong)ACLocalDevice *device;
@property(nonatomic,strong)ACUserDevice *listparmter;
@property(nonatomic,strong)NSMutableArray<ACLocalDevice *> *LocalDevices;
@property(nonatomic,strong)UITextField *tex;
@property(nonatomic,strong)NSMutableArray<ACUserDevice *> *BindDevices;
@property(nonatomic,strong)UITextField *nametext;

@property (nonatomic, strong) DataAnalysis *dataAnl;

@property (nonatomic, assign) BOOL isConnect;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSString *keyStr;

@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isConnect = YES;
    //BA55D3 18685211
    self.view.backgroundColor = [UIColor colorWithRed:158/255.0 green:116/255.0 blue:168/255.0 alpha:1];
    self.list = [[UITableView alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 200) style:UITableViewStyleGrouped];
    self.list.delegate = self;
    self.list.dataSource  = self;
    [self.list registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.list];
    self.devices = [NSMutableArray array];
    self.LocalDevices = [NSMutableArray array];
    self.list.backgroundColor = [UIColor clearColor];
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(30, self.view.frame.size.height - 100, self.view.frame.size.width - 60, 69)];
    [btn1 setTintColor:[UIColor whiteColor]];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"Rectangle 1 copy 5"] forState:0];
    [btn1 addTarget:self action:@selector(BtnClick:) forControlEvents:6];
    btn1.tag = 10004;
    [self.view addSubview:btn1];
    [btn1 setTitle:@"网关配网" forState:0];
    [ACBindManager listDevicesWithStatusCallback:^(NSArray *devices, NSError *error) {
        if (!error) {
            self.BindDevices = [NSMutableArray arrayWithArray:devices];
            NSLog(@"%@",self.BindDevices);
            [self.list reloadData];
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
    [ACBindManager listDevicesWithCallback:^(NSArray *devices, NSError *error) {
         NSLog(@"devices = %@", devices);
    }];
    [ACBindManager listDevicesWithStatusCallback:^(NSArray *devices, NSError *error) {
        if (!error) {
            NSLog(@"%@",devices);
            ACUserDevice *device = devices[0];
            NSLog(@"dic = %ld",(long)device.deviceId);
            _keyStr = [NSString stringWithFormat:@"%ld", device.deviceId];
            NSLog(@"----->>>>%@", _keyStr);
            NSUserDefaults *defa = [NSUserDefaults standardUserDefaults];
            [defa setObject:_keyStr forKey:@"defa"];
        }
    }];
    //订阅
    NSLog(@"===%@====",[ACKeyChain getUserId].stringValue);
    [ACCustomDataManager subscribeCustomDataWithSubDomain:@"xinlian01" type:@"topic_type" key:[[NSUserDefaults standardUserDefaults] objectForKey:@"defa"] callback:^(NSError *error) {
        if (error) {
            NSLog(@"err = %@", error);
        }
    }];
    NSLog(@"----->>>>%@", _keyStr);
    [ACCustomDataManager setCustomMessageHandler:^(NSString *subDomain, NSString *type, NSString *key, ACObject *payload) {
        NSArray *payArr = [payload get:@"payload"];
        NSLog(@"str = %@", [payArr class]);
        NSData* decodeData = [[NSData alloc] initWithBase64EncodedString:payArr[0] options:0];
        NSLog(@"接受的数据：sub：%@；type：%@；key：%@；payLoad：%@",subDomain, type, key, decodeData);
        NSString *myStr = [self hexStringFromData:decodeData];
        if ([myStr containsString:@"6974617a0042"]) {
            NSNotificationCenter *notiC = [NSNotificationCenter defaultCenter];
            [notiC postNotificationName:@"scan" object:myStr];
        }
        if ([myStr containsString:@"6974617a004a"]) {
            NSNotificationCenter *notiC = [NSNotificationCenter defaultCenter];
            [notiC postNotificationName:@"send" object:myStr];
        }
    }];
}

//data转成string
//data转换为十六进制的string
-(NSString *)hexStringFromData:(NSData *)myD{
    
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    NSLog(@"hex = %@",hexStr);
    
    return hexStr;
}
//ejzbsklixe@qq.com

-(void)BtnClick:(UIButton *)sender{
    
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"输入WiFi密码" message:[ACWifiLinkManager getCurrentSSID] preferredStyle:1];
    self.tex = [[UITextField alloc]init];
    [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        self.tex = textField;
        self.tex.secureTextEntry = YES;
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ACWifiLinkManager *manager = [[ACWifiLinkManager alloc]
                                      initWithLinkerName:@""];
        // AI6060基于swift版本的配网协议 注：不包含于SDK当中
        XLAI6060 *ai = [[XLAI6060 alloc]init];
        ai.passText = self.tex.text;
        [ai setUp];
        [ai config];
        
            [manager sendWifiInfo:[ACWifiLinkManager getCurrentSSID] password:_tex.text timeout:60 callback:^(NSArray *localDevices, NSError *error) {
                NSLog(@"localDevices = %@",localDevices);
                if (error) {
                    [SVProgressHUD showErrorWithStatus:@"配网超时"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                }else{
                    [manager stopWifiLink];
                    self.device = [localDevices firstObject];
                    [self UpdateDeviceList:self.device];
                    [SVProgressHUD showSuccessWithStatus:@"配网成功!"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        UIButton *btn = [self.view viewWithTag:10004];
                        btn.enabled = false;
                    });
                }
            }];
    }];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [aler addAction:action];
    [aler addAction:action1];
    
    [self presentViewController:aler animated:YES completion:nil];

}

-(void)UpdateDeviceList:(ACLocalDevice *)device{
    [ACBindManager isDeviceBoundsWithSubDomain:@"xinlian01" physicalDeviceId:device.deviceId callback:^(BOOL isBounded, NSError *error) {
        if (error) {
            NSLog(@"%@",error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"设备绑定状态获取失败:%@",error.localizedDescription]];
            return;
            
        }else{
            if (!isBounded) {
                [self.LocalDevices addObject:device];
                [self.list reloadData];
            }
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.LocalDevices.count;
    }else{
        return self.BindDevices.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.section == 0) {
        if (self.LocalDevices.count !=0) {
            cell.textLabel.text = [self.LocalDevices[indexPath.row]deviceId];;
        }
    }else{
        if (self.BindDevices.count != 0) {
            cell.textLabel.text = [self.BindDevices[indexPath.row]physicalDeviceId];
    
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 1) {
            NSLog(@"%ld",[self.device.deviceId integerValue]);
           [ACBindManager unbindDeviceWithSubDomain:@"xinlian01" deviceId:[self.BindDevices[indexPath.row] deviceId] callback:^(NSError *error) {
               if (error) {
                   NSLog(@"%@",error.localizedDescription);
               }else{
                   [SVProgressHUD showSuccessWithStatus:@"解绑成功!"];
                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                       [SVProgressHUD dismiss];
                   });
                   ACUserDevice *user = [self.BindDevices objectAtIndex:indexPath.row];
                   [self.BindDevices removeObject:user];
                   [self.list reloadData];
                   [ACloudLib findDeviceTimeout:20 callback:^(NSArray *localDeviceList) {
                       self.LocalDevices = [NSMutableArray arrayWithArray:localDeviceList];
                       NSLog(@"%@",self.LocalDevices);
                       [self.list reloadData];
                   }];
               }
           }];
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSLog(@"%ld",section);
    UIView *vie = [[UIView alloc]initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 30)];
    UILabel *headerlabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 30)];
    headerlabel.textColor = [UIColor whiteColor];
    if (section == 0) {
        headerlabel.text = @"未绑定的网关";
    }else if(section == 1){
        headerlabel.text = @"已绑定的网关";
    }
    [vie addSubview:headerlabel];
    return vie;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"绑定设备？" message:@"是否绑定设备?" preferredStyle:1];
        [aler addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            self.nametext = textField;
        }];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ACBindManager bindDeviceWithSubDomain:@"xinlian01" physicalDeviceId:[self.LocalDevices[indexPath.row] deviceId] name:self.nametext.text callback:^(ACUserDevice *userDevice, NSError *error) {
                if (!error) {
                    [SVProgressHUD showSuccessWithStatus:@"绑定成功!"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                    [self.BindDevices addObject:userDevice];
                    [self.LocalDevices removeObjectAtIndex:indexPath.row];
                    [self.list reloadData];
                }
            }];
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [aler addAction:action];
        [aler addAction:action1];
        [self presentViewController:aler animated:YES completion:nil];
    }else{
        UIStoryboard *s = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        MessageViewController *mess = [s instantiateViewControllerWithIdentifier:@"mess"];
        mess.physicalDeviceId = [self.BindDevices[indexPath.row] physicalDeviceId];
        [self addChildViewController:mess];
        mess.deviceid = [NSString stringWithFormat:@"%ld",[self.BindDevices[indexPath.row]deviceId]];
        mess.view.frame = self.view.frame;
        [self.view addSubview:mess.view];
        [mess didMoveToParentViewController:self];

   
    }
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
    
@end
