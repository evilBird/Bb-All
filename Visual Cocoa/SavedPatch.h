//
//  Document.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/20/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMutableArray (Stack)

- (void)push:(id)toPush;
- (id)pop;

@end

@implementation NSMutableArray (Stack)

- (void)push:(id)toPush
{
    if (toPush != nil) {
        [self addObject:toPush];
    }
}

- (id)pop
{
    if (self.count == 0) {
        return nil;
    }else{
        id popped = self.lastObject;
        [self removeObjectIdenticalTo:popped];
        return popped;
    }
}

@end


@class BbPatch,BbCompiledPatch;
@interface SavedPatch : NSDocument

+ (BbPatch *)patchFromText:(NSString *)text;
+ (BbCompiledPatch *)compiledPatchFromText:(NSString *)text;
+ (NSString *)textForSavedPatchWithName:(NSString *)patchName;

@end

