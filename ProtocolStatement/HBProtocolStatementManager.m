//
//  HBProtocolStatementManager.m
//  class-dump
//
//  Created by linsunxin on 2023/2/10.
//

#import "HBProtocolStatementManager.h"
#import "HBLinkMapManager.h"
#import "CDObjectiveCProcessor.h"
#import "CDProtocolUniquer.h"
#import "CDOCClassReference.h"
#import "CDOCProtocol+Add.h"
#import "CDOCClass+Add.h"
#import "CDOCMethod+Add.h"

@interface HBProtocolStatementManager ()

@property (nonatomic, strong) CDOCProtocol *P_NSObject; // 借用一下，浅copy

@end

@implementation HBProtocolStatementManager

+ (instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    static HBProtocolStatementManager *defaultManager;
    dispatch_once(&onceToken, ^{
        defaultManager = [[HBProtocolStatementManager alloc] init];
    });
    return defaultManager;
}

- (void)analyze:(CDObjectiveCProcessor *)processor
{
    [self configLinkMap];
    
    NSDictionary<NSString *, NSArray<NSString *> *> *whiteList = [self featchWhiteList];
    
    /// 白名单 - 方法名列表
    NSArray<NSString *> *methodNameWhiteList = whiteList[@"method"];
    /// 白名单 - 类名 ： [方法名列表]
    NSDictionary<NSString *, NSArray<NSString *> *> *methodClassWhiteList = whiteList[@"class"];

    /// 类名 ：{方法名 ： [协议1， 协议2， 协议3]}
    NSMutableDictionary *result = @{}.mutableCopy;
    
    /// 方法名 ：[协议1， 协议2， 协议3]
    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *protocolMethodsMap = [self getProtocolMethodsMap:processor];
    
    for (CDOCClass *aClass in [processor getClasses]) {
        
        NSString *searchingComponent = @"yychannelcomponent";
        searchingComponent = @"yyulivesdk";
        if (![[HBLinkMapManager defaultManager] is:aClass.name inComponent:searchingComponent]) {
            continue;
        }
        
        if ([aClass.name isEqualToString:@"ActivityInfo"]) {
            NSLog(@"...");
        }
        NSArray<NSString *> *classWhiteList = methodClassWhiteList[aClass.name];
        
        
        BOOL (^addBlock)(CDOCMethod *, BOOL) = ^BOOL(CDOCMethod *method, BOOL isClass) {
            NSString *mName = isClass ? method.hb_className : method.hb_instanceName;
            do {
                if ([methodNameWhiteList containsObject:mName]) {
                    break;
                }
                if ([classWhiteList containsObject:mName]) {
                    break;
                }
                if ([aClass hb_methodIsInSelfProtocols:method isClass:isClass]) {
                    break;
                }
                if ([aClass hb_methodIsSuper:method isClass:isClass]) {
                    break;
                }
                if ([aClass hb_methodIsGetterOrSetter:method isClass:isClass]) {
                    break;
                }
                if (protocolMethodsMap[mName]) {
//                    NSLog(@"%@ - %@ : %@", aClass.name, method.name, protocolMethodsMap[mName]);
                    NSMutableDictionary *classMap = result[aClass.name] ? : @{}.mutableCopy;
                    classMap[method.name] = protocolMethodsMap[mName];
                    result[aClass.name] = classMap;
                    
                    return YES;
                }
            } while (0);
            return NO;
        };

//        for (CDOCMethod *method in [aClass hb_allClassMethods]) {
//            addBlock(method, YES);
//        }
        for (CDOCMethod *method in [aClass hb_allInstanceMethods]) {
            addBlock(method, NO);
        }
    }
    
    NSLog(@"%@", result);
    NSLog(@"all class count: %@", @(result.allKeys.count));
}

- (NSDictionary *)getSysteamProtocols
{
//    NSString *python = @"/Users/linsunxin/opt/anaconda3/bin/python";
//    {
//        NSTask *task = [[NSTask alloc] init];
//        [task setLaunchPath:@"/usr/bin/whereis"];
//        [task setArguments:@[@"python"]];
//
//        NSPipe *pipe = [NSPipe pipe];
//        [task setStandardOutput:pipe];
//
//        NSFileHandle *file;
//        file = [pipe fileHandleForReading];
//
//        [task launch];
//
//        NSData *data = [file readDataToEndOfFile];
//        NSString *path = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"");
//    }
    
    NSString *scriptPath = @"/Users/linsunxin/Documents/Workspace/Git/appsizetool-ios/scripts/findSysFramework.py";
    NSString *outputPath = @"/Users/linsunxin/Documents/Workspace/Git/appsizetool-ios/scripts/cache/sysFrameworkProtocols.json";
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/Users/linsunxin/opt/anaconda3/bin/python"];
    [task setArguments:@[scriptPath, @"-o", outputPath]];
    [task launch];
    

    if (![[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        return nil;
    }
    NSString *jsonString = [NSString stringWithContentsOfFile:outputPath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *map = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    /*
     {
        "name" : {
            "methods" : ["" ...],
            "parent" : ["" ...]
         }
     }
     */
    return map;
}

- (NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *)getProtocolMethodsMap:(CDObjectiveCProcessor *)processor
{
    NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *protocolMethodsMap = @{}.mutableCopy;
    
    void (^addBlock)(NSString *, NSString *) = ^void(NSString *mName, NSString *pName) {
        NSMutableArray *protocolNames = protocolMethodsMap[mName];
        if (protocolNames == nil) {
            protocolNames = @[].mutableCopy;
            protocolMethodsMap[mName] = protocolNames;
        }
        if (![protocolNames containsObject:pName]) {
            [protocolNames addObject:pName];
        }
    };

    for (CDOCProtocol *protocol in [processor.protocolUniquer uniqueProtocolsSortedByName]) {
        if ([protocol.name isEqualToString:@"NSObject"]) {
            self.P_NSObject = protocol;
        }
        for (CDOCMethod *method in [protocol hb_allClassMethods]) {
            addBlock([method hb_className], protocol.name);
        }
        for (CDOCMethod *method in [protocol hb_allInstanceMethods]) {
            addBlock([method hb_instanceName], protocol.name);
        }
    }
    
    NSDictionary *systeamProtocols = [self getSysteamProtocols];
    for (NSString *key in systeamProtocols) {
        NSDictionary *item = systeamProtocols[key];
        for (NSString *mName in item[@"methods"]) {
            addBlock(mName, key);
        }
    }

    return protocolMethodsMap;
}

- (NSDictionary<NSString *, NSArray<NSString *> *> *)featchWhiteList
{
    NSString *whiteListPath = @"/Users/linsunxin/Documents/Workspace/APPTHIN/YYSDK/protocol_statement_white_list.json";
    if (![[NSFileManager defaultManager] fileExistsAtPath:whiteListPath]) {
        return nil;
    }
    NSString *jsonString = [NSString stringWithContentsOfFile:whiteListPath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:jsonData
                                           options:NSJSONReadingMutableContainers
                                             error:nil];
}

- (void)configLinkMap
{
    NSString *linkmapPath = @"/Users/linsunxin/Documents/Workspace/APPTHIN/YYSDK/haokan2.39_nolive/YYULiveSDKBridgeDemo-LinkMap-normal-arm64.txt";
    [[HBLinkMapManager defaultManager] analyze:[NSURL fileURLWithPath:linkmapPath]];
}

@end
