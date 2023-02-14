//
//  CDOCClass+Add.h
//  class-dump
//
//  Created by linsunxin on 2023/2/10.
//

#import "CDOCClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDOCClass (Add)
- (BOOL)hb_methodIsInSelfProtocols:(CDOCMethod *)method isClass:(BOOL)isClass;
- (BOOL)hb_methodIsSuper:(CDOCMethod *)method isClass:(BOOL)isClass;
- (BOOL)hb_methodIsGetterOrSetter:(CDOCMethod *)method isClass:(BOOL)isClass;
@end

NS_ASSUME_NONNULL_END
