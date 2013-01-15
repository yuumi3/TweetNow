//
//  TweetNewViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 2012/11/11.
//  Copyright (c) 2012年 Yuumi Yoshida. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TweetNewViewController.h"
#import "Place.h"
#import "PlaceList.h"
#import "Config.h"
#import "TwitterHelper.h"
#import "RegisteredPlaceList.h"
#import "StationSearch.h"
#import "PhraseList.h"
#import "MKPlacePinAnnotationView.h"
#import "SimpleAlertView.h"

#define DELTA	3.0e-7

@interface TweetNewViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *placeMapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UITableView *phraseTable;
@property (weak, nonatomic) IBOutlet UITextField *postText;
@property (weak, nonatomic) IBOutlet UIView  *textFrame;
@property (strong, nonatomic)        UIView	 *bussyMaskView;
@property (strong, nonatomic)        UIImageView *splash;

- (IBAction)onPushPost:(id)sender;
- (IBAction)onPushRefresh:(id)sender;
- (IBAction)startEditTextField:(id)sender;


@property (strong, nonatomic) PlaceList		*placeList;
@property (strong, nonatomic) Place			*lastPoint;
@property (nonatomic)         BOOL			mapLocked;
@property (nonatomic)         BOOL          popupKeyborad;
@property (nonatomic)         BOOL          accountAvailable;

@end


@implementation TweetNewViewController


- (void)viewDidLoad
{
	[self registerForKeyboardNotifications];
    [super viewDidLoad];
    _postText.layer.zPosition = _textFrame.layer.zPosition = 10.0;  // for _textFrame shadow
    _accountAvailable = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _phraseTable.hidden = YES;
    _popupKeyborad = NO;

    [_placeMapView.userLocation addObserver:self forKeyPath:@"location" options:0 context:NULL];

    [_phraseTable reloadData];
	[self startGPS];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGRect mapRect = _placeMapView.frame;
    if (!_bussyMaskView) {
        _bussyMaskView = [[UIView alloc] initWithFrame:CGRectMake(mapRect.origin.x, mapRect.origin.y - 45.0,
                                                                  mapRect.size.width, mapRect.size.height + 45.0)];
        _bussyMaskView.backgroundColor = [UIColor grayColor];
        _bussyMaskView.alpha = 0.6;
        _bussyMaskView.layer.zPosition = 20.0;
        _bussyMaskView.hidden = YES;
        [self.view addSubview:_bussyMaskView];
    }
    if (!_splash) {
        UIImage *sourceImage = [UIImage imageNamed:@"TweetNow.png"];
        UIGraphicsBeginImageContext(mapRect.size);
        [sourceImage drawInRect:CGRectMake((mapRect.size.width - sourceImage.size.width) / 2,
                                           (mapRect.size.height - sourceImage.size.height) / 2,
                                           sourceImage.size.width, sourceImage.size.height)];
        UIImage	*splashImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _splash = [[UIImageView alloc] initWithImage:splashImage];
        _splash.frame = mapRect;
        _splash.backgroundColor = [UIColor colorWithWhite:0.66 alpha:1.0];
        _splash.layer.zPosition = 15.0;
        _splash.hidden = NO;
        [self.view addSubview:_splash];
    }
    
    [TwitterHelper getTwitterAccountsWithCompletion:^(NSArray *accounts) {
        _accountAvailable = accounts != nil;
        if (!accounts) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _postButton.enabled = NO;
                [SimpleAlertView alertWithTitle:@"エラー" message:@"Twitterアカウントを設定して下さい"];
            });
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([_postText.text length] > 0) {
        [UIPasteboard generalPasteboard].string = _postText.text;
    }
    
    [_placeMapView.userLocation removeObserver:self forKeyPath:@"location"];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	_placeMapView.showsUserLocation = NO;
}


#pragma mark Event handle methods.


- (IBAction)onPushPost:(id)sender {
    if ([_postText.text length] > 0) {
        _postButton.enabled = NO;
        _bussyMaskView.hidden = NO;
        _mapLocked = YES;
        
        [TwitterHelper postMessage:_postText.text completion:^(NSString *errorMessage){
            dispatch_async(dispatch_get_main_queue(), ^{
                _postButton.enabled = _accountAvailable;
                _bussyMaskView.hidden = YES;
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                if (errorMessage) {
                    [SimpleAlertView alertWithTitle:@"エラー" message:errorMessage];
                }
            });
        }];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
	[_postText resignFirstResponder];
}

- (IBAction)onPushRefresh:(id)sender {
	[self startGPS];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
	if (_mapLocked) return;
	if (!_splash.hidden) {
		[self hideSplash];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;;
    
	float longitude = _placeMapView.userLocation.location.coordinate.longitude;
	float latitude = _placeMapView.userLocation.location.coordinate.latitude;

	if (_lastPoint &&
		[_lastPoint squareDistanceFromLongitude:longitude latitude:latitude] < DELTA)  return;
	_lastPoint = [Place placeWithLongitude:longitude latitude:latitude name:nil kind:0];
    
	MKCoordinateRegion region;
	region.center.latitude = latitude;
	region.center.longitude = longitude;
	region.span.latitudeDelta  = 0.02;
	region.span.longitudeDelta = 0.02;
    
	_placeMapView.centerCoordinate = _placeMapView.userLocation.location.coordinate;
	[_placeMapView setRegion:region animated:NO];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	float longitude = mapView.region.center.longitude;
	float latitude = mapView.region.center.latitude;
    
	_placeList = [[RegisteredPlaceList sharedInstance] nearLongitude:longitude withLatitude:latitude withDelta:mapView.region.span.latitudeDelta / 2.0];
	[_placeList addPlaceList:[StationSearch nearLongitude:longitude withLatitude:latitude withDelta:mapView.region.span.latitudeDelta / 2.0]];
	[_placeList sortByDistanceFromLongitude:longitude latitude:latitude];
    
	[_placeMapView removeAnnotations:_placeMapView.annotations];
	for (int i = 0; i < [_placeList count]; i++) {
		[_placeMapView addAnnotation:[_placeList placeAtIndex:i]];
	}
	
	if ([_placeList count] > 0) {
		NSLog(@"nearest %@ (%@)", [_placeList nameAtIndex:0], _placeMapView.userLocation.location.description);
		[self tweetMessage:[_placeList nameAtIndex:0]];
		[_placeMapView selectAnnotation:[_placeList placeAtIndex:0] animated:YES];
	} else {
		NSLog(@"No nearest (%@)", _placeMapView.userLocation.location.description);
		[self tweetMessage:@"所在知れず"];
	}
	_postButton.enabled = _accountAvailable;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	static NSString *AnnotationIdentifier = @"PlaceAnnotations";
	
    if ([annotation isKindOfClass:[Place class]]) {
		int pinNo = [_placeList indexOfName:[annotation title]];
		MKPlacePinAnnotationView *placePinView = [[MKPlacePinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        Place *p = (Place *)annotation;
		placePinView.pinColor = p.kind == PLACE_STATION ? MKPinAnnotationColorRed : MKPinAnnotationColorGreen;
		placePinView.animatesDrop = YES;
		placePinView.canShowCallout = YES;
		placePinView.tag = pinNo;
        
        [placePinView addTouchEventProc:^(int index) {
            _mapLocked = YES;
            if ([_placeList count] == 0) {
                return;
            }
            if (index >= 0) {
                [self tweetMessage:[_placeList nameAtIndex:index]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_placeMapView deselectAnnotation:[_placeList placeAtIndex:index] animated:YES];
                });
            }
        }];

		return placePinView;
    }
    return nil;
}


- (IBAction)startEditTextField:(id)sender {
	_mapLocked = YES;
    _phraseTable.hidden = YES;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    PhraseList *phrases = [PhraseList sharedInstance];
    cell.textLabel.text = [phrases list][indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhraseList *phrases = [PhraseList sharedInstance];
    [self addTweetMessage:[phrases list][indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



#pragma mark -
#pragma mark Private methods

- (void) startGPS {
	_placeMapView.showsUserLocation = NO;
	_mapLocked = NO;
	_postButton.enabled = NO;
	_placeMapView.showsUserLocation = YES;
	_lastPoint = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;;
}


- (void) hideSplash {
    [UIView animateWithDuration:0.8  delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
        _splash.alpha = 0.0;
    } completion: ^(BOOL finished){
    }];
}


- (void) tweetMessage:(NSString *)message {
	Config *config = [Config sharedInstance];

	NSMutableString *s = [NSMutableString stringWithFormat:@"%@%@%@", config.prefix, message, config.postfix];
    if (![config.hashTag isEqualToString:@""]) {
        [s appendFormat:@" #%@", config.hashTag];
    }
    _postText.text = s;
}
     
- (void) addTweetMessage:(NSString *)message {
	NSString *hashTag = [Config sharedInstance].hashTag;

	NSMutableString *s = [_postText.text mutableCopy];
    if (![hashTag isEqualToString:@""]) {
        NSRange hashTagRenge = [s rangeOfString:[@"#" stringByAppendingString:hashTag]];
        if (hashTagRenge.location != NSNotFound) {
            [s deleteCharactersInRange:hashTagRenge];
        }
        [s appendFormat:@" %@ #%@", message, hashTag];
    } else {
        [s appendFormat:@" %@", message];
    }
    _postText.text = s;    
}


// http://www.ifans.com/forums/showthread.php?t=222944
- (void)registerForKeyboardNotifications {
	[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        CALayer *layer = [_textFrame layer];
        layer.shadowOpacity = 0.6;
        layer.shadowOffset = CGSizeMake(3, 3);
        [UIView animateWithDuration:0.2 animations:^{ _phraseTable.hidden = NO; }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        CALayer *layer = [_textFrame layer];
        layer.shadowOpacity = 0.0;
        [UIView animateWithDuration:0.1 animations:^{ _phraseTable.hidden = YES; }];
    }];
}

@end
