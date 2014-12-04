//
//  BSDMapObject.h
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import <objc/runtime.h>

@interface BSDMapObject : BSDObject

//BSDMapObject: map an object to a dictionary
//Hot inlet: takes any key-value coding compliant object
//Cold inlet: NA
//Main outlet: emits a dictionary

- (NSDictionary *)dictionaryForObject:(id)object;
- (NSArray *)properties:(id)obj;
NSDictionary* plist_for_object(id obj);

@end
