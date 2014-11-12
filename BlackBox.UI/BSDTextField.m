//
//  BSDTextField.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/25/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDTextField.h"
#import "BSDObjectLookup.h"
#import "BSDObject.h"

@interface BSDTextField ()

@property (nonatomic,strong)NSStringDrawingContext *context;

@end

@implementation BSDTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _suggestedCompletion = nil;
        _context = [[NSStringDrawingContext alloc]init];
        _context.minimumScaleFactor = 0.5;
        self.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
        self.enabled = YES;
    }
    
    return self;
}

- (void)editingWillBegin
{
    self.suggestedCompletion = nil;
    self.suggestedText = nil;
    [self setNeedsDisplay];
    [self addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)editingWillEnd
{
    self.suggestedText = [self suggestedTextForText:self.text];
    self.suggestedCompletion = nil;
    [self setNeedsDisplay];
    [self removeTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventAllEditingEvents];
}

- (NSString *)suggestedTextForText:(NSString *)text
{
    NSMutableArray *words = [[text componentsSeparatedByString:@" "]mutableCopy];
    
    if (!words || words.count == 0) {
        return nil;
    }
    
    if (words.count == 1) {
        NSString *classText = words.firstObject;
        NSString *shortName = [self completionForText:classText withDatasource:[self allShortBSDClassNames]];
        if (shortName) {
            return [@"BSD" stringByAppendingString:shortName];
        }
        
        return nil;
    }
    
    if (words.count > 1) {
        
        NSString *classText = words.firstObject;
        NSString *shortName = [self completionForText:classText withDatasource:[self allShortBSDClassNames]];
        if (shortName) {
            NSString *className = [@"BSD" stringByAppendingString:shortName];
            if ([className isEqualToString:@"BSDCompiledPatch"]) {
                NSString *patchText = words[1];
                NSString *patchName = [self completionForText:patchText withDatasource:[self allPatchNames]];
                if (patchName) {
                    return [NSString stringWithFormat:@"%@ %@",className,patchName];
                }
            }else{
                
                NSMutableString *result = [[NSMutableString alloc]initWithString:className];
                [words removeObject:words.firstObject];
                for (NSString *aWord in words) {
                    [result appendFormat:@"%@",aWord];
                }
                return result;
            }
            
        }
        
    }
    return nil;
}

- (void)textFieldTextDidChange:(id)sender
{
    BSDTextField *textField = sender;
    NSString *currentText = textField.text;
    NSArray *words = [currentText componentsSeparatedByString:@" "];
    
    if (!words || words.count == 0) {
        self.suggestedCompletion = nil;
        [self setNeedsDisplay];
    } else if (words.count == 1) {
        NSString *classText = words.firstObject;
        NSString *shortName = [self completionForText:classText withDatasource:[self allShortBSDClassNames]];
        if (shortName) {
            NSString *className = [@"BSD" stringByAppendingString:shortName];
            self.suggestedCompletion = className;
            [self setNeedsDisplay];
        }
    }else if (words.count == 2) {
        
        NSString *classText = words.firstObject;
        NSString *shortName = [self completionForText:classText withDatasource:[self allShortBSDClassNames]];
        if (shortName) {
            NSString *className = [@"BSD" stringByAppendingString:shortName];
            if (![classText isEqualToString:className]) {
                NSString *updatedText = [currentText stringByReplacingOccurrencesOfString:classText withString:className];
                self.text = updatedText;
                self.suggestedCompletion = nil;
                [self setNeedsDisplay];
            }
        }
        
        if ([words.firstObject isEqualToString:@"BSDCompiledPatch"]) {
            NSString *patchText = words[1];
            NSString *patchName = [self completionForText:patchText withDatasource:[self allPatchNames]];
            if (patchName) {
                self.suggestedCompletion = patchName;
                [self setNeedsDisplay];
            }else{
                self.suggestedCompletion = nil;
                [self setNeedsDisplay];
            }
        }else{
            self.suggestedCompletion = nil;
        }
    }
}



- (NSString *)completionForText:(NSString *)text withDatasource:(NSArray *)datasource
{
    if (!datasource) {
        return nil;
    }
    
    NSString *abbr = [self abbreviatedClassWithText:text];
    if (abbr) {
        return abbr;
    }
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",text];
    NSArray *filtered1 = [datasource filteredArrayUsingPredicate:predicate1];
    
    if (filtered1 && filtered1.count > 1) {
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF LIKE[cd] %@",text];
        NSArray *filtered2 = [filtered1 filteredArrayUsingPredicate:predicate2];
        if (filtered2 && filtered2.count > 0) {
            return filtered2.firstObject;
        }else{
            return filtered1.firstObject;
        }
    }else if (filtered1 && filtered1.count>0){
        return filtered1.firstObject;
    }
    
    return nil;

}

- (NSString *)abbreviatedClassWithText:(NSString *)text
{
    if ([text isEqualToString:@"+"]) {
        return @"Add";
    }
    if ([text isEqualToString:@"-"]) {
        return @"Subtract";
    }
    
    if ([text isEqualToString:@"*"]) {
        return @"Multiply";
    }
    
    if ([text isEqualToString:@"/"]) {
        return @"Divide";
    }
    
    if ([text isEqualToString:@"%"]) {
        return @"Mod";
    }
    
    return nil;
}

- (NSArray *)allNSObjectClasses
{
    return [NSObject subclassList];
}

- (NSArray *)allBSDObjectClasses
{
    BSDObjectLookup *lookup = [[BSDObjectLookup alloc]init];
    return [lookup classList];
}

- (NSArray *)allShortBSDClassNames
{
    BSDObjectLookup *lookup = [[BSDObjectLookup alloc]init];
    NSArray *classes = [lookup classList];
    NSMutableArray *result = nil;
    for (NSString *className in classes) {
        NSString *shortname = [className stringByReplacingOccurrencesOfString:@"BSD" withString:@""];
        if (shortname) {
            if (!result) {
                result = [NSMutableArray array];
            }
            [result addObject:shortname];
        }
    }
    
    
    
    [result addObject:@"CompiledPatch"];
    
    return result;
}

- (NSArray *)allBSDClassNames
{
    BSDObjectLookup *lookup = [[BSDObjectLookup alloc]init];
    return [lookup classList];
}

- (NSArray *)allPatchNames
{
    BSDObjectLookup *lookup = [[BSDObjectLookup alloc]init];
    return [lookup patchList];
}

- (NSString *)suggestedCompletionForText:(NSString *)text
{
    NSString *searchText = nil;
    NSString *argsText = nil;
    NSArray *components = [text componentsSeparatedByString:@" "];
    if (components.count > 1) {
        searchText = components.firstObject;
        NSRange ws = [text rangeOfString:searchText];
        argsText = [text stringByReplacingCharactersInRange:ws withString:@""];
        
    }else{
        searchText = text;
    }
    
    BSDObjectLookup *lookup = [[BSDObjectLookup alloc]init];
    NSArray *classes = [lookup classList];    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",searchText];
    NSArray *filtered1 = [classes filteredArrayUsingPredicate:predicate1];
    NSArray *filtered = nil;
    
    if (filtered1 && filtered1.count > 1) {
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF LIKE[cd] %@",searchText];
        NSArray *filtered2 = [classes filteredArrayUsingPredicate:predicate2];
        
        if (filtered2 && filtered2.count > 0) {
            filtered = filtered2;
        }else{
            filtered = filtered1;
        }
    }else{
        filtered = filtered1;
    }
    
    if (filtered && filtered.count > 0) {
        NSString *suggestedCompletion = filtered.firstObject;
        self.suggestedCompletion = suggestedCompletion;
        if (argsText) {
            self.suggestedText = [NSString stringWithFormat:@"%@%@",suggestedCompletion,argsText];
        }else{
            self.suggestedText = self.suggestedCompletion;
        }
        
        [self setNeedsDisplay];
        return suggestedCompletion;
    }else{
        self.suggestedCompletion = nil;
        self.suggestedText = nil;
        [self setNeedsDisplay];
        return nil;
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    //textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName:self.font,
                                 NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.5],
                                 NSParagraphStyleAttributeName:textStyle
                                 };
    CGRect frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    NSString *toDraw = @"";
    
    if (self.suggestedCompletion) {
        toDraw = self.suggestedCompletion;
    }
    
    [toDraw drawWithRect:frame
                 options:NSStringDrawingUsesLineFragmentOrigin
              attributes:attributes
                 context:self.context];
}


@end
