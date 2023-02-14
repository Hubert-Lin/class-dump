//
//  CDOCClass+Add.m
//  class-dump
//
//  Created by linsunxin on 2023/2/10.
//

#import "CDOCClass+Add.h"
#import "CDOCClassReference.h"
#import "CDOCMethod+Add.h"
#import "CDOCProtocol+Add.h"
#import "CDOCProperty.h"
#import "HBProtocolStatementManager.h"

@implementation CDOCClass (Add)

- (NSArray<CDOCProtocol *> *)_allProtocol
{
    NSMutableArray *list = @[].mutableCopy;
    if (self.superClassRef.classObject) {
        [list addObjectsFromArray:[self.superClassRef.classObject _allProtocol]];
    }
    
    NSArray *protocols = self.protocols;
    if (protocols.count == 0) {
        protocols = @[HBProtocolStatementManager.defaultManager.P_NSObject];
    }
    
    for (CDOCProtocol *aProtocol in protocols) {
        NSArray *all = aProtocol.hb_allProtocols;
        if (all.count == 0) {
            continue;
        }
        [list addObjectsFromArray:all];
    }
    
    return list.copy;
}

- (NSArray *)_allSuperMethod
{
    NSMutableArray *list = @[].mutableCopy;
    if (self.superClassRef.classObject) {
        for (CDOCMethod *aMethod in self.superClassRef.classObject.hb_allClassMethods) {
            [list addObject:aMethod.hb_className];
        }
        for (CDOCMethod *aMethod in self.superClassRef.classObject.hb_allInstanceMethods) {
            [list addObject:aMethod.hb_instanceName];
        }
        
        [list addObjectsFromArray:[self.superClassRef.classObject _allSuperMethod]];
    }
    
    
    return list.copy;
}

- (NSArray *)_allGetterSetterMethod
{
    NSMutableArray *list = @[].mutableCopy;
    
    for (CDOCProperty *aProperty in self.properties) {
        if (aProperty.isDynamic) {
            continue;
        }
        
        NSString *getterName = aProperty.name;
        if (aProperty.customGetter.length > 0) {
            getterName = aProperty.customGetter;
        }
        
        NSString *setterName = [aProperty.name stringByReplacingCharactersInRange:
                                NSMakeRange(0,1) withString:
                                [[aProperty.name substringToIndex:1] capitalizedString]];
        setterName = [NSString stringWithFormat:@"set%@:", setterName];
        if (aProperty.customSetter.length > 0) {
            setterName = aProperty.customSetter;
        }
        
        [list addObject:[NSString stringWithFormat:@"-%@", getterName]];
        [list addObject:[NSString stringWithFormat:@"-%@", setterName]];
    }
    
    return list;
}

- (BOOL)hb_methodIsInSelfProtocols:(CDOCMethod *)method isClass:(BOOL)isClass
{
    for (CDOCProtocol *aProtocol in [self _allProtocol]) {
        for (CDOCMethod *aMethod in [aProtocol hb_allClassMethods]) {
            if ([method.hb_className isEqualToString:aMethod.hb_className]) {
                return YES;
            }
        }
        for (CDOCMethod *aMethod in [aProtocol hb_allInstanceMethods]) {
            if ([method.hb_instanceName isEqualToString:aMethod.hb_instanceName]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)hb_methodIsSuper:(CDOCMethod *)method isClass:(BOOL)isClass
{
    NSString *mName = isClass ? method.hb_className : method.hb_instanceName;
    return [[self _allSuperMethod] containsObject:mName];
}

- (BOOL)hb_methodIsGetterOrSetter:(CDOCMethod *)method isClass:(BOOL)isClass
{
    if (isClass) {
        return NO;
    }
    
    return [[self _allGetterSetterMethod] containsObject:method.hb_instanceName];
}

@end
