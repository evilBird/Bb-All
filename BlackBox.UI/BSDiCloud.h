//
//  BSDiCloud.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import <iCloud/iCloud.h>

//Get files:
//Cold inlet args: none
//Returns: an array of file names stored in iCloud
static NSString *kGetFileListSelectorKey = @"list";
//Download file:
//Cold inlet args: iCloud URL of the file to download
//Returns: The requested file if found, an error message if not found
static NSString *kDownloadFileSelectorKey = @"download";
//Upload file:
//Cold inlet args: the name of the file in app's documents directory to be uploaded
//Returns: The iCloud URL of the upload if successful, an error message if not
static NSString *kUploadFileSelectorKey = @"upload";
//Synchronize file:
//Cold inlet args: An array containing: 1)The URL of the master file, 2)The URL of the file to be overwritten by 1)
//Returns: nil if successful, an error message if not
static NSString *kSynchronizeFileSelectorKey = @"sync";
//Get file version:
//Cold inlet args: An array containing 1)The iCloud URL of the file to be versioned, 2)The version id of the file to be retrieved
//Returns: The specified file version if successful, an error message if not
static NSString *kGetFileVersionSelectorKey = @"version";

@interface BSDiCloud : BSDObject<iCloudDelegate,iCloudDocumentDelegate>

+ (NSData *)dataForPlistAtPath:(NSString *)path;
+ (NSDictionary *)plistWithData:(NSData *)data;

//Hot inlet takes a string selector key, values defined above
@property (nonatomic,strong)BSDInlet *hotInlet;
//Cold inlet takes arguments to be passed to keyed selector
@property (nonatomic,strong)BSDInlet *coldInlet;



@end
