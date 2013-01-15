//
//  AddPlaceViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 2012/11/11.
//  Copyright (c) 2012年 Yuumi Yoshida. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AddPlaceViewController.h"
#import "Place.h"
#import "RegisteredPlaceList.h"

#define DELTA	3.0e-7

@interface AddPlaceViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UIView *textFrame;
@property (weak, nonatomic) IBOutlet MKMapView *placeMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)onPushSave:(id)sender;
- (IBAction)startEditTextField:(id)sender;

@property (strong, nonatomic) Place		*addPlace;
@property (nonatomic)         BOOL		mapLocked;

@end

@implementation AddPlaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _nameText.layer.zPosition = _textFrame.layer.zPosition = 10.0;
    _textFrame.layer.shadowOpacity = 0.6;
    _textFrame.layer.shadowOffset = CGSizeMake(0, 3); 
	_addPlace = [Place placeWithLongitude:0 latitude:0 name:@"" kind:PLACE_USER_REGISTERED];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_placeMapView.showsUserLocation = NO;
	[_placeMapView removeAnnotations:_placeMapView.annotations];
	_placeMapView.showsUserLocation = YES;
    _saveButton.enabled = NO;

	[self lockMapView:NO];
    [_placeMapView.userLocation addObserver:self forKeyPath:@"location" options:0 context:NULL];

    MKCoordinateRegion region;
	region.center.latitude = 35.688323;
	region.center.longitude = 139.754389;
	region.span.latitudeDelta  = 1.0;
	region.span.longitudeDelta = 1.0;
    _placeMapView.region = region;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	_placeMapView.showsUserLocation = NO;
    [_placeMapView.userLocation removeObserver:self forKeyPath:@"location"];
	_nameText.text = @"";
	[_nameText resignFirstResponder];
}

#pragma mark Event handle methods.


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (_mapLocked) return;
    
	float longitude = _placeMapView.userLocation.location.coordinate.longitude;
	float latitude = _placeMapView.userLocation.location.coordinate.latitude;
    if ([_addPlace squareDistanceFromLongitude:longitude latitude:latitude] < DELTA)  return;

	_addPlace.longitude = longitude;
	_addPlace.latitude = latitude;
    
	MKCoordinateRegion region;
	region.center.latitude = latitude;
	region.center.longitude = longitude;
	region.span.latitudeDelta  = 0.01;
	region.span.longitudeDelta = 0.01;
	_placeMapView.centerCoordinate = _placeMapView.userLocation.location.coordinate;
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_placeMapView setRegion:region animated:YES];
}  


- (IBAction)onPushSave:(id)sender {
	RegisteredPlaceList *placeList = [RegisteredPlaceList sharedInstance];
	_addPlace.name = _nameText.text;
    [placeList addCopyOfPlace:_addPlace];
	[placeList save];
	
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)startEditTextField:(id)sender {
	[self lockMapView:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	_saveButton.enabled = ([textField.text length] + [string length] - range.length) > 0;
    return YES;
}


#pragma mark -
#pragma mark Private methods

- (void) lockMapView:(BOOL)lock {
	_mapLocked = lock;
	if (lock) {
		_nameText.backgroundColor = [UIColor whiteColor];
	} else {
		_nameText.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	}
}

@end
