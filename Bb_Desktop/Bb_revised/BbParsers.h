//
//  BbParsers.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BbDescription : NSObject

@property (nonatomic)NSUInteger stackIndex;
@property (nonatomic,strong)NSString *stackInstruction;
@property (nonatomic,strong)NSString *UIType;

@end

@interface BbObjectDescription : BbDescription

@property (nonatomic,strong)NSValue *UICenter;
@property (nonatomic,strong)NSValue *UISize;
@property (nonatomic,strong)NSString *BbObjectType;
@property (nonatomic,strong)NSArray *BbObjectArgs;

@end

@interface BbConnectionDescription : BbDescription

@property (nonatomic) NSUInteger senderObjectIndex;
@property (nonatomic) NSUInteger senderPortIndex;
@property (nonatomic) NSUInteger receiverObjectIndex;
@property (nonatomic) NSUInteger receiverPortIndex;

@end

@interface BbPatchDescription : BbDescription

@property (nonatomic,strong)NSArray *objectDescriptions;
@property (nonatomic,strong)NSArray *connectionDescriptions;
@property (nonatomic,strong)NSArray *BbObjectArgs;
@property (nonatomic,strong)NSArray *BbUIFlags;

@end

@interface BbBasicParser : NSObject

+ (BbDescription *)descriptionWithText:(NSString *)text;

@end