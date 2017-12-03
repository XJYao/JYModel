//
//  NSObject+JYModel.m
//  JYModel
//
//  Created by XJY on 2017/12/2.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "NSObject+JYModel.h"
#import <objc/runtime.h>

@implementation NSObject (JYModel)

#define kBeginNote @"/* JYModel auto generate begin, don't change this note! */"
#define kEndNote @"/* JYModel auto generate end, don't change this note! */"

+ (BOOL)autoGeneratePropertiesWithJSONString:(NSString *)jsonString {
    if ([self paramError:jsonString cls:[NSString class]]) {
        return NO;
    }
    return [self autoGeneratePropertiesWithJSONData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (BOOL)autoGeneratePropertiesWithJSONDict:(NSDictionary *)jsonDict {
    if ([self paramError:jsonDict cls:[NSDictionary class]]) {
        return NO;
    }
    
    NSError *jsonError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
    if ([self paramError:data cls:[NSData class]] || ![self isObjectNull:jsonError]) {
        return NO;
    }
    return [self autoGeneratePropertiesWithJSONData:data];
}

+ (BOOL)autoGeneratePropertiesWithJSONData:(NSData *)data {
    Class NSDataClass = [NSData class];
    if ([self paramError:data cls:NSDataClass]) {
        //Data is nil or is not kind of NSData.
        return NO;
    }
    
    Class selfClass = [self class];
    
    NSString *headFilePath = nil;
    if ([selfClass respondsToSelector:@selector(classHeadFilePath)]) {
        headFilePath = [(id<JYModel>)selfClass classHeadFilePath];
    }
    
    Class NSStringClass = [NSString class];
    if ([self paramError:headFilePath cls:NSStringClass]) {
        //Head file path is nil or is not kind of NSString.
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:headFilePath]) {
        //Head file path is not exist.
        return NO;
    }
    if (![[NSFileManager defaultManager] isWritableFileAtPath:headFilePath]) {
        //Head file is not writable.
        return NO;
    }
    NSError *readFileError = nil;
    NSString *headFileContent = [NSString stringWithContentsOfFile:headFilePath encoding:NSUTF8StringEncoding error:&readFileError];
    if ([self paramError:headFileContent cls:NSStringClass] || ![self isObjectNull:readFileError]) {
        //There is something wrong for reading head file.
        return NO;
    }
    
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    if ([self isObjectNull:jsonObject] || ![self isObjectNull:jsonError]) {
        //There is something wrong for parsing JSON.
        return NO;
    }
    Class NSDictionaryClass = [NSDictionary class];
    if (![jsonObject isKindOfClass:NSDictionaryClass]) {
        //JSON is not king of NSDictionary.
        return NO;
    }
    
    NSDictionary *jsonDict = (NSDictionary *)jsonObject;
    
    Class NSArrayClass = [NSArray class];
    
    NSString *startKeyPath = nil;
    //Get start key path.
    if ([selfClass respondsToSelector:@selector(startKeyPathFromJSONToGenerateProperties)]) {
        startKeyPath = [(id<JYModel>)selfClass startKeyPathFromJSONToGenerateProperties];
    }
    if (![self paramError:startKeyPath cls:NSStringClass]) {
        NSArray *startKeys = [startKeyPath componentsSeparatedByString:@"->"];
        if (startKeys.count == 0) {
            return NO;
        }
        id subJSONObject = (id)jsonDict;
        BOOL isJSONArray = NO;
        for (NSInteger i = 0; i < startKeys.count; i ++) {
            NSString *key = [startKeys objectAtIndex:i];
            subJSONObject = [self subJSONObjectWithKey:key jsonDict:subJSONObject];
            
            if ([self paramError:subJSONObject cls:NSDictionaryClass]) {
                if (i != startKeys.count - 1) {
                    return NO;
                }
                if ([self paramError:subJSONObject cls:NSArrayClass]) {
                    return NO;
                }
                //Maybe it's an array.
                isJSONArray = YES;
            }
        }
        if (isJSONArray) {
            BOOL found = NO;
            for (id sub in subJSONObject) {
                if (![self paramError:sub cls:NSDictionaryClass]) {
                    jsonDict = (NSDictionary *)sub;
                    found = YES;
                    break;
                }
            }
            if (!found) {
                return NO;
            }
        } else {
            jsonDict = (NSDictionary *)subJSONObject;
        }
    }
    
    //Generate properties.
    Class NSNumberClass = [NSNumber class];
    NSArray *allPropertyNames = jsonDict.allKeys;
    
    NSDictionary *customClassForKey = nil;
    if ([selfClass respondsToSelector:@selector(customClassForKeyMapper)]) {
        customClassForKey = [(id<JYModel>)selfClass customClassForKeyMapper];
    }
    
    NSMutableArray *properties = [[NSMutableArray alloc] init];
    for (NSString *name in allPropertyNames) {
        if ([self paramError:name cls:NSStringClass]) {
            continue;
        }
        id value = [jsonDict objectForKey:name];
        
        NSString *key = @"strong";
        NSString *clsName = @"id";
        BOOL isPoint = NO;
        if (![self isObjectNull:value]) {
            if ([value isKindOfClass:NSStringClass]) {
                key = @"copy";
                clsName = @"NSString";
                isPoint = YES;
            } else if ([value isKindOfClass:NSArrayClass]) {
                key = @"strong";
                clsName = @"NSArray";
                isPoint = YES;
            } else if ([value isKindOfClass:NSDictionaryClass]) {
                
                NSString *customClass = [customClassForKey objectForKey:name];
                if ([self paramError:customClass cls:NSStringClass]) {
                    customClass = @"NSDictionary";
                } else {
                    [NSClassFromString(customClass) autoGeneratePropertiesWithJSONDict:value];
                }
                
                key = @"strong";
                clsName = customClass;
                isPoint = YES;
            } else if ([value isKindOfClass:NSNumberClass]) {
                const char *type = ((NSNumber *)value).objCType;
                
                switch (*type) {
                    case _C_CHR: { //char
                        key = @"assign";
                        clsName = @"BOOL";
                        isPoint = NO;
                    } break;
                        
                    case _C_INT: { //int32
                        key = @"assign";
                        clsName = @"int";
                        isPoint = NO;
                    } break;
                        
                    case _C_SHT: { //short
                        key = @"assign";
                        clsName = @"short";
                        isPoint = NO;
                    } break;
                        
                    case _C_LNG: { //long
                        key = @"assign";
                        clsName = @"long";
                        isPoint = NO;
                    } break;
                        
                    case _C_LNG_LNG: { //long long / int64
                        key = @"assign";
                        clsName = @"NSInteger";
                        isPoint = NO;
                    } break;
                        
                    case _C_UCHR: { //unsigned char / unsigned int8
                        key = @"assign";
                        clsName = @"unsigned char";
                        isPoint = NO;
                    } break;
                        
                    case _C_UINT: { //unsigned int
                        key = @"assign";
                        clsName = @"unsigned int";
                        isPoint = NO;
                    } break;
                        
                    case _C_USHT: { //unsigned short
                        key = @"assign";
                        clsName = @"unsigned short";
                        isPoint = NO;
                    } break;
                        
                    case _C_ULNG: { //unsigned long
                        key = @"assign";
                        clsName = @"unsigned long";
                        isPoint = NO;
                    } break;
                        
                    case _C_ULNG_LNG: { //unsigned long long / unsigned int64
                        key = @"assign";
                        clsName = @"NSUInteger";
                        isPoint = NO;
                    } break;
                        
                    case _C_FLT: { //float
                        key = @"assign";
                        clsName = @"float";
                        isPoint = NO;
                    } break;
                        
                    case _C_DBL: { //double
                        key = @"assign";
                        clsName = @"double";
                        isPoint = NO;
                    } break;
                        
                    case 'D': { //long double
                        key = @"assign";
                        clsName = @"CGFloat";
                        isPoint = NO;
                    } break;
                        
                    case _C_BOOL: { //a C++ bool or a C99 _Bool
                        key = @"assign";
                        clsName = @"BOOL";
                        isPoint = NO;
                    } break;
                    default: {
                        key = @"strong";
                        clsName = @"NSNumber";
                        isPoint = YES;
                    } break;
                }
            }
        }
        [properties addObject:[self propertyWithName:name clsName:clsName key:key isPoint:isPoint]];
    }
    
    if ([self paramError:properties cls:NSArrayClass]) {
        return NO;
    }
    
    NSMutableArray *components = [headFileContent componentsSeparatedByString:@"\n"].mutableCopy;
    
    //Find interface index, @end index, old NOTE index.
    //Old properties should be deleted.
    NSInteger interfaceIndexInSelfClass = NSNotFound;
    NSInteger endIndexInSelfClass = NSNotFound;
    NSInteger beginNoteIndexInSelfClass = NSNotFound;
    NSInteger endNoteIndexInSelfClass = NSNotFound;
    
    for (NSInteger i = 0; i < components.count; i ++) {
        NSString *contentForRow = [components objectAtIndex:i];
        if (contentForRow.length == 0) {
            continue;
        }
        if (interfaceIndexInSelfClass != NSNotFound) {
            if (endIndexInSelfClass == NSNotFound) {
                if (beginNoteIndexInSelfClass == NSNotFound && [contentForRow rangeOfString:kBeginNote].location != NSNotFound) {
                    beginNoteIndexInSelfClass = i;
                } else if (endNoteIndexInSelfClass == NSNotFound && [contentForRow rangeOfString:kEndNote].location != NSNotFound) {
                    endNoteIndexInSelfClass = i;
                } else if ([contentForRow rangeOfString:@"@end"].location != NSNotFound) {
                    endIndexInSelfClass = i;
                }
            }
        }
        
        if ([contentForRow rangeOfString:@"@interface"].location != NSNotFound &&
            [contentForRow rangeOfString:NSStringFromClass(selfClass)].location != NSNotFound &&
            [contentForRow rangeOfString:@":"].location != NSNotFound) {
            interfaceIndexInSelfClass = i;
        }
    }
    if (interfaceIndexInSelfClass == NSNotFound) {
        return NO;
    }
    NSInteger insertIndex = interfaceIndexInSelfClass + 1;
    
    //Delete old properties
    if (beginNoteIndexInSelfClass != NSNotFound &&
        endNoteIndexInSelfClass != NSNotFound) {
        [components removeObjectsInRange:NSMakeRange(beginNoteIndexInSelfClass, endNoteIndexInSelfClass - beginNoteIndexInSelfClass + 1)];
    }
    
    //Write properties to head file.
    NSString *propertiesString = [properties componentsJoinedByString:@"\n"];
    propertiesString = [NSString stringWithFormat:@"%@\n%@\n%@", kBeginNote, propertiesString, kEndNote];
    
    [components insertObject:propertiesString atIndex:insertIndex];
    
    NSData *newFileData = [[components componentsJoinedByString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
    return [newFileData writeToURL:[NSURL fileURLWithPath:headFilePath] atomically:YES];
}

+ (NSString *)propertyWithName:(NSString *)name clsName:(NSString *)clsName key:(NSString *)key isPoint:(BOOL)isPoint {
    return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@%@;", key, clsName, isPoint ? @"*" : @"", name];
}

+ (id)subJSONObjectWithKey:(NSString *)key jsonDict:(NSDictionary *)jsonDict {
    if ([self paramError:key cls:[NSString class]]) {
        return nil;
    }
    if ([self paramError:jsonDict cls:[NSDictionary class]]) {
        return nil;
    }
    return [jsonDict objectForKey:key];
}

+ (BOOL)paramError:(id)param cls:(Class)cls {
    if ([self isObjectNull:param]) {
        return YES;
    }
    if (!cls || cls == Nil) {
        return YES;
    }
    if (![param isKindOfClass:cls]) {
        return YES;
    }
    if ([param isKindOfClass:[NSString class]]) {
        return ((NSString *)param).length == 0;
    } else if ([param isKindOfClass:[NSData class]]) {
        return ((NSData *)param).length == 0;
    } else if ([param isKindOfClass:[NSDictionary class]]) {
        return ((NSDictionary *)param).count == 0;
    } else if ([param isKindOfClass:[NSArray class]]) {
        return ((NSArray *)param).count == 0;
    }
    return YES;
}

+ (BOOL)isObjectNull:(id)obj {
    if (!obj || obj == nil || obj == Nil || obj == NULL || [obj isEqual:[NSNull null]] || obj == (id)kCFNull) {
        return YES;
    } else {
        return NO;
    }
}

@end
