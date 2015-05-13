//
//  BSDStringReplace.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import "BSDStringInlet.h"

//hot inlet: takes an NSString
//stringToReplaceInlet: takes an NSString. Occurences of this value within the hot inlet value are replaced by the value of the replacementStringInlet
//replacementStringInlet: takes an NSString. Replaces occurences of stringToReplaceInlet value within the hotInlet value
//main outlet: Outputs an NSString

@interface BSDStringReplace : BSDObject


@property (nonatomic,strong)BSDInlet *stringToReplaceInlet;
@property (nonatomic,strong)BSDInlet *replacementStringInlet;


// Optional Creation Arguments: an NSArray containing 1 or 2 NSStrings. First value sets stringToReplaceInlet, second value sets replacementStringInlet


@end
