//
//  NSObject+JYModel.h
//  JYModel
//
//  Created by XJY on 2017/12/2.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JYModel)

/**
 CN: 传入JSON，自动生成属性并写入到头文件中
 EN: Auto writing properties to head file.

 @param data JSON data.
 @return CN: 成功返回YES，失败返回NO; EN: If something wrong, return NO.
 */
+ (BOOL)autoGeneratePropertiesWithJSONData:(NSData *)data;

@end

@protocol JYModel <NSObject>

@required

/**
 CN: 待写入的头文件路径; EN: Header file path to be written.

 @return CN: 文件路径; EN: File path.
 */
+ (NSString *)classHeadFilePath;

@optional

/**
 CN: 如果需要用到的是JSON中某个字段下的数据，返回用"->"符号拼接出的该字段的路径。如果返回nil，则默认使用完整的JSON。
 EN: Let me know which data you want to use. Use "->" to separate keys. If return nil, use full JSON.
 
 Example: {"data" : {"list" : {"name" : "Tom"}}}
 
 CN: 如果"{"name" : "Tom"}"是需要使用的部分，则返回@"data->list"即可。
 EN: If "{"name" : "Tom"}" is what you want, return @"data->list".

 @return Start key path. Use "->" to separate keys.
 */
+ (NSString *)startKeyPathFromJSONToGenerateProperties;

/**
 CN: 字段与自定义类的映射, 字段值是从使用的部分开始。
 EN: Key and custom class mapper. Key is start from the JSON be used.

 Example: {"data" : {"list" : {"person" : {\"name\" : \"Tom\"}}}}
 
 {"person" : {\"name\" : \"Tom\"}} is be used.
 
 + (NSDictionary *)customClassForKeyMapper {
 return @{@"person" : @"Person"};//'person' is kind of Person class.
 }
 
 @return CN: 映射表; EN: Mapper Table;
 */
+ (NSDictionary *)customClassForKeyMapper;

@end
