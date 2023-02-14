//
//  CDOCProtocol+Add.h
//  class-dump
//
//  Created by linsunxin on 2023/2/10.
//

#import "CDOCProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDOCProtocol (Add)
- (NSArray *)hb_allClassMethods;
- (NSArray *)hb_allInstanceMethods;

- (NSArray<CDOCProtocol *> *)hb_allProtocols;

@end

NS_ASSUME_NONNULL_END
