//
//  Person.m
//  JYModelDemo
//
//  Created by XJY on 2017/12/2.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "Person.h"
#import <JYModel/JYModel.h>

@implementation Person

+ (NSString *)classHeadFilePath {
    NSString *infoPlistPath = [[NSBundle mainBundle]pathForResource:@"Info.plist" ofType:nil];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
    NSString *projectPath = [infoDict objectForKey:@"ProjectPath"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.h", projectPath, NSStringFromClass([self class])];
    return filePath;
}

+ (NSString *)startKeyPathFromJSONToGenerateProperties {
    return @"data->person";
}

+ (NSDictionary *)customClassForKeyMapper {
    return @{@"school" : @"School"};
}

+ (NSDictionary *)customPropertyNameForKeyMapper {
    return @{@"id" : @"identifier"};
}

@end
