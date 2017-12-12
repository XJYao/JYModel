//
//  NSObject+JYModelGeneration.h
//  JYModel
//
//  Created by XJY on 2017/12/4.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JYModelGeneration)

/**
 CN: 传入JSON字符串，自动生成属性列表，如果方法'shouldAutoWritingProperties'返回YES，则自动写入到头文件中
 EN: Input JSON string, generating properties automatically. They will be written to head file if protocol method 'shouldAutoWritingProperties' return YES.
 
 @param jsonString JSON string.
 @return CN: 成功返回生成结果，你可以自行复制并粘贴到头文件中。失败返回nil; EN: If success, return a properties string, you can copy it and paste to head file by yourself. If something wrong, return nil.
 */
+ (NSString *)autoGeneratePropertiesWithJSONString:(NSString *)jsonString;

/**
 CN: 传入JSON对象（NSDictionary），自动生成属性列表，如果方法'shouldAutoWritingProperties'返回YES，则自动写入到头文件中
 EN: Input JSON dictionary, generating properties automatically. They will be written to head file if protocol method 'shouldAutoWritingProperties' return YES.
 
 @param jsonDict JSON dictionary.
 @return CN: 成功返回生成结果，你可以自行复制并粘贴到头文件中。失败返回nil; EN: If success, return a properties string, you can copy it and paste to head file by yourself. If something wrong, return nil.
 */
+ (NSString *)autoGeneratePropertiesWithJSONDict:(NSDictionary *)jsonDict;

/**
 CN: 传入JSON，自动生成属性列表，如果方法'shouldAutoWritingProperties'返回YES，则自动写入到头文件中
 EN: Input JSON data, generating properties automatically. They will be written to head file if protocol method 'shouldAutoWritingProperties' return YES.
 
 @param data JSON data.
 @return CN: 成功返回生成结果，你可以自行复制并粘贴到头文件中。失败返回nil; EN: If success, return a properties string, you can copy it and paste to head file by yourself. If something wrong, return nil.
 */
+ (NSString *)autoGeneratePropertiesWithJSONData:(NSData *)data;

@end

@protocol JYModelGeneration <NSObject>

@optional

/**
 CN: 待写入的头文件路径; EN: Header file path to be written.
 
 @return CN: 文件路径; EN: File path.
 */
+ (NSString *)classHeadFilePath;

/**
 CN: 如果要使用自动写入功能，请使用模拟器，不支持真机！如果返回NO，将不会自动帮你写入到头文件中，需要你自己手动去复制粘贴。默认YES，自动写入。
 EN: If you want to write automatically, please use simulator, I can't support device. If return NO, I won't write properties to head file, you should copy it and paste to head file by your self. Default is YES.
 
 @return can I help you?
 */
+ (BOOL)shouldAutoWritingProperties;

/**
 CN: 如果需要用到的是JSON中某个字段下的数据，返回用"->"符号拼接出的该字段的路径。如果返回nil，则默认使用完整的JSON。
 EN: Let me know which data you want to use. Use "->" to separate keys. If return nil, use full JSON.
 
 Example: {"data" : {"person" : {"name" : "Tom"}}}
 
 CN: 如果"{"name" : "Tom"}"是需要使用的部分，则返回@"data->person"即可。
 EN: If "{"name" : "Tom"}" is what you want, return @"data->person".
 
 @return Start key path. Use "->" to separate keys.
 */
+ (NSString *)startKeyPathFromJSONToGenerateProperties;

/**
 CN: 字段与自定义类的映射, 字段值是从使用的部分开始。支持枚举。
 EN: Key and custom class mapper. Key is start from the JSON be used. Support enum.
 
 Example: {"data" : {"list" : {"person" : {\"name\" : \"Tom\"}}}}
 
 {"person" : {\"name\" : \"Tom\"}} is be used.
 
 + (NSDictionary *)customClassForKeyMapper {
 return @{@"person" : @"Person"};//'person' is kind of Person class.
 }
 
 @return CN: 映射表; EN: Mapper Table;
 */
+ (NSDictionary *)customClassForKeyMapper;

/**
 CN: 自定义属性名映射
 EN: Custom property name for key.
 
 Example: {\"name\" : \"Tom\"}
 If you want to use 'customName' instead of 'name'
 + (NSDictionary *)customPropertyNameForKeyMapper {
 return @{@"name", @"customName"};
 }
 
 @return CN: 映射表; EN: Mapper Table;
 */
+ (NSDictionary *)customPropertyNameForKeyMapper;

/**
 CN: 是否需要添加注释模板，默认YES
 EN: If you want note templates, return YES. Default is YES.
 
 @return Do you want?
 */
+ (BOOL)shouldAddNoteTemplates;

/**
 CN: 属性注释映射
 EN: Custom note for key.
 
 Example: {\"name\" : \"Tom\"}

 + (NSDictionary *)customNoteForKeyMapper {
 return @{@"name", @"The student's name."};
 }
 
 @return CN: 映射表; EN: Mapper Table;
 */
+ (NSDictionary *)customNoteForKeyMapper;

/**
 CN: 属性修饰映射
 EN: Custom modification for key.
 
 Example: {\"name\" : \"Tom\"}
 
 + (NSDictionary *)customModificationForKeyMapper {
 return @{@"name", @"nonatomic, copy"};
 }
 
 @return CN: 映射表; EN: Mapper Table;
 */
+ (NSDictionary *)customModificationForKeyMapper;

@end
