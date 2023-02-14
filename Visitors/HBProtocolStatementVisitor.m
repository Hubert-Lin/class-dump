//
//  HBProtocolStatementVisitor.m
//  class-dump
//
//  Created by linsunxin on 2023/2/10.
//

#import "HBProtocolStatementVisitor.h"
#import "HBProtocolStatementManager.h"

@implementation HBProtocolStatementVisitor

// Called after visiting.
- (void)didVisitObjectiveCProcessor:(CDObjectiveCProcessor *)processor
{
    [[HBProtocolStatementManager defaultManager] analyze:processor];
}


@end
