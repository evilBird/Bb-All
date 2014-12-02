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
#import "BSDPatchManager.h"

@interface BSDTextField ()

@property (nonatomic,strong)NSStringDrawingContext *context;
@property (nonatomic,strong)NSMutableArray *words;
@property (nonatomic,strong)NSMutableArray *completedWords;
@property (nonatomic,strong)NSString *completedText;
@property (nonatomic,strong)NSString *replacementText;

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
    self.replacementText  = nil;
    self.suggestedCompletion = nil;
    self.suggestedText = nil;
    self.className = nil;
    self.arguments = nil;
    [self setNeedsDisplay];
    [self addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)editingWillEnd
{
    self.replacementText  = nil;
    [self textFieldEndedEditing];
    self.suggestedText = self.text;
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
        NSString *alias = [self aliasForWord:classText];
        if (alias) {
            return alias;
        }
        
        NSString *shortName = [self completionForText:classText withDatasource:[self allShortBSDClassNames]];
        if (shortName) {
            return [@"BSD" stringByAppendingString:shortName];
        }
        
        return nil;
    }
    
    if (words.count > 1) {
        
        NSString *classText = words.firstObject;
        NSString *alias = [self aliasForWord:classText];
        NSString *shortName = nil;
        if (alias) {
            shortName = [alias stringByReplacingOccurrencesOfString:@"BSD" withString:@""];
        }else{
            shortName = [self completionForText:classText withDatasource:[self allShortBSDClassNames]];
        }
        
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
/*
- (void)textFieldTextDidChange:(id)sender
{
    static NSString *previousText;
    BSDTextField *textField = sender;
    NSString *currentText = textField.text;
    NSString *newText = nil;
    NSString *removedText = nil;
    if (previousText) {
        NSRange oldRange = [currentText rangeOfString:previousText];
        if (oldRange.length > 0) {
            newText = [currentText stringByReplacingOccurrencesOfString:previousText withString:@""];
            NSLog(@"added text: %@",newText);
            if ([newText isEqualToString:@" "]) {
                
                if (self.className) {
                    NSMutableArray *theWords = [currentText componentsSeparatedByString:@" "].mutableCopy;
                    [theWords replaceObjectAtIndex:0 withObject:self.className];
                    self.text = [self completionTextWithWords:theWords];
                }

            }else{
                
            }
        }else{
            NSRange newRange = [previousText rangeOfString:currentText];
            if (newRange.length > 0) {
                removedText = [previousText stringByReplacingOccurrencesOfString:currentText withString:@""];
                NSLog(@"removed text: %@",newText);
            }
        }
    }
    previousText = currentText;
    NSMutableArray *words = [currentText componentsSeparatedByString:@" "].mutableCopy;
    
    self.className = [self classNameForWord:words.firstObject];
    
    
    
    if (words.count > 1) {
        if ([self.className isEqualToString:@"BSDCompiledPatch"]) {
            NSString *secondWord = words[1];
            NSArray *components = [secondWord componentsSeparatedByString:@"."];
            NSMutableString *path = [[NSMutableString alloc]initWithString:@""];
            for (NSString *c in components) {
                NSLog(@"looking for word %@ at path %@",c,path);
                NSString *new = [self patchNameForWord:c atPath:path];
                NSLog(@"new %@",new);
                if (new) {
                    if (path.length == 0) {
                        [path appendString:new];
                    }else{
                        [path appendFormat:@".%@",new];
                    }
                    self.suggestedCompletion = path;
                    [self setNeedsDisplay];
                }
            }
            
            NSLog(@"path: %@",path);
        }
    }
    
    //self.suggestedCompletion = [self completionTextWithWords:words];
    //[self setNeedsDisplay];

}
*/
- (NSString *)completionTextWithWords:(NSArray *)words
{
    if (!words || !words.count) {
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc]init];
    for (NSInteger i = 0; i < words.count; i++) {
        if (i > 0) {
            [result appendString:@" "];
        }
        [result appendString:words[i]];
    }
    
    return result;
}

- (NSInteger)wordCountForText:(NSString *)text
{
    return [text componentsSeparatedByString:@" "].count;
}

- (NSString *)classNameForWord:(NSString *)word
{
    NSString *result = nil;
    result = [self aliasForWord:word];
    if (result) {
        return result;
    }
    
    NSArray *classList = [self allBSDClassNames];
    if (![[word lowercaseString] hasPrefix:@"bsd"]) {
        word = [@"BSD" stringByAppendingString:word];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@",word];
    NSArray *filtered = [classList filteredArrayUsingPredicate:predicate];
    if (filtered && filtered.count) {
        result = filtered.firstObject;
        return result;
    }
    
    predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[cd] %@",word];
    filtered = [classList filteredArrayUsingPredicate:predicate];
    if (filtered && filtered.count) {
        result = filtered.firstObject;
        return result;
    }
    
    return nil;
}

- (NSString *)patchNameForWord:(NSString *)word atPath:(NSString *)path
{
    NSDictionary *currentDictionary = nil;
    NSDictionary *patches = [[BSDPatchManager sharedInstance]savedPatches];
    
    if (!path) {
        currentDictionary = patches;
    }else{
        currentDictionary = [patches dictionaryAtKeyPath:path];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@",word];
    
    NSArray *filtered = [patches.allKeys filteredArrayUsingPredicate:predicate];
    if (filtered && filtered.count) {
        return filtered.firstObject;
    }
    
    predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[cd] %@",word];
    filtered = [patches.allKeys filteredArrayUsingPredicate:predicate];
    if (filtered && filtered.count) {
        return filtered.firstObject;
    }
    
    return nil;
}

- (NSString *)aliasForWord:(NSString *)word
{
    NSString *text = [NSString stringWithString:word];
    
    if ([text isEqualToString:@"c"]) {
        return @"BSDCompiledPatch";
    }
    
    if ([text isEqualToString:@"+"]) {
        return @"BSDAdd";
    }
    if ([text isEqualToString:@"-"]) {
        return @"BSDSubtract";
    }
    
    if ([text isEqualToString:@"*"]) {
        return @"BSDMultiply";
    }
    
    if ([text isEqualToString:@"/"]) {
        return @"BSDDivide";
    }
    
    if ([text isEqualToString:@"%"]) {
        return @"BSDMod";
    }
    
    if ([text isEqualToString:@"^"]) {
        return @"BSDExponent";
    }
    
    if ([text isEqualToString:@"="]) {
        return @"BSDEqual";
    }
    
    if ([text isEqualToString:@"<"]) {
        return @"BSDLess";
    }
    
    if ([text isEqualToString:@">"]) {
        return @"BSDGreater";
    }
    
    if ([text isEqualToString:@"<="]||[text isEqualToString:@"=<"]) {
        return @"BSDEqualLess";
    }
    
    if ([text isEqualToString:@">="]||[text isEqualToString:@"=>"]) {
        return @"BSDEqualGreater";
    }
    
    if ([text isEqualToString:@">"]) {
        return @"BSDGreater";
    }
    
    if ([text isEqualToString:@"t"]) {
        return @"BSDTrigger";
    }
    
    if ([text isEqualToString:@"v"]){
        return @"BSDValue";
    }
    
    if ([text isEqualToString:@"s"]) {
        return @"BSDSend";
    }
    
    if ([text isEqualToString:@"r"]) {
        return @"BSDReceive";
    }
    
    if ([text isEqualToString:@"p"]) {
        return @"BSDPrint";
    }
    
    if ([text isEqualToString:@"sc"]) {
        return @"BSDScreen";
    }
    
    if ([text isEqualToString:@"vi"]) {
        return @"BSDView";
    }
    
    if ([text isEqualToString:@"re"]) {
        return @"BSDRect";
    }
    if ([text isEqualToString:@"po"]) {
        return @"BSDPoint";
    }
    
    return nil;
}

/*
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
        
        if ([words.firstObject isEqualToString:@"BSDCompiledPatch"]) {
            NSString *patchText = words[1];
            NSString *patchName = [self completionForText:patchText withDatasource:[self allPatchNames]];
            if (patchName) {
                self.suggestedCompletion = [@"BSDCompiledPatch" stringByAppendingFormat:@" %@",patchName];
                [self setNeedsDisplay];
            }else{
                self.suggestedCompletion = [@"BSDCompiledPatch" stringByAppendingFormat:@" %@",patchText];
                [self setNeedsDisplay];
            }
            
            return;
        }
        
        
        NSString *classText = words.firstObject;
        NSString *shortName = [self completionForText:classText withDatasource:[self allShortBSDClassNames]];
        if (shortName) {
            NSString *className = [@"BSD" stringByAppendingString:shortName];
            if (![classText isEqualToString:className]) {
                NSString *updatedText = [currentText stringByReplacingOccurrencesOfString:classText withString:className];
                self.text = updatedText;
                self.suggestedCompletion = nil;
                [self setNeedsDisplay];
                return;
            }
        }
    }
}


*/
- (NSString *)completionForText:(NSString *)text withDatasource:(NSArray *)datasource
{
    if (!datasource) {
        return nil;
    }
    
    NSArray *words = [text componentsSeparatedByString:@" "];
    NSString *alias = [self aliasForWord:words.firstObject];
    if (alias) {
        return alias;
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
    
    NSString *alias = [self aliasForWord:searchText];
    if (alias) {
        NSString *suggestedCompletion = alias;
        self.suggestedCompletion = suggestedCompletion;
        if (argsText) {
            self.suggestedText = [NSString stringWithFormat:@"%@%@",suggestedCompletion,argsText];
        }else{
            self.suggestedText = self.suggestedCompletion;
        }
        
        [self setNeedsDisplay];
        return suggestedCompletion;
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

#pragma mark - Autocomplete implementation v 2.0

- (void)textFieldTextDidChange:(id)sender
{
    NSString *text = [sender text];
    static NSString *previousText;
    NSString *addedText = [self string:text minusString:previousText];
    NSString *removedText = [self string:previousText minusString:text];
    if ((addedText && [self isSpace:addedText]) || (removedText && [self isSpace:removedText])) {
        self.completedText = [self completeText:text];
    }
    
    NSArray *completedWords = [self completedWordsFromText:text];
    NSString *currentWord = nil;
    if (self.completedText) {
        currentWord = [self lastWordInText:text];
        if (currentWord) {
            text = [self.completedText stringByAppendingFormat:@" %@",currentWord];
        }
    }else{
        currentWord = text;
    }
    
    NSInteger numCompleteWords = completedWords.count;
    NSString *className = nil;
    if (numCompleteWords > 0) {
        className = completedWords.firstObject;
    }
    self.suggestedCompletion = [self suggestedCompletionForWord:currentWord atIndex:numCompleteWords className:className];
    //NSLog(@"\nTEXTFIELD DEBUG\ntextField old text: %@\ntextField new text: %@\naddedText: %@\nremovedText: %@\ncompletedText: %@\nnumber completed words:%@\ncompletedWords: %@\ncurrentWord: %@\nclassName: %@\nsuggestedCompletion: %@\n",[sender text],text,addedText,removedText,self.completedText,@(numCompleteWords),completedWords,currentWord,className,self.suggestedCompletion);

    if (![text isEqualToString:[sender text]]) {
        if (self.replacementText) {
            [(BSDTextField *)sender setText:self.replacementText];
        }else{
            [(BSDTextField *)sender setText:text];
        }
    }
    [self setNeedsDisplay];
    previousText = text;
    
}

- (void)textFieldEndedEditing
{
    NSMutableArray *completedWords = [self completedWordsFromText:self.text].mutableCopy;
    NSString *currentWord = [self lastWordInText:self.text];
    NSInteger numCompleteWords = completedWords.count;
    NSString *className = nil;
    if (numCompleteWords > 0) {
        className = completedWords.firstObject;
    }
    
    NSString *lastWord = [self suggestedCompletionForWord:currentWord atIndex:numCompleteWords className:className];
    if (lastWord) {
        if (!completedWords) {
            completedWords = [NSMutableArray array];
        }
        
        [completedWords addObject:lastWord];
    }
    
    NSMutableString *finalText = [NSMutableString string];
    for (NSInteger i = 0; i < completedWords.count; i ++) {
        if (i != 0) {
            [finalText appendString:@" "];
        }
        
        [finalText appendString:completedWords[i]];
    }
    
    self.text = finalText;
}

- (NSString *)string:(NSString *)firstString minusString:(NSString *)secondString
{
    if (!firstString) {
        return nil;
    }
    
    if (!secondString) {
        return firstString;
    }
    
    NSRange range = [firstString rangeOfString:secondString];
    if (range.length > 0) {
        return [firstString stringByReplacingOccurrencesOfString:secondString withString:@""];
    }
    return nil;
}

- (NSString *)suggestedCompletionForWord:(NSString *)word atIndex:(NSInteger)index
{
    return [self suggestedCompletionForWord:word atIndex:index className:nil];
}

- (NSString *)suggestedCompletionForWord:(NSString *)word atIndex:(NSInteger)index className:(NSString *)className
{
    switch (index) {
        case 0:
        {
            return [self suggestedClassNameForWord:word];
        }
            break;
        case 1:
        {
            if ([className isEqualToString:@"BSDCompiledPatch"]) {
                return [self suggestedPatchNameForWord:word];
            }else{
                return word;
            }
        }
            break;
            
        default:
        {
            return word;
        }
            break;
    }
    return word;
}

- (NSString *)lastWordInText:(NSString *)text
{
    NSArray *components = [text componentsSeparatedByString:@" "];
    return components.lastObject;
}

- (NSString *)completeText:(NSString *)text
{
    NSArray *words = [self completedWordsFromText:text];
    return [self completedTextWithWords:words];
}

- (NSString *)completedTextWithWords:(NSArray *)words
{
    if (!words) {
        return nil;
    }
    NSMutableString *result = nil;
    for (NSInteger i = 0; i < words.count; i++) {
        if (!result) {
            result = [NSMutableString string];
        }
        if (i != 0) {
            [result appendString:@" "];
        }
        
        [result appendString:words[i]];
    }
    
    return result;
}
                                
                                

- (NSArray *)completedWordsFromText:(NSString *)text
{
    if (!text || text.length == 0) {
        return nil;
    }
    
    NSMutableArray *result = nil;
    NSMutableArray *words = [text componentsSeparatedByString:@" "].mutableCopy;
    if (words.count <= 1) {
        return nil;
    }
    
    [words removeLastObject];
    for (NSInteger i = 0; i < words.count; i++) {
        NSString *className = nil;
        if (result && result.count > 0) {
            className = result.firstObject;
        }
        
        NSString *word = [self suggestedCompletionForWord:words[i] atIndex:i className:className];
        if (word) {
            if (!result) {
                result = [NSMutableArray array];
            }
            
            [result addObject:word];
            
        }else{
            
            return result;
        }
    }
    
    return result;
}

- (BOOL)isSpace:(NSString *)text
{
    return [text isEqualToString:@" "];
}

- (NSInteger)countCompletedWordsInText:(NSString *)text
{
    if (!text || text.length == 0) {
        return 0;
    }
    NSArray *words = [self completedWordsFromText:text];
    if (words) {
        return words.count;
    }else{
        return 0;
    }
}

- (NSDictionary *)classNameDictionary
{
    NSMutableDictionary *result = nil;
    NSArray *classList = [self allBSDObjectClasses];
    for (NSString *className in classList) {
        NSString *key = [className lowercaseString];
        if (!result) {
            result = [NSMutableDictionary dictionary];
        }
        
        result [key] = className;
        NSString *shortKey = nil;
        if ([key hasPrefix:@"bsd"]) {
            NSRange range = [key rangeOfString:@"bsd"];
            shortKey = [key stringByReplacingCharactersInRange:range withString:@""];
            result [shortKey] = className;
        }
    }
    
    return result;
}

- (NSString *)suggestedClassNameForWord:(NSString *)word
{
    if (!word || !word.length) {
        return nil;
    }
    
    NSString *result = nil;
    result = [self aliasForWord:word];
    if (result) {
        return result;
    }
    
    NSDictionary *classDictionary = [self classNameDictionary];
    NSArray *classList = classDictionary.allKeys;
    
    NSString *classKey = nil;
    
    NSPredicate *predicate = nil;
    NSArray *filteredClassList = nil;
    predicate = [NSPredicate predicateWithFormat:@"SELF == %@",word];
    filteredClassList = [classList filteredArrayUsingPredicate:predicate];
    if (filteredClassList) {
        classKey = filteredClassList.firstObject;
        if (classKey) {
            result = classDictionary[classKey];
            return result;
        }
    }
    
    predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@",word];
    filteredClassList = [classList filteredArrayUsingPredicate:predicate];
    if (filteredClassList) {
        classKey = filteredClassList.firstObject;
        if (classKey) {
            result = classDictionary[classKey];
            return result;
        }
    }
    
    predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[cd] %@",word];
    filteredClassList = [classList filteredArrayUsingPredicate:predicate];
    if (filteredClassList) {
        classKey = filteredClassList.firstObject;
        if (classKey) {
            result = classDictionary[classKey];
            return result;
        }
    }
    
    return result;
}

- (NSString *)suggestedPatchNameForWord:(NSString *)word
{
    if (!word || !word.length) {
        return nil;
    }
    
    NSString *workingPath = [BSDPatchManager sharedInstance].workingPath;
    BOOL shouldSub = [self shouldSubWorkingPath:workingPath inWord:word];
    if (shouldSub) {
        word = [self prependPath:workingPath toWord:word];
        NSRange range = [self.text rangeOfString:@"$"];
        self.replacementText = [self.text stringByReplacingCharactersInRange:range withString:workingPath];
        self.text = self.replacementText;
    }else{
        self.replacementText = nil;
    }
    
    NSArray *patchList = [[BSDPatchManager sharedInstance]allSavedPatchNames];
    
    NSPredicate *predicate = nil;
    NSArray *filteredPatchList = nil;
    predicate = [NSPredicate predicateWithFormat:@"SELF == [cd] %@",word];
    filteredPatchList = [patchList filteredArrayUsingPredicate:predicate];
    if (filteredPatchList && filteredPatchList.count) {
        return filteredPatchList.firstObject;
    }
    
    predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] %@",word];
    filteredPatchList = [patchList filteredArrayUsingPredicate:predicate];
    if (filteredPatchList && filteredPatchList.count) {
        return filteredPatchList.firstObject;
    }
    
    predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[cd] %@",word];
    filteredPatchList = [patchList filteredArrayUsingPredicate:predicate];
    if (filteredPatchList && filteredPatchList.count) {
        return filteredPatchList.firstObject;
    }
    
    return nil;
}


- (BOOL)shouldSubWorkingPath:(NSString *)workingPath inWord:(NSString *)word
{
    if (!workingPath || !workingPath.length || !word || !word.length) {
        return NO;
    }
    
    NSString *firstChar = [word substringToIndex:1];
    if ([firstChar isEqualToString:@"$"]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)prependPath:(NSString *)path toWord:(NSString *)word
{
    NSRange toReplace = NSRangeFromString(@"0, 1");
    return [word stringByReplacingCharactersInRange:toReplace withString:path];
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
