//
//  ViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "ViewController.h"
#import "BSDCanvasViewController.h"
#import "BSDPatchCompiler.h"
#import "NSUserDefaults+HBVUtils.h"
#import <MessageUI/MessageUI.h>

@interface ViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic,strong)NSMutableSet *cloudPatchList;

@end

@implementation ViewController

#pragma mark - UIViewController overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *result = [NSDictionary saveText:@"sometext" path:@"path" dictionary:nil];

    /*
    [[iCloud sharedCloud] setDelegate:self]; // Set this if you plan to use the delegate
    [[iCloud sharedCloud] setVerboseLogging:YES]; // We want detailed feedback about what's going on with iCloud, this is OFF
    // Do any additional setup after loading the view, typically from a nib.
    BOOL cloudIsAvailable = [[iCloud sharedCloud] checkCloudAvailability];
    if (cloudIsAvailable) {
        //YES
        NSLog(@"cloud is available");
        //[self migrateSavedToCloud];
    }else{
        NSLog(@"cloud not available");
    }
    
    BOOL cloudContainerIsAvailable = [[iCloud sharedCloud] checkCloudUbiquityContainer];
    if (cloudContainerIsAvailable) {
        NSLog(@"cloud container is available");
    }else{
        NSLog(@"cloud container is not available");
    }
     */
    
}


- (NSString *)exportPatches
{
    NSString  *dictPath;
    
    NSDictionary *dictionary = [NSUserDefaults valueForKey:@"descriptions"];
    
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    
    if ([paths count] > 0)
    {
        // Path to save dictionary
        dictPath = [[paths objectAtIndex:0]
                    stringByAppendingPathComponent:@"patches.plist"];
        
        // Write dictionary
        [dictionary.mutableCopy writeToFile:dictPath atomically:YES];
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:dictPath];
    
    
    return dictPath;
}

- (void)showEmail:(NSString*)file path:(NSString *)path {
    
    NSString *emailTitle = @"Saved patches";
    NSString *messageBody = @"These are some saved patches";
    NSArray *toRecipents = [NSArray arrayWithObject:@"travis.henspeter@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Determine the file name and extension
    NSArray *filepart = [file componentsSeparatedByString:@"."];
    NSString *filename = [filepart objectAtIndex:0];
    NSString *extension = [filepart objectAtIndex:1];
    
    // Get the resource path and read the file using NSData
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    
    // Determine the MIME type
    NSString *mimeType = @"application/xml";
    
    // Add attachment
    [mc addAttachmentData:fileData mimeType:mimeType fileName:filename];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self copyPatches];
    //NSString *path = [self exportPatches];
    //NSLog(@"path:%@",path);
    
    /*
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error;
     */

}

- (void)copyPatches
{
    NSString  *dictPath;
    
    NSDictionary *dictionary = [NSUserDefaults valueForKey:@"descriptions"];
    
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    
    if ([paths count] > 0)
    {
        // Path to save dictionary
        dictPath = [[paths objectAtIndex:0]
                    stringByAppendingPathComponent:@"patches.plist"];
        
        // Write dictionary
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:dictPath];
    if (dict) {
        NSMutableDictionary *copy = dictionary.mutableCopy;
        [copy addEntriesFromDictionary:dict];
        [NSUserDefaults setUserValue:copy forKey:@"descriptions"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.presentedViewController) {
        [self presentCanvasForPatchWithName:nil];
    }
}

- (void)presentCanvasForPatchWithName:(NSString *)patchName
{
    BSDCanvasViewController *vc = [[BSDCanvasViewController alloc]initWithName:nil description:nil];
    //vc.delegate = self;
    [self presentViewController:vc animated:YES completion:NULL];
}
/*
- (void)updatePatch:(NSDictionary *)patch
{
    NSMutableDictionary *saved = [[NSUserDefaults valueForKey:@"descriptions"]mutableCopy];
    if (!saved) {
        saved = [NSMutableDictionary dictionary];
    }
    
    NSString *patchName = patch.allKeys.firstObject;
    NSString *patchData = patch.allValues.firstObject;
    
    saved[patchName] = patchData;
    [NSUserDefaults setUserValue:saved forKey:@"descriptions"];
}
*/
/*
- (void)migrateSavedToCloud
{
    NSDictionary *saved = [NSUserDefaults valueForKey:@"descriptions"];
    if (saved) {
        for (NSString *patchName in saved.allKeys){
            NSString *fileName = [NSString stringWithFormat:@"%@.txt",patchName];
            BOOL fileExists = [[iCloud sharedCloud] doesFileExistInCloud:fileName];
            if (fileExists == NO) {
                NSLog(@"will sync patch %@",patchName);
                NSString *patch = [saved valueForKey:patchName];
                [self syncPatch:patch withName:patchName];
            }else{
                NSLog(@"patch %@ exists in iCloud",patchName);
            }
        }
    }
}
*/

#pragma mark - BSDCanvasViewControllerDelegate
/*
- (NSArray *)patchList
{
    return self.cloudPatchList.allObjects.mutableCopy;
}

- (void)syncPatch:(NSString *)patch withName:(NSString *)name
{
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",name];
    NSData *patchData = [patch dataUsingEncoding:NSUTF8StringEncoding];
    [[iCloud sharedCloud] saveAndCloseDocumentWithName:fileName withContent:patchData completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        if (error == nil) {
            // Code here to use the UIDocument or NSData objects which have been passed with the completion handler
        }else{
            NSLog(@"error saving to iCloud: %@",error.description);
        }
    }];
}

- (void)deleteSyncedPatchWithName:(NSString *)name
{
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",name];
    [[iCloud sharedCloud] deleteDocumentWithName:fileName completion:^(NSError *error) {
        // Completion handler could be used to update your UI and tell the user that the document was deleted
        if (error == nil) {
            NSLog(@"successfully deleted patch %@ from iCloud",name);
            [self.cloudPatchList removeObject:name];
        }else{
            NSLog(@"error deleting patch %@ from iCloud: %@",name,error.description);
        }
    }];
}

- (NSString *)getSyncedPatchwithName:(NSString *)name
{
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",name];
    [[iCloud sharedCloud] retrieveCloudDocumentWithName:fileName completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
        if (!error) {
            NSString *fileName = [cloudDocument.fileURL lastPathComponent];
            NSData *fileData = documentData;
            NSString *patch = [[NSString alloc]initWithData:fileData encoding:NSUTF8StringEncoding];
            NSString *patchName = [fileName stringByReplacingOccurrencesOfString:@".txt" withString:@""];
            NSDictionary *patchdict = @{patchName:patch};
            [self updatePatch:patchdict];
        }
    }];
    
    return nil;
}


- (NSDictionary *)getSyncedPatches
{
    return nil;
}
*/

#pragma mark - iCloudDelegate

/** Called when the availability of iCloud changes
 
 @param cloudIsAvailable Boolean value that is YES if iCloud is available and NO if iCloud is not available
 @param ubiquityToken An iCloud ubiquity token that represents the current iCloud identity. Can be used to determine if iCloud is available and if the iCloud account has been changed (ex. if the user logged out and then logged in with a different iCloud account). This object may be nil if iCloud is not available for any reason.
 @param ubiquityContainer The root URL path to the current application's ubiquity container. This URL may be nil until the ubiquity container is initialized. */
/*
- (void)iCloudAvailabilityDidChangeToState:(BOOL)cloudIsAvailable withUbiquityToken:(id)ubiquityToken withUbiquityContainer:(NSURL *)ubiquityContainer
{
    
}

*/
/** Called when the iCloud initiaization process is finished and the iCloud is available
 
 @param cloudToken An iCloud ubiquity token that represents the current iCloud identity. Can be used to determine if iCloud is available and if the iCloud account has been changed (ex. if the user logged out and then logged in with a different iCloud account). This object may be nil if iCloud is not available for any reason.
 @param ubiquityContainer The root URL path to the current application's ubiquity container. This URL may be nil until the ubiquity container is initialized. */
/*
- (void)iCloudDidFinishInitializingWitUbiquityToken:(id)cloudToken withUbiquityContainer:(NSURL *)ubiquityContainer
{
    
}
 */

/** Called before creating an iCloud Query filter. Specify the type of file to be queried.
 
 @discussion If this delegate is not implemented or returns nil, all files stored in the documents directory will be queried.
 
 @return An NSString with one file extension formatted like this: @"txt" */


/** Called before an iCloud Query begins.
 @discussion This may be useful to display interface updates. */
/*
- (void)iCloudFileUpdateDidBegin
{
    
}
 */
/** Called when an iCloud Query ends.
 @discussion This may be useful to display interface updates. */
/*
- (void)iCloudFileUpdateDidEnd
{
    
}
*/
/** Tells the delegate that the files in iCloud have been modified
 
 @param files A list of the files now in the app's iCloud documents directory - each NSMetadataItem in the array contains information such as file version, url, localized name, date, etc.
 @param fileNames A list of the file names (NSString) now in the app's iCloud documents directory */
/*
- (void)iCloudFilesDidChange:(NSMutableArray *)files withNewFileNames:(NSMutableArray *)fileNames
{
    if (!self.cloudPatchList) {
        self.cloudPatchList = [NSMutableSet set];
    }

    for (NSString *fileName in fileNames) {
        NSString *patchName = [fileName stringByReplacingOccurrencesOfString:@".txt" withString:@""];
        [self.cloudPatchList addObject:patchName];
    }
    for (NSString *fileName in fileNames) {
        [[iCloud sharedCloud] retrieveCloudDocumentWithName:fileName completion:^(UIDocument *cloudDocument, NSData *documentData, NSError *error) {
            if (!error) {
                NSString *fileName = [cloudDocument.fileURL lastPathComponent];
                NSData *fileData = documentData;
                NSString *patch = [[NSString alloc]initWithData:fileData encoding:NSUTF8StringEncoding];
                NSString *patchName = [fileName stringByReplacingOccurrencesOfString:@".txt" withString:@""];
                NSDictionary *toUpdate = @{patchName:patch};
                [weakself updatePatch:toUpdate];
            }
        }];
    }
 
}
*/
/** Sent to the delegate where there is a conflict between a local file and an iCloud file during an upload or download
 
 @discussion When both files have the same modification date and file content, iCloud Document Sync will not be able to automatically determine how to handle the conflict. As a result, this delegate method is called to pass the file information to the delegate which should be able to appropriately handle and resolve the conflict. The delegate should, if needed, present the user with a conflict resolution interface. iCloud Document Sync does not need to know the result of the attempted resolution, it will continue to upload all files which are not conflicting.
 
 It is important to note that **this method may be called more than once in a very short period of time** - be prepared to handle the data appropriately.
 
 The delegate is only notified about conflicts during upload and download procedures with iCloud. This method does not monitor for document conflicts between documents which already exist in iCloud. There are other methods provided to you to detect document state and state changes / conflicts.
 
 @param cloudFile An NSDictionary with the cloud file and various other information. This parameter contains the fileContent as NSData, fileURL as NSURL, and modifiedDate as NSDate.
 @param localFile An NSDictionary with the local file and various other information. This parameter contains the fileContent as NSData, fileURL as NSURL, and modifiedDate as NSDate. */
/*
- (void)iCloudFileConflictBetweenCloudFile:(NSDictionary *)cloudFile andLocalFile:(NSDictionary *)localFile
{
    
}

#pragma mark - iCloudDocumentDelegate
- (void)iCloudDocumentErrorOccured:(NSError *)error
{
    NSLog(@"error with icloud doc: %@",error.description);
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
