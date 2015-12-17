#import "NSObject+ObjC.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import "UIView+Layout.h"

@implementation NSObject (ObjC)

+ (NSArray *)getMethodListForClass:(NSString *)className matchingPattern:(NSString *)matchingPattern
{
    NSArray *methodList = [NSObject getMethodListForClass:className];
    
    if ( nil == methodList || methodList.count == 0 ) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@",matchingPattern];
    NSArray *filtered = [methodList filteredArrayUsingPredicate:predicate];
    
    return filtered;
}

+ (NSArray *)getMethodListForClass:(NSString *)className
{
    Class class = NSClassFromString(className);
    unsigned int count = 0;
    class_copyMethodList(class, &count);
    if ( count == 0 ) {
        return nil;
    }
    
    Method *methods = (Method *)malloc(sizeof(Method)*count);
    unsigned int copiedCount = 0;
    methods = class_copyMethodList(class, &copiedCount);
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:copiedCount];
    for (unsigned int i = 0; i<copiedCount; i++) {
        Method aMethod = methods[i];
        SEL aSelector = method_getName(aMethod);
        NSString *selectorName = NSStringFromSelector(aSelector);
        [temp addObject:selectorName];
    }
    
    if ( temp.count == 0 ) {
        return nil;
    }
    
    return [temp sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
}

+ (NSArray *)getClassNamesMatchingPattern:(NSString *)matchingPattern
{
    NSArray *allClasses = [NSObject getClassList];
    if ( nil == allClasses || allClasses.count == 0 ) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@",matchingPattern];
    NSArray *filtered = [allClasses filteredArrayUsingPredicate:predicate];
    
    return filtered;
}

+ (NSArray *)getClassList
{
    unsigned int count;
    objc_copyClassList(&count);
    Class *buffer = (Class *)malloc(sizeof(Class)*count);
    objc_getClassList(buffer, count);
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++) {
        Class aClass = buffer[i];
        NSString *className = NSStringFromClass(aClass);
        [temp addObject:className];
    }
    if ( count > 0 ) {
        free(buffer);
    }
    return [NSArray arrayWithArray:temp];
}

@end
