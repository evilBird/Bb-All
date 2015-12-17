//
//  BbCocoaEntityViewDescription.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/12/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BbCocoaEntityViewDescription : NSObject

@property (nonatomic,strong)    NSString        *entityViewType;
@property (nonatomic,strong)    NSString        *text;
@property (nonatomic)           NSUInteger      inlets;
@property (nonatomic)           NSUInteger      outlets;
@property (nonatomic)           CGPoint         center;
@property (nonatomic)           NSPoint         normalizedPosition;

+ (NSDictionary *)textAttributes;

+ (BbCocoaEntityViewDescription *)placeholderEntityViewDescription;

@end
