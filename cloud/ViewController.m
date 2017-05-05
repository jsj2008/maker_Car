//
//  ViewController.m
//  cloud
//
//  Created by 朱帅 on 2017/3/13.
//  Copyright © 2017年 朱帅. All rights reserved.
//

#import "ViewController.h"
#import "ACWifiLinkManager.h"
#import "ACloudLib.h"
#import "ACAccountManager.h"
#import "RegisterViewController.h"
#import "SVProgressHUD.h"
#import "DeviceViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
@interface ViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *Username;
@property (nonatomic, strong) UITextField *password;
@property (weak, nonatomic) IBOutlet UIImageView *back;
@property(nonatomic,strong)UIButton *btn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //zapfino
    NSLog(@"%@", [ACloudLib getMajorDomain]);
    NSLog(@"%zd", [ACloudLib getMajorDomainId]);
    
    UILabel *le = [[UILabel alloc]initWithFrame:CGRectMake(self.view.center.x - 75, 120, 150, 40)];
    le.textAlignment = NSTextAlignmentCenter;
    le.text = @"Sharelink";
    le.font = [UIFont fontWithName:@"zapfino" size:25];
    le.textColor = [UIColor whiteColor];
    [self.view addSubview:le];
    
    self.Username = [[UITextField alloc]initWithFrame:CGRectMake(self.view.center.x - 60, self.view.center.y-40, 120, 35)];
    self.Username.textAlignment = NSTextAlignmentCenter;
    self.Username.placeholder = @"Phone";
    self.Username.text = @"18327683412";
    self.Username.backgroundColor = [UIColor clearColor];
    self.Username.returnKeyType = UIReturnKeyNext;
    self.Username.delegate = self;
    self.Username.textColor = [UIColor whiteColor];
    [self.view addSubview:self.Username];
    
    self.password = [[UITextField alloc]initWithFrame:CGRectMake(self.view.center.x - 60, self.view.center.y + 5, 120, 35)];
    self.password.textAlignment = NSTextAlignmentCenter;
    self.password.placeholder = @"Password";
    self.password.text = @"122313aq";
    self.password.backgroundColor = [UIColor clearColor];
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.textColor = [UIColor whiteColor];
    self.password.delegate = self;
    self.password.secureTextEntry = true;
    [self.view addSubview:self.password];
    
    [_Username setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_password setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    UIView *vie = [[UIView alloc]initWithFrame:CGRectMake(30, self.view.center.y, self.view.frame.size.width - 60, 0.5)];
    vie.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:vie];
    
    self.btn = [[UIButton alloc]initWithFrame:CGRectMake(30, self.view.frame.size.height - 150, self.view.frame.size.width - 60, 69)];
    self.btn.titleLabel.textColor = [UIColor blackColor];
    [self.btn setTintColor:[UIColor whiteColor]];
    [self.btn setBackgroundImage:[UIImage imageNamed:@"Rectangle 1 copy 5"] forState:0];
    [self.btn addTarget:self action:@selector(star) forControlEvents:UIControlEventTouchUpInside];
    self.btn.titleLabel.font = [UIFont systemFontOfSize:25];
    self.btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.btn setTitle:@"Connect" forState:0];
    [self.view addSubview:self.btn];
    
    UILabel *labe = [[UILabel alloc]initWithFrame:CGRectMake(40, self.view.frame.size.height - 60, 160, 15)];
    labe.text = @"Don't have account?";
    labe.font = [UIFont systemFontOfSize:15];
    labe.textColor = [UIColor whiteColor];
    [self.view addSubview:labe];
    
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(205, self.view.frame.size.height - 60, 85, 15)];
    [btn1 setTitle:@"Tap Here" forState:0];
    btn1.titleLabel.textColor = [UIColor whiteColor];
    btn1.backgroundColor = [UIColor clearColor];
    btn1.titleLabel.textAlignment = NSTextAlignmentLeft;
    btn1.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(Reigster) forControlEvents:UIControlEventTouchUpInside];
    self.navigationController.navigationBar.hidden = YES;
    
    NSLog(@"ip地址:%@",[self getIPAddresses]);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)star{
  [ACAccountManager loginWithAccount:self.Username.text password:self.password.text callback:^(NSString *uid, NSError *error) {
      if (!error) {
          [SVProgressHUD showSuccessWithStatus:@"登录成功!"];
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              [SVProgressHUD dismiss];
              DeviceViewController *devi = [[DeviceViewController alloc]init];
              [self.navigationController pushViewController:devi animated:YES];
          });
      }else{
          NSLog(@"%@",error.localizedDescription);
      }
  }];
}

- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

-(void)Reigster{
    RegisterViewController *regi = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"regi"];
    [self.navigationController pushViewController:regi animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
