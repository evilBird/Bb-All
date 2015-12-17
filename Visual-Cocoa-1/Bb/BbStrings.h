//
//  BbStrings.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"

@interface BbStringObject : BbObject
@end

@interface BbStringLength : BbStringObject
@end

@interface BbStringReplace : BbStringObject
@end

@interface BbStringComponents : BbStringObject
@end

@interface BbStringAppend : BbStringObject
@end

@interface BbStringPrepend : BbStringObject
@end

@interface BbIsString : BbStringObject
@end

@interface BbToString : BbStringObject
@end

@interface BbArrayToString : BbStringObject
@end
