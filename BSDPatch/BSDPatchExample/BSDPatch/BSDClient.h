//
//  BSDClient.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDClient : BSDObject

- (instancetype)initWithBaseURL:(NSString *)baseURL;

@property (nonatomic,strong)BSDInlet *parameterInlet;

@end
