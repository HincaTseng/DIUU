//
//  Test.m
//  
//
//  Created by 曾宪杰 on 2019/4/30.
//  Copyright © 2019 曾宪杰. All rights reserved.
//

#import "Test.h"
#import "Test+Pass.h"

@implementation Test

//- (NSString *)mmm {
//    return @"mmmm";
//}

//-(void)setMmm:(NSString *)mmm {
//    _mmm = mmm;
//    _mmm = @"sdasda";
//}

//扩展中的方法的实现。没有这个会崩溃。
-(void)setMmm:(NSString *)mmm {
    _mmm = mmm;
}

- (void)privateMethod {
    NSLog(@"---privateMethod\n");
}

@end


