//
//  BSDObjectDescription.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *kClassName = @"className";
static NSString *kUUID = @"uniqueId";
static NSString *kRect = @"displayRect";
static NSString *kArgs = @"creationArguments";
static NSString *kBoxClass = @"boxClassName";

@interface BSDObjectDescription : NSObject

@property (nonatomic,strong)NSString *className;
@property (nonatomic,strong)NSString *uniqueId;
@property (nonatomic,strong)NSString *assignedId;
@property (nonatomic,strong)id creationArguments;
@property (nonatomic,strong)NSValue *displayRect;
@property (nonatomic,strong)NSString *boxClassName;

- (NSDictionary *)dictionaryRespresentation;
+ (BSDObjectDescription *)objectDescriptionWithDictionary:(NSDictionary *)dictionary;
+ (BSDObjectDescription *)objectDescriptionWithDictionary:(NSDictionary *)dictionary appendId:(NSString *)appendId;

@end
