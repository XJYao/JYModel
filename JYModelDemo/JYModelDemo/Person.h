//
//  Person.h
//  JYModelDemo
//
//  Created by XJY on 2017/12/2.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "School.h"

typedef NS_ENUM(NSUInteger, PersonGender) {
    PersonGenderBoy = 0,
    PersonGenderGirl = 1
};

@interface Person : NSObject

@property (nonatomic, assign) PersonGender gender;

@property (nonatomic, assign) double height;

@property (nonatomic, strong) School *school;

@property (nonatomic, assign) NSInteger identifier;

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, strong) NSArray <NSDictionary *> *lessons;

@property (nonatomic, assign) BOOL isStudent;

@property (nonatomic, copy) NSString *name;

@end

