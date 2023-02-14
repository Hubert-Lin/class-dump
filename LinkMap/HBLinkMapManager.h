//
//  HBLinkMapManager.h
//  class-dump
//
//  Created by linsunxin on 2023/1/30.
//

#import <Foundation/Foundation.h>
#import "HBSymbolModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBLinkMapManager : NSObject

+ (instancetype)defaultManager;
- (void)analyze:(NSURL *)url;
- (HBSymbolModel *)symbolModelWithName:(NSString *)name;

- (BOOL)is:(NSString *)className inComponent:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
