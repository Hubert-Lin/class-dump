//
//  CDOCProtocol+Add.m
//  class-dump
//
//  Created by linsunxin on 2023/2/10.
//

#import "CDOCProtocol+Add.h"

@implementation CDOCProtocol (Add)

- (NSArray *)hb_allClassMethods
{
    NSMutableArray *list = self.classMethods.mutableCopy;
    [list addObjectsFromArray:self.optionalClassMethods];
    return list;
}

- (NSArray *)hb_allInstanceMethods
{
    NSMutableArray *list = self.instanceMethods.mutableCopy;
    [list addObjectsFromArray:self.optionalInstanceMethods];
    return list;
}

- (NSArray<CDOCProtocol *> *)hb_allProtocols
{
    NSMutableArray *list = @[self].mutableCopy;

    if (self.protocols.count == 0) {
        return list;
    }

    for (CDOCProtocol *aProtocol in self.protocols) {
        [list addObject:aProtocol];
        NSArray *all = aProtocol.hb_allProtocols;
        if (all.count == 0) {
            continue;
        }
        [list addObjectsFromArray:all];
    }
    
    return list.copy;
}

@end
