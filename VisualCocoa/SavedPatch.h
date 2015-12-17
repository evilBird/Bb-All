//
//  Document.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/20/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define VCDocument      UIDocument
#define VCStoryboard    UIStoryboard
#else
#import <AppKit/AppKit.h>
#define VCDocument      NSDocument
#define VCStoryboard    NSStoryboard
#endif

@class BbPatch;
@interface SavedPatch : VCDocument

- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)abstract:(id)sender;

+ (BbPatch *)patchFromText:(NSString *)text;

@end

