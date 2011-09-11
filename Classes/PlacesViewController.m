//
//  PlacesViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "PlacesViewController.h"
#import "RegisteredPlaceList.h"
#import "AdBanner.h"


#define LIST_MARK_IMAGE [UIImage imageNamed:@"pin.png"]

@interface PlacesViewController ()
@property(nonatomic, retain) UIImage  *listMark;
@end

@implementation PlacesViewController

@synthesize placesList;
@synthesize addPlaceViewController;
@synthesize listMark;

#pragma mark View and memory management methods.

- (void)viewDidLoad {
    [super viewDidLoad];
    self.listMark = LIST_MARK_IMAGE;

    bannerView = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0.0,
                                            ADMOB_BANNER_TOP_Y, // self.view.frame.size.height - GAD_SIZE_320x50.height,
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];
    
    bannerView.adUnitID = ADMOB_BANNER_UNIT_ID;
    bannerView.rootViewController = self;
    [self.view addSubview:bannerView];
    [bannerView loadRequest:[GADRequest request]];
}

- (void)viewDidUnload {
	self.placesList = nil;
	self.addPlaceViewController = nil;
    self.listMark = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[placesList reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [bannerView loadRequest:[GADRequest request]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[placesList release];
	[addPlaceViewController release];
    [listMark release];
    [bannerView release];
    [super dealloc];
}

#pragma mark Event handle methods.

- (BOOL)toggleEditingMode {
	if (placesList.editing) {
        self.listMark = LIST_MARK_IMAGE;
		[placesList setEditing:NO animated:YES];
		[placesList reloadData];
		return NO;
	} else {
        self.listMark = nil;
		[placesList setEditing:YES animated:YES];
		[placesList reloadData];
		return YES;
	}
}

- (IBAction)onPushEdit:(id)sender {    
	if ([self toggleEditingMode]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onPushEdit:)] autorelease];
	} else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onPushEdit:)] autorelease];
	}
 }

- (IBAction)onPushAdd:(id)sender {
    addPlaceViewController.hidesBottomBarWhenPushed = YES; 
    [self.navigationController pushViewController:addPlaceViewController animated: YES];
}

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[RegisteredPlaceList sharedInstance] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"PlaceList";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [[RegisteredPlaceList sharedInstance] nameAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    cell.imageView.image = listMark;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[UIPasteboard generalPasteboard] setString:[[RegisteredPlaceList sharedInstance] nameAtIndex:indexPath.row]]; 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	RegisteredPlaceList *places = [RegisteredPlaceList sharedInstance];
	if (indexPath.row < [places count]) {
		[places removeAtIndex:indexPath.row];
		[places save];
		[placesList reloadData];	
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
	RegisteredPlaceList *places = [RegisteredPlaceList sharedInstance];
	if (fromIndexPath.row < [places count]) {
        [places movePlaceAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
		[places save];
		[placesList reloadData];	
    }
}


@end
