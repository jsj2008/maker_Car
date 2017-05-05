//
//  AI6060.swift
//  AI6060
//
//  Created by __zimu on 16/8/12.
//  Copyright © 2016年 __zimu. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import NetworkExtension.NEHotspotHelper
import Foundation

class AI6060: NSObject {

}

extension String {
    
    subscript (i: Int) -> Character {
        return self[startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(startIndex.advancedBy(r.startIndex)..<startIndex.advancedBy(r.endIndex)))
    }
}

extension Character
{
    func toInt() -> Int
    {
        var intFromCharacter:Int = 0
        for i in String(self).utf8
        {
            intFromCharacter = Int(i)
        }
        return intFromCharacter
    }
    
    func toU8() -> UInt8
    {
        var intFromCharacter:UInt8 = 0
        for i in String(self).utf8
        {
            intFromCharacter = UInt8(i)
        }
        return intFromCharacter
    }
    
    func value() -> Int
    {
        var intFromCharacter:Int = 0
        for i in String(self).utf16
        {
            intFromCharacter = Int(i)
        }
        return intFromCharacter
    }
}

class wController: UIViewController,GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate, UITableViewDataSource, UITableViewDelegate {
    let rc4Key = "Key"
    let magicNumber = "iot"
    let cmdNumber = 3
    var ackData = String()
    var ipaddr = String()
    
    var stable = [Int](count: 256, repeatedValue: 0)
    var sonkey = [Int](count: 256, repeatedValue: 0)
    var tmpPacket = [Int](count: 256, repeatedValue: 0)
    var tmpSeq = [Int](count: 256, repeatedValue: 0)
    var packetData = [String(), String(), String()]
    var seqData = [String(), String(), String()]
    let testDataRetryNum = 150
    let DataRetryNum = [10,10,5]
    var mUdpSocket:GCDAsyncUdpSocket!
    var mSocket:GCDAsyncSocket!
    var mSocket1:GCDAsyncSocket!
    var recvArr:NSMutableArray!;
    var sendButtonAction = false
    var thread1 = NSThread()
    var thread2 = NSThread()
    var tableView : UITableView?
    var items = [""]
    var passText = UITextField()
    var error : NSError?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origin_x    = UIScreen.mainScreen().bounds.origin.x
        let origin_y   = UIScreen.mainScreen().bounds.origin.y
        let origin_w    = UIScreen.mainScreen().bounds.size.width
        let origin_h   = UIScreen.mainScreen().bounds.size.height
        print("\(origin_x), \(origin_y), \(origin_w), \(origin_h)\n")
        let average_w = origin_h / 3
        let average_h = origin_h / 8
        let ssidLabel = UILabel(frame: CGRectMake(10,origin_y,average_w,average_h))
        ssidLabel.text = "SSID"
        self.view.addSubview(ssidLabel)
        let ssidText = UITextField(frame: CGRectMake(120,origin_y,2*average_w,average_h))
        //设置边框样式为圆角矩形
        ssidText.borderStyle = UITextBorderStyle.RoundedRect
        self.view.addSubview(ssidText)
        ssidText.placeholder="请输入SSID"
        ssidText.text = getSSID().0
        let bssidLabel = UILabel(frame: CGRectMake(10,origin_y + average_h,average_w,average_h))
        bssidLabel.text = "MAC"
        self.view.addSubview(bssidLabel)
        let bssidText = UITextField(frame: CGRectMake(120,origin_y + average_h,2*average_w,average_h))
        //设置边框样式为圆角矩形
        bssidText.borderStyle = UITextBorderStyle.RoundedRect
        self.view.addSubview(bssidText)
        bssidText.placeholder="请输入BSSID"
        bssidText.text = getSSID().1
        let passLabel = UITextField(frame: CGRectMake(10,(origin_y + 2 * average_h),average_w,average_h))
        //设置边框样式为圆角矩形
        passLabel.text = "PASSWORD"
        self.view.addSubview(passLabel)
        passText = UITextField(frame: CGRectMake(120,(origin_y + 2 * average_h),2*average_w,average_h))
        passText.borderStyle = UITextBorderStyle.RoundedRect
        self.view.addSubview(passText)
        passText.placeholder="请输入PASSWORD"
        let sendButton = UIButton()
        sendButton.frame = CGRectMake(origin_x,(origin_y + 3 * average_h), origin_w, average_h)
        sendButton.setTitle("send", forState: UIControlState.Normal)
        sendButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.7, alpha: 0.2)
        sendButton.tag = 5
        sendButton.addTarget(self, action: #selector(wController.pressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(sendButton)
        let receLabel = UILabel(frame: CGRectMake(origin_x,(origin_y + 4 * average_h),origin_w,average_h))
        receLabel.text = "IP/MAC"
        receLabel.backgroundColor = UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 0.2)
        receLabel.textAlignment = NSTextAlignment.Center;
        self.view.addSubview(receLabel)
        self.tableView = UITableView(frame: CGRectMake(origin_x,(origin_y + 5 * average_h),origin_w,(origin_h - (origin_y + 5 * average_h))), style: UITableViewStyle.Plain)
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.view.addSubview(self.tableView!)
        //initUdpSocket();
        KSA()
        PRGA()
        if let addr = getWiFiAddress() {
            ipaddr = addr
        } else {
            print("No WiFi address")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0 ..< len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    func crc8_msb(poly:UInt8, cmdNum: Int)->UInt8 {
        var crc:UInt8 = 0x0
        for data in packetData[cmdNum].characters {
            crc = crc ^ UInt8(data.value())
            for _ in 0...7 {
                if(crc & 0x80 != 0x00) {
                    crc = ((crc << 1) ^ poly)
                } else {
                    crc <<= 1
                }
            }
        }
        
        return crc
    }
    
    func KSA() {
        var j = 0;
        for i in 0 ..< 256 {
            stable[i] = i
        }
        for i in 0 ..< 256 {
            let index = i % rc4Key.characters.count
            j = (j + stable[i] + rc4Key[index].toInt()) % 256
            let tmp = stable[i]
            stable[i] = stable[j]
            stable[j] = tmp
        }
    }
    
    func PRGA() {
        var l = 256
        var i = 0, j = 0, m = 1;
        while(l > 0) {
            i = (i + 1) % 256
            j = (j + stable[i]) % 256
            let tmp = stable[i]
            stable[i] = stable[j]
            stable[j] = tmp
            let t  = (stable[j] + stable[i]) % 256
            sonkey[m] = stable[t]
            l -= 1
        }
        
    }
    
    func cmdCryption(cmdNum: Int) {
        for i in 0 ..< packetData[cmdNum].characters.count {
            tmpPacket[i] = (packetData[cmdNum][i].value()) ^ sonkey[i]
            tmpSeq[i] = seqData[cmdNum][i].value() ^ sonkey[0]
        }
        
    }
    
    func addSeqPacket(cmdNum: Int) {
        var value = 0
        for i in 0 ..< packetData[cmdNum].characters.count {
            if(cmdNum == 0) {
                value = ((i << 0) | 0x00)
            } else if(cmdNum == 1) {
                value = ((i << 1) | 0x01)
            } else {
                value = ((i << 2) | 0x02)
            }
            seqData[cmdNum].append(Character(UnicodeScalar(value)))
        }
    }
    
    func setCmdData() {
        for i in 0 ..< cmdNumber {
            if(i == 0) {
                packetData[0] = magicNumber
            } else if(i == 1) {
                let ssidLen = getSSID().0.characters.count
                let passLen = passText.text!.characters.count
                packetData[1].append(Character(UnicodeScalar(ssidLen)))
                packetData[1].append(Character(UnicodeScalar(passLen)))
                var ipData = ipaddr.componentsSeparatedByString(".")
                packetData[1].append(Character(UnicodeScalar(Int(ipData[0])!)))
                packetData[1].append(Character(UnicodeScalar(Int(ipData[1])!)))
                packetData[1].append(Character(UnicodeScalar(Int(ipData[2])!)))
                packetData[1].append(Character(UnicodeScalar(Int(ipData[3])!)))
            } else {
                packetData[2] = getSSID().0 + passText.text!
            }
            let crcData = crc8_msb(0x1D, cmdNum: i)
            packetData[i].append(Character(UnicodeScalar(crcData)))
            addSeqPacket(i)
        }
    }
    
    func sendCmdData() {
        for i in 0 ..< cmdNumber {
            cmdCryption(i)
            for _ in 0 ..< DataRetryNum[i] {
                for k in 0 ..< packetData[i].characters.count {
                    
                    mUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
                    do {
                        try mUdpSocket.enableBroadcast(true)
                    } catch let error as NSError {
                        print(error)
                    }
                    let seqdata = randomStringWithLength(tmpSeq[k] + 1 + 256).dataUsingEncoding(NSUTF8StringEncoding)
                    mUdpSocket.sendData(seqdata, toHost: "255.255.255.255", port: 8300, withTimeout: 2, tag: 0)
                    usleep(5000);
                    let data = randomStringWithLength(tmpPacket[k] + 1).dataUsingEncoding(NSUTF8StringEncoding)
                    mUdpSocket.sendData(data, toHost: "255.255.255.255", port: 8300, withTimeout: 2, tag: 0)
                    usleep(5000);
                    
                    mUdpSocket.close()
                }
            }
        }
    }
    
    func sendTestData() {
        let testData = [1,2,3,4]
        for _ in 0 ..< testDataRetryNum {
            for k in 0 ..< testData.count {
                mUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
                
                do {
                    try mUdpSocket.enableBroadcast(true)
                } catch let error as NSError {
                    print(error)
                }
                let data = randomStringWithLength(testData[k]).dataUsingEncoding(NSUTF8StringEncoding)
                mUdpSocket.sendData(data, toHost: "255.255.255.255", port: 8300, withTimeout: 2, tag: 0)
                usleep(5000);
                mUdpSocket.close()
            }
        }
    }
    
    func thread1Routine() {
        autoreleasepool{
            let curThread = NSThread.currentThread()
            _ = NSRunLoop.currentRunLoop()
            
            while curThread.cancelled == false {
                sendTestData()
                setCmdData()
                sendCmdData()
                packetData[0] = ""
                packetData[1] = ""
                packetData[2] = ""
                seqData[0] = ""
                seqData[1] = ""
                seqData[2] = ""
            }
            
            NSThread.exit()
        }
    }
    
    func thread2Routine(){
        autoreleasepool{
            _ = NSThread.currentThread()
            _ = NSRunLoop.currentRunLoop()
            //var socket:GCDAsyncSocket!
            mSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            do {
                print("Try to open server")
                try mSocket.acceptOnPort(8209)
            } catch let error {
                print("There was a TCP error: \(error)")
            }
            
            NSThread.exit()
        }
    }
    
    func pressed(sender: UIButton) {
        self.passText.resignFirstResponder()
        if(sendButtonAction == false) {
            (sender ).backgroundColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 0.2)
            sendButtonAction = true
            self.thread1 = NSThread(target: self, selector: #selector(wController.thread1Routine), object: nil);
            thread1.start()
            self.thread2 = NSThread(target: self, selector: #selector(wController.thread2Routine), object: nil);
            thread2.start()
        } else {
            (sender ).backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.7, alpha: 0.2)
            sendButtonAction = false
            
            self.thread1.cancel()
            self.thread2.cancel()
        }
        
        
    }
    
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let interface = ptr.memory
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface.ifa_addr.memory.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    if let name = String.fromCString(interface.ifa_name) where name == "en0" {
                        
                        // Convert interface address to a human readable string:
                        var addr = interface.ifa_addr.memory
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        getnameinfo(&addr, socklen_t(interface.ifa_addr.memory.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String.fromCString(hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    func getSSID() -> (String, String){
        if let cfa:NSArray = CNCopySupportedInterfaces() {
            for x in cfa {
                if let dict = CFBridgingRetain(CNCopyCurrentNetworkInfo(x as! CFString)) {
                    let ssid = dict["SSID"]!
                    let mac  = dict["BSSID"]!
                    return (ssid as! String,mac as! String)
                }
            }
        }
        return ("","")
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 获得cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let row=indexPath.row as Int
        cell.textLabel!.text=self.items[row]
        
        return cell;
    }
    
    func initUdpSocket(){
        mUdpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try mUdpSocket.enableBroadcast(true)
        } catch let error as NSError {
            print(error)
        }
        do {
            try mUdpSocket.beginReceiving()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        print("SOCK IT BABY")
        mSocket1 = newSocket
        newSocket.readDataWithTimeout(-1, tag: 0)
    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        var array = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&array, length:data.length)
        let str = String(bytes: array, encoding: NSUTF8StringEncoding)
        ackData.appendContentsOf(sock.connectedHost + "/")
        ackData.appendContentsOf(str!)
        if (([] == items.filter({$0 == self.ackData}))) {
            if(self.items.count == 1 && self.items[0] == "") {
                self.items.removeLast()
                let row = self.items.count
                let index0Path = NSIndexPath(forRow:row,inSection:0)
                self.tableView?.deleteRowsAtIndexPaths([index0Path], withRowAnimation: UITableViewRowAnimation.Fade)
                self.items.append(ackData)
                self.tableView?.insertRowsAtIndexPaths([index0Path], withRowAnimation: UITableViewRowAnimation.Middle)
            } else {
                let row = self.items.count
                let indexPath = NSIndexPath(forRow:row,inSection:0)
                self.items.append(ackData)
                self.tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
            }
        }
        let Data : NSString = "ok"
        sock.writeData(Data.dataUsingEncoding(NSUTF8StringEncoding), withTimeout: 10, tag: 0)
    }
}

