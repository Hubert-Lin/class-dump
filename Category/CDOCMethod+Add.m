//
//  CDOCMethod+Add.m
//  class-dump
//
//  Created by linsunxin on 2023/2/10.
//

#import "CDOCMethod+Add.h"

@implementation CDOCMethod (Add)

- (NSString *)hb_instanceName
{
    return [@"-" stringByAppendingString:self.name];
}

- (NSString *)hb_className
{
    return [@"+" stringByAppendingString:self.name];
}

@end
