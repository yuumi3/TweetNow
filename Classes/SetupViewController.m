//
//  SetupViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 10/01/04.
//  Copyright 2010 EY-Office. All rights reserved.
//

#import "SetupViewController.h"
#import "UIPartsMacro.h"
#import "TweetNowViewController.h"
#import "SimpleAlertView.h"

#pragma mark Private properties and methods definition
@interface SetupViewController ()

@property (nonatomic, retain) Config *config;

@end


#pragma mark -
@implementation SetupViewController
@synthesize	aboutViewController;
@synthesize	login;
@synthesize	password;
@synthesize	prefix;
@synthesize	postfix;
@synthesize	logUpUrl;
@synthesize	config;


#pragma mark View and memory management methods.

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.sectionHeaderHeight = 30;
	self.tableView.sectionFooterHeight = 4;
}

- (void)viewDidUnload {
	self.aboutViewController = nil;
	self.login = nil;
	self.password = nil;
	self.prefix = nil;
	self.postfix = nil;
	self.logUpUrl = nil;
	self.config = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	config = [Config sharedInstance];
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[login resignFirstResponder];
	[password resignFirstResponder];
	[prefix resignFirstResponder];
	[postfix resignFirstResponder];
	if (config.debug) {
		[logUpUrl resignFirstResponder];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[aboutViewController release];
	[login release];
	[password release];
	[prefix release];
	[postfix release];
	[logUpUrl release];
	[config release];
    [super dealloc];
}


#pragma mark Event handle methods.

- (IBAction)onPushSave:(id)sender {
	if ([login.text isEqualToString:@""] || [password.text isEqualToString:@""]) {
		[SimpleAlertView alertWithTitle:@"" message:@"ログイン、パスワードを入力して下さい"];
		return;
	}
	config.login = login.text;
	config.password = password.text;
	config.prefix = prefix.text;
	config.postfix = postfix.text;
    config.xAuthToken = @"";    // clear cached AuthToken
	if (config.debug) {
		config.logUpUrl = logUpUrl.text;
	}
	[config save];
	
	self.tabBarController.selectedIndex = 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return config.debug ?  4 : 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case 0:
		case 1:
			return 2;
		case 2:
		case 3:
			return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
		case 0:
			return @"Twetterアカウント";
		case 1:
			return @"つぶやき文言";
		case 2:
			if (config.debug) {
				return @"Log upload URL";
			}
		case 3:
			return @"情報";
    }
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"SetupTable";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		switch ([indexPath indexAtPosition:0]) {
			case 0:
				switch([indexPath indexAtPosition:1]) {
					case 0:
						cell.textLabel.text = @"ログイン";
						addCellToTextField(login);
						break;
					case 1:
						cell.textLabel.text = @"パスワード";
						addCellToTextField(password);
						password.secureTextEntry = YES;
						break;
				}
				break;
			case 1:
				switch([indexPath indexAtPosition:1]) {
					case 0:
						cell.textLabel.text = @"接頭文言";
						addCellToTextField(prefix);
						break;
					case 1:
						cell.textLabel.text = @"接尾文言";
						addCellToTextField(postfix);
						break;
				}
				break;
			case 2:
				if (config.debug) {
					cell.textLabel.text = @"";
					addCellToFullTextField(logUpUrl);
					break;
				}
			case 3:				
				cell.textLabel.text = @"このソフトウェア";
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
		}
	}

	switch ([indexPath indexAtPosition:0]) {
		case 0:
			switch([indexPath indexAtPosition:1]) {
				case 0:
					login.text = config.login;
					break;
				case 1:
					password.text = config.password;
					break;
			}
			break;
		case 1:
			switch([indexPath indexAtPosition:1]) {
			case 0:
				prefix.text = config.prefix;
				break;
			case 1:
				postfix.text = config.postfix;
				break;
			}
			break;
		case 2:
			if (config.debug) {
				logUpUrl.text = config.logUpUrl;
			}
			break;
	}
	
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch ([indexPath indexAtPosition:0]) {
		case 0:
		case 1:
			return nil;
		case 2:
			if (config.debug) {
				return nil;
			}
		case 3:
			return indexPath;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch ([indexPath indexAtPosition:0]) {
		case 2:
			if (config.debug) {
				return;
			}
		case 3:
			aboutViewController.hidesBottomBarWhenPushed = YES;
			[self.navigationController pushViewController:aboutViewController animated: YES];
			break;
	}
}



@end

