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

@property (weak, nonatomic) IBOutlet UILabel *jsonLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *json = @"{\"data\" : {\"person\" : {\"name\" : \"Tom\", \"age\" : 21, \"gender\" : 1, \"isStudent\" : true, \"height\" : 180.3, \"id\" : 14124897432759830, \"school\" : {\"schoolName\" : \"what?\", \"city\" : \"Beijing\"}, \"lessons\" : [{\"lessonName\" : \"English\"}]}}}";
    [self.jsonLabel setText:json];
    
    NSString *result = [Person autoGeneratePropertiesWithJSONString:json];
    NSLog(@"%@", result);
    [self.resultLabel setText:result];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
