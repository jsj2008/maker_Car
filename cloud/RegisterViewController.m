//
//  RegisterViewController.m
//  cloud
//
//  Created by 朱帅 on 2017/3/14.
//  Copyright © 2017年 朱帅. All rights reserved.
//

#import "RegisterViewController.h"
#import "ACAccountManager.h"
#import "lineTextFeild.h"
#import "SVProgressHUD.h"





@interface RegisterViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>
@property(nonatomic,strong)UITextField *username;
@property(nonatomic,strong)UIButton *Image;
@property (weak, nonatomic) IBOutlet UIImageView *back;
@property(nonatomic,strong)UITextField *password;
@property(nonatomic,strong)UITextField *phoneNumber;
@property(nonatomic,strong)UIButton *btn;
@property(nonatomic,strong)lineTextFeild *verti;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *back = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, 50, 50)];
    [back setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(BackToMainpage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    
    self.Image = [[UIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 40, 80, 80, 80)];
     self.Image.backgroundColor = [UIColor clearColor];
    self.Image.layer.borderWidth = 1;
    self.Image.layer.borderColor = [UIColor whiteColor].CGColor;
    self.Image.layer.cornerRadius = 40.0;
    [self.Image addTarget:self action:@selector(PickImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.Image];
    
    NSArray *arr = @[@"昵称",@"密码",@"手机号"];
    for (int i = 0; i<3; i++) {
        UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(20, 220 + i  * 80, 90, 15)];
        text.text = arr[i];
        text.textColor = [UIColor whiteColor];
        [self.view addSubview:text];
        lineTextFeild *fe = [[lineTextFeild alloc]initWithFrame:CGRectMake(text.frame.size.width + 10, 220 + i * 80,self.view.frame.size.width - 130, 25)];
        fe.tag = 1000 +  i;
        fe.delegate = self;
        fe.returnKeyType = UIReturnKeyGo;
        fe.textColor = [UIColor whiteColor];
        fe.backgroundColor = [UIColor clearColor];
        [self.view addSubview:fe];
    }

    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 140, self.view.frame.size.height - 200 , 120, 40)];
    [btn setTitle:@"获取验证码" forState:0];
    btn.backgroundColor = [UIColor clearColor];
    btn.titleLabel.textColor = [UIColor whiteColor];
    [btn setBackgroundImage:[UIImage imageNamed:@"Rectangle 1 copy 5.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(verify:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    self.verti = [[lineTextFeild alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height - 170, self.view.frame.size.width - 170 , 15)];
    self.verti.textColor = [UIColor whiteColor];
    self.verti.delegate = self;
    [self.view addSubview:self.verti];
    
    UIButton *regi = [[UIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 75, self.view.frame.size.height - 90, 140, 60)];
    [regi addTarget:self action:@selector(registerFromAccount) forControlEvents:UIControlEventTouchUpInside];
    regi.backgroundColor = [UIColor clearColor];
    [regi setTitle:@"确认注册" forState:0];
    regi.layer.borderWidth = 0.5;
    regi.layer.borderColor = [UIColor whiteColor].CGColor;
    regi.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:regi];


}





-(void)verify:(UIButton *)sender{
    //正常状态下的背景颜色
    UIColor *mainColor = [UIColor colorWithRed:84/255.0 green:180/255.0 blue:98/255.0 alpha:1.0f];
    //倒计时状态下的颜色
    UIColor *countColor = [UIColor lightGrayColor];
    UILabel *phone = (UILabel *)[self.view viewWithTag:1002];

    [self setTheCountdownButton:sender startWithTime:55 title:@"获取验证码"countDownTitle:@"s" mainColor:mainColor countColor:countColor];
    NSLog(@"%@",phone.text);
    [ACAccountManager checkExist:phone.text callback:^(BOOL exist, NSError *error) {
        if (!error) {
            if (exist) {
                UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"手机号已注册" message:@"手机号已经注册" preferredStyle:1];
                UIAlertAction *act = [UIAlertAction actionWithTitle:@"确认" style:0 handler:nil];
                [aler addAction:act];
                [self presentViewController:aler animated:YES completion:nil];
            }else{
                [ACAccountManager sendVerifyCodeWithAccount:phone.text template:1 callback:^(NSError *error) {
                    if (error) {
                        NSLog(@"%@",error.localizedDescription);
                    }else{
                        NSLog(@"验证码已经发送，请注意查收");
                    }
            }];
            }
        }
    }];
}


-(void)registerFromAccount{
    UILabel *password = (UILabel *)[self.view viewWithTag:1001];
    UILabel *phone = (UILabel *)[self.view viewWithTag:1002];
    NSLog(@"----%@",phone.text);
    NSLog(@"----%@",password.text);
    [ACAccountManager checkVerifyCodeWithAccount:phone.text verifyCode:self.verti.text callback:^(BOOL valid, NSError *error) {
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }else{
            if (valid) {
                [ACAccountManager registerWithPhone:phone.text email:nil password:password.text verifyCode:self.verti.text callback:^(NSString *uid, NSError *error) {
                    if (!error) {
                        [SVProgressHUD showSuccessWithStatus:@"注册成功"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            [self.navigationController popViewControllerAnimated:true];
                        });
                    }else{
                        [SVProgressHUD showErrorWithStatus:@"手机号或者密码错误"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [SVProgressHUD dismiss];
                        });
                    }
                }];
            }else{
                [SVProgressHUD showErrorWithStatus:@"验证码错误"];
                [SVProgressHUD dismiss];
            }
          
        }
    }];
}

#pragma mark - button倒计时
- (void)setTheCountdownButton:(UIButton *)button startWithTime:(NSInteger)timeLine title:(NSString *)title countDownTitle:(NSString *)subTitle mainColor:(UIColor *)mColor countColor:(UIColor *)color {
    //倒计时时间
    __block NSInteger timeOut = timeLine;
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL,0), 1.0 * NSEC_PER_SEC,0);
    dispatch_source_set_event_handler(_timer, ^{
        
        //倒计时结束，关闭
        if (timeOut == 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                button.backgroundColor = mColor;
                [button setTitle:title forState:UIControlStateNormal];
                button.userInteractionEnabled =YES;
                [button setTitle:@"重新获取" forState:0];
            });
        } else {
            int seconds = timeOut % 60;
            NSString *timeStr = [NSString stringWithFormat:@"%0.1d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                button.backgroundColor = color;
                [button setTitle:[NSString stringWithFormat:@"%@%@",timeStr,subTitle]forState:UIControlStateNormal];
                button.userInteractionEnabled =NO;
            });
            timeOut--;
        }
    });
    dispatch_resume(_timer);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return true;
}


-(void)PickImage{
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"选择照片" message:@"选择照片来源" preferredStyle:0];
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"个人专辑" style:0 handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
        
        pickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerC.delegate = self;
        
        pickerC.allowsEditing = YES;
        
        [self presentViewController:pickerC animated:YES completion:nil];
    }];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"相机" style:0 handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
        
        pickerC.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerC.delegate = self;
        
        pickerC.allowsEditing = YES;  
        
        [self presentViewController:pickerC animated:YES completion:nil];
    }];
    
    [aler addAction:album];
    [aler addAction:camera];
    [self presentViewController:aler animated:YES completion:nil];
   
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];

}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.Image setBackgroundImage:img forState:0];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 屏幕上弹
-( void )textFieldDidBeginEditing:(UITextField *)textField
{
    //键盘高度216
    
    //滑动效果（动画）
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
    self.view.frame = CGRectMake(0.0f, -100.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
    
    [UIView commitAnimations];
}   

#pragma mark -屏幕恢复
-( void )textFieldDidEndEditing:(UITextField *)textField
{
    //滑动效果
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //恢复屏幕
    self.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
    
    [UIView commitAnimations];
}


-(void)BackToMainpage{
    [self.navigationController popViewControllerAnimated:YES];
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
