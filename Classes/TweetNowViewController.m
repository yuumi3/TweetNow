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
#import "PhraseList.h"
#import "TNLogger.h"
#import "MKPlacePinAnnotationView.h"

#define TWITTER_POST_TIMEOUT 30.0
#define DELTA	3.0e-7

#pragma mark Private properties and methods definition
@interface TweetNowViewController ()

@property (nonatomic, retain) PlaceList	*placeList;
@property (nonatomic, retain) Place     *lastPoint;
@property (nonatomic)         BOOL		mapLocked;
@property (nonatomic)         BOOL		popupKeyborad;
@property (nonatomic, retain) TwitterStatusPost *twetterPost;

- (void) startGPS;
- (void) showSplash;
- (void) hideSplash;
- (void) tweetMessage:(NSString *)placeName;
- (void) selectPlace:(id)argument;
- (void) phrasePaletteAnimation:(BOOL)show;
- (void)registerForKeyboardNotifications;

@end

#pragma mark -
@implementation TweetNowViewController

@synthesize placeMapView;
@synthesize postText;
@synthesize splash;
@synthesize postButton;
@synthesize placeList;
@synthesize lastPoint;
@synthesize mapLocked;
@synthesize popupKeyborad;
@synthesize twetterPost;
@synthesize bussyMaskView;
@synthesize phraseTable;
@synthesize textFrame;

#pragma mark View and memory management methods.


- (void)viewDidLoad {
	[self registerForKeyboardNotifications];
    [super viewDidLoad];
	
	self.twetterPost = [[TwitterStatusPost alloc] init];
	self.twetterPost.delegate = self;
    self.bussyMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 368)];
    bussyMaskView.backgroundColor = [UIColor grayColor];
    bussyMaskView.alpha = 0.6;
    bussyMaskView.hidden = YES;
    [self.view addSubview:bussyMaskView];

    [placeMapView.userLocation addObserver:self forKeyPath:@"location" options:0 context:NULL];  
}

- (void)viewDidUnload {
	self.placeMapView = nil;
	self.postText = nil;
	self.postButton = nil;
	self.splash = nil;
	self.twetterPost = nil;
    self.bussyMaskView = nil;
    self.textFrame = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    phraseTable.hidden = YES;
    popupKeyborad = NO;
    [phraseTable reloadData];
	[self showSplash];
	[self startGPS];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([postText.text length] > 0) {
        [UIPasteboard generalPasteboard].string = postText.text;
    }
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	placeMapView.showsUserLocation = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[placeMapView release];
	[postText release];
	[splash  release];
	[postButton release];
	[twetterPost release];
    [bussyMaskView release];
    [textFrame release];
    [super dealloc];
}


#pragma mark Event handle methods.

- (void) postDidAction {
	postButton.enabled = YES;
	bussyMaskView.hidden = YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;;
}

- (IBAction)onPushPost:(id)sender {
    if ([postText.text length] > 0) {
        postButton.enabled = NO; 
        bussyMaskView.hidden = NO;
        self.mapLocked = YES;
        
        Config *config = [Config sharedInstance];
        [twetterPost setUserName:config.login password:config.password];
        twetterPost.didSuccessSelector =  @selector(postDidAction);
        twetterPost.didFailedSelector  =  @selector(postDidAction);
        [twetterPost postMessage:postText.text timeoutInterval:TWITTER_POST_TIMEOUT];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;        
    }

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

	float longitude = placeMapView.userLocation.location.coordinate.longitude;
	float latitude = placeMapView.userLocation.location.coordinate.latitude;
#if TARGET_IPHONE_SIMULATOR
	longitude = 139.670245;
	latitude = 35.612152;
#endif
	
	TNLog(@"-- delta %e", lastPoint ? [lastPoint squareDistanceFromLongitude:longitude latitude:latitude] : -1.0);
	if (lastPoint && 
		[lastPoint squareDistanceFromLongitude:longitude latitude:latitude] < DELTA)  return;
	self.lastPoint = [Place placeWithLongitude:longitude latitude:latitude name:nil kind:0];

	MKCoordinateRegion region;
	region.center.latitude = latitude;
	region.center.longitude = longitude;
	region.span.latitudeDelta  = 0.02;
	region.span.longitudeDelta = 0.02;

	placeMapView.centerCoordinate = placeMapView.userLocation.location.coordinate;	
	[placeMapView setRegion:region animated:NO];
}  

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	float longitude = mapView.region.center.longitude;
	float latitude = mapView.region.center.latitude;
    
	self.placeList = [[RegisteredPlaceList sharedInstance] nearLongitude:longitude withLatitude:latitude withDelta:mapView.region.span.latitudeDelta / 2.0];
	[placeList addPlaceList:[StationSearch nearLongitude:longitude withLatitude:latitude withDelta:mapView.region.span.latitudeDelta / 2.0]];
	[placeList sortByDistanceFromLongitude:longitude latitude:latitude];

	[placeMapView removeAnnotations:placeMapView.annotations];
	for (int i = 0; i < [placeList count]; i++) {
		[placeMapView addAnnotation:[placeList placeAtIndex:i]];
	}
	
	if ([placeList count] > 0) {
		TNLog(@"nearest %@ (%@)", [placeList nameAtIndex:0], placeMapView.userLocation.location.description);
		[self tweetMessage:[placeList nameAtIndex:0]];
		[placeMapView selectAnnotation:[placeList placeAtIndex:0] animated:YES];
	} else {
		TNLog(@"No nearest (%@)", placeMapView.userLocation.location.description);
		[self tweetMessage:@"所在知れず"];	
	}
	postButton.enabled = YES;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	static NSString *AnnotationIdentifier = @"PlaceAnnotations";
	
    if ([annotation isKindOfClass:[Place class]]) {
		int pinNo = [placeList indexOfName:[annotation title]];
		MKPlacePinAnnotationView *placePinView = [[[MKPlacePinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
        Place *p = (Place *)annotation;
		placePinView.pinColor = p.kind == PLACE_STATION ? MKPinAnnotationColorRed : MKPinAnnotationColorGreen;
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
    phraseTable.hidden = YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PhraseList *phrases = [PhraseList sharedInstance];
    return [phrases count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"PhreaseList";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    PhraseList *phrases = [PhraseList sharedInstance];
    cell.textLabel.text = [[phrases list] objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhraseList *phrases = [PhraseList sharedInstance];
    postText.text = [postText.text stringByAppendingFormat:@" %@", [[phrases list] objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark -
#pragma mark Private methods

- (void) startGPS {
	placeMapView.showsUserLocation = NO;
	self.mapLocked = NO;
	postButton.enabled = NO;
	placeMapView.showsUserLocation = YES;
	
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
		[placeMapView deselectAnnotation:[placeList placeAtIndex:index] animated:YES];
	}
}

- (void)phrasePaletteAnimation:(BOOL)show {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    
    CALayer *layer = [textFrame layer];
    if (show) {
        layer.shadowOpacity = 0.6;
        layer.shadowOffset = CGSizeMake(0, 3); 
        animation.duration = 0.2;
    } else {
        layer.shadowOpacity = 0.0;
        animation.duration = 0.1;
    }

	animation.type = kCATransitionFade;
    phraseTable.hidden = !show;
	[[phraseTable layer] addAnimation:animation forKey:@"splashFadeAnimation"];
}


- (void)keyboardWillShow:(NSNotification*)aNotification {
    [self phrasePaletteAnimation:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    [self phrasePaletteAnimation:NO];
}

// http://www.ifans.com/forums/showthread.php?t=222944
- (void)registerForKeyboardNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
}



@end
