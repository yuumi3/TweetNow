//
//  PlacesViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "PlacesViewController.h"
#import "RegisteredPlaceList.h"


@implementation PlacesViewController

@synthesize placesList;
@synthesize addPlaceViewController;


#pragma mark View and memory management methods.


- (void)viewDidUnload {
	self.placesList = nil;
	self.addPlaceViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[placesList reloadData];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[placesList release];
	[addPlaceViewController release];
    [super dealloc];
}

#pragma mark Event handle methods.

- (BOOL)toggleEditingMode {
	if (placesList.editing) {
		[placesList setEditing:NO animated:YES];
		[placesList reloadData];
		return NO;
	} else {
		[placesList setEditing:YES animated:YES];
		[placesList reloadData];
		return YES;
	}
}

- (IBAction)onPushEdit:(id)sender {
	if ([self toggleEditingMode]) {
		self.navigationItem.rightBarButtonItem.title = @"終了";
	} else {
		self.navigationItem.rightBarButtonItem.title = @"編集";
	}
}


#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[RegisteredPlaceList sharedInstance] count] + (placesList.editing ? 0 : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"PlaceList";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
	if (indexPath.row >= [[RegisteredPlaceList sharedInstance] count]) {
		cell.textLabel.text = @"新規登録";
		cell.textLabel.textColor = [UIColor lightGrayColor];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	} else {
		cell.textLabel.text = [[RegisteredPlaceList sharedInstance] nameAtIndex:indexPath.row];
		cell.textLabel.textColor = [UIColor blackColor];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row < [[RegisteredPlaceList sharedInstance] count]) {
		[[UIPasteboard generalPasteboard] setString:[[RegisteredPlaceList sharedInstance] nameAtIndex:indexPath.row]]; 
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else {
		addPlaceViewController.hidesBottomBarWhenPushed = YES; 
		[self.navigationController pushViewController:addPlaceViewController animated: YES];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	RegisteredPlaceList *places = [RegisteredPlaceList sharedInstance];
	if (indexPath.row < [places count]) {
		[places removeAtIndex:indexPath.row];
		[places save];
		[placesList reloadData];	
	}
}


@end
