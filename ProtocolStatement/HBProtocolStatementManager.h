//
//  HBProtocolStatementManager.h
//  class-dump
//
//  Created by linsunxin on 2023/2/10.
//

#import <Foundation/Foundation.h>
#import "CDObjectiveCProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@class CDOCProtocol;

@interface HBProtocolStatementManager : NSObject

@property (nonatomic, strong, readonly) CDOCProtocol *P_NSObject;

+ (instancetype)defaultManager;

- (void)analyze:(CDObjectiveCProcessor *)processor;

@end

NS_ASSUME_NONNULL_END
