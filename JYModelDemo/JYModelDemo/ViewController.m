//
//  ViewController.m
//  JYModelDemo
//
//  Created by XJY on 2017/12/2.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

#import <JYModel/JYModel.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *json = @"{\"data\" : {\"list\" : {\"name\" : \"Tom\", \"age\" : 21, \"gender\" : 1, \"isStudent\" : true, \"height\" : 180.3, \"id\" : 14124897432759830, \"school\" : {\"schoolName\" : \"what?\", \"city\" : {\"cityName\" : \"Beijing\"}}}}}";
    
    NSString *result = [Person autoGeneratePropertiesWithJSONString:json];
    NSLog(@"%@", result);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
