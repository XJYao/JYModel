//
//  Coach.h
//  JYModelDemo
//
//  Created by XJY on 2017/12/2.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ddd : NSObject
/* JYModel auto generate begin, don't change this note! */
@property (nonatomic, copy) NSString *mail;
/* JYModel auto generate end, don't change this note! */
@end

@interface Coach : NSObject
/* JYModel auto generate begin, don't change this note! */
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, assign) double height;
@property (nonatomic, strong) School *school;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) BOOL isStudent;
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, copy) NSString *name;
/* JYModel auto generate end, don't change this note! */
@end

@interface hahaha : NSObject
/* JYModel auto generate begin, don't change this note! */
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, copy) NSString *photo;
/* JYModel auto generate end, don't change this note! */
@end
