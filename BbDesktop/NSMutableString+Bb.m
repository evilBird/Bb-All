//
//  NSMutableString+Bb.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/13/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSMutableString+Bb.h"
#import "NSObject+Bb.h"
#import "NSString+Bb.h"
#import "NSArray+Bb.h"
#import "NSInvocation+Bb.h"

static NSString *kUITypeSelector = @"UIType";
static NSString *kInstructionSelector = @"stackInstruction";

@implementation NSMutableString (Bb)

+ (NSMutableString *)descBbObject:(NSString *)objClass
                        ancestors:(NSUInteger)ancestors
                         position:(NSArray *)position
                             args:(id)args
{
    return [NSMutableString
            descBbObject:objClass
            ancestors:ancestors
            position:position
            size:nil
            args:args];
}

+ (NSMutableString *)descBbObject:(NSString *)objClass
                        ancestors:(NSUInteger)ancestors
                         position:(NSArray *)position
                             size:(NSArray *)size
                             args:(id)args
{
    NSMutableString *desc = [NSMutableString newDescription];
    [desc tabCt:ancestors];
    id instruction = [NSInvocation doClassMethod:objClass
                                    selectorName:kInstructionSelector
                                            args:nil];
    [desc appendThenSpace:instruction];
    
    id uitype = [NSInvocation doClassMethod:objClass
                               selectorName:kUITypeSelector
                                       args:nil];
    [desc appendThenSpace:uitype];
    
    [desc appendThenSpace:position];
    if (size)
    {
        [desc appendThenSpace:size];
    }
    
    [desc appendThenSpace:objClass];
    
    [desc appendThenSpace:args];
    
    [desc semiColon];

    [desc lineBreak];
    
    return desc;
}

+ (NSMutableString *)newDescription
{
    return [[NSMutableString alloc]init];
}

- (void)space;
{
    [self appendString:@" "];
}

- (void)tab
{
    [self appendString:@"\t"];
}

- (void)tabCt:(NSUInteger)count
{
    for (NSUInteger i = 0; i < count; i ++) {
        [self tab];
    }
}
- (void)semiColon
{
    [self appendString:@";"];
}

- (void)lineBreak
{
    [self appendString:@"\n"];
}

- (void)comma
{
    [self appendString:@","];
}

- (void)openQuote
{
    [self appendString:@"@\""];
}

- (void)closeQuote
{
    [self appendString:@"\""];
}

- (void)dollar
{
    [self appendString:@"$"];
}

- (void)error
{
    [self appendString:@"ERR"];
}

- (void)appendFloat:(NSNumber *)fl
{
    [self appendFormat:@"%@",@(fl.floatValue)];
}

- (void)appendInt:(NSNumber *)i
{
    [self appendFormat:@"%@",@(i.integerValue)];
}

- (void)appendObject:(id)object
{
    if (!object) {
        [self error];
        return;
    }
    
    NSString *objString = nil;
    if ([object BbValueType] == BbValueType_String) {
        [self appendString:object];
        return;
    }else if ([object BbValueType] == BbValueType_Array){
        [self appendString:[(NSArray *)object toString]];
        return;
    }
    objString = [object convertToCompatibleTypeFromSet:[NSSet setWithObject:@(BbValueType_String)]];
    if (!objString) {
        [self error];
        return;
    }
    
    [self appendString:objString];
}

- (void)appendThenSpace:(id)object
{
    [self appendObject:object];
    [self space];
}

- (void)spaceThenAppend:(id)object
{
    [self space];
    [self appendObject:object];
}

- (void)appendThenNewLine:(id)object
{
    [self appendObject:object];
    [self lineBreak];
}

- (void)newLineThenAppend:(id)object
{
    [self lineBreak];
    [self appendObject:object];
}

@end
