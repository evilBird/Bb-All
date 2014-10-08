//
//  BSDPatchDescription.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/3/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BSDPatchDescription : NSObject

- (instancetype)initWithCanvasRect:(CGRect)rect;
- (instancetype)initWithCanvasRect:(CGRect)rect name:(NSString *)name;

+ (NSString *)newWithName:(NSString *)name frame:(CGRect)frame;
- (NSString *)getDescription;
- (NSUInteger)addPatchDescription:(NSString *)desc name:(NSString *)name frame:(CGRect)frame;
- (NSUInteger)addPatchDescription:(NSString *)desc name:(NSString *)name position:(CGPoint)position;
- (NSUInteger)addEntryType:(NSString *)type className:(NSString *)className args:(NSString *)args position:(CGPoint)position;
- (void)addConnectionSender:(NSUInteger)sender outlet:(NSUInteger)outlet receiver:(NSUInteger)receiver inlet:(NSUInteger)inlet;

- (void)removeObject:(NSUInteger)index;
- (void)removeConnection:(NSUInteger)index;
- (void)clear;
- (void)print;

@end
