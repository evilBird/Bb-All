//
//  BSDMapSuper.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/23/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDMapSuper.h"

@implementation BSDMapSuper

- (NSDictionary *)dictionaryForObject:(id)object
{
    if (object) {
        return plist_for_super(object);
    }
    
    return nil;
}

NSDictionary* plist_for_super(id obj)
{
    Class superClass = class_getSuperclass([obj class]);
    return plist_for_object(superClass);
}

@end
