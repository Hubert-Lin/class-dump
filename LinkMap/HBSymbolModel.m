//
//  HBSymbolModel.m
//  class-dump
//
//  Created by linsunxin on 2023/1/30.
//

#import "HBSymbolModel.h"

@implementation HBSymbolModel

- (void)setFile:(NSString *)file
{
    _file = file;
    
    NSString *name = file.lastPathComponent;
    if ([name hasSuffix:@")"] && [name containsString:@"("]) {
        NSRange range = [name rangeOfString:@"("];
        self.component = [name substringToIndex:range.location];
        self.name = [[name substringFromIndex:range.location+1] componentsSeparatedByString:@"."].firstObject;
    }
}

@end
