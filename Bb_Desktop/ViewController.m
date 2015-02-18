//
//  ViewController.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ViewController.h"
#import "BbCocoaPatchView+Touches.h"
#import "BbObject+Decoder.h"
#import "BbCocoaObjectView.h"
#import "BbCocoaPatchView+Connections.h"
#import "BbUI.h"
#import "BbPatch.h"
#import "NSMutableString+Bb.h"
@interface ViewController ()
{
    CGPoint kFocusPoint;
}

@property (nonatomic,strong)BbCocoaPatchView *patchView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.patchView = [[BbCocoaPatchView alloc]initWithEntity:[[BbPatch alloc]initWithArguments:@"test"]
                                                 viewDescription:nil
                                                    inParent:self.view];
    // Do any additional setup after loading the view.
    NSString *desc = nil;
    NSUInteger ancestors;
    ancestors = [[self.patchView patch]countAncestors];
    
    desc = [NSMutableString descBbObject:@"BbBangObject"
                               ancestors:ancestors+1
                                position:@[@50,@60]
                                    args:nil
            ];
    
    [self.patchView addObjectWithText:desc];
    
    desc = [NSMutableString descBbObject:@"BbMessage"
                               ancestors:ancestors+1
                                position:@[@50,@50]
                                    args:@"This is a message"
            ];
    
    [self.patchView addObjectWithText:desc];
    
    desc = [NSMutableString descBbObject:@"BbLog"
                               ancestors:ancestors+1
                                position:@[@50,@40]
                                    args:@"print"];
    
    [self.patchView addObjectWithText:desc];
    
    [self.patchView connectSender:0 outlet:0 receiver:1 inlet:0];
    [self.patchView connectSender:1 outlet:0 receiver:2 inlet:0];
    [self.view setNeedsDisplay:YES];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
    
}

@end
