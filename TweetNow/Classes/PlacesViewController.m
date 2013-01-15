//
//  PlacesViewController.m
//  TweetNow
//
//  Created by Yuumi Yoshida on 2012/11/11.
//  Copyright (c) 2012年 Yuumi Yoshida. All rights reserved.
//

#import "PlacesViewController.h"
#import "RegisteredPlaceList.h"
#import "AdBanner.h"

#define LIST_MARK_IMAGE [UIImage imageNamed:@"pin.png"]

@interface PlacesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *placesTable;

@property (strong, nonatomic) UIImage  *listMark;
@property(strong, nonatomic) AdBanner *adBanner;

@end

@implementation PlacesViewController

#pragma mark View and memory management methods.

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _listMark = LIST_MARK_IMAGE;
    _adBanner = [[AdBanner alloc] initWithRootViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[_placesTable reloadData];
    [super viewWillAppear:animated];
}

#pragma mark Event handle methods.

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];

    _listMark =  editing ? nil : LIST_MARK_IMAGE;
    [_placesTable reloadData];
    [_placesTable setEditing:editing animated:animated];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *addPlaceViewControlle = [segue destinationViewController];
    addPlaceViewControlle.hidesBottomBarWhenPushed = YES;
}


#pragma mark Table view methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[RegisteredPlaceList sharedInstance] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[RegisteredPlaceList sharedInstance] nameAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.imageView.image = _listMark;
	
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
		[_placesTable reloadData];
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
		[_placesTable reloadData];
    }
}


@end
