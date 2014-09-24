//
//  BSDCompiledPatch.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import "BSDObjectDescription.h"
#import "BSDPortConnectionDescription.h"
#import "BSDPatchInlet.h"
#import "BSDPatchOutlet.h"

@interface BSDCompiledPatch : BSDObject

@property (nonatomic,strong)BSDPatchInlet *patchInlet;
@property (nonatomic,strong)BSDPatchOutlet *patchOutlet;


@end
