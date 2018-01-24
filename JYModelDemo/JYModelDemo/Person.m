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
    return @{@"school" : @"School",
             @"gender" : @"PersonGender",
             @"lessons" : @"NSArray <NSDictionary *>"
             };
}

+ (NSDictionary *)customPropertyNameForKeyMapper {
    return @{@"id" : @"identifier"};
}

+ (NSDictionary *)customNoteForKeyMapper {
    return @{@"name" : @"The student's name.",
             @"age" : @"The student's age.",
             @"gender" : @"The student's gender. 0 is boy, 1 is girl.",
             @"isStudent" : @"is he student?",
             @"height" : @"The student's height. cm",
             @"id" : @"The student's identifier",
             @"school" : @"The student's school",
             @"lessons" : @"The student's lessons"
             };
}

+ (NSDictionary *)customModificationForKeyMapper {
    return @{@"age" : @"nonatomic, assign, readonly"};
}

@end
