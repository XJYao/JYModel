//
//  NSObject+JYModelGeneration.m
//  JYModel
//
//  Created by XJY on 2017/12/4.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "NSObject+JYModelGeneration.h"
#import <objc/runtime.h>

@implementation NSObject (JYModelGeneration)

+ (NSString *)autoGeneratePropertiesWithJSONString:(NSString *)jsonString {
#ifdef DEBUG
    if ([self isStringEmpty:jsonString]) {
        NSLog(@"JYModel ERROR: JSON string is nil or is not kind of NSString");
        return nil;
    }
    return [self autoGeneratePropertiesWithJSONData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
#else
    return nil;
#endif
}

+ (NSString *)autoGeneratePropertiesWithJSONData:(NSData *)data {
#ifdef DEBUG
    if ([self isDataEmpty:data]) {
        NSLog(@"JYModel ERROR: JSON data is nil or is not kind of NSData");
        return nil;
    }
    
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    if ([self isObjectNull:jsonObject] || ![self isObjectNull:jsonError]) {
        NSLog(@"JYModel ERROR: There is something wrong for parsing JSON with reason: %@", jsonError.localizedDescription);
        return nil;
    }
    return [self autoGeneratePropertiesWithJSONDict:jsonObject];
#else
    return nil;
#endif
}

+ (NSString *)autoGeneratePropertiesWithJSONDict:(NSDictionary *)jsonDict {
#ifdef DEBUG
    if ([self isDictionaryEmpty:jsonDict]) {
        NSLog(@"JYModel ERROR: JSON is nil or is not king of NSDictionary");
        return nil;
    }
    
    Class selfClass = [self class];
    
    BOOL shouldAutoWriting = YES;
#if TARGET_OS_SIMULATOR
    if ([selfClass respondsToSelector:@selector(shouldAutoWritingProperties)]) {
        shouldAutoWriting = [(id<JYModelGeneration>)selfClass shouldAutoWritingProperties];
    }
#else
    shouldAutoWriting = NO;
    NSLog(@"JYModel WARN: If you want to write to head file automatically, please use simulator!");
#endif
    
    NSString *headFilePath = nil;
    NSString *headFileContent = nil;
    if (shouldAutoWriting) {
        if ([selfClass respondsToSelector:@selector(classHeadFilePath)]) {
            headFilePath = [(id<JYModelGeneration>)selfClass classHeadFilePath];
        }
        if ([self isStringEmpty:headFilePath]) {
            NSLog(@"JYModel ERROR: Head file path is nil or is not kind of NSString");
            shouldAutoWriting = NO;
        } else if (![[NSFileManager defaultManager] fileExistsAtPath:headFilePath]) {
            NSLog(@"JYModel ERROR: Head file path is not exist");
            shouldAutoWriting = NO;
        } else if (![[NSFileManager defaultManager] isWritableFileAtPath:headFilePath]) {
            NSLog(@"JYModel ERROR: Head file is not writable");
            shouldAutoWriting = NO;
        }
        NSError *readFileError = nil;
        headFileContent = [NSString stringWithContentsOfFile:headFilePath encoding:NSUTF8StringEncoding error:&readFileError];
        if ([self isStringEmpty:headFileContent] || ![self isObjectNull:readFileError]) {
            NSLog(@"JYModel ERROR: There is something wrong for reading head file with reason: %@", readFileError.localizedDescription);
            shouldAutoWriting = NO;
        }
    }
    
    NSString *startKeyPath = nil;
    //Get start key path.
    if ([selfClass respondsToSelector:@selector(startKeyPathFromJSONToGenerateProperties)]) {
        startKeyPath = [(id<JYModelGeneration>)selfClass startKeyPathFromJSONToGenerateProperties];
    }
    if (![self isStringEmpty:startKeyPath]) {
        NSArray *startKeys = [startKeyPath componentsSeparatedByString:@"->"];
        if (startKeys.count == 0) {
            NSLog(@"JYModel ERROR: I don't know which key you want to start with");
            return nil;
        }
        id subJSONObject = (id)jsonDict;
        BOOL isJSONArray = NO;
        for (NSInteger i = 0; i < startKeys.count; i ++) {
            NSString *key = [startKeys objectAtIndex:i];
            subJSONObject = [self subJSONObjectWithKey:key jsonDict:subJSONObject];
            
            if ([self isDictionaryEmpty:subJSONObject]) {
                if (i != startKeys.count - 1) {
                    NSLog(@"JYModel ERROR: The key path that you want to start is wrong");
                    return nil;
                }
                if ([self isArrayEmpty:subJSONObject]) {
                    NSLog(@"JYModel ERROR: The key path that you want to start is wrong");
                    return nil;
                }
                //Maybe it's an array.
                isJSONArray = YES;
            }
        }
        if (isJSONArray) {
            BOOL found = NO;
            for (id sub in subJSONObject) {
                if (![self isDictionaryEmpty:sub]) {
                    jsonDict = (NSDictionary *)sub;
                    found = YES;
                    break;
                }
            }
            if (!found) {
                NSLog(@"JYModel ERROR: The key path that you want to start is wrong");
                return nil;
            }
        } else {
            jsonDict = (NSDictionary *)subJSONObject;
        }
    }
    
    //Generate properties.
    
    NSDictionary *customClassForKey = nil;
    if ([selfClass respondsToSelector:@selector(customClassForKeyMapper)]) {
        customClassForKey = [(id<JYModelGeneration>)selfClass customClassForKeyMapper];
    }
    
    NSDictionary *customPropertyNameForKey = nil;
    if ([selfClass respondsToSelector:@selector(customPropertyNameForKeyMapper)]) {
        customPropertyNameForKey = [(id<JYModelGeneration>)selfClass customPropertyNameForKeyMapper];
    }
    
    shouldAutoWriting = shouldAutoWriting && ![self isStringEmpty:headFilePath] && ![self isStringEmpty:headFileContent];
    
    NSMutableArray *components = nil;
    if (shouldAutoWriting) {
        components = [headFileContent componentsSeparatedByString:@"\n"].mutableCopy;
    }
    
    Class NSStringClass = [NSString class];
    Class NSArrayClass = [NSArray class];
    Class NSDictionaryClass = [NSDictionary class];
    Class NSNumberClass = [NSNumber class];
    NSArray *allPropertyNames = jsonDict.allKeys;
    
    NSMutableArray *properties = [[NSMutableArray alloc] init];
    for (NSString *name in allPropertyNames) {
        if ([self isStringEmpty:name]) {
            continue;
        }
        id value = [jsonDict objectForKey:name];
        
        //class
        NSString *clsName = @"id";
        NSString *customClass = [customClassForKey objectForKey:name];
        if ([self isStringEmpty:customClass]) {
            if (![self isObjectNull:value]) {
                if ([value isKindOfClass:NSStringClass]) {
                    clsName = @"NSString";
                } else if ([value isKindOfClass:NSArrayClass]) {
                    clsName = @"NSArray";
                } else if ([value isKindOfClass:NSDictionaryClass]) {
                    clsName = @"NSDictionary";
                } else if ([value isKindOfClass:NSNumberClass]) {
                    const char *type = ((NSNumber *)value).objCType;
                    
                    switch (*type) {
                        case _C_CHR: { //char
                            clsName = @"BOOL";
                        } break;
                            
                        case _C_INT: { //int32
                            clsName = @"int";
                        } break;
                            
                        case _C_SHT: { //short
                            clsName = @"short";
                        } break;
                            
                        case _C_LNG: { //long
                            clsName = @"long";
                        } break;
                            
                        case _C_LNG_LNG: { //long long / int64
                            clsName = @"NSInteger";
                        } break;
                            
                        case _C_UCHR: { //unsigned char / unsigned int8
                            clsName = @"unsigned char";
                        } break;
                            
                        case _C_UINT: { //unsigned int
                            clsName = @"unsigned int";
                        } break;
                            
                        case _C_USHT: { //unsigned short
                            clsName = @"unsigned short";
                        } break;
                            
                        case _C_ULNG: { //unsigned long
                            clsName = @"unsigned long";
                        } break;
                            
                        case _C_ULNG_LNG: { //unsigned long long / unsigned int64
                            clsName = @"NSUInteger";
                        } break;
                            
                        case _C_FLT: { //float
                            clsName = @"float";
                        } break;
                            
                        case _C_DBL: { //double
                            clsName = @"double";
                        } break;
                            
                        case 'D': { //long double
                            clsName = @"CGFloat";
                        } break;
                            
                        case _C_BOOL: { //a C++ bool or a C99 _Bool
                            clsName = @"BOOL";
                        } break;
                        default: {
                            clsName = @"NSNumber";
                        } break;
                    }
                }
            }
        } else {
            clsName = customClass;
            
            if (![self isObjectNull:value] && [value isKindOfClass:NSDictionaryClass]) {
                [NSClassFromString(customClass) autoGeneratePropertiesWithJSONDict:value];
            }
        }
        NSArray *keys = nil;
        BOOL isPoint = NO;
        
        if ([clsName isEqualToString:@"id"]) {
            keys = @[@"nonatomic", @"strong"];
            isPoint = NO;
        } else if ([clsName isEqualToString:@"NSString"]) {
            keys = @[@"nonatomic", @"copy"];
            isPoint = YES;
        } else {
            NSString *tempClsName = clsName;
            NSUInteger leftIndex = [tempClsName rangeOfString:@"<"].location;
            if (leftIndex != NSNotFound && [tempClsName rangeOfString:@">"].location != NSNotFound) {
                tempClsName = [tempClsName substringToIndex:leftIndex];
                tempClsName = [tempClsName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            Class cls = NSClassFromString(tempClsName);
            if ([self isClassNull:cls]) {
                keys = @[@"nonatomic", @"assign"];
                isPoint = NO;
            } else {
                keys = @[@"nonatomic", @"strong"];
                isPoint = YES;
            }
        }
        
        //name
        NSString *propertyName = [customPropertyNameForKey objectForKey:name];
        if ([self isStringEmpty:propertyName]) {
            propertyName = name;
        }
        
        NSString *propertyString = [self propertyWithName:propertyName clsName:clsName keys:keys isPoint:isPoint];
        [properties addObject:propertyString];
        
        if (!shouldAutoWriting) {
            continue;
        }
        
        //Find interface index, @end index
        NSInteger interfaceIndexInSelfClass = NSNotFound;
        NSInteger endIndexInSelfClass = NSNotFound;
        
        for (NSInteger i = 0; i < components.count; i ++) {
            NSString *contentForRow = [components objectAtIndex:i];
            if ([self isStringEmpty:contentForRow]) {
                continue;
            }
            if (interfaceIndexInSelfClass != NSNotFound) {
                if (endIndexInSelfClass == NSNotFound) {
                    if ([contentForRow rangeOfString:@"@end"].location != NSNotFound) {
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
        
        if (interfaceIndexInSelfClass == NSNotFound || endIndexInSelfClass == NSNotFound) {
            continue;
        }
        
        BOOL found = NO;
        for (NSInteger i = interfaceIndexInSelfClass + 1; i < endIndexInSelfClass; i ++) {
            NSString *contentForRow = [components objectAtIndex:i];
            if ([self isStringEmpty:contentForRow]) {
                continue;
            }
            if ([contentForRow rangeOfString:@"@property"].location == NSNotFound) {
                continue;
            }
            if ([contentForRow rangeOfString:[NSString stringWithFormat:@" %@%@;", isPoint ? @"*" : @"", propertyName]].location == NSNotFound && [contentForRow rangeOfString:[NSString stringWithFormat:@" %@;", propertyName]].location == NSNotFound) {
                continue;
            }
            found = YES;
            
            [components replaceObjectAtIndex:i withObject:propertyString];
            break;
        }
        if (!found) {
            [components insertObject:[NSString stringWithFormat:@"%@", propertyString] atIndex:endIndexInSelfClass];
            [components insertObject:@"" atIndex:endIndexInSelfClass + 1];
        }
    }
    
    if (shouldAutoWriting) {
        //Write file content to head file.
        NSData *newFileData = [[components componentsJoinedByString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
        BOOL writeSuccess = [newFileData writeToURL:[NSURL fileURLWithPath:headFilePath] atomically:YES];
        if (!writeSuccess) {
            NSLog(@"JYModel ERROR: There is something wrong for writing to head file.");
        }
    }

    NSString *propertiesString = [properties componentsJoinedByString:@"\n\n"];
    return propertiesString;
#else
    return nil;
#endif
}

+ (NSString *)propertyWithName:(NSString *)name clsName:(NSString *)clsName keys:(NSArray *)keys isPoint:(BOOL)isPoint {
    return [NSString stringWithFormat:@"@property (%@) %@ %@%@;", [keys componentsJoinedByString:@", "], clsName, isPoint ? @"*" : @"", name];
}

+ (id)subJSONObjectWithKey:(NSString *)key jsonDict:(NSDictionary *)jsonDict {
    if ([self isStringEmpty:key] || [self isDictionaryEmpty:jsonDict]) {
        return nil;
    }
    return [jsonDict objectForKey:key];
}

+ (BOOL)isObjectNull:(id)obj {
    if (!obj || obj == nil || obj == Nil || obj == NULL || [obj isEqual:[NSNull null]] || obj == (id)kCFNull) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isStringEmpty:(NSString *)str {
    if ([self isObjectNull:str]) {
        return YES;
    }
    if (![str isKindOfClass:[NSString class]]) {
        return YES;
    }
    return str.length == 0;
}

+ (BOOL)isArrayEmpty:(NSArray *)array {
    if ([self isObjectNull:array]) {
        return YES;
    }
    if (![array isKindOfClass:[NSArray class]]) {
        return YES;
    }
    return array.count == 0;
}

+ (BOOL)isDictionaryEmpty:(NSDictionary *)dictionary {
    if ([self isObjectNull:dictionary]) {
        return YES;
    }
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    return dictionary.count == 0;
}

+ (BOOL)isDataEmpty:(NSData *)data {
    if ([self isObjectNull:data]) {
        return YES;
    }
    if (![data isKindOfClass:[NSData class]]) {
        return YES;
    }
    return data.length == 0;
}

+ (BOOL)isClassNull:(Class)cls {
    if (!cls || cls == Nil) {
        return YES;
    } else {
        return NO;
    }
}

@end
