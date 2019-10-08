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

1. 分析一下这个JSON。我们需要一个 'Person'类 对应 "person"字段, 一个 'School'类 对应 "school"字段.
  所以这里创建了两个model：Person.h|m, School.h|m.

2. 但是分析发现有价值的JSON是从 "person"字段开始的, 所以需要在Person.m里实现方法 'startKeyPathFromJSONToGenerateProperties' 并使用 '->' 连接关键字形成路径，通过这个方法返回. 如果你没有实现这个方法，或者返回nil，则默认使用完整的JSON。

```
+ (NSString *)startKeyPathFromJSONToGenerateProperties {
    return @"data->person";
}
```

3. 如果要自动写入，必须告诉它Person.h的本地绝对路径。你可以在plist中添加一行，key设置为"ProjectPath"，value设置为"$(SRCROOT)/$(PROJECT_NAME)"。 然后实现方法 'classHeadFilePath' 返回文件路径。当然，如果你使用的是真机，或者你不希望自动写入，可以忽略这一步。

```
+ (NSString *)classHeadFilePath {
    NSString *infoPlistPath = [[NSBundle mainBundle]pathForResource:@"Info.plist" ofType:nil];
    NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
    NSString *projectPath = [infoDict objectForKey:@"ProjectPath"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.h", projectPath, NSStringFromClass([self class])];
    return filePath;
}
```

4. "id"在iOS中是一个关键字，我们不能用它作为属性名，用另一个名字来代替它, 例如 "identifier". 在Person.m中实现 'customPropertyNameForKeyMapper' 然后 return 映射表 (Key 是JSON中的字段名, value 是你自定义的新名字).

```
+ (NSDictionary *)customPropertyNameForKeyMapper {
    return @{@"id" : @"identifier"};
}
```

5. 如果需要为"school"字段自定义为'School'类。 在Person.m里实现 'customClassForKeyMapper', return映射表 (key 是JSON中的字段名, value 是类名)。 支持枚举。

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
@property (nonatomic, assign) NSInteger gender;

@property (nonatomic, assign) double height;

@property (nonatomic, strong) School *school;

@property (nonatomic, assign) NSInteger identifier;

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, assign) BOOL isStudent;

@property (nonatomic, copy) NSString *name;

```

9. 必须手动导入自定义类的头文件或者 @class 类.
