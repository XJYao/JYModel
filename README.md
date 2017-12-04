# JYModel
A model framework for iOS.

# Installation
pod 'JYModel'

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

2. But I find the valuable JSON is from "person", so I need to implement method 'startKeyPathFromJSONToGenerateProperties' in Person.m and use '->' to let it know the key path.

```
+ (NSString *)startKeyPathFromJSONToGenerateProperties {
    return @"data->person";
}
```

3. I need to tell it path of 'Person.h'. You can add a row in plist, set key to be "ProjectPath" and set value to be "$(SRCROOT)/$(PROJECT_NAME)". Then implement method 'classHeadFilePath' in Person.m to let it know where it is.

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

8. Finally, call 'autoGeneratePropertiesWithJSONString'、'autoGeneratePropertiesWithJSONDict' or 'autoGeneratePropertiesWithJSONData' depend on what kind of your JSON data.

```
NSString *result = [Person autoGeneratePropertiesWithJSONString:json];
NSLog(@"%@", result);
```
Print:
```
/* JYModel auto generate begin, don't change this note! */
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, assign) double height;
@property (nonatomic, strong) School *school;
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) BOOL isStudent;
@property (nonatomic, copy) NSString *name;
/* JYModel auto generate end, don't change this note! */
```

9. You have to import or @class your custom class by yourself. Don't change the note! If you do, I can't find and replace them if you generate them repeatedly!


