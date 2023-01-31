//
//  HBUnusedMethodManager.m
//  class-dump
//
//  Created by linsunxin on 2023/1/31.
//

#import "HBUnusedMethodManager.h"
#import "HBLinkMapManager.h"
#import "CDMachOFileDataCursor.h"
#import "CDMachOFile.h"
#import "CDLCSegment.h"
#import "CDOCClass.h"
#import "CDOCClassReference.h"
#import "CDOCMethod.h"
#import "CDOCProperty.h"

@interface HBUnusedMethodManager ()

@property (nonatomic, copy) NSDictionary *norefsMethods;

@end

@implementation HBUnusedMethodManager

+ (instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    static HBUnusedMethodManager *defaultManager;
    dispatch_once(&onceToken, ^{
        defaultManager = [[HBUnusedMethodManager alloc] init];
    });
    return defaultManager;
}

- (void)analyze:(CDObjectiveCProcessor *)processor
{
    NSString *linkmapPath = @"/Users/linsunxin/Documents/Temp/haokan2.39_nolive/YYULiveSDKBridgeDemo-LinkMap-normal-arm64.txt";
    [[HBLinkMapManager defaultManager] analyze:[NSURL fileURLWithPath:linkmapPath]];
    
    NSDictionary<NSString *, NSArray<NSString *> *> *whiteList = [self featchWhiteList];
    
    NSMutableArray *selrefsArray = @[].mutableCopy;
    NSMutableArray *noRefArray = @[].mutableCopy;
    NSMutableDictionary *allNoRefDict = @{}.mutableCopy;
    
    CDSection *section = [[processor.machOFile dataConstSegment] sectionWithName:@"__objc_selrefs"];
    CDMachOFileDataCursor *cursor = [[CDMachOFileDataCursor alloc] initWithSection:section];
    
    while ([cursor isAtEnd] == NO) {
        uint64_t val = [cursor readPtr];
        NSString *str = [processor.machOFile stringAtAddress:val];
        if (str.length > 0) {
            [selrefsArray addObject:str];
        }
    }

    for (CDOCClass *aClass in [processor getClasses]) {
        HBSymbolModel *symbolModel = [[HBLinkMapManager defaultManager] symbolModelWithName:aClass.name];

        if (![symbolModel.component hasPrefix:@"yychannelcomponent"]) {
            continue;
        }
        
        if ([aClass.name isEqualToString:@"YYPluginPermission"]) {
            NSLog(@" ");
        }
        
        NSMutableArray *protocolMethods = @[].mutableCopy;
        
        for (CDOCProtocol *protocol in aClass.protocols) {
            for (CDOCMethod *method in protocol.instanceMethods) {
                [protocolMethods addObject:method.name];
            }
            for (CDOCMethod *method in protocol.optionalInstanceMethods) {
                [protocolMethods addObject:method.name];
            }
            for (CDOCMethod *method in protocol.classMethods) {
                [protocolMethods addObject:method.name];
            }
            for (CDOCMethod *method in protocol.optionalClassMethods) {
                [protocolMethods addObject:method.name];
            }
        }
        
        NSMutableArray *getterAndSetterMethods = @[].mutableCopy;
        for (CDOCProperty *property in aClass.properties) {
            NSString *propertySetter = property.name;
            propertySetter = [propertySetter stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[propertySetter substringToIndex:1] capitalizedString]];
            propertySetter = [NSString stringWithFormat:@"set%@:", propertySetter];
            
            [getterAndSetterMethods addObject:property.name];
            [getterAndSetterMethods addObject:propertySetter];
        }
        
        for (CDOCMethod *method in aClass.instanceMethods) {
            if ([noRefArray containsObject:method.name]) {
                continue;
            }
            if ([getterAndSetterMethods containsObject:method.name]) {
                continue;
            }
            if ([protocolMethods containsObject:method.name]) {
                continue;
            }
            if ([whiteList[aClass.name] containsObject:method.name]) {
                continue;
            }
            
            if (![selrefsArray containsObject:method.name]) {
                [noRefArray addObject:method.name];
                
                NSMutableArray *noRefFromeClassArray = allNoRefDict[aClass.name];
                if (!noRefFromeClassArray) {
                    noRefFromeClassArray = @[].mutableCopy;
                }
                
                [noRefFromeClassArray addObject:method.name];
                allNoRefDict[aClass.name] = noRefFromeClassArray;
            }
        }
    }
    
    self.norefsMethods = allNoRefDict.copy;
    
    for (NSString *key in self.norefsMethods.allKeys) {
        NSLog(@"%@", key);
        for (NSString *m in self.norefsMethods[key]) {
            NSLog(@"    %@", m);
        }
    }
    exit(0);
}

- (NSDictionary<NSString *, NSArray<NSString *> *> *)featchWhiteList
{
    NSString *whiteListPath = @"/Users/linsunxin/Downloads/yychannelcomponent_unused_white_list.json";
    if (![[NSFileManager defaultManager] fileExistsAtPath:whiteListPath]) {
        return nil;
    }
    NSString *jsonString = [NSString stringWithContentsOfFile:whiteListPath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:jsonData
                                           options:NSJSONReadingMutableContainers
                                             error:nil];
}

@end
