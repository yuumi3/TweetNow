//
//  TweetNowViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/21.
//  Copyright EY-Office 2009. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TweetNowViewController.h"
#import "Config.h"
#import "RegisteredPlaceList.h"
#import "TNLogger.h"
#import "MKPlacePinAnnotationView.h"

#define TWITTER_POST_TIMEOUT 30.0
#define DELTA	3.0e-7

#pragma mark Private properties and methods definition
@interface TweetNowViewController ()

@property (nonatomic, retain) PlaceList	*placeList;
@property (nonatomic, retain) Place     *lastPoint;
@property (nonatomic)         BOOL		mapLocked;
@property (nonatomic, retain) XAuthTwitterStatusPost *twetterPost;

- (void) startGPS;
- (void) showSplash;
- (void) hideSplash;
- (void) tweetMessage:(NSString *)placeName;
- (void) selectPlace:(id)argument;

@end

#pragma mark -
@implementation TweetNowViewController

@synthesize mapView;
@synthesize postText;
@synthesize splash;
@synthesize postButton;
@synthesize placeList;
@synthesize lastPoint;
@synthesize mapLocked;
@synthesize twetterPost;
@synthesize bussyMaskView;

#pragma mark View and memory management methods.

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.twetterPost = [[XAuthTwitterStatusPost alloc] init];
	self.twetterPost.delegate = self;
    [mapView.userLocation addObserver:self forKeyPath:@"location" options:0 context:NULL];  
}

- (void)viewDidUnload {
	self.mapView = nil;
	self.postText = nil;
	self.postButton = nil;
	self.splash = nil;
	self.twetterPost = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self showSplash];
	[self startGPS];
}

- (void)viewWillDisappear:(BOOL)animated {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;;
	mapView.showsUserLocation = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[mapView release];
	[postText release];
	[splash  release];
	[postButton release];
	[twetterPost release];
    [super dealloc];
}


#pragma mark Event handle methods.

- (void) postDidAction {
	postButton.enabled = YES;
	bussyMaskView.hidden = YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;;
}

- (IBAction)onPushPost:(id)sender {
	postButton.enabled = NO; 
	bussyMaskView.hidden = NO;
	self.mapLocked = YES;

	Config *config = [Config sharedInstance];
	[twetterPost setUserName:config.login password:config.password];
	twetterPost.didSuccessSelector =  @selector(postDidAction);
	twetterPost.didFailedSelector  =  @selector(postDidAction);
	[twetterPost postMessage:postText.text timeoutInterval:TWITTER_POST_TIMEOUT];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;;
	[postText resignFirstResponder];
}

- (IBAction)onPushRefresh:(id)sender {
	[self startGPS];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

	if (mapLocked) return;	
	if (!splash.hidden) {
		[self hideSplash];
	}	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;;

	float longitude = mapView.userLocation.location.coordinate.longitude;
	float latitude = mapView.userLocation.location.coordinate.latitude;
#if TARGET_IPHONE_SIMULATOR
	longitude = 139.670245;
	latitude = 35.612152;
#endif
	
	TNLog(@"-- delta %e", lastPoint ? [lastPoint squareDistanceFromLongitude:longitude latitude:latitude] : -1.0);
	if (lastPoint && 
		[lastPoint squareDistanceFromLongitude:longitude latitude:latitude] < DELTA)  return;
	
	self.lastPoint = [Place placeWithLongitude:longitude latitude:latitude name:nil];
	self.placeList = [[RegisteredPlaceList sharedInstance] nearLongitude:longitude withLatitude:latitude];
	[placeList addPlaceList:[StationSearch nearLongitude:longitude withLatitude:latitude]];
	[placeList sortByDistanceFromLongitude:longitude latitude:latitude];
	
	[mapView removeAnnotations:mapView.annotations];
	for (int i = 0; i < [placeList count]; i++) {
		[mapView addAnnotation:[placeList placeAtIndex:i]];
	}
	
	MKCoordinateRegion region;
	region.center.latitude = latitude;
	region.center.longitude = longitude;
	Location *distance = [placeList distanceOfPlaceListWithLongitude:longitude latitude:latitude];
	region.span.latitudeDelta  = distance->latitude * 1.1 + 0.001;
	region.span.longitudeDelta = distance->longitude * 1.1 + 0.001;
	mapView.centerCoordinate = mapView.userLocation.location.coordinate;
	
	postButton.enabled = YES;
	[mapView setRegion:region animated:NO];
	
	if ([placeList count] > 0) {
		TNLog(@"nearest %@ (%@)", [placeList nameAtIndex:0], mapView.userLocation.location.description);
		[self tweetMessage:[placeList nameAtIndex:0]];
		[mapView selectAnnotation:[placeList placeAtIndex:0] animated:YES];
	} else {
		TNLog(@"No nearest (%@)", mapView.userLocation.location.description);
		[self tweetMessage:@"所在知れず"];	
	}		
}  


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	static NSString *AnnotationIdentifier = @"PlaceAnnotations";
	
    if ([annotation isKindOfClass:[Place class]]) {
		int pinNo = [placeList indexOfName:[annotation title]];
		MKPlacePinAnnotationView *placePinView = [[[MKPlacePinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
		placePinView.pinColor = MKPinAnnotationColorRed;
		placePinView.animatesDrop = YES;
		placePinView.canShowCallout = YES;
		placePinView.tag = pinNo;
		[placePinView addTouchEventTarget:self action:@selector(selectPlace:)];
		return placePinView;
    }
    return nil;
}

- (IBAction)startEditTextField:(id)sender {
	self.mapLocked = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}



#pragma mark -
#pragma mark Private methods

- (void) startGPS {
	mapView.showsUserLocation = NO;
	self.mapLocked = NO;
	postButton.enabled = NO;
	mapView.showsUserLocation = YES;
	
	self.lastPoint = nil; 
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;;
}


- (void) showSplash {
	UIImage *sourceImage = [UIImage imageNamed:@"TweetNow.png"];
	UIGraphicsBeginImageContext(splash.frame.size);
	[sourceImage drawInRect:CGRectMake((splash.frame.size.width - sourceImage.size.width) / 2,
									   (splash.frame.size.height - sourceImage.size.height) / 2,
									   sourceImage.size.width, sourceImage.size.height)];
	UIImage	*splashImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	splash.image = splashImage;
	splash.hidden = NO;	
}

- (void) hideSplash {	
	CATransition *animation = [CATransition animation];
	animation.delegate = self;
	animation.duration = 0.8;
	animation.type = kCATransitionFade;
	
	splash.hidden = YES;
	[[splash layer] addAnimation:animation forKey:@"splashFadeAnimation"];
}


- (void) tweetMessage:(NSString *)placeName {
	Config *config = [Config sharedInstance];
	postText.text = [NSString stringWithFormat:@"%@%@%@", config.prefix, placeName, config.postfix];
}

- (void)selectPlace:(id)argument {
	self.mapLocked = YES;
	if ([placeList count] == 0) {
		return;
	}
	
	int index = [(NSNumber *)argument intValue];
	if (index >= 0) {
		[self tweetMessage:[placeList nameAtIndex:index]];
		[mapView deselectAnnotation:[placeList placeAtIndex:index] animated:YES];
	}
}


@end
