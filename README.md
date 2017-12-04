# English Introduction

# JYModel
A model framework for iOS.

# Installation

## Cocoapods
pod 'JYModel'

## Manually
1. Download all files.
2. Add the source files to your Xcode project.
3. import "JYModel/JYModel.h"

# Usage

## NSObject+JYModelGeneration

You can use it to generate properties code automatically from JSON and write to head file automatically on simulator if you want.
(If you want to write automatically, please use simulator!)

Let's see how to use it.

There is a JSON:
{
  "data" : {
    "person" : {
      "name" : "Tom", 
      "age" : 21, 
      "gender" : 1, 
      "isStudent" : true, 
      "height" : 180.3, 
      "id" : 14124897432759830, 
      "school" : {
        "schoolName" : "what?", 
        "city" : "Beijing"
      }
    }
  } 
}

1. Let's analyze this JSON. I need a 'Person' Class for "person", a 'School' Class for "school".

  So I create two models: Person.h|m, School.h|m.

2. But I find the valuable JSON is from "person", so I need to implement method 'startKeyPathFromJSONToGenerateProperties' in Person.m and use '->' to let it know the key path. If you are not implementing this method or return nil, it will use full JSON.

```
+ (NSString *)startKeyPathFromJSONToGenerateProperties {
    return @"data->person";
}
```

3. I need to tell it path of 'Person.h'. You can add a row in plist, set key to be "ProjectPath" and set value to be "$(SRCROOT)/$(PROJECT_NAME)". Then implement method 'classHeadFilePath' in Person.m to let it know where it is. Of course, if you are not using simulator or you don't want it to write automatically, ignore this step.

```
+ (NSString *)classHeadFilePath {
    NSString *infoPlistPath = [[NSBundle mainBundle]pathForResource:@"Info.plist" ofType:nil];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
    NSString *projectPath = [infoDict objectForKey:@"ProjectPath"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.h", projectPath, NSStringFromClass([self class])];
    return filePath;
}
```

4. The "id" is keyword for iOS system. We can't use it as property name. I need to use another name to instead of it, such as "identifier". So implement 'customPropertyNameForKeyMapper' in Person.m and return the mapper with NSDictionary (Key is name from JSON, value is name what you want).

```
+ (NSDictionary *)customPropertyNameForKeyMapper {
    return @{@"id" : @"identifier"};
}
```

5. I need to let it know I want to use 'School' class for "school". Implement 'customClassForKeyMapper' in Person.m, return the mapper with NSDictionary (key is name, value is class name).

```
+ (NSDictionary *)customClassForKeyMapper {
    return @{@"school" : @"School"};
}
```

6. If you want to copy and paste properties by youself. No problem, implement 'shouldAutoWritingProperties' in Person.m, return NO, it won't write properties to head file automatically. Of course, if you are not using simulator, you must copy and paste by yourself.

```
+ (BOOL)shouldAutoWritingProperties {
    return NO;
}
```

7. In School.m, repeat the above steps if necessary.

8. Finally, call 'autoGeneratePropertiesWithJSONString'、'autoGeneratePropertiesWithJSONDict' or 'autoGeneratePropertiesWithJSONData' depend on what kind of your JSON data. It will return the result. If result is nil, there is something wrong, you can see log in Xcode console.

```
NSString *result = [Person autoGeneratePropertiesWithJSONString:json];
NSLog(@"%@", result);
```
Print:
```
/* JYModel auto generate begin, don't change this note! */

/**
<#Description#>
*/
@property (nonatomic, assign) NSInteger gender;

/**
<#Description#>
*/
@property (nonatomic, assign) double height;

/**
<#Description#>
*/
@property (nonatomic, strong) School *school;

/**
<#Description#>
*/
@property (nonatomic, assign) NSInteger identifier;

/**
<#Description#>
*/
@property (nonatomic, assign) NSInteger age;

/**
<#Description#>
*/
@property (nonatomic, assign) BOOL isStudent;

/**
<#Description#>
*/
@property (nonatomic, copy) NSString *name;

/* JYModel auto generate end, don't change this note! */
```

9. You have to import or @class your custom class by yourself. Don't change the begin and end notes! If you do, I can't find and replace them if you generate them repeatedly!


# 中文介绍

# JYModel
一个iOS上使用的model框架

# 安装说明

## Cocoapods
pod 'JYModel'

## 手动安装
pod 'JYModel'
1. 下载所有文件
2. 添加源文件到工程中
3. 在需要的地方导入 "JYModel/JYModel.h"

# 用法
## NSObject+JYModelGeneration

NSObject+JYModelGeneration是一个能根据JSON自动生成属性声明代码，并且在模拟器上支持自动写入到头文件的工具。如果你使用真机运行，必须自己手动复制工具生成并返回的字符串，然后粘贴到头文件中。

接下来看看如何使用。

这是一个JSON:
{
  "data" : {
    "person" : {
      "name" : "Tom", 
      "age" : 21, 
      "gender" : 1, 
      "isStudent" : true, 
      "height" : 180.3, 
      "id" : 14124897432759830, 
      "school" : {
        "schoolName" : "what?", 
        "city" : "Beijing"
      }
    }
  } 
}

1. 让我们分析一下这个JSON。我需要一个 'Person'类 对应 "person"字段, 一个 'School'类 对应 "school"字段.
  所以我创建了两个model：Person.h|m, School.h|m.

2. 但是我发现有价值的JSON是从 "person"字段开始的, 所以我需要在Person.m里实现方法 'startKeyPathFromJSONToGenerateProperties' 并使用 '->' 连接关键字形成路径，通过这个方法返回. 如果你没有实现这个方法，或者返回nil，则默认使用完整的JSON。

```
+ (NSString *)startKeyPathFromJSONToGenerateProperties {
    return @"data->person";
}
```

3. 我需要告诉它Person.h的本地绝对路径。你可以在plist中添加一行，key设置为"ProjectPath"，value设置为"$(SRCROOT)/$(PROJECT_NAME)"。 然后实现方法 'classHeadFilePath' 返回文件路径。当然，如果你使用的是真机，或者你不希望自动写入，可以忽略这一步。

```
+ (NSString *)classHeadFilePath {
    NSString *infoPlistPath = [[NSBundle mainBundle]pathForResource:@"Info.plist" ofType:nil];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
    NSString *projectPath = [infoDict objectForKey:@"ProjectPath"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.h", projectPath, NSStringFromClass([self class])];
    return filePath;
}
```

4. "id"在iOS中是一个关键字，我们不能用它作为属性名。 我需要用另一个名字来代替它, 例如 "identifier". 在Person.m中实现 'customPropertyNameForKeyMapper' 然后 return 映射表 (Key 是JSON中的字段名, value 是你自定义的新名字).

```
+ (NSDictionary *)customPropertyNameForKeyMapper {
    return @{@"id" : @"identifier"};
}
```

5. 我需要为"school"字段自定义为'School'类. 在Person.m里实现 'customClassForKeyMapper', return映射表 (key 是JSON中的字段名, value 是类名).

```
+ (NSDictionary *)customClassForKeyMapper {
    return @{@"school" : @"School"};
}
```

6. 如果你希望自己手动复制并粘贴最终生成的结果，在Person.m中实现 'shouldAutoWritingProperties', return NO, 它将不会自动写入到头文件中. 当然，如果你使用的是真机，则必须手动复制粘贴。

```
+ (BOOL)shouldAutoWritingProperties {
    return NO;
}
```

7. 在 School.m中, 如果有必要的话，重复上述步骤。

8. 最后, 根据你JSON数据的类型，选择调用 'autoGeneratePropertiesWithJSONString'、'autoGeneratePropertiesWithJSONDict' 或 'autoGeneratePropertiesWithJSONData'. 将会返回最终生成的结果，如果返回nil，则某个地方发生了错误，具体原因可以在Xcode的控制台查看LOG。

```
NSString *result = [Person autoGeneratePropertiesWithJSONString:json];
NSLog(@"%@", result);
```
打印结果:
```
/* JYModel auto generate begin, don't change this note! */

/**
<#Description#>
*/
@property (nonatomic, assign) NSInteger gender;

/**
<#Description#>
*/
@property (nonatomic, assign) double height;

/**
<#Description#>
*/
@property (nonatomic, strong) School *school;

/**
<#Description#>
*/
@property (nonatomic, assign) NSInteger identifier;

/**
<#Description#>
*/
@property (nonatomic, assign) NSInteger age;

/**
<#Description#>
*/
@property (nonatomic, assign) BOOL isStudent;

/**
<#Description#>
*/
@property (nonatomic, copy) NSString *name;

/* JYModel auto generate end, don't change this note! */
```

9. 你必须手动导入自定义类的头文件或者 @class 类. 不要修改结果中头尾两行的注释！我需要根据这两行注释确定写入位置，实现重复写入时替换。
