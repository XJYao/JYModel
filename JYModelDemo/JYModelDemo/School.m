//
//  School.m
//  JYModelDemo
//
//  Created by XJY on 2017/12/3.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "School.h"

@implementation School

+ (NSString *)classHeadFilePath {
    NSString *infoPlistPath = [[NSBundle mainBundle]pathForResource:@"Info.plist" ofType:nil];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
    NSString *projectPath = [infoDict objectForKey:@"ProjectPath"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.h", projectPath, NSStringFromClass([self class])];
    return filePath;
}

+ (BOOL)shouldAddNoteTemplates {
    return NO;
}

@end
