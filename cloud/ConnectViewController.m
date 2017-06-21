//
//  ConnectViewController.m
//  cloud
//
//  Created by 朱帅 on 2017/3/15.
//  Copyright © 2017年 朱帅. All rights reserved.
//

#import "ConnectViewController.h"
#import "ACloudLib.h"
#import "ACWifiLinkManager.h"
#import "lineTextFeild.h"
#import "AI6060-Swift.h"
#import "UserDefaultUtils.h"
#import "SVProgressHUD.h"
#import "ACLocalDevice.h"
#import "ACBindManager.h"
static NSString *kWifiLinkAI6060Name = @"AI6060"; //AI6060基于swift版本的配网协议 注：不包含于SDK当中

@interface ConnectViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)UIButton *btn;
@property(nonatomic,strong)UILabel *le;
@property(nonatomic,strong)UILabel *le2;
@property(nonatomic,strong)UITextField *li;
@property(nonatomic,strong)UITextField *li2;
@property(nonatomic, copy) NSDictionary *modes;
@property(nonatomic,strong)ACLocalDevice *device;
@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UIView *vie = [[UIView alloc]initWithFrame:CGRectMake(self.view.center.x - 150, 150, 300, 300)];
    vie.backgroundColor = [UIColor colorWithRed:72.0/255.0 green:118/255.0 blue:255/255.0 alpha:1];
    [self.view addSubview:vie];
    _le = [[UILabel alloc]initWithFrame:CGRectMake(vie.center.x - 80, 60, 160, 20)];
    _le.text = @"WiFi-SSID";
    _li.delegate = self;
    _le.textColor = [UIColor whiteColor];
    _le.font = [UIFont systemFontOfSize:20];
    
    [vie addSubview:_le];
    _li = [[lineTextFeild alloc]initWithFrame:CGRectMake(vie.center.x - 80, 105, 120, 20)];
    _li.textAlignment = NSTextAlignmentCenter;
    _li.text = [ACWifiLinkManager getCurrentSSID];
    _li.textColor = [UIColor whiteColor];
    [vie addSubview:_li];
    _le2 =[[UILabel alloc]initWithFrame:CGRectMake(self.view.center.x - 80, 135, 160, 20)];
    _le2.textColor = [UIColor whiteColor];
        _le2.text = @"WiFi密码";
        _le2.font = [UIFont systemFontOfSize:20];
        [vie addSubview:_le2];
    _li2 = [[lineTextFeild alloc]initWithFrame:CGRectMake(vie.center.x - 80, 175, 120, 20)];
     _li2.delegate = self;
    _li2.textAlignment = NSTextAlignmentCenter;
    _li2.textColor = [UIColor whiteColor];
    _li2.delegate = self;
    [vie addSubview:_li2];
    
    self.btn = [[UIButton alloc]initWithFrame:CGRectMake(vie.center.x - 90, 220,160, 50)];
    [self.btn setTintColor:[UIColor whiteColor]];
    [self.btn setBackgroundImage:[UIImage imageNamed:@"Rectangle 1 copy 5"] forState:0];
    [self.btn addTarget:self action:@selector(star) forControlEvents:UIControlEventTouchUpInside];
    self.btn.titleLabel.font = [UIFont systemFontOfSize:25];
    self.btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.btn setTitle:@"配网" forState:0];
    [vie addSubview:self.btn];
   
    UIButton * shutdown = [[UIButton alloc]initWithFrame:CGRectMake(vie.frame.size.width - 40, 20, 30, 30)];
    [shutdown setImage:[UIImage imageNamed:@"关闭"] forState:0];
    [shutdown addTarget:self action:@selector(shutdown) forControlEvents:6];
    [vie addSubview:shutdown];

}

-(void)star{
   }

-(void)shutdown{
    [self.view removeFromSuperview];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
