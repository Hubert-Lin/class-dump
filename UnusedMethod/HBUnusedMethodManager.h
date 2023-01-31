//
//  HBUnusedMethodManager.h
//  class-dump
//
//  Created by linsunxin on 2023/1/31.
//

#import <Foundation/Foundation.h>
#import "CDObjectiveCProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBUnusedMethodManager : NSObject

+ (instancetype)defaultManager;

- (void)analyze:(CDObjectiveCProcessor *)processor;

- (NSDictionary *)featchWhiteList;

@end

NS_ASSUME_NONNULL_END
