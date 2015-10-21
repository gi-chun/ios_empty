//
//  CPSnapshotListViewController.m
//  11st
//
//  Created by spearhead on 2014. 11. 20..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPSnapshotListViewController.h"
#import "CPHomeViewController.h"
#import "CPWebViewController.h"
#import "CPNavigationBarView.h"
#import "CPCommonInfo.h"

@interface CPSnapshotListViewController () <UITableViewDataSource,
                                            UITableViewDelegate>
{
    BOOL editing;
}

@end

@implementation CPSnapshotListViewController

- (id)init
{
    if ((self = [super init]))
    {
        _snapshotListArray = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self initNavigationBar];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0 , self.view.frame.size.width, self.view.frame.size.height - NAVIBAR_HEIGHT - [Modules statusBarHeight]) style:UITableViewStyleGrouped];
    [self.listTableView setDelegate:self];
    [self.listTableView setDataSource:self];
    [self.listTableView setRowHeight:85.0f];
    [self.listTableView setBackgroundView:nil];
    [self.listTableView setSectionFooterHeight:0];
    [self.listTableView setBackgroundColor:[UIColor clearColor]];
    [self.listTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view setBackgroundColor:UIColorFromRGB(TABLE_BG_COLOR)];
    [self.view addSubview:self.listTableView];
    
    [self fetchSnapshotList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initNavigationBar];
    
    //네비게이션바가 없어진 상태라면 복구시킨다.
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

- (void)initNavigationBar
{
    self.title = NSLocalizedString(@"SnapshotList", nil);
    
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if ([subView isKindOfClass:[CPNavigationBarView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(edit:)];
}

#pragma mark - Private Methods

- (void)edit:(id)sender
{
    editing = !editing;
    
    [self.navigationItem.rightBarButtonItem setTitle:editing ? NSLocalizedString(@"Success", nil) : NSLocalizedString(@"Edit", nil)];
    [self.listTableView reloadData];
}

- (void)onDeleteButton:(id)sender
{
    [self deleteSnapshotItem:[sender tag]];
    [self fetchSnapshotList];
    
    [self.listTableView reloadData];
}

- (void)onTapThumbnail:(UIGestureRecognizer *)tap
{
    SnapshotPreview *preview = [[SnapshotPreview alloc] init];
    UIImage *image = [UIImage imageWithData:[[self.snapshotListArray objectAtIndex:[[tap view] tag]] valueForKey:@"image"]];
    
    [preview setPreviewImage:image];
    
    [self.navigationController presentViewController:preview animated:YES completion:nil];
}

- (void)fetchSnapshotList
{
    NSError *error;
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SnapshotItem" inManagedObjectContext:managedObjectContext];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    
    NSArray *object = [managedObjectContext executeFetchRequest:request error:&error];
    
    [self.snapshotListArray removeAllObjects];
    [self.snapshotListArray setArray:[object sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    
    [self.listTableView reloadData];
}

- (void)deleteSnapshotItem:(NSUInteger)section
{
    NSError *error;
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SnapshotItem" inManagedObjectContext:managedObjectContext];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    
    NSArray *datas = [managedObjectContext executeFetchRequest:request error:&error];
    NSArray *sortDatas = [datas sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    if ([sortDatas count] > 0 && [sortDatas count] >= section) {
        NSManagedObject *object = [sortDatas objectAtIndex:section];
        
        [managedObjectContext deleteObject:object];
    }
    
    [managedObjectContext save:&error];
}

- (void)openWebViewControllerWithUrl:(NSString *)url animated:(BOOL)animated
{
    CPWebViewController *viewControlelr = [[CPWebViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:viewControlelr animated:animated];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.snapshotListArray count] == 0 ? 1 : [self.snapshotListArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.snapshotListArray count] == 0 ? 0 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 35)];
    
    if (section == 0) {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenBoundsWidth-20, 35)];
        [headerLabel setNumberOfLines:0];
        [headerLabel setTextColor:UIColorFromRGB(0x313c55)];
        [headerLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [headerLabel setText:NSLocalizedString(@"SnapshotList", nil)];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerView addSubview:headerLabel];
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SnapshotListCell";
    
    CGFloat margin = [self groupedCellMarginWithTableWidth:tableView.frame.size.width], padding = 10.0f;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSManagedObject *object = [self.snapshotListArray objectAtIndex:indexPath.section];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapThumbnail:)];
    
    UIImage *arrowImage = [UIImage imageNamed:@"btn_accesory_arro.png"];
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
    [arrowImageView setFrame:CGRectMake(tableView.frame.size.width - arrowImage.size.width - margin * 2 - padding, (85.0f - arrowImage.size.height) / 2, arrowImage.size.width, arrowImage.size.height)];
    [cell.contentView addSubview:arrowImageView];
    
    UIImage *image = [UIImage imageWithData:[object valueForKey:@"thumbnail"]];
    UIImageView *thumbnailImageView = [[UIImageView alloc] initWithImage:image];
    [thumbnailImageView setTag:indexPath.section];
    [thumbnailImageView setUserInteractionEnabled:YES];
    [thumbnailImageView addGestureRecognizer:tapRecognizer];
    [thumbnailImageView setContentMode:UIViewContentModeCenter];
    [thumbnailImageView setContentMode:UIViewContentModeScaleAspectFit];
    [thumbnailImageView setFrame:CGRectMake(5.0f, 10.0f, 60.0f, 60.0f)];
    [cell.contentView addSubview:thumbnailImageView];
    
    UIImage *deleteImageNor = [UIImage imageNamed:@"btn_delete_off.png"];
    UIImage *deleteImageHil = [UIImage imageNamed:@"btn_delete_on.png"];
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTag:indexPath.section];
    [deleteButton setImage:deleteImageNor forState:UIControlStateNormal];
    [deleteButton setImage:deleteImageHil forState:UIControlStateHighlighted];
    [deleteButton addTarget:self action:@selector(onDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setFrame:CGRectMake(arrowImageView.frame.origin.x, arrowImageView.frame.origin.y, deleteImageNor.size.width, deleteImageNor.size.height)];
    [cell.contentView addSubview:deleteButton];
    
    UIView *contentsView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(thumbnailImageView.frame)+5, 0, tableView.frame.size.width - 80.0f - margin * 2 - 24.0f, 85)];
    [cell.contentView addSubview:contentsView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(contentsView.frame), 42.5f)];
    [titleLabel setNumberOfLines:2];
    [titleLabel setText:[object valueForKey:@"title"]];
    [titleLabel setTextColor:UIColorFromRGB(0x444444)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [contentsView addSubview:titleLabel];
    
    UILabel *urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(contentsView.frame), 42.5f)];
    [urlLabel setNumberOfLines:2];
    [urlLabel setText:[object valueForKey:@"url"]];
    [urlLabel setTextColor:UIColorFromRGB(0x999999)];
    [urlLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [urlLabel setBackgroundColor:[UIColor clearColor]];
    [contentsView addSubview:urlLabel];
    
    if (editing) {
        [arrowImageView setHidden:YES];
        [deleteButton setHidden:NO];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else {
        [arrowImageView setHidden:NO];
        [deleteButton setHidden:YES];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (editing) {
        return;
    }
    
    NSString *url = [[self.snapshotListArray objectAtIndex:indexPath.section] valueForKey:@"url"];
    
    BOOL isException = [CPCommonInfo isExceptionalUrl:url];
    [self openWebViewControllerWithUrl:url animated:!isException];
}

@end


@interface SnapshotPreview ()
{
    UIImageView *imageView;
}

@end

@implementation SnapshotPreview

@synthesize scrollView = _scrollView, previewImage = _previewImage;

- (id)init
{
    if ((self = [super init])) {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat addHeight = [SYSTEM_VERSION intValue] >= 7 ? [Modules statusBarHeight] : 0.f;
    
    UIImage *closeImageNor = [UIImage imageNamed:@"btn_close_nor.png"];
    UIImage *closeImageHil = [UIImage imageNamed:@"btn_close_press.png"];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, addHeight, self.view.frame.size.width, self.view.frame.size.height - addHeight)];
    [closeButton setImage:closeImageNor forState:UIControlStateNormal];
    [closeButton setImage:closeImageHil forState:UIControlStateHighlighted];
    [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [closeButton addTarget:self action:@selector(onCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setFrame:CGRectMake(self.view.frame.size.width - closeImageNor.size.width - 10.0f, addHeight + 10.0f, closeImageNor.size.width, closeImageNor.size.height)];
    [self.view addSubview:closeButton];
    
    imageView = [[UIImageView alloc] init];
    [imageView setImage:self.previewImage];
    [imageView setContentMode:UIViewContentModeCenter];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setBackgroundColor:[UIColor clearColor]];
    [imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - addHeight)];
    [imageView setCenter:CGPointMake(self.scrollView.center.x, self.scrollView.center.y - addHeight)];
    
    [self.scrollView setDelegate:self];
    [self.scrollView addSubview:imageView];
    [self.scrollView setMinimumZoomScale:1.0f];
    [self.scrollView setMaximumZoomScale:6.0f];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.scrollView];
    
}

- (void)onCloseButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize boundsSize = scrollView.bounds.size;
    CGRect frameToCenter = imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else frameToCenter.origin.x = 0;
    
    if (frameToCenter.size.height < boundsSize.height) frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else frameToCenter.origin.y = 0;
    
    imageView.frame = frameToCenter;
}

@end
