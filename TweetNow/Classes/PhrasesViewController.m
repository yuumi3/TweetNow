//
//  PhrasesViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 2012/11/11.
//  Copyright (c) 2012年 Yuumi Yoshida. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PhrasesViewController.h"
#import "PhraseList.h"
#import "Config.h"
#import "AdBanner.h"

#define LIST_MARK_IMAGE [UIImage imageNamed:@"comment16.png"]

@interface PhrasesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *phraseTable;
@property (weak, nonatomic) IBOutlet UIView *textFrame;
@property (weak, nonatomic) IBOutlet UITextField *addPhraseText;
@property (weak, nonatomic) IBOutlet UINavigationItem *thisNavgationItem;
- (IBAction)onPushAdd:(id)sender;

@property(nonatomic, strong) UIImage  *listMark;
@property(nonatomic) int             editItemIndex;
@property(nonatomic) float           phraseTableHeigth;
@property(nonatomic) BOOL            addMode;

@property(strong, nonatomic) AdBanner *adBanner;
@end

@implementation PhrasesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _addPhraseText.layer.zPosition = _textFrame.layer.zPosition = 10.0;
    _thisNavgationItem.rightBarButtonItem = self.editButtonItem;
    _listMark = LIST_MARK_IMAGE;
    _adBanner = [[AdBanner alloc] initWithRootViewController:self];
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _phraseTableHeigth = _phraseTable.frame.size.height;
    [self showNewTextField:NO];
    NSString *word = [self extractTypedWord:[UIPasteboard generalPasteboard].string];
    if (word) {
        _addPhraseText.text = word;
    }
}


- (IBAction)onPushAdd:(id)sender {
    if (!_addMode) {
        [self showNewTextField:YES];
    }
}


- (IBAction)onPushCancel:(id)sender {
    _addPhraseText.text = @"";
    [_phraseTable reloadData];
    [_addPhraseText resignFirstResponder];
    [self showNewTextField:NO];
}

- (IBAction)onPushSave:(id)sender {
    PhraseList *phrases = [PhraseList sharedInstance];
    if ([[_addPhraseText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        // NOP
    }
    else if (_editItemIndex < 0) {
        [phrases add:_addPhraseText.text];
    } else {
        [phrases set:_addPhraseText.text atIndex:_editItemIndex];
    }
    [phrases save];
    _addPhraseText.text = @"";
    [_phraseTable reloadData];
    [_addPhraseText resignFirstResponder];
    [self showNewTextField:NO];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    _listMark =  editing ? nil : LIST_MARK_IMAGE;
    [_phraseTable reloadData];
    [_phraseTable setEditing:editing animated:animated];
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PhraseList *phrases = [PhraseList sharedInstance];
    return [phrases count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhaseCell" forIndexPath:indexPath];
    PhraseList *phrases = [PhraseList sharedInstance];
    cell.textLabel.text = [phrases list][indexPath.row];
    cell.imageView.image = _listMark;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhraseList *phrases = [PhraseList sharedInstance];
    _addPhraseText.text = [phrases list][indexPath.row];
    
    [self showNewTextField:YES withIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PhraseList *phrases = [PhraseList sharedInstance];
	if (indexPath.row < [phrases count]) {
		[phrases remove:indexPath.row];
		[phrases save];
		[_phraseTable reloadData];
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

- (NSString *)extractTypedWord:(NSString *)inputMessage {
    if (inputMessage && [inputMessage length] > 0) {
        NSMutableString *message = [inputMessage mutableCopy];
        Config *config = [Config sharedInstance];
        
        NSRange wordRange = [message rangeOfString:config.postfix];
        if (wordRange.location != NSNotFound) {
            [message deleteCharactersInRange:NSMakeRange(0, wordRange.location + wordRange.length)];
        }
        wordRange = [message rangeOfString:[@"#" stringByAppendingString:config.hashTag]];
        if (wordRange.location != NSNotFound) {
            [message deleteCharactersInRange:wordRange];
        }
        
        return [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    } else {
        return nil;
    }
}

- (void)showNewTextField:(BOOL)show {
    [self showNewTextField:show withIndex:-1];
}

- (void)showNewTextField:(BOOL)show withIndex:(int)index {
    CGRect tableFrame = _phraseTable.frame;
    float textFrameHeight = _textFrame.frame.size.height;
    tableFrame.origin.y = (show ? textFrameHeight : 0) + 45;
    tableFrame.size.height = show ? tableFrame.size.height - textFrameHeight : _phraseTableHeigth;
    [_phraseTable setFrame:tableFrame];
    
    _addMode = show;
    _editItemIndex = index;
    
    CALayer *layer = [_textFrame layer];
    if (show) {
        _thisNavgationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onPushSave:)];
        _thisNavgationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onPushCancel:)];
        _addPhraseText.hidden = NO;
        _textFrame.hidden = NO;
        layer.shadowOpacity = 0.6;
        layer.shadowOffset = CGSizeMake(0, 3);
        [_addPhraseText becomeFirstResponder];
    } else {
        _thisNavgationItem.rightBarButtonItem = self.editButtonItem;
        _thisNavgationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onPushAdd:)];
        _addPhraseText.hidden = YES;
        _textFrame.hidden = YES;
        layer.shadowOpacity = 0.0;
    }
}

@end
