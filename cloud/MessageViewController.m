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
#import "AI6060-Swift.h"
#import "StepSlider.h"
#import "ANDLineChartView.h"
#import "ACCustomDataManager.h"
#import "ACObject.h"



#define kScreenWidth \
([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.width)
#define kScreenHeight \
([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.height)

#define RGB(r,g,b)  [UIColor colorWithRed:r green:g blue:b alpha:1]


@interface MessageViewController ()<ANDLineChartViewDelegate,ANDLineChartViewDataSource>
@property(nonatomic,strong)UIScrollView *MainScrollview;
@property(nonatomic,strong)NSMutableString *currentMsg;
#pragma mark - BackgroundView
@property(nonatomic,strong)UIVisualEffectView *car;
@property(nonatomic,strong)UIVisualEffectView *thermo;
@property(nonatomic,strong)UIVisualEffectView *distance;
@property(nonatomic,strong)UIVisualEffectView *LED;

#pragma mark - Current Tempture and Distance
@property(nonatomic,strong)UILabel *currentTemp;
@property(nonatomic,strong)UILabel *currentDistance;

#pragma mark - thermo and distance Array
@property(nonatomic,strong)NSMutableArray *element;
@property(nonatomic,strong)NSMutableArray *distances;

#pragma mark - thermo and distance chart
@property(nonatomic,strong) ANDLineChartView *line;
@property(nonatomic,strong) ANDLineChartView *distancechart;

#pragma mark - currentStepCycle
@property(nonatomic,strong)NSMutableString *currentThermoCycle;
@property(nonatomic,strong)NSMutableString *currentDistanceCycle;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    
    NSString *back1 = @"660280808080000f0099";
    [self SenMesage:back1];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *back2 = @"66028080808000080099";
        [self SenMesage:back2];
    });
    
    
    
    //Configureation Background Image
    UIImageView *img = [[UIImageView alloc]initWithFrame:self.view.frame];
    img.image = [UIImage imageNamed:@"bubble.jpeg"];
    [self.view addSubview:img];
    
    self.MainScrollview = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.MainScrollview.backgroundColor = [UIColor clearColor];
    self.MainScrollview.contentSize = CGSizeMake(0, 1230);
    [self.view addSubview:self.MainScrollview];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    //Configuration Thermo View
    self.car = [[UIVisualEffectView alloc]initWithFrame:CGRectMake(10, 30, self.view.frame.size.width - 20, 300)];
    self.car.effect = blur;
    [self.MainScrollview addSubview:self.car];
    NSArray *title = @[@"前进",@"后退",@"停止",@"左转",@"右转"];
    for (int i = 0; i<3; i++) {
        ZFRippleButton *rippe = [[ZFRippleButton alloc]initWithFrame:CGRectMake(10, 20 + i * 50, 120, 40)];
        rippe.backgroundColor = [UIColor clearColor];
        rippe.layer.borderColor = [UIColor whiteColor].CGColor;
        rippe.layer.borderWidth =  1;
        rippe.tag = 10000+i;
        [rippe setTitle:title[i] forState:0];
        [rippe addTarget:self action:@selector(Getmeesage:) forControlEvents:UIControlEventTouchUpInside];
        rippe.titleLabel.textColor = [UIColor whiteColor];
        [self.car addSubview:rippe];
    }
    
    NSArray *imgs = @[[UIImage imageNamed:@"左"],[UIImage imageNamed:@"右"]];
    for (int i = 0; i<2; i++) {
        ZFRippleButton *btn = [[ZFRippleButton alloc]initWithFrame:CGRectMake(170 + i *85, 120, 60, 40)];
        btn.tag = 10003+i;
        [btn setImage:imgs[i] forState:0];
        [btn addTarget:self action:@selector(Getmeesage:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.textColor = [UIColor whiteColor];
        [self.car addSubview:btn];
    }
    
    
    StepSlider *sl = [[StepSlider alloc]initWithFrame:CGRectMake(150, 30, 180, 20)];
    sl.maxCount = 3;
    sl.index = 0;
    [sl addTarget:self action:@selector(GearChange:) forControlEvents:UIControlEventValueChanged];
    sl.labels = @[@"第一档",@"第二档",@"第三档"];
    sl.labelColor = [UIColor whiteColor];
    [self.car addSubview:sl];
   
    //Configuration ThermoView
    self.thermo = [[UIVisualEffectView alloc]initWithFrame:CGRectMake(10, 340, kScreenWidth - 20, 330)];
    self.thermo.effect = blur;
    [self.MainScrollview addSubview:self.thermo];
    
    UILabel *la = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 130, 30)];
    la.text = @"是否接收温度";
    la.textColor = [UIColor whiteColor];
    [self.thermo addSubview:la];
    //30,144,255
    CustomSwitch *sw = [[CustomSwitch alloc]initWithFrame:CGRectMake(135, 30,60, 30)];
    sw.isOn = false;
    [sw addTarget:self action:@selector(SwitchUnitChange:) forControlEvents:UIControlEventValueChanged];
    sw.tag = 100001;
    [self.thermo addSubview:sw];
    
    UILabel *la1 = [[UILabel alloc]initWithFrame:CGRectMake(10,70, 80, 30)];
    la1.text = @"显示周期";
    la1.textColor = [UIColor whiteColor];
    [self.thermo addSubview:la1];
    
    GMStepper *stp = [[GMStepper alloc]initWithFrame:CGRectMake(95, 70, 100, 30)];
    stp.tag = 1000001;
    stp.leftButton.titleLabel.textColor = [UIColor whiteColor];
    stp.backgroundColor = [UIColor clearColor];
    stp.layer.borderColor = [UIColor whiteColor].CGColor;
    stp.leftButtonText = @"-";
    stp.rightButtonText = @"+";
    stp.maximumValue = 9;
    stp.value = 1;
    stp.minimumValue = 1;
     self.currentThermoCycle = [NSMutableString stringWithString:[NSString stringWithFormat:@"0%d",(int)stp.value]];
    [stp addTarget:self action:@selector(StepChange:) forControlEvents:UIControlEventValueChanged];
    [self.thermo addSubview:stp];
    
    self.currentTemp = [[UILabel alloc]initWithFrame:CGRectMake(self.thermo.frame.size.width - 120, 20, 100, 100)];
    self.currentTemp.textColor = [UIColor whiteColor];
    self.currentTemp.font = [UIFont systemFontOfSize:30];
    
    [self.thermo addSubview:self.currentTemp];
    
    _line = [[ANDLineChartView alloc]initWithFrame:CGRectMake(0, 125, self.thermo.frame.size.width, 200)];
    _line.delegate = self;
    _line.dataSource = self;
    _line.animationDuration = 0.5;
    [self.thermo addSubview:_line];
    self.element = [NSMutableArray array];
    
    self.distance = [[UIVisualEffectView alloc]initWithFrame:CGRectMake(10, 680, kScreenWidth - 20, 330)];
    self.distance.effect = blur;
    [self.MainScrollview addSubview:self.distance];
    
    
    UILabel *la3 = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 130, 30)];
    la3.text = @"是否接收距离";
    la3.textColor = [UIColor whiteColor];
    [self.distance addSubview:la3];

    
    CustomSwitch *sw2 = [[CustomSwitch alloc]initWithFrame:CGRectMake(135, 30,60, 30)];
    sw2.isOn = false;
    [sw2 addTarget:self action:@selector(SwitchUnitChange:) forControlEvents:UIControlEventValueChanged];
    sw2.tag = 100002;
    [self.distance addSubview:sw2];
    
    UILabel *la4 = [[UILabel alloc]initWithFrame:CGRectMake(10,70, 80, 30)];
    la4.text = @"显示周期";
    la4.textColor = [UIColor whiteColor];
    [self.distance addSubview:la4];
    
    GMStepper *stp2 = [[GMStepper alloc]initWithFrame:CGRectMake(95, 70, 100, 30)];
    stp2.tag = 1000002;
    stp2.leftButton.titleLabel.textColor = [UIColor whiteColor];
    stp2.backgroundColor = [UIColor clearColor];
    stp2.layer.borderColor = [UIColor whiteColor].CGColor;
    stp2.leftButtonText = @"-";
    stp2.rightButtonText = @"+";
    stp2.maximumValue = 9;
    stp2.value = 1;
    stp2.minimumValue = 1;
    self.currentDistanceCycle = [NSMutableString stringWithString:[NSString stringWithFormat:@"0%d",(int)stp2.value]];
    [stp2 addTarget:self action:@selector(StepChange:) forControlEvents:UIControlEventValueChanged];
    [self.distance addSubview:stp2];
    
    
    _distancechart = [[ANDLineChartView alloc]initWithFrame:CGRectMake(0, 125, self.distance.frame.size.width, 200)];
    _distancechart.delegate = self;
    _distancechart.dataSource = self;
    _distancechart.animationDuration = 0.5;
    [self.distance addSubview:_distancechart];
    self.distances = [NSMutableArray array];
    
    
    self.currentDistance = [[UILabel alloc]initWithFrame:CGRectMake(self.distance.frame.size.width - 120, 20, 120, 100)];
    self.currentDistance.textColor = [UIColor whiteColor];
    self.currentDistance.font = [UIFont systemFontOfSize:30];
    [self.distance addSubview:self.currentDistance];
   
    
    self.LED = [[UIVisualEffectView alloc]initWithFrame:CGRectMake(10,1020, kScreenWidth - 20, 200)];
    self.LED.effect = blur;
    [self.MainScrollview addSubview:self.LED];
    NSArray *titl = @[@"LED1点亮",@"LED2点亮"];
    
    for (int i = 0; i<2; i++) {
        UILabel *la = [[UILabel alloc]initWithFrame:CGRectMake(10, 30 + i*40, 100, 30)];
        la.text = titl[i];
        la.textColor = [UIColor whiteColor];
        [self.LED addSubview:la];
    }
    
    CustomSwitch *led1 = [[CustomSwitch alloc]initWithFrame:CGRectMake(120, 30, 80, 30)];
    led1.isOn = false;
    [led1 addTarget:self action:@selector(SwitchUnitChange:) forControlEvents:UIControlEventValueChanged];
    led1.tag = 100003;
    [self.LED addSubview:led1];
    
    CustomSwitch *led2 = [[CustomSwitch alloc]initWithFrame:CGRectMake(120, 70, 80, 30)];
    led2.isOn = false;
    [led2 addTarget:self action:@selector(SwitchUnitChange:) forControlEvents:UIControlEventValueChanged];
    led2.tag = 100004;
    [self.LED addSubview:led2];
    
    
    NSMutableString *defualt = [NSMutableString stringWithString:@"66028080808000000099"];
    [self SenMesage:defualt];
    self.currentMsg = defualt;
    
    [ACCustomDataManager subscribeCustomDataWithSubDomain:@"xinlian01" type:@"topic_type" key:self.deviceid callback:^(NSError *error) {
        if (error) {
            NSLog(@"subscriptError! %@",error.localizedDescription);
        }
    }];
    
    [ACCustomDataManager setCustomMessageHandler:^(NSString *subDomain, NSString *type, NSString *key, ACObject *payload) {
        NSArray *payArr = [payload get:@"payload"];
        
        NSData* decodeData = [[NSData alloc] initWithBase64EncodedString:payArr[0] options:0];
        
        NSLog(@"Decodelength = %ld",decodeData.length);
        
        if (decodeData.length == 5) {
            if ([[decodeData.description substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"c2"]) {
                NSString *temp = [[NSString stringWithFormat:@"%g",(float)strtoul([[decodeData.description substringWithRange:NSMakeRange(5, 4)] UTF8String], 0, 16)/10] stringByAppendingString:@"℃"];
                CGFloat flo = (float)strtoul([[decodeData.description substringWithRange:NSMakeRange(5, 4)] UTF8String], 0, 16)/10;
                self.currentTemp.text = temp;
                [self.element addObject:@(flo)];
                [self.line reloadData];
                self.line.scrollView.contentOffset = CGPointMake(self.distancechart.scrollView.contentSize.width - self.distancechart.frame.size.width + 40, 0);
                
            }else if ([[decodeData.description substringWithRange:NSMakeRange(3, 2)] isEqualToString:@"c3"]){

                
                NSString *decodestr = [self convertDataToHexStr:decodeData];
                NSString *distance1 = [decodestr substringWithRange:NSMakeRange(4, 4)];
                
                unsigned long distancedecimal = strtoul([distance1 UTF8String], 0, 16);
                [self.distances addObject:@((float)distancedecimal/10)];
                self.currentDistance.text = [[NSString stringWithFormat:@"%g",(float)distancedecimal/10] stringByAppendingString:@"cm"];
                [self.distancechart reloadData];
                
                self.distancechart.scrollView.contentOffset = CGPointMake(self.distancechart.scrollView.contentSize.width - self.distancechart.frame.size.width + 40, 0);
                
            }
        }else if (decodeData.length == 10){
            
            NSString *decodestr = [self convertDataToHexStr:decodeData];
            
            
            NSString *thermo = [decodestr substringWithRange:NSMakeRange(4, 4)];
            
            
            NSString *distance1 = [decodestr substringWithRange:NSMakeRange(14, 4)];
            
            unsigned long distancedecimal = strtoul([distance1 UTF8String], 0, 16);
           
            
            
            
            unsigned long thermodecimal = strtoul([thermo UTF8String], 0, 16);
      
            
            [self.element addObject:@((float)thermodecimal/10)];
            
            [self.distances addObject:@((float)distancedecimal/10)];
            
            
            
            
            NSString *ct = [[NSString stringWithFormat:@"%g",(float)thermodecimal/10] stringByAppendingString:@"℃"];
            
            NSString *cd = [[NSString stringWithFormat:@"%g",(float)distancedecimal/10] stringByAppendingString:@"cm"];
            
            self.currentTemp.text = ct;
            self.currentDistance.text = cd;
            
            [self.line reloadData];
            
            [self.distancechart reloadData];
            
            
           
            
        }
    }];
    
    
}
#pragma mark - gearChange Method
-(void)GearChange:(StepSlider *)sender{
    NSString *gear = [NSString stringWithFormat:@"0%ld",sender.index+1];
    [self.currentMsg replaceCharactersInRange:NSMakeRange(12, 2) withString:gear];
    NSLog(@"CurrentMsg = %@",self.currentMsg);
    [self SenMesage:self.currentMsg];
}


#pragma AllSwitch ValueChange Method
-(void)SwitchUnitChange:(CustomSwitch *)sender{
    if (sender.tag == 100001) {
        if (sender.isOn == true) {
         

            [self.currentMsg replaceCharactersInRange:NSMakeRange(14, 2) withString:@"f0"];
            
            [self.currentMsg replaceCharactersInRange:NSMakeRange(16, 2) withString:self.currentThermoCycle];
            [self SenMesage:self.currentMsg];
        }else{
            [self.currentMsg replaceCharactersInRange:NSMakeRange(14, 2) withString:@"0f"];
            [self.currentMsg replaceCharactersInRange:NSMakeRange(16, 2) withString:@"00"];
            [self SenMesage:self.currentMsg];
        }
    }else if (sender.tag == 100002){
        if (sender.isOn == true) {
            [self.currentMsg replaceCharactersInRange:NSMakeRange(14, 2) withString:@"80"];
            [self.currentMsg replaceCharactersInRange:NSMakeRange(16, 2) withString:self.currentDistanceCycle];
            [self SenMesage:self.currentMsg];
        }else{
            [self.currentMsg replaceCharactersInRange:NSMakeRange(14, 2) withString:@"08"];
            [self.currentMsg replaceCharactersInRange:NSMakeRange(16, 2) withString:@"00"];
            [self SenMesage:self.currentMsg];
        }

    }else if (sender.tag == 100003){
        if (sender.isOn == true) {
            [self.currentMsg replaceCharactersInRange:NSMakeRange(14, 2) withString:@"0a"];
            [self SenMesage:self.currentMsg];
        }else{
            [self.currentMsg replaceCharactersInRange:NSMakeRange(14, 2) withString:@"a0"];
            [self SenMesage:self.currentMsg];
        }
    }else if (sender.tag == 100004){
        if (sender.isOn == true) {
            [self.currentMsg replaceCharactersInRange:NSMakeRange(14, 2) withString:@"1a"];
            [self SenMesage:self.currentMsg];
        }else{
            [self.currentMsg replaceCharactersInRange:NSMakeRange(14, 2) withString:@"a1"];
            [self SenMesage:self.currentMsg];
        }
    }
}

#pragma mark - StepChange
-(void)StepChange:(GMStepper *)step{
    if (step.tag == 1000001) {
        self.currentThermoCycle = [NSMutableString stringWithFormat:@"0%d",(int)step.value];
    }else{
        self.currentDistanceCycle = [NSMutableString stringWithFormat:@"0%d",(int)step.value];
    }
    
}

#pragma mark - AndLineChart Delegate and Datasource
-(NSUInteger)numberOfElementsInChartView:(ANDLineChartView *)chartView{
    if (chartView == self.line) {
        return _element.count;
    }
    return _distances.count;
}

-(NSUInteger)numberOfGridIntervalsInChartView:(ANDLineChartView *)chartView{
    return 8;
}

-(CGFloat)maxValueForGridIntervalInChartView:(ANDLineChartView *)chartView{
    if (chartView == self.distancechart) {
        return 100;
    }
    return 40;
}

-(CGFloat)minValueForGridIntervalInChartView:(ANDLineChartView *)chartView{
    return -4;
}

- (CGFloat)chartView:(ANDLineChartView *)graphView valueForElementAtRow:(NSUInteger)row{
    if (graphView == self.line) {
        return [(NSNumber*)_element[row] floatValue];
    }else{
        return [(NSNumber *)_distances[row] floatValue];
    }
}


- (NSString*)chartView:(ANDLineChartView *)graphView descriptionForGridIntervalValue:(CGFloat)interval{
    return [NSString stringWithFormat:@"%.1f",interval];
}

- (CGFloat)chartView:(ANDLineChartView *)graphView spacingForElementAtRow:(NSUInteger)row{
    return 30;
}

#pragma mark - communicate Code

-(void)Getmeesage:(UIButton *)sender{
    if (sender.tag == 10000) {
        [self.currentMsg replaceCharactersInRange:NSMakeRange(4, 8) withString:@"ffffffff"];
        [self.currentMsg replaceCharactersInRange:NSMakeRange(12, 2) withString:@"01"];
        [self SenMesage:self.currentMsg];

    }else if(sender.tag == 10001){
        [self.currentMsg replaceCharactersInRange:NSMakeRange(4, 8) withString:@"00000000"];
        [self.currentMsg replaceCharactersInRange:NSMakeRange(12, 2) withString:@"01"];

        [self SenMesage:self.currentMsg];
    }else if(sender.tag == 10002){
        [self.currentMsg replaceCharactersInRange:NSMakeRange(4, 8) withString:@"80808080"];

        [self SenMesage:self.currentMsg];

    }else if (sender.tag == 10003){
        [self.currentMsg replaceCharactersInRange:NSMakeRange(4, 8) withString:@"80ff8080"];
        [self SenMesage:self.currentMsg];
    }else if(sender.tag == 10004){
        [self.currentMsg replaceCharactersInRange:NSMakeRange(4, 8) withString:@"ff808080"];
        [self SenMesage:self.currentMsg];
    }

}

- (void)comeHome:(UIApplication *)application {
    NSLog(@"进入后台");
}



-(void)SenMesage:(NSString *)packge{
    NSData *data = [self convertHexStrToData:packge];
    ACDeviceMsg *msg = [[ACDeviceMsg alloc]initWithCode:89 binaryData:data];
    [ACBindManager sendToDeviceWithOption:ACDeviceCommunicationOptionOnlyCloud SubDomain:@"xinlian01" physicalDeviceId:self.physicalDeviceId msg:msg callback:^(ACDeviceMsg *responseMsg, NSError *error) {
        if (!error) {
            NSLog(@"发送消息 %@",packge);
            NSString *s = [[NSString alloc]initWithData:responseMsg.payload encoding:NSUTF8StringEncoding];
            if (s != nil) {
            }else{
            }
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
}

- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
