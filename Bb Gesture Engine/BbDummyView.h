//
//  BbDummyView.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BbDummyView : UIView

- (instancetype)initWithDummyClass:(NSString *)dummyClass;

@property (nonatomic,strong)        NSString        *dummyClass;

@end
