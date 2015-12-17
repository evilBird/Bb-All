//
//  BSDNestedPatchTableViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDNestedPatchTableViewController.h"
#import "BSDPatchManager.h"

static NSString *kCellId = @"PatchCell";
static NSString *kNestedCellId = @"PatchCellNested";

@interface BSDNestedPatchTableViewController ()

@property (nonatomic,strong)NSDictionary *leafPatches;
@property (nonatomic,strong)NSDictionary *subpatches;

@end

@implementation BSDNestedPatchTableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.patches) {
        return 0;
    }
    
    if (section == 0) {
        return self.leafPatches.allKeys.count;
    }
    return self.subpatches.allKeys.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.patches) {
        return 0;
    }
    if (self.subpatches) {
        return 2;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    UITableViewCell *result = nil;
    if (section == 0) {
        result = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
        NSArray *sortedNames = [self.leafPatches.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSString *patchTitle = [self patchTitleForName:sortedNames[indexPath.row]];
        result.textLabel.text = patchTitle;
    }else if (section == 1){
        result = [tableView dequeueReusableCellWithIdentifier:kNestedCellId forIndexPath:indexPath];
        NSArray *sortedNames = [self.subpatches.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSString *folderName = sortedNames[indexPath.row];
        result.textLabel.text = [self pathForSubpatchFolder:folderName];
        result.imageView.image = [UIImage imageNamed:@"toolbar_load"];
    }
    
    return result;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *toDelete = nil;
        if (indexPath.section == 0) {
            NSArray *sortedNames = [self.leafPatches.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            toDelete = [self patchTitleForName:sortedNames[indexPath.row]];
            NSMutableDictionary *dict = self.leafPatches.mutableCopy;
            [dict removeObjectForKey:sortedNames[indexPath.row]];
            self.leafPatches = dict;
        }else if (indexPath.section == 1){
            NSArray *sortedNames = [self.subpatches.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            NSString *folderName = sortedNames[indexPath.row];
            toDelete = [self pathForSubpatchFolder:folderName];
            NSMutableDictionary *dict = self.subpatches.mutableCopy;
            [dict removeObjectForKey:sortedNames[indexPath.row]];
            self.subpatches = dict;
        }
        
        if (toDelete){
            ///[self.delegate patchTableViewController:self deletedItemAtPath:toDelete];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[BSDPatchManager sharedInstance]deleteItemAtPath:toDelete];
            [self refreshData];
            [tableView reloadData];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        NSArray *sortedNames = [self.leafPatches.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSString *patchName = sortedNames[indexPath.row];
        NSString *patchText = self.leafPatches[patchName];
        NSString *patchTitle = [self patchTitleForName:patchName];
        [self.delegate patchTableViewController:self selectedPatchWithName:patchTitle patchText:patchText];
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BSDNestedPatchTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NestedPatchTableViewController"];
        NSArray *sortedNames = [self.subpatches.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSString *subPatchName = sortedNames[indexPath.row];
        NSDictionary *patches = self.subpatches[subPatchName];
        vc.patches = patches;
        vc.path = [self pathForSubpatchFolder:subPatchName];
        vc.delegate = self.delegate;
        vc.title = vc.path;
        [self.navigationController showViewController:vc sender:self];
    }
}

- (void)setPatches:(NSDictionary *)patches
{
    _patches = patches;
    NSArray *allKeys = [patches allKeys];
    NSMutableDictionary *leaves = nil;
    NSMutableDictionary *branches = nil;
    for (NSString *aKey in allKeys) {
        if ([aKey hasSuffix:@".bb"]) {
            if (!leaves) {
                leaves = [NSMutableDictionary dictionary];
            }
            leaves[aKey] = patches[aKey];
        }else{
            if (!branches) {
                branches = [NSMutableDictionary dictionary];
            }
            branches[aKey] = patches[aKey];
        }
    }
    
    self.leafPatches = leaves;
    self.subpatches = branches;
}

- (NSString *)patchTitleForName:(NSString *)name
{
    return [NSString stringWithFormat:@"%@.bb",self.title];
}

- (NSString *)pathForSubpatchFolder:(NSString *)folderName
{
    if (self.path.length == 0) {
        return folderName;
    }
    
    return [self.path stringByAppendingPathExtension:folderName];
}

- (void)refreshData
{
    NSDictionary *patches = [[BSDPatchManager sharedInstance]savedPatches];
    self.patches = [patches objectAtKeyPath:self.path];
    if (![self.navigationController.viewControllers containsObject:self]) {
        return;
    }
    
    NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
    
    if (index == 0){
        return;
    }
    
    NSInteger parentIndex = index - 1;
    if (parentIndex > self.navigationController.viewControllers.count) {
        return;
    }
    id parent = self.navigationController.viewControllers[parentIndex];
    
    if ([parent isKindOfClass:[BSDNestedPatchTableViewController class]]) {
        [self.navigationController.viewControllers[parentIndex] refreshData];
        return;
    }
    
}

@end
