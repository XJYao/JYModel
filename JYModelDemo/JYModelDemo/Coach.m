//
//  Coach.m
//  JYModelDemo
//
//  Created by XJY on 2017/12/2.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "Coach.h"
#import <JYModel/JYModel.h>

@implementation Coach

+ (NSString *)classHeadFilePath {
    NSString *infoPlistPath = [[NSBundle mainBundle]pathForResource:@"Info.plist" ofType:nil];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
    NSString *projectPath = [infoDict objectForKey:@"ProjectPath"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.h", projectPath, NSStringFromClass([self class])];
    return filePath;
}

+ (NSString *)startKeyPathFromJSONToGenerateProperties {
    return @"data->list";
}

+ (NSDictionary *)customClassForKeyMapper {
    return @{@"school" : @"School"};
}

+ (NSDictionary *)customPropertyNameForKeyMapper {
    return @{@"id" : @"identifier"};
}

@end
