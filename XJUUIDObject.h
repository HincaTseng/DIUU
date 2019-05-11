//
//  XJUUIDObject.h
//
//
//  Created by 曾宪杰 on 2019/5/10.
//  Copyright © 2019 曾宪杰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XJUUIDObject : NSObject

/**
 [XJUUIDObject UUID];

 @return uuid value
 */
+ (NSString *)UUID;

/**
 [XJUUIDObject networkType];

 @return NetWorkTypeWiFi,NetWorkTypeWWAN,NetWorkTypeNone,error privacy
 */
+ (NSString *)networkType;

@end

NS_ASSUME_NONNULL_END
