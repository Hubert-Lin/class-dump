//
//  HBSymbolModel.h
//  class-dump
//
//  Created by linsunxin on 2023/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBSymbolModel : NSObject

@property (nonatomic, copy) NSString *file;//文件

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *component;

@end

NS_ASSUME_NONNULL_END
