//
//  HBLinkMapManager.m
//  class-dump
//
//  Created by linsunxin on 2023/1/30.
//

#import "HBLinkMapManager.h"

@interface HBLinkMapManager ()

@property (nonatomic, strong) NSDictionary<NSString *, HBSymbolModel *> *symbolMap;

@end

@implementation HBLinkMapManager

+ (instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    static HBLinkMapManager *defaultManager;
    dispatch_once(&onceToken, ^{
        defaultManager = [[HBLinkMapManager alloc] init];
    });
    return defaultManager;
}

- (void)analyze:(NSURL *)url {
    if (!url || ![[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:nil]) {
        NSAssert(NO, @"LinkMap file path error!");
        return;
    }
    
    NSError *error;
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSMacOSRomanStringEncoding error:&error];

    self.symbolMap = [self symbolMapFromContent:content].copy;
}

- (HBSymbolModel *)symbolModelWithName:(NSString *)name
{
    return name.length > 0 ? self.symbolMap[name] : nil;
}

- (NSMutableDictionary *)symbolMapFromContent:(NSString *)content {
    NSMutableDictionary <NSString *, HBSymbolModel *>*symbolMap = [NSMutableDictionary new];
    // 符号文件列表
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    
    BOOL reachFiles = NO;
    BOOL reachSymbols = NO;
    BOOL reachSections = NO;
    
    for(NSString *line in lines) {
        if([line hasPrefix:@"#"]) {
            if([line hasPrefix:@"# Object files:"])
                reachFiles = YES;
            else if ([line hasPrefix:@"# Sections:"])
                reachSections = YES;
            else if ([line hasPrefix:@"# Symbols:"])
                reachSymbols = YES;
            else if ([line hasPrefix:@"# Dead Stripped"])
                break;
        } else {
            if(reachFiles == YES && reachSections == NO && reachSymbols == NO) {
                NSRange range = [line rangeOfString:@"]"];
                if(range.location != NSNotFound) {
                    HBSymbolModel *symbol = [HBSymbolModel new];
                    symbol.file = [line substringFromIndex:range.location+1];
                    if (symbol.name.length > 0) {
                        symbolMap[symbol.name] = symbol;
                    }
                }
            }
        }
    }
    return symbolMap;
}

@end
