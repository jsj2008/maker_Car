//
//  XLAI6060.m
//  XLKJCloudSDK
//
//  Created by Apple on 17/4/27.
//  Copyright © 2017年 XLKJ. All rights reserved.
//

#import "XLAI6060.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NEHotspotHelper.h>

@interface XLAI6060()<GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) NSString *rc4Key;
@property (nonatomic, strong) NSString *magicNumber;
@property (nonatomic, assign) NSInteger cmdNumber;
@property (nonatomic, strong) NSMutableString *ackData;
@property (nonatomic, strong) NSString *ipaddr;

@property (nonatomic, strong) NSMutableArray *stable;
@property (nonatomic, strong) NSMutableArray *sonkey;
@property (nonatomic, strong) NSMutableArray *tmpPacket;
@property (nonatomic, strong) NSMutableArray *tmpSeq;
@property (nonatomic, strong) NSMutableArray *packetData;
@property (nonatomic, strong) NSMutableArray *seqData;
@property (nonatomic, assign) NSInteger testDataRetryNum;
@property (nonatomic, strong) NSArray *DataRetryNum;
@property (nonatomic, strong) GCDAsyncUdpSocket *mUdpSocket;
@property (nonatomic, strong) GCDAsyncSocket *mSocket;
@property (nonatomic, strong) GCDAsyncSocket *mSocket1;
@property (nonatomic, strong) NSMutableArray *recvArr;
@property (nonatomic, assign) BOOL sendButtonAction;
@property (nonatomic, strong) NSThread *thread1;
@property (nonatomic, strong) NSThread *thread2;

@property (nonatomic, strong) NSTimer *timoutTimer;


@end

@implementation XLAI6060

- (void)setUp {
    
    _sendButtonAction = NO;
    _rc4Key = @"Key";
    _magicNumber = @"iot";
    _cmdNumber = 3;
    _ackData = [NSMutableString string];
    _ipaddr = [NSString string];
    _stable = [NSMutableArray array];
    _sonkey = [NSMutableArray array];
    _tmpPacket = [NSMutableArray array];
    _tmpSeq = [NSMutableArray array];
    
    for (int i = 0; i < 256; i++) {
        [_tmpPacket addObject:[NSData data]];
        [_tmpSeq addObject:[NSData data]];
        [_sonkey addObject:@0];
        [_stable addObject:@0];
    }
    
    _packetData = [NSMutableArray arrayWithObjects:[NSMutableData data], [NSMutableData data], [NSMutableData data], nil];
    _seqData = [NSMutableArray arrayWithObjects:[NSMutableData data], [NSMutableData data], [NSMutableData data], nil];
    _testDataRetryNum = 150;
    _DataRetryNum = @[@10,@10,@5];
    
    [self KSA];
    [self PRGA];
    
    NSString *addr = [self getWiFiAddress];
    if (addr) {
        _ipaddr = addr;
    }
    
}

- (NSString *)randomStringWithLength:(NSInteger)len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    
    for (int i=0; i < len; i++){
        UInt32 length = (UInt32)letters.length;
        UInt32 rand = arc4random_uniform(length);
        [randomString appendString:[letters substringWithRange:NSMakeRange(rand, 1)]];
        
    }
    
    return randomString;
    
}

- (UInt8)crc8_msbPoly:(UInt8)poly cmdNum:(int)cmdnum {
    
    UInt8 crc = 0x0;
    
    NSData *packStr = _packetData[cmdnum];
    
    for (int i = 0; i < packStr.length; i++) {
        
        NSData *d = [packStr subdataWithRange:NSMakeRange(i, 1)];
        
        UInt8 a = 0;
        
        [d getBytes:&a length:1];
        crc = crc ^ a;
        for (int j = 0; j < 8; j++) {
            if((crc & 0x80) != 0x00) {
                crc = ((crc << 1) ^ poly);
            } else {
                crc <<= 1;
            }
        }

    }
    return crc;
    
}

- (void)KSA {
    
    int j = 0;
    
    for (int i = 0; i < 256; i++) {
        _stable[i] = @(i);
    }
    
    for (int i = 0; i < 256; i++) {
        int index = i % _rc4Key.length;
        j = (j + [_stable[i] intValue] + [_rc4Key characterAtIndex:index]) % 256;
        int tmpi = [_stable[i] intValue];
        int tmpj = [_stable[j] intValue];
        _stable[i] = @(tmpj);
        _stable[j] = @(tmpi);
    }
    
}

- (void)PRGA {
    
    int l = 256;
    
    int i = 0, j = 0, m = 0;
    
    while (l > 0) {
        i = (i + 1) % 256;
        j = (j + [_stable[i] intValue]) % 256;
        int tmpi = [_stable[i] intValue];
        int tmpj = [_stable[j] intValue];
        _stable[i] = @(tmpj);
        _stable[j] = @(tmpi);
        int t = ([_stable[j] intValue] + [_stable[i] intValue]) % 256;
        _sonkey[m++] = _stable[t];
        l--;
    }    
    
}

- (void)cmdCryption:(int)cmdNum {
    
    NSData *packetStr = _packetData[cmdNum];
    NSData *seqStr = _seqData[cmdNum];
    for (int i = 0; i < packetStr.length; i++) {
        
        int a = 0,b = 0;
        
        NSData *ad = [packetStr subdataWithRange:NSMakeRange(i, 1)];
        NSData *bd = [seqStr subdataWithRange:NSMakeRange(i, 1)];
        
        [ad getBytes:&a length:1];
        [bd getBytes:&b length:1];
        
        int a1 = a ^ [_sonkey[i] intValue];
        int b1 = b ^ [_sonkey[0] intValue];
        
        _tmpPacket[i] = [NSData dataWithBytes:&a1 length:1];
        _tmpSeq[i] = [NSData dataWithBytes:&b1 length:1];
        
    }
    
}

- (void)addSeqPacket:(int)cmdNum {
    
    int value = 0;
    
    NSData *packetStr = _packetData[cmdNum];
    
    NSMutableData *tmpd = [NSMutableData data];
    
    for (int i = 0; i < packetStr.length; i++) {
        if(cmdNum == 0) {
            value = ((i << 0) | 0x00);
        } else if(cmdNum == 1) {
            value = ((i << 1) | 0x01);
        } else {
            value = ((i << 2) | 0x02);
        }
        
        [tmpd appendBytes:&value length:1];

    }
    
    _seqData[cmdNum] = tmpd;
    
}


- (void)setCmdData {
    
    for (int i = 0; i < _cmdNumber; i++) {
        
        if (i == 0) {
            
            char d[3] = {0x69,0x6f,0x74};
            _packetData[0] = [NSMutableData dataWithBytes:d length:3];
            
        } else if (i == 1) {
            
            NSArray *arr = [_ipaddr componentsSeparatedByString:@"."];
            
            NSMutableData *data = [NSMutableData data];
            
            int ssidLen = (int)[[self getSSID][@"SSID"] length];
            
            [data appendBytes:&ssidLen length:1];
            
            int passLen = (int)_passText.length;
            
            [data appendBytes:&passLen length:1];
            
            for (int j = 0; j < arr.count; j++) {
                int tmp = [arr[j] intValue];
                
                [data appendBytes:&tmp length:1];

            }
            _packetData[1] = data;
            
        } else {
            
            NSString *tms = [NSString stringWithFormat:@"%@%@",[self getSSID][@"SSID"],_passText];
            
            NSMutableData *data = [NSMutableData data];
            
            for (int j = 0; j < tms.length; j++) {
                
                int a = [tms characterAtIndex:j];
                
                [data appendBytes:&a length:1];
                
            }
            
            _packetData[2] = data;
        
        }
        
        UInt8 crcData = [self crc8_msbPoly:0x1D cmdNum:i];
        [_packetData[i] appendBytes:&crcData length:1];
        
        [self addSeqPacket:i];
    }

}



- (void)sendCmdData {
    
    for (int i = 0; i < _cmdNumber; i++) {
        [self cmdCryption:i];
        for (int j = 0; j < [_DataRetryNum[i] intValue]; j++) {
            NSData *s = _packetData[i];
            for (int k = 0; k < s.length; k++) {
                
                _mUdpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
                [_mUdpSocket enableBroadcast:YES error:nil];
                
                int a = 0;
                
                NSData *ad = _tmpSeq[k];
                
                [ad getBytes:&a length:1];
                
                NSData *seqdata = [[self randomStringWithLength:a + 257] dataUsingEncoding:NSUTF8StringEncoding];
                
                [_mUdpSocket sendData:seqdata toHost:@"255.255.255.255" port:8300 withTimeout:2 tag:0];
                usleep(5000);
                
                int b = 0;
                
                NSData *bd = _tmpPacket[k];
                
                [bd getBytes:&b length:1];
                
                NSData *data = [[self randomStringWithLength:b + 1] dataUsingEncoding:NSUTF8StringEncoding];
                
                [_mUdpSocket sendData:data toHost:@"255.255.255.255" port:8300 withTimeout:2 tag:0];
                usleep(5000);
                
                [_mUdpSocket close];
                
            }
        }
    }
    
}


- (void)sendTestData {
    NSArray *testData = @[@1,@2,@3,@4];
    
    for (int k = 0; k < _testDataRetryNum; k++) {
        
        for (int i = 0; i < testData.count; i++) {
            _mUdpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            [_mUdpSocket enableBroadcast:YES error:nil];
            
            NSData *data = [[self randomStringWithLength:[testData[i] intValue]] dataUsingEncoding:NSUTF8StringEncoding];
            [_mUdpSocket sendData:data toHost:@"255.255.255.255" port:8300 withTimeout:2 tag:0];
            usleep(5000);
            
            [_mUdpSocket close];
        }
    }
}

- (void)thread1Routine {
    
    @autoreleasepool {
        NSThread *curThread = [NSThread currentThread];
        
        while (curThread.cancelled == NO) {
            [self sendTestData];
            [self setCmdData];
            [self sendCmdData];
        }
        
        [NSThread exit];

    }
}


- (void)thread2Routine {
    
    @autoreleasepool {
        
        _mSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_mSocket acceptOnPort:8209 error:nil];
        
        [NSThread exit];
        
    }
}

- (void)configWithTimeOut:(NSTimeInterval)timeOut {

    self.thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(thread1Routine) object:nil];
    [_thread1 start];
    self.thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(thread2Routine) object:nil];
    [_thread2 start];
    
    if (_timoutTimer.isValid) {
        [_timoutTimer invalidate];
        _timoutTimer = nil;
    }
    _timoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeOut target:self selector:@selector(stopConfig) userInfo:nil repeats:NO];

}

- (void)stopConfig {
    
    [self.thread1 cancel];
    [self.thread2 cancel];
    
}

- (void)config {
    
    if (_sendButtonAction == NO) {
        _sendButtonAction = YES;
        self.thread1 = [[NSThread alloc]initWithTarget:self selector:@selector(thread1Routine) object:nil];
        [_thread1 start];
        self.thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(thread2Routine) object:nil];
        [_thread2 start];
        
    } else {
        _sendButtonAction = NO;
        [self.thread1 cancel];
        [self.thread2 cancel];
    }
}



- (NSString *)getWiFiAddress {
    
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}



- (void)initUdpSocket {
    
    _mUdpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [_mUdpSocket enableBroadcast:YES error:nil];
    
    [_mUdpSocket beginReceiving:nil];
    
}


- (NSDictionary *)getSSID {
    
    NSArray *cfa = CFBridgingRelease(CNCopySupportedInterfaces());
    
    for (NSString *x in cfa) {
        
        NSDictionary *dict = CFBridgingRelease(CFBridgingRetain(CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)x))));
        return dict;
    }
    return [NSDictionary new];
    
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    _mSocket1 = newSocket;
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *d = @"ok";
    [sock writeData:[d dataUsingEncoding:NSUTF8StringEncoding] withTimeout:10 tag:0];

}



@end
