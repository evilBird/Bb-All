//
//  BSDMapObject.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDMapObject.h"

@implementation BSDMapObject

- (void)setupWithArguments:(id)arguments
{
    self.name = @"mapObject";
    self.coldInlet.open = NO;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    if (hot == nil) {
        return;
    }
    NSDictionary *output = [self dictionaryForObject:hot];
    [self.mainOutlet output:output.mutableCopy];
}

- (NSDictionary *)dictionaryForObject:(id)object
{
    if (object) {
        
        return [self mapObject:object];
        
        //return plist_for_object(object);
    }
    
    return nil;
}

- (NSArray *)properties:(id)obj
{
    NSMutableArray *result = nil;
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if (!result) {
            result = [NSMutableArray array];
        }
        [result addObject:key];
    }
    
    if (properties) {
        free(properties);
    }
    
    return result;
}

- (NSDictionary *)mapObject:(id)obj
{
    NSMutableArray *properties = [self properties:obj].mutableCopy;
    NSString *badKey = @"unsatisfiableConstraintsLoggingSuspended";
    if ([properties containsObject:badKey]) {
        [properties removeObject:badKey];
    }
    
    return [obj dictionaryWithValuesForKeys:properties];
}

NSDictionary* plist_for_object(id obj)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        Class classObject = NSClassFromString([key capitalizedString]);
        
        id object = [obj valueForKey:key];
        
        if (classObject) {
            id subObj = plist_for_object(object);
            [dict setObject:subObj forKey:key];
        }
        else if([object isKindOfClass:[NSArray class]])
        {
            NSMutableArray *subObj = [NSMutableArray array];
            for (id o in object) {
                [subObj addObject:plist_for_object(o) ];
            }
            [dict setObject:subObj forKey:key];
        }
        else
        {
            if(object) [dict setObject:object forKey:key];
        }
    }
    if (properties){
        free(properties);
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}


@end
