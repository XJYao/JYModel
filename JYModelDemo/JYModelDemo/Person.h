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
/* JYModel auto generate begin, don't change this note! */

/**
The student's gender. 0 is boy, 1 is girl.
*/
@property (nonatomic, assign) PersonGender gender;

/**
The student's height. cm
*/
@property (nonatomic, assign) double height;

/**
<#Description#>
*/
@property (nonatomic, strong) School *school;

/**
The student's identifier
*/
@property (nonatomic, assign) NSInteger identifier;

/**
The student's age.
*/
@property (nonatomic, assign, readonly) NSInteger age;

/**
is he student?
*/
@property (nonatomic, assign) BOOL isStudent;

/**
The student's name.
*/
@property (nonatomic, copy) NSString *name;

/* JYModel auto generate end, don't change this note! */

@end

