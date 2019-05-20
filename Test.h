//
//  Test.h
//
//
//  Created by 曾宪杰 on 2019/4/30.
//  Copyright © 2019 曾宪杰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//不能被其他类集成
__attribute__((objc_subclassing_restricted))
@interface Test : NSObject
@property (nonatomic,copy) NSString *name;
//@property (nonatomic,copy) NSString *mmm; //变成私有
- (void)privateMethod;
@end

NS_ASSUME_NONNULL_END
