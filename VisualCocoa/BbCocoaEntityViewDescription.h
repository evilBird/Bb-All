//
//  BbCocoaEntityViewDescription.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/12/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE == 1
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

@class BbObject;

@interface BbCocoaEntityViewDescription : NSObject

@property (nonatomic,strong)    NSString        *entityViewType;
@property (nonatomic,strong)    NSString        *text;
@property (nonatomic)           NSUInteger      inlets;
@property (nonatomic)           NSUInteger      outlets;

#if TARGET_OS_IPHONE == 1

@property (nonatomic)           CGPoint         center;
@property (nonatomic)           CGPoint         position;

#else

@property (nonatomic)           CGPoint         center;
@property (nonatomic)           NSPoint         position;

#endif

+ (NSDictionary *)textAttributes;
+ (BbCocoaEntityViewDescription *)placeholderEntityViewDescription;
+ (BbCocoaEntityViewDescription *)viewDescriptionForObject:(BbObject *)object;

@end
