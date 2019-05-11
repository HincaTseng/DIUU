//
//  XJUUIDObject.m
//  
//
//  Created by 曾宪杰 on 2019/5/10.
//  Copyright © 2019 曾宪杰. All rights reserved.
//

#import "XJUUIDObject.h"
#import <UIKit/UIPasteboard.h>
#import "UICKeyChainStore.h"
#import "Reachability.h"
static NSString *XJUUIDCache = nil;

static NSString *const XJUUID = @"com.xj.uuid";
static NSString *const XJAppUUID = @"com.xj.appuuid";
static NSString *const XJPbType = @"com.xj.pb";
static NSString *const XJPbSlotID = @"com.xj.pbid";
static int const XJUUIDRedundancySlots = 100;

@implementation XJUUIDObject
+ (NSString *)UUID {
    NSString *uuid = [XJUUIDObject value];
    //save uuid to keychain...
    UICKeyChainStore *keychainStore = [UICKeyChainStore keyChainStore];
    if (!keychainStore[@"uuid"]) {
        keychainStore[@"uuid"] = uuid;
    }
    NSLog(@"uuuuuuuid %@\n",keychainStore[@"uuid"]);
    return keychainStore[@"uuid"];
}

+ (NSString *)networkType {
    return [self currentNetworkType];
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
        appuuid = [XJUUIDObject getMYUUID];
    }
    
    NSString *availableSlotPbid = nil;
    NSDictionary *frequencyDict = [NSMutableDictionary dictionaryWithCapacity:XJUUIDRedundancySlots];
    for (int i = 0; i < XJUUIDRedundancySlots; i++) {
        NSString *pbid = [NSString stringWithFormat:@"%@.%d",XJPbSlotID,i];
        UIPasteboard *pb = [UIPasteboard pasteboardWithName:pbid create:NO];
        if (pb) {
            NSMutableDictionary *pbdict = [XJUUIDObject getDicFromPboard:pb];
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
            aaXJUUID = [XJUUIDObject getMYUUID];
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
            [XJUUIDObject setDict:localDict forPasteBoard:npb];
        }
    }
    
    if (localDict && saveuserID) {
        [defaults setObject:localDict forKey:XJUUID];
    }
    XJUUIDCache = aaXJUUID;
    return XJUUIDCache;
}

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

@end
