

#import "XJDeviceTool.h"
#import "sys/utsname.h"
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#include <sys/sysctl.h>
#include <mach/mach.h>
#import <UIKit/UIPasteboard.h>
#import "UICKeyChainStore.h"
#import "Reachability.h"
#import "Test+Pass.h"

static NSString *XJUUIDCache = nil;

static NSString *const XJUUID = @"com.xj.uuid";
static NSString *const XJAppUUID = @"com.xj.appuuid";
static NSString *const XJPbType = @"com.xj.pb";
static NSString *const XJPbSlotID = @"com.xj.pbid";
static int const XJUUIDRedundancySlots = 100;
//网络类型
typedef NS_ENUM(NSInteger,NetworkStrengthType) {
    NetworkStrengthType_Hight = 3,
    NetworkStrengthType_Medium = 2,
    NetworkStrengthType_Low = 1
};

// 设备型号的枚举值
typedef NS_ENUM(NSUInteger, DiviceType) {
    iPhone_1G = 0,
    iPhone_3G,
    iPhone_3GS,
    iPhone_4,
    iPhone_4_Verizon,
    iPhone_4S,
    iPhone_5_GSM,
    iPhone_5_CDMA,
    iPhone_5C_GSM,
    iPhone_5C_GSM_CDMA,
    iPhone_5S_GSM,
    iPhone_5S_GSM_CDMA,
    iPhone_6,
    iPhone_6_Plus,
    iPhone_6S,
    iPhone_6S_Plus,
    iPhone_SE,
    Chinese_iPhone_7,
    Chinese_iPhone_7_Plus,
    American_iPhone_7,
    American_iPhone_7_Plus,
    Chinese_iPhone_8,
    Chinese_iPhone_8_Plus,
    Chinese_iPhone_X,
    Global_iPhone_8,
    Global_iPhone_8_Plus,
    Global_iPhone_X,
    iPhone_XS,
    iPhone_XS_Max,
    iPhone_XR,
    
    iPod_Touch_1G,
    iPod_Touch_2G,
    iPod_Touch_3G,
    iPod_Touch_4G,
    iPod_Touch_5Gen,
    iPod_Touch_6G,
    
    iPad_1,
    iPad_3G,
    iPad_2_WiFi,
    iPad_2_GSM,
    iPad_2_CDMA,
    iPad_3_WiFi,
    iPad_3_GSM,
    iPad_3_CDMA,
    iPad_3_GSM_CDMA,
    iPad_4_WiFi,
    iPad_4_GSM,
    iPad_4_CDMA,
    iPad_4_GSM_CDMA,
    iPad_Air,
    iPad_Air_Cellular,
    iPad_Air_2_WiFi,
    iPad_Air_2_Cellular,
    iPad_Pro_97inch_WiFi,
    iPad_Pro_97inch_Cellular,
    iPad_Pro_129inch_WiFi,
    iPad_Pro_129inch_Cellular,
    iPad_Mini,
    iPad_Mini_WiFi,
    iPad_Mini_GSM,
    iPad_Mini_CDMA,
    iPad_Mini_GSM_CDMA,
    iPad_Mini_2,
    iPad_Mini_2_Cellular,
    iPad_Mini_3_WiFi,
    iPad_Mini_3_Cellular,
    iPad_Mini_4_WiFi,
    iPad_Mini_4_Cellular,
    iPad_5_WiFi,
    iPad_5_Cellular,
    iPad_Pro_129inch_2nd_gen_WiFi,
    iPad_Pro_129inch_2nd_gen_Cellular,
    iPad_Pro_105inch_WiFi,
    iPad_Pro_105inch_Cellular,
    iPad_6,
    
    appleTV2,
    appleTV3,
    appleTV4,
    
    i386Simulator,
    x86_64Simulator,
    
    iUnknown,
};

@interface XJDeviceTool ()
@property (nonatomic, assign) DiviceType iDevice;
@property (nonatomic,strong) NSString *networkState;

@end
@implementation XJDeviceTool

/**
 测试添加私有属性

 */
- (id)info:(Test *)test {
    test.mmm = @"test-mmm";
    [test privateMethod];
    NSString *obj = [NSString stringWithFormat:@"%@-%@",test.name,test.mmm];
    NSLog(@"log>>> %@\n",obj);
    return obj;
}

+ (instancetype)shareManager {
    static XJDeviceTool *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XJDeviceTool alloc] init];
        manager.iDevice = [self transformMachineToIdevice];
    });
    return manager;
}

- (id)info {
    double start = CFAbsoluteTimeGetCurrent();
    
    @autoreleasepool {
    
    NSString *infoObj = @"";
    //save uuid to keychain...
    UICKeyChainStore *keychainStore = [UICKeyChainStore keyChainStore];
    if (!keychainStore[@"uuid"]) {
        NSString *uuid = [XJDeviceTool value];
        keychainStore[@"uuid"] = uuid;
    }

    NSString *devName = [self getDiviceName];
    NSString *criber = [self getcriberCellularProvider];
    NSString *version = [self getInitialVersion];
    NSString *cpu = [self getCPUProcessor];
    int64_t totalMemory = [self getTotalMemory];
    int64_t freeMemory = [self getFreeMemory];
    
    NSString *totalMemoryStr = [NSString stringWithFormat:@" %.2f MB", totalMemory/1024/1024.0];
    NSString *freeMemoryStr = [NSString stringWithFormat:@" %.2f MB", freeMemory/1024/1024.0];
    NSString *cpuCount = [NSString stringWithFormat:@"%.1f%%",[self getCPUUsage]];
   
    NSString *networkStrength = [self getNetworkStrength];
    
    self.networkState = [self currentNetworkType];
    //判空
    if (!keychainStore[@"uuid"]) {
        NSString *uuid = [XJDeviceTool value];
        keychainStore[@"uuid"] = uuid;
    }
    if (!devName) {
        devName = @"";
    }
    if (!criber) {
        criber = @"";
    }
    if (!version) {
        version = @"";
    }
    if (!cpu) {
        cpu = @"";
    }
    if (!cpuCount) {
        cpuCount = @"";
    }
    if (!totalMemoryStr) {
        totalMemoryStr = @"";
    }
    if (!freeMemoryStr) {
        freeMemoryStr = @"";
    }
    if (!self.networkState) {
        self.networkState = @"";
    }
    
    if (!networkStrength) {
        networkStrength = @"";
    }
    
    NSArray *object = [NSArray arrayWithObjects:keychainStore[@"uuid"],devName,criber,version,cpu,cpuCount,totalMemoryStr,freeMemoryStr,self.networkState,networkStrength, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"iOS_UUID",@"iOS_设备名称",@"iOS_运营商",@"iOS_APP版本",@"iOS_CPU",@"iOS_CPU百分比",@"iOS_内存大小",@"iOS_可用内存",@"iOS_设备网络",@"iOS_网络强度", nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjects:object forKeys:keys];
    infoObj = [self convertToJsonData:dic];
    NSLog(@"show info %@\n",infoObj);
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:infoObj message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
//    [alert show];
    double endtime = CFAbsoluteTimeGetCurrent();
    NSLog(@"coust time %f\n",endtime - start);
        
    return infoObj;
    }
}

#pragma mark - 网络类型
- (NSString *)currentNetworkType {

    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];

    NSString *networkType = @"";
    switch (internetStatus) {
        case ReachableViaWiFi:
            networkType = @"NetWorkTypeWiFi";
            break;

        case ReachableViaWWAN:
            networkType = @"NetWorkTypeWWAN";
            break;

        case NotReachable:
            networkType = @"NetWorkTypeNone";
            break;
            
        default: networkType = @"error privacy";
            break;
    }

    return networkType;
}

- (NSString *)getDiviceName {
    return iDeviceNameContainer[self.iDevice];
}

- (NSString *)getInitialVersion {
    return initialFirmwareContainer[self.iDevice];
}

- (NSString *)getCPUProcessor {
    return CPUNameContainer[self.iDevice];
}

- (float)getCPUUsage {
    float cpu = 0;
    NSArray *cpus = [self getPerCPUUsage];
    if (cpus.count == 0) {
        return -1;
    }
    for (NSNumber *n in cpus) {
        cpu +=n.floatValue;
    }
    return cpu;
}

#pragma mark - Private Method
+ (DiviceType)transformMachineToIdevice{
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machineString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([machineString isEqualToString:@"iPhone1,1"])   return iPhone_1G;
    if ([machineString isEqualToString:@"iPhone1,2"])   return iPhone_3G;
    if ([machineString isEqualToString:@"iPhone2,1"])   return iPhone_3GS;
    if ([machineString isEqualToString:@"iPhone3,1"])   return iPhone_4;
    if ([machineString isEqualToString:@"iPhone3,3"])   return iPhone_4_Verizon;
    if ([machineString isEqualToString:@"iPhone4,1"])   return iPhone_4S;
    if ([machineString isEqualToString:@"iPhone5,1"])   return iPhone_5_GSM;
    if ([machineString isEqualToString:@"iPhone5,2"])   return iPhone_5_CDMA;
    if ([machineString isEqualToString:@"iPhone5,3"])   return iPhone_5C_GSM;
    if ([machineString isEqualToString:@"iPhone5,4"])   return iPhone_5C_GSM_CDMA;
    if ([machineString isEqualToString:@"iPhone6,1"])   return iPhone_5S_GSM;
    if ([machineString isEqualToString:@"iPhone6,2"])   return iPhone_5S_GSM_CDMA;
    if ([machineString isEqualToString:@"iPhone7,2"])   return iPhone_6;
    if ([machineString isEqualToString:@"iPhone7,1"])   return iPhone_6_Plus;
    if ([machineString isEqualToString:@"iPhone8,1"])   return iPhone_6S;
    if ([machineString isEqualToString:@"iPhone8,2"])   return iPhone_6S_Plus;
    if ([machineString isEqualToString:@"iPhone8,4"])   return iPhone_SE;
    
    if ([machineString isEqualToString:@"iPhone9,1"])   return Chinese_iPhone_7;
    if ([machineString isEqualToString:@"iPhone9,2"])   return Chinese_iPhone_7_Plus;
    if ([machineString isEqualToString:@"iPhone9,3"])   return American_iPhone_7;
    if ([machineString isEqualToString:@"iPhone9,4"])   return American_iPhone_7_Plus;
    if ([machineString isEqualToString:@"iPhone10,1"])  return Chinese_iPhone_8;
    if ([machineString isEqualToString:@"iPhone10,4"])  return Global_iPhone_8;
    if ([machineString isEqualToString:@"iPhone10,2"])  return Chinese_iPhone_8_Plus;
    if ([machineString isEqualToString:@"iPhone10,5"])  return Global_iPhone_8_Plus;
    if ([machineString isEqualToString:@"iPhone10,3"])  return Chinese_iPhone_X;
    if ([machineString isEqualToString:@"iPhone10,6"])  return Global_iPhone_X;
    if ([machineString isEqualToString:@"iPhone11,2"])  return iPhone_XS;
    if ([machineString isEqualToString:@"iPhone11,4"] || [machineString isEqualToString:@"iPhone11,6"])  return iPhone_XS_Max;
    if ([machineString isEqualToString:@"iPhone11,8"])  return iPhone_XR;
    
    if ([machineString isEqualToString:@"iPod1,1"])     return iPod_Touch_1G;
    if ([machineString isEqualToString:@"iPod2,1"])     return iPod_Touch_2G;
    if ([machineString isEqualToString:@"iPod3,1"])     return iPod_Touch_3G;
    if ([machineString isEqualToString:@"iPod4,1"])     return iPod_Touch_4G;
    if ([machineString isEqualToString:@"iPod5,1"])     return iPod_Touch_5Gen;
    if ([machineString isEqualToString:@"iPod7,1"])     return iPod_Touch_6G;
    
    if ([machineString isEqualToString:@"iPad1,1"])     return iPad_1;
    if ([machineString isEqualToString:@"iPad1,2"])     return iPad_3G;
    if ([machineString isEqualToString:@"iPad2,1"])     return iPad_2_WiFi;
    if ([machineString isEqualToString:@"iPad2,2"])     return iPad_2_GSM;
    if ([machineString isEqualToString:@"iPad2,3"])     return iPad_2_CDMA;
    if ([machineString isEqualToString:@"iPad2,4"])     return iPad_2_CDMA;
    if ([machineString isEqualToString:@"iPad2,5"])     return iPad_Mini_WiFi;
    if ([machineString isEqualToString:@"iPad2,6"])     return iPad_Mini_GSM;
    if ([machineString isEqualToString:@"iPad2,7"])     return iPad_Mini_CDMA;
    if ([machineString isEqualToString:@"iPad3,1"])     return iPad_3_WiFi;
    if ([machineString isEqualToString:@"iPad3,2"])     return iPad_3_GSM;
    if ([machineString isEqualToString:@"iPad3,3"])     return iPad_3_CDMA;
    if ([machineString isEqualToString:@"iPad3,4"])     return iPad_4_WiFi;
    if ([machineString isEqualToString:@"iPad3,5"])     return iPad_4_GSM;
    if ([machineString isEqualToString:@"iPad3,6"])     return iPad_4_CDMA;
    if ([machineString isEqualToString:@"iPad4,1"])     return iPad_Air;
    if ([machineString isEqualToString:@"iPad4,2"])     return iPad_Air_Cellular;
    if ([machineString isEqualToString:@"iPad4,4"])     return iPad_Mini_2;
    if ([machineString isEqualToString:@"iPad4,5"])     return iPad_Mini_2_Cellular;
    if ([machineString isEqualToString:@"iPad4,7"])     return iPad_Mini_3_WiFi;
    if ([machineString isEqualToString:@"iPad4,8"])     return iPad_Mini_3_Cellular;
    if ([machineString isEqualToString:@"iPad4,9"])     return iPad_Mini_3_Cellular;
    if ([machineString isEqualToString:@"iPad5,1"])     return iPad_Mini_4_WiFi;
    if ([machineString isEqualToString:@"iPad5,2"])     return iPad_Mini_4_Cellular;
    
    if ([machineString isEqualToString:@"iPad5,3"])     return iPad_Air_2_WiFi;
    if ([machineString isEqualToString:@"iPad5,4"])     return iPad_Air_2_Cellular;
    if ([machineString isEqualToString:@"iPad6,3"])     return iPad_Pro_97inch_WiFi;
    if ([machineString isEqualToString:@"iPad6,4"])     return iPad_Pro_97inch_Cellular;
    if ([machineString isEqualToString:@"iPad6,7"])     return iPad_Pro_129inch_WiFi;
    if ([machineString isEqualToString:@"iPad6,8"])     return iPad_Pro_129inch_Cellular;
    
    if ([machineString isEqualToString:@"iPad6,11"])    return iPad_5_WiFi;
    if ([machineString isEqualToString:@"iPad6,12"])    return iPad_5_Cellular;
    if ([machineString isEqualToString:@"iPad7,1"])     return iPad_Pro_129inch_2nd_gen_WiFi;
    if ([machineString isEqualToString:@"iPad7,2"])     return iPad_Pro_129inch_2nd_gen_Cellular;
    if ([machineString isEqualToString:@"iPad7,3"])     return iPad_Pro_105inch_WiFi;
    if ([machineString isEqualToString:@"iPad7,4"])     return iPad_Pro_105inch_Cellular;
    if ([machineString isEqualToString:@"iPad7,6"])     return iPad_6;
    
    if ([machineString isEqualToString:@"AppleTV2,1"])  return appleTV2;
    if ([machineString isEqualToString:@"AppleTV3,1"])  return appleTV3;
    if ([machineString isEqualToString:@"AppleTV3,2"])  return appleTV3;
    if ([machineString isEqualToString:@"AppleTV5,3"])  return appleTV4;
    
    if ([machineString isEqualToString:@"i386"])        return i386Simulator;
    if ([machineString isEqualToString:@"x86_64"])      return x86_64Simulator;
    
    return iUnknown;
}

#pragma Containers
static NSString *const iDeviceNameContainer[] = {
    [iPhone_1G]                 = @"iPhone 1G",
    [iPhone_3G]                 = @"iPhone 3G",
    [iPhone_3GS]                = @"iPhone 3GS",
    [iPhone_4]                  = @"iPhone 4",
    [iPhone_4_Verizon]          = @"Verizon iPhone 4",
    [iPhone_4S]                 = @"iPhone 4S",
    [iPhone_5_GSM]              = @"iPhone 5 (GSM)",
    [iPhone_5_CDMA]             = @"iPhone 5 (CDMA)",
    [iPhone_5C_GSM]             = @"iPhone 5C (GSM)",
    [iPhone_5C_GSM_CDMA]        = @"iPhone 5C (GSM+CDMA)",
    [iPhone_5S_GSM]             = @"iPhone 5S (GSM)",
    [iPhone_5S_GSM_CDMA]        = @"iPhone 5S (GSM+CDMA)",
    [iPhone_6]                  = @"iPhone 6",
    [iPhone_6_Plus]             = @"iPhone 6 Plus",
    [iPhone_6S]                 = @"iPhone 6S",
    [iPhone_6S_Plus]            = @"iPhone 6S Plus",
    [iPhone_SE]                 = @"iPhone SE",
    [Chinese_iPhone_7]          = @"国行/日版/港行 iPhone 7",
    [Chinese_iPhone_7_Plus]     = @"港行/国行 iPhone 7 Plus",
    [American_iPhone_7]         = @"美版/台版 iPhone 7",
    [American_iPhone_7_Plus]    = @"美版/台版 iPhone 7 Plus",
    [Chinese_iPhone_8]          = @"国行/日版 iPhone 8",
    [Chinese_iPhone_8_Plus]     = @"国行/日版 iPhone 8 Plus",
    [Chinese_iPhone_X]          = @"国行/日版 iPhone X",
    [Global_iPhone_8]           = @"美版(Global) iPhone 8",
    [Global_iPhone_8_Plus]      = @"美版(Global) iPhone 8 Plus",
    [Global_iPhone_X]           = @"美版(Global) iPhone X",
    [iPhone_XS]                 = @"iPhone XS",
    [iPhone_XS_Max]             = @"iPhone XS Max",
    [iPhone_XR]                 = @"iPhone XR",
    
    [iPod_Touch_1G]             = @"iPod Touch 1G",
    [iPod_Touch_2G]             = @"iPod Touch 2G",
    [iPod_Touch_3G]             = @"iPod Touch 3G",
    [iPod_Touch_4G]             = @"iPod Touch 4G",
    [iPod_Touch_5Gen]           = @"iPod Touch 5(Gen)",
    [iPod_Touch_6G]             = @"iPod Touch 6G",
    [iPad_1]                    = @"iPad 1",
    [iPad_3G]                   = @"iPad 3G",
    [iPad_2_CDMA]               = @"iPad 2 (GSM)",
    [iPad_2_GSM]                = @"iPad 2 (CDMA)",
    [iPad_2_WiFi]               = @"iPad 2 (WiFi)",
    [iPad_3_WiFi]               = @"iPad 3 (WiFi)",
    [iPad_3_GSM]                = @"iPad 3 (GSM)",
    [iPad_3_CDMA]               = @"iPad 3 (CDMA)",
    [iPad_3_GSM_CDMA]           = @"iPad 3 (GSM+CDMA)",
    [iPad_4_WiFi]               = @"iPad 4 (WiFi)",
    [iPad_4_GSM]                = @"iPad 4 (GSM)",
    [iPad_4_CDMA]               = @"iPad 4 (CDMA)",
    [iPad_4_GSM_CDMA]           = @"iPad 4 (GSM+CDMA)",
    [iPad_Air]                  = @"iPad Air",
    [iPad_Air_Cellular]         = @"iPad Air (Cellular)",
    [iPad_Air_2_WiFi]           = @"iPad Air 2 (WiFi)",
    [iPad_Air_2_Cellular]       = @"iPad Air 2 (Cellular)",
    [iPad_Mini_WiFi]            = @"iPad Mini (WiFi)",
    [iPad_Mini_GSM]             = @"iPad Mini (GSM)",
    [iPad_Mini_CDMA]            = @"iPad Mini (CDMA)",
    [iPad_Mini_2]               = @"iPad Mini 2",
    [iPad_Mini_2_Cellular]      = @"iPad Mini 2 (Cellular)",
    [iPad_Mini_3_WiFi]          = @"iPad Mini 3 (WiFi)",
    [iPad_Mini_3_Cellular]      = @"iPad Mini 3 (Cellular)",
    [iPad_Mini_4_WiFi]          = @"iPad Mini 4 (WiFi)",
    [iPad_Mini_4_Cellular]      = @"iPad Mini 4 (Cellular)",
    
    [iPad_Pro_97inch_WiFi]      = @"iPad Pro 9.7 inch(WiFi)",
    [iPad_Pro_97inch_Cellular]  = @"iPad Pro 9.7 inch(Cellular)",
    [iPad_Pro_129inch_WiFi]     = @"iPad Pro 12.9 inch(WiFi)",
    [iPad_Pro_129inch_Cellular] = @"iPad Pro 12.9 inch(Cellular)",
    [iPad_5_WiFi]               = @"iPad 5(WiFi)",
    [iPad_5_Cellular]           = @"iPad 5(Cellular)",
    [iPad_Pro_129inch_2nd_gen_WiFi]     = @"iPad Pro 12.9 inch(2nd generation)(WiFi)",
    [iPad_Pro_129inch_2nd_gen_Cellular] = @"iPad Pro 12.9 inch(2nd generation)(Cellular)",
    [iPad_Pro_105inch_WiFi]             = @"iPad Pro 10.5 inch(WiFi)",
    [iPad_Pro_105inch_Cellular]         = @"iPad Pro 10.5 inch(Cellular)",
    [iPad_6]                            = @"iPad 6",
    
    [appleTV2]                  = @"appleTV2",
    [appleTV3]                  = @"appleTV3",
    [appleTV4]                  = @"appleTV4",
    
    [i386Simulator]             = @"i386Simulator",
    [x86_64Simulator]           = @"x86_64Simulator",
    
    [iUnknown]                  = @"Unknown"
};


static NSString *const initialFirmwareContainer[] = {
    [iPhone_1G]                 = @"1.0",
    [iPhone_3G]                 = @"2.0",
    [iPhone_3GS]                = @"3.0",
    [iPhone_4]                  = @"4.0/4.2.5/4.2.6",
    [iPhone_4_Verizon]          = @"4.0/4.2.5/4.2.6",
    [iPhone_4S]                 = @"5.0",
    [iPhone_5_GSM]              = @"6.0",
    [iPhone_5_CDMA]             = @"6.0",
    [iPhone_5C_GSM]             = @"7.0",
    [iPhone_5C_GSM_CDMA]        = @"7.0",
    [iPhone_5S_GSM]             = @"7.0",
    [iPhone_5S_GSM_CDMA]        = @"7.0",
    [iPhone_6]                  = @"8.0",
    [iPhone_6_Plus]             = @"8.0",
    [iPhone_6S]                 = @"9.0",
    [iPhone_6S_Plus]            = @"9.0",
    [iPhone_SE]                 = @"9.3",
    [Chinese_iPhone_7]          = @"10.0",
    [American_iPhone_7]         = @"10.0",
    [American_iPhone_7_Plus]    = @"10.0",
    [Chinese_iPhone_7_Plus]     = @"10.0",
    [Chinese_iPhone_8]          = @"11.0",
    [Chinese_iPhone_8_Plus]     = @"11.0",
    [Chinese_iPhone_X]          = @"11.0.1",
    [Global_iPhone_8]           = @"11.0",
    [Global_iPhone_8_Plus]      = @"11.0",
    [Global_iPhone_X]           = @"11.0.1",
    [iPhone_XS]                 = @"12.0",
    [iPhone_XS_Max]             = @"12.0",
    [iPhone_XR]                 = @"12.0",
    
    
    [iPod_Touch_1G]             = @"1.1",
    [iPod_Touch_2G]             = @"2.1.1(MB)/3.1.1(MC)",
    [iPod_Touch_3G]             = @"3.1.1",
    [iPod_Touch_4G]             = @"4.1",
    [iPod_Touch_5Gen]           = @"6.0/6.1.3",
    [iPod_Touch_6G]             = @"8.4",
    [iPad_1]                    = @"3.2",
    [iPad_2_CDMA]               = @"4.3/5.1",
    [iPad_2_GSM]                = @"4.3/5.1",
    [iPad_2_WiFi]               = @"4.3/5.1",
    [iPad_3_WiFi]               = @"5.1",
    [iPad_3_GSM]                = @"5.1",
    [iPad_3_CDMA]               = @"5.1",
    [iPad_4_WiFi]               = @"6.0/6.0.1",
    [iPad_4_GSM]                = @"6.0/6.0.1",
    [iPad_4_CDMA]               = @"6.0/6.0.1",
    [iPad_Air]                  = @"7.0.3/7.1",
    [iPad_Air_Cellular]         = @"7.0.3/7.1",
    [iPad_Air_2_WiFi]           = @"8.1",
    [iPad_Air_2_Cellular]       = @"8.1",
    [iPad_Mini_WiFi]            = @"6.0/6.0.1",
    [iPad_Mini_GSM]             = @"6.0/6.0.1",
    [iPad_Mini_CDMA]            = @"6.0/6.0.1",
    [iPad_Mini_2]               = @"7.0.3/7.1",
    [iPad_Mini_2_Cellular]      = @"7.0.3/7.1",
    [iPad_Mini_3_WiFi]          = @"8.0/8.1",
    [iPad_Mini_3_Cellular]      = @"8.0/8.1",
    [iPad_Mini_4_WiFi]          = @"9.0",
    [iPad_Mini_4_Cellular]      = @"9.0",
    
    [iPad_Pro_97inch_WiFi]      = @"9.3",
    [iPad_Pro_97inch_Cellular]  = @"9.3",
    [iPad_Pro_129inch_WiFi]     = @"9.1",
    [iPad_Pro_129inch_Cellular] = @"9.1",
    [iPad_Pro_129inch_2nd_gen_WiFi]     = @"10.3.2",
    [iPad_Pro_129inch_2nd_gen_Cellular] = @"10.3.2",
    [iPad_Pro_105inch_WiFi]             = @"10.3.2",
    [iPad_Pro_105inch_Cellular]         = @"10.3.2",
    [iPad_6]                            = @"11.3",
    
    [iUnknown]                          = @"Unknown"
};

static NSString *const CPUNameContainer[] = {
    [iPhone_1G]                 = @"ARM 1176JZ",
    [iPhone_3G]                 = @"ARM 1176JZ",
    [iPhone_3GS]                = @"ARM Cortex-A8",
    [iPhone_4]                  = @"Apple A4",
    [iPhone_4_Verizon]          = @"Apple A4",
    [iPhone_4S]                 = @"Apple A5",
    [iPhone_5_GSM]              = @"Apple A6",
    [iPhone_5_CDMA]             = @"Apple A6",
    [iPhone_5C_GSM]             = @"Apple A6",
    [iPhone_5C_GSM_CDMA]        = @"Apple A6",
    [iPhone_5S_GSM]             = @"Apple A7",
    [iPhone_5S_GSM_CDMA]        = @"Apple A7",
    [iPhone_6]                  = @"Apple A8",
    [iPhone_6_Plus]             = @"Apple A8",
    [iPhone_6S]                 = @"Apple A9",
    [iPhone_6S_Plus]            = @"Apple A9",
    [iPhone_SE]                 = @"Apple A9",
    [Chinese_iPhone_7]          = @"Apple A10",
    [American_iPhone_7]         = @"Apple A10",
    [American_iPhone_7_Plus]    = @"Apple A10",
    [Chinese_iPhone_7_Plus]     = @"Apple A10",
    [Chinese_iPhone_8]          = @"Apple A11",
    [Chinese_iPhone_8_Plus]     = @"Apple A11",
    [Chinese_iPhone_X]          = @"Apple A11",
    [Global_iPhone_8]           = @"Apple A11",
    [Global_iPhone_8_Plus]      = @"Apple A11",
    [Global_iPhone_X]           = @"Apple A11",
    [iPhone_XS]                 = @"A12 Bionic",
    [iPhone_XS_Max]             = @"A12 Bionic",
    [iPhone_XR]                 = @"A12 Bionic",
    
    [iPod_Touch_1G]             = @"ARM 1176JZ",
    [iPod_Touch_2G]             = @"ARM 1176JZ",
    [iPod_Touch_3G]             = @"ARM Cortex-A8",
    [iPod_Touch_4G]             = @"ARM Cortex-A8",
    [iPod_Touch_5Gen]           = @"Apple A5",
    [iPod_Touch_6G]             = @"Apple A8",
    [iPad_1]                    = @"ARM Cortex-A8",
    [iPad_2_CDMA]               = @"ARM Cortex-A9",
    [iPad_2_GSM]                = @"ARM Cortex-A9",
    [iPad_2_WiFi]               = @"ARM Cortex-A9",
    [iPad_3_WiFi]               = @"ARM Cortex-A9",
    [iPad_3_GSM]                = @"ARM Cortex-A9",
    [iPad_3_CDMA]               = @"ARM Cortex-A9",
    [iPad_4_WiFi]               = @"Apple A6X",
    [iPad_4_GSM]                = @"Apple A6X",
    [iPad_4_CDMA]               = @"Apple A6X",
    [iPad_Air]                  = @"Apple A7",
    [iPad_Air_Cellular]         = @"Apple A7",
    [iPad_Air_2_WiFi]           = @"Apple A8X",
    [iPad_Air_2_Cellular]       = @"Apple A8X",
    [iPad_Mini_WiFi]            = @"ARM Cortex-A9",
    [iPad_Mini_GSM]             = @"ARM Cortex-A9",
    [iPad_Mini_CDMA]            = @"ARM Cortex-A9",
    [iPad_Mini_2]               = @"Apple A7",
    [iPad_Mini_2_Cellular]      = @"Apple A7",
    [iPad_Mini_3_WiFi]          = @"Apple A7",
    [iPad_Mini_3_Cellular]      = @"Apple A7",
    [iPad_Mini_4_WiFi]          = @"Apple A8",
    [iPad_Mini_4_Cellular]      = @"Apple A8",
    
    [iPad_Pro_97inch_WiFi]      = @"Apple A9X",
    [iPad_Pro_97inch_Cellular]  = @"Apple A9X",
    [iPad_Pro_129inch_WiFi]     = @"Apple A9X",
    [iPad_Pro_129inch_Cellular] = @"Apple A9X",
    [iPad_Pro_129inch_2nd_gen_WiFi]     = @"Apple A10X",
    [iPad_Pro_129inch_2nd_gen_Cellular] = @"Apple A10X",
    [iPad_Pro_105inch_WiFi]             = @"Apple A10X",
    [iPad_Pro_105inch_Cellular]         = @"Apple A10X",
    [iPad_6]                            = @"Apple A10",
    
    [iUnknown]                          = @"Unknown"
};

- (int64_t)getTotalMemory {
    int64_t totalMemory = [[NSProcessInfo processInfo] physicalMemory];
    if (totalMemory < -1) totalMemory = -1;
    return totalMemory;
}

- (int64_t)getFreeMemory {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.free_count * page_size;
}

- (NSString *)getcriberCellularProvider {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString *obj = [NSString stringWithFormat:@"%@",carrier.carrierName];
    if ([obj isEqualToString:@"中国电信"]) {
        return @"China DX";
    } else if ([obj isEqualToString:@"中国联通"]) {
        return @"China LT";
    } else if ([obj isEqualToString:@"中国移动"]) {
        return @"China YD";
    } else {
        return @"MoNiQi";
    }
}

- (NSArray *)getPerCPUUsage {
    processor_info_array_t _cpuInfo, _prevCPUInfo = nil;
    mach_msg_type_number_t _numCPUInfo, _numPrevCPUInfo = 0;
    unsigned _numCPUs;
    NSLock *_cpuUsageLock;
    
    int _mib[2U] = { CTL_HW, HW_NCPU };
    size_t _sizeOfNumCPUs = sizeof(_numCPUs);
    int _status = sysctl(_mib, 2U, &_numCPUs, &_sizeOfNumCPUs, NULL, 0U);
    if (_status)
        _numCPUs = 1;
    
    _cpuUsageLock = [[NSLock alloc] init];
    
    natural_t _numCPUsU = 0U;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &_numCPUsU, &_cpuInfo, &_numCPUInfo);
    if (err == KERN_SUCCESS) {
        [_cpuUsageLock lock];
        
        NSMutableArray *cpus = [NSMutableArray new];
        for (unsigned i = 0U; i < _numCPUs; ++i) {
            Float32 _inUse, _total;
            if (_prevCPUInfo) {
                _inUse = (
                          (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                          + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                          );
                _total = _inUse + (_cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - _prevCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                _inUse = _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                _total = _inUse + _cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            [cpus addObject:@(_inUse / _total)];
        }
        
        [_cpuUsageLock unlock];
        if (_prevCPUInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * _numPrevCPUInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)_prevCPUInfo, prevCpuInfoSize);
        }
        return cpus;
    } else {
        return nil;
    }
}

#pragma mark - 转化json数据
-(NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}

+ (NSString *)getMYUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuiddd = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    CFRelease(uuid);
    return uuiddd;
}

+ (NSMutableDictionary *)getDicFromPboard:(id)past {
    id item = [past dataForPasteboardType:XJPbType];
    if (item) {
        @try {
            item = [NSKeyedUnarchiver unarchiveObjectWithData:item];
        } @catch (NSException *exception) {
            item = nil;
        }
    }
    return [NSMutableDictionary dictionaryWithDictionary:(item == nil || [item isKindOfClass:[NSDictionary class]]) ? item: nil];
    
}

+ (void)setDict:(id)dict forPasteBoard:(id)pboard {
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:dict] forPasteboardType:XJPbType];
}

#pragma mark - UUID
+ (NSString *)value {
    if (XJUUIDCache) {
        return XJUUIDCache;
    }
    NSString *aaXJUUID = nil;
    NSString *appuuid = nil;
    NSString *panid = nil;
    BOOL saveuserID = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *localDict = [defaults objectForKey:XJUUID];
    if ([localDict isKindOfClass:[NSDictionary class]]) {
        localDict = [NSMutableDictionary dictionaryWithDictionary:localDict];
        aaXJUUID = [localDict objectForKey:XJUUID];
        appuuid = [localDict objectForKey:XJAppUUID];
        panid = [localDict objectForKey:XJPbSlotID];
    } else {
        appuuid = [XJDeviceTool getMYUUID];
    }
    
    NSString *availableSlotPbid = nil;
    NSDictionary *frequencyDict = [NSMutableDictionary dictionaryWithCapacity:XJUUIDRedundancySlots];
    for (int i = 0; i < XJUUIDRedundancySlots; i++) {
        NSString *pbid = [NSString stringWithFormat:@"%@.%d",XJPbSlotID,i];
        UIPasteboard *pb = [UIPasteboard pasteboardWithName:pbid create:NO];
        if (pb) {
            NSMutableDictionary *pbdict = [XJDeviceTool getDicFromPboard:pb];
            NSString *pbuuid = [pbdict objectForKey:XJUUID];
            if (pbuuid) {
                int count = [[frequencyDict objectForKey:pbuuid] intValue];
                [frequencyDict setValue:[NSNumber numberWithInt:++count] forKey:pbuuid];
            }
            else
            {
                if (!availableSlotPbid) availableSlotPbid = pbid;
            }
        } else {
            if (!availableSlotPbid) availableSlotPbid = pbid;
        }
    }
    NSArray *pbuuidArray = [frequencyDict keysSortedByValueUsingSelector:@selector(compare:)];
    NSString *most = [pbuuidArray lastObject];
    
    if (!aaXJUUID) {
        if (most) {
            aaXJUUID = most;
        } else {
            aaXJUUID = [XJDeviceTool getMYUUID];
        }
        if (!localDict) {
            localDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [localDict setObject:aaXJUUID forKey:XJUUID];
            [localDict setObject:appuuid forKey:XJAppUUID];
            saveuserID = YES;
        }
    }
    
    if (availableSlotPbid && (!panid || [panid isEqualToString:availableSlotPbid])) {
        UIPasteboard *npb = [UIPasteboard pasteboardWithName:availableSlotPbid create:YES];
        [npb setPersistent:YES];
        
        if (localDict) {
            [localDict setObject:availableSlotPbid forKey:XJPbSlotID];
            saveuserID = YES;
        }
        
        if (localDict && aaXJUUID) {
            [XJDeviceTool setDict:localDict forPasteBoard:npb];
        }
    }
    
    if (localDict && saveuserID) {
        [defaults setObject:localDict forKey:XJUUID];
    }
    XJUUIDCache = aaXJUUID;
    return XJUUIDCache;
}
/*
 NetworkStatusType_None = -1,
 NetworkStatusType_WiFi = 2,
 NetworkStatusType_3G   = 3,
 NetworkStatusType_4G   = 4
*/
- (NSString *)netState:(NetworkStrengthType)type {
    switch (type) {
        case NetworkStrengthType_Hight:
            return @"高";
        break;
        case NetworkStrengthType_Medium:
            return @"中";
        break;
            case NetworkStrengthType_Low:
            return @"低";
            break;
        default:
            return @"无";
        break;
    }
}

#pragma mark - WiFi强度
- (NSString *)getNetworkStrength {
    UIApplication *app = [UIApplication sharedApplication];
    
    if ([[app valueForKeyPath:@"statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        NSString *wifiEntry = [[[[app valueForKey:@"statusBar"] valueForKey:@"_statusBar"] valueForKey:@"_currentAggregatedData"] valueForKey:@"_wifiEntry"];

        int signal = [[wifiEntry valueForKey:@"_displayValue"] intValue];
        NSString * obj = [self netState:signal];
        return obj;
    }
    else
    {
        int signalStrength = 0;
        NSArray *subviews =[[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
        for(id subview in subviews){
            if([subview isKindOfClass: [NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]){
                NSString *dataNetworkItemView = nil;
                dataNetworkItemView = subview;
                /*
                 //WiFi类型 iphonex 下不可
                 int networkType = [[subview valueForKey:@"dataNetworkType"] intValue];
                 NSLog(@"network type %d\n",networkType);
                 */
                //WiFi强度
                signalStrength =[[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
                break;
                
            }
        }
        NSString *obj = [self netState:signalStrength];
        return obj;
    }
}



@end
