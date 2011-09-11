//
//  AddPlaceViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AddPlaceViewController.h"
#import "TNLogger.h"
#import "RegisteredPlaceList.h"
#import "SimpleAlertView.h"


#pragma mark Private properties and methods definition
@interface AddPlaceViewController ()
@property (nonatomic, retain) Place	*newPlace;
@property (nonatomic)         BOOL	mapLocked;	

- (void) lockMapView:(BOOL)loc;

@end

#pragma mark -
@implementation AddPlaceViewController
@synthesize mapView;  
@synthesize nameTextField;
@synthesize saveButton;
@synthesize newPlace;
@synthesize mapLocked;
@synthesize textFrame;


#pragma mark View and memory management methods.

- (void)viewDidLoad {
    [super viewDidLoad];
    [mapView.userLocation addObserver:self forKeyPath:@"location" options:0 context:NULL];  
	self.newPlace = [Place placeWithLongitude:0 latitude:0 name:@"" kind:PLACE_USER_REGISTERED];
    CALayer *layer = [textFrame layer];
    layer.shadowOpacity = 0.6;
    layer.shadowOffset = CGSizeMake(0, 3);        
}

- (void)viewDidUnload {
	self.mapView = nil;  
	self.nameTextField = nil;
	self.saveButton = nil;
	self.newPlace = nil;
    self.textFrame = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	mapView.showsUserLocation = NO;
	[mapView removeAnnotations:mapView.annotations];
	mapView.showsUserLocation = YES;
    saveButton.enabled = NO;
	[self lockMapView:NO];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	mapView.showsUserLocation = NO;
	nameTextField.text = @"";
	[nameTextField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[mapView release];  
	[nameTextField release];
	[saveButton release];
	[newPlace release];
    [textFrame release];
    [super dealloc];
}


#pragma mark Event handle methods.

- (IBAction)onPushDone:(id)sender {
	RegisteredPlaceList *placeList = [RegisteredPlaceList sharedInstance];
	newPlace.name = nameTextField.text;
	[placeList addCopyOfPlace:newPlace];
	[placeList save];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {  
	if (mapLocked) return;

	float longitude = mapView.userLocation.location.coordinate.longitude;
	float latitude = mapView.userLocation.location.coordinate.latitude;
#if TARGET_IPHONE_SIMULATOR
	longitude = 139.670245;
	latitude = 35.612152;
#endif
	newPlace.longitude = longitude;
	newPlace.latitude = latitude;

	MKCoordinateRegion region;
	region.center.latitude = latitude;
	region.center.longitude = longitude;
	region.span.latitudeDelta  = 0.01;
	region.span.longitudeDelta = 0.01;
	mapView.centerCoordinate = mapView.userLocation.location.coordinate;

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[mapView setRegion:region animated:YES];
}  

- (IBAction)startEditTextField:(id)sender {
	[self lockMapView:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	saveButton.enabled = ([textField.text length] + [string length] - range.length) > 0;
    return YES;
}

#pragma mark -
#pragma mark Private methods

- (void) lockMapView:(BOOL)lock {
	mapLocked = lock;
	if (lock) {
		nameTextField.backgroundColor = [UIColor whiteColor];
	} else {
		nameTextField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	}
}

@end
