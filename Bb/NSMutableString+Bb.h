//
//  NSMutableString+Bb.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/13/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Bb)

+ (NSMutableString *)newDescription;

+ (NSMutableString *)descBbObject:(NSString *)objClass
                        ancestors:(NSUInteger)ancestors
                         position:(NSArray *)position
                             args:(id)args;

+ (NSMutableString *)descBbObject:(NSString *)objClass
                        ancestors:(NSUInteger)ancestors
                         position:(NSArray *)position
                             size:(NSArray *)size
                             args:(id)args;

- (void)space;
- (void)tab;

- (void)semiColon;
- (void)lineBreak;
- (void)comma;
- (void)openQuote;
- (void)closeQuote;
- (void)dollar;
- (void)error;

- (void)tabCt:(NSUInteger)count;
- (void)appendFloat:(NSNumber *)fl;
- (void)appendInt:(NSNumber *)i;

- (void)appendObject:(id)object;
- (void)spaceThenAppend:(id)object;
- (void)appendThenSpace:(id)object;

- (void)appendThenNewLine:(id)object;
- (void)newLineThenAppend:(id)object;

- (NSString *)trimWhiteSpace;
- (NSString *)trimLeadingAndTrailingWhiteSpace;
- (NSString *)trimLeadingWhiteSpace;
- (NSString *)trimTrailingWhiteSpace;
@end
