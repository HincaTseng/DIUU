//
//  XJDeviceTool.h
//  SuperKit
//
//  Created by 曾宪杰 on 2019/4/1.
//  Copyright © 2019 zengxianjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Test.h"

NS_ASSUME_NONNULL_BEGIN

@interface XJDeviceTool : NSObject
/*
 [[XJDeviceTool shareManager] info];
 */
+ (instancetype)shareManager;
- (id)info;
/*
 Test *test = [[Test alloc] init];
 test.name = @"小明";
 //    test.mmm = @"abc";
 [[XJDeviceTool shareManager] info:test];
 */
- (id)info:(Test *)test;

@end

NS_ASSUME_NONNULL_END
