//
//  BbJSObject.h
//  JavaScriptThingy
//
//  Created by Travis Henspeter on 1/6/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BSDObject.h"
#import <UIKit/UIKit.h>

@interface BSDJSObject : BSDObject

- (BOOL)isNumber:(NSString *)string;

@end

@interface BSDJSFunction : BSDJSObject

@end

@interface BSDJSScript : BSDJSObject



@end
