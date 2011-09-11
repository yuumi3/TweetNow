//
//  PhraseViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 11/05/08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PhraseViewController.h"
#import "PhraseList.h"
#import "Config.h"
#import "AdBanner.h"

#define LIST_MARK_IMAGE [UIImage imageNamed:@"comment16.png"]

@interface PhraseViewController ()
@property(nonatomic, retain) UIImage  *listMark;

- (BOOL)toggleEditingMode;
- (void)showNewTextField:(BOOL)show;
- (void)showNewTextField:(BOOL)show withIndex:(int)index;

@end


@implementation PhraseViewController

@synthesize phraseTable;
@synthesize newPhraseText;
@synthesize textFrame;
@synthesize listMark;

- (void)dealloc {
    [phraseTable release];
    [newPhraseText release];
    [listMark release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    phraseTableHeigth = phraseTable.frame.size.height;
    [self showNewTextField:NO];
    NSString *pastBuffer = [UIPasteboard generalPasteboard].string;
    if (pastBuffer && [pastBuffer length] > 0) {
        Config *config = [Config sharedInstance];
        NSRange r = [pastBuffer rangeOfString:config.postfix];
        if (r.location != NSNotFound) {
            pastBuffer = [pastBuffer substringFromIndex:(r.location + r.length)];
        }
        newPhraseText.text = [pastBuffer stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

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
    self.phraseTable = nil;
    self.newPhraseText = nil;
    self.listMark = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [bannerView loadRequest:[GADRequest request]];
}

#pragma mark -
#pragma mark Event handle methods.

- (IBAction)onPushAdd:(id)sender {
    if (!addMode) {
        [self showNewTextField:YES];
    }
}

- (BOOL)toggleEditingMode {
	if (phraseTable.editing) {
        self.listMark = LIST_MARK_IMAGE;
		[phraseTable setEditing:NO animated:YES];
		return NO;
	} else {
        self.listMark = nil;
		[phraseTable setEditing:YES animated:YES];
		return YES;
	}
}

- (IBAction)onPushEdit:(id)sender {    
	if ([self toggleEditingMode]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onPushEdit:)] autorelease];
        self.navigationItem.leftBarButtonItem.enabled = NO;
	} else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onPushEdit:)] autorelease];
        self.navigationItem.leftBarButtonItem.enabled = YES;
	}
    [phraseTable reloadData];
}

- (IBAction)onPushCancel:(id)sender {    
    newPhraseText.text = @"";
    [phraseTable reloadData];
    [newPhraseText resignFirstResponder];
    [self showNewTextField:NO];
}

- (IBAction)onPushSave:(id)sender {    
    PhraseList *phrases = [PhraseList sharedInstance];
    if ([[newPhraseText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        // NOP
    }
    else if (editItemIndex < 0) {
        [phrases add:newPhraseText.text];
    } else {
        [phrases set:newPhraseText.text atIndex:editItemIndex];
    }
    [phrases save];
    newPhraseText.text = @"";
    [phraseTable reloadData];
    [newPhraseText resignFirstResponder];
    [self showNewTextField:NO];
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
    NSString *CellIdentifier = @"PhreaseTableList";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    PhraseList *phrases = [PhraseList sharedInstance];
    cell.textLabel.text = [[phrases list] objectAtIndex:indexPath.row];
    cell.imageView.image = listMark;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhraseList *phrases = [PhraseList sharedInstance];
    newPhraseText.text = [[phrases list] objectAtIndex:indexPath.row];

    [self showNewTextField:YES withIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PhraseList *phrases = [PhraseList sharedInstance];
	if (indexPath.row < [phrases count]) {
		[phrases remove:indexPath.row];
		[phrases save];
		[phraseTable reloadData];	
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    PhraseList *phrases = [PhraseList sharedInstance];
    if(toIndexPath.row < [phrases count]) {
        [phrases moveFrom:fromIndexPath.row to:toIndexPath.row];
    }
}

#pragma mark -
#pragma mark Private methods

- (void)showNewTextField:(BOOL)show {
    [self showNewTextField:show withIndex:-1];
}

- (void)showNewTextField:(BOOL)show withIndex:(int)index {
    CGRect tableFrame = phraseTable.frame;
    float textFrameHeight = textFrame.frame.size.height;
    tableFrame.origin.y = show ? textFrameHeight : 0;
    tableFrame.size.height = show ? tableFrame.size.height - textFrameHeight : phraseTableHeigth;
    [phraseTable setFrame:tableFrame];

    addMode = show;
    editItemIndex = index;

    CALayer *layer = [textFrame layer];
    if (show) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onPushSave:)] autorelease];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onPushCancel:)] autorelease];
        newPhraseText.hidden = NO;
        textFrame.hidden = NO;
        layer.shadowOpacity = 0.6;
        layer.shadowOffset = CGSizeMake(0, 3);        
        [newPhraseText becomeFirstResponder];
    } else {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onPushEdit:)] autorelease];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onPushAdd:)] autorelease];       
        newPhraseText.hidden = YES;
        textFrame.hidden = YES;
        layer.shadowOpacity = 0.0;        
    }
}


@end
