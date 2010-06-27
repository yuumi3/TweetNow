//
//  LogViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 09/12/25.
//  Copyright 2009 EY-Office. All rights reserved.
//

#import "LogViewController.h"
#import "TNLogger.h"
#import "Config.h"
#import "SimpleAlertView.h"



@implementation LogViewController
@synthesize textView;
@synthesize uploadButton;


#pragma mark View and memory management methods.

- (void)viewDidUnload {
	self.textView = nil;
	self.uploadButton = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	Config *config = [Config sharedInstance];
	uploadButton.hidden = !config.logUpUrl || [config.logUpUrl isEqualToString:@""];
	textView.text = [TNLogger readLogFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[textView release];
	[uploadButton release];
    [super dealloc];
}


#pragma mark Event handle methods.

- (IBAction)onPushClearLog:(id)sender {
	UIAlertView *clearConfirmAlertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@""
																   delegate:self cancelButtonTitle:@"No"
																   otherButtonTitles:@"Yes", nil];
	[clearConfirmAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[TNLogger deleteLogFile];
		textView.text = [TNLogger readLogFile];
	}
	[alertView release];
}

- (IBAction)onPushUploadLog:(id)sender {
	Config *config = [Config sharedInstance];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:config.logUpUrl]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
															timeoutInterval:30.0];
	[request setHTTPMethod:@"POST"];
	
	[request setHTTPBody:[[NSString stringWithFormat:@"%@=%@", @"log",
						   [[TNLogger readLogFile] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
						  dataUsingEncoding:NSASCIIStringEncoding]];
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (conn == nil) {
		TNLog(@"NSURLConnection error");
		[SimpleAlertView alertWithTitle:@"通信エラー" message:@"サーバー接続失敗"];
	} else {
		[conn start];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	int statusCode = ((NSHTTPURLResponse *)response).statusCode;

	if ((statusCode / 100) != 2) {
		NSString *errorMessage = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
		TNLog(@"NSURLConnection error %@", errorMessage);
		[SimpleAlertView alertWithTitle:@"通信エラー" message:errorMessage];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSString *errorMessage = [error localizedDescription];
	TNLog(@"NSURLConnection error %@", errorMessage);
	[SimpleAlertView alertWithTitle:@"通信エラー" message:errorMessage];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self release];
}



@end
