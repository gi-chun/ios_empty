//
//  CPSnapshotViewController.m
//  11st
//
//  Created by spearhead on 2014. 11. 20..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import "CPSnapshotViewController.h"
#import "CPSnapshotListViewController.h"
#import "CPNavigationBarView.h"
#import "ALToastView.h"


#define MAX_WIDTH			314
#define MAX_HEIGHT			314
#define GUIDE_PADDING		3

@interface CPSnapshotViewController () <UITableViewDataSource,
                                        UITableViewDelegate,
                                        UITextFieldDelegate,
                                        ImageCropEditorDelegate>
{
    UITableViewCell *selectCell;
}

@end

@implementation CPSnapshotViewController

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self initNavigationBar];
    
    _snapshotTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.snapshotTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - NAVIBAR_HEIGHT)];
    [self.snapshotTableView setDelegate:self];
    [self.snapshotTableView setDataSource:self];
    [self.snapshotTableView setBackgroundView:nil];
    
    if ([SYSTEM_VERSION intValue] >= 7) [self.snapshotTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    else [self.snapshotTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.snapshotTableView setBackgroundColor:[UIColor clearColor]];
    
    [self.view setBackgroundColor:UIColorFromRGB(TABLE_BG_COLOR)];
    [self.view addSubview:self.snapshotTableView];
    
    [self setCaptureImage:[self startCapturing]];
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
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = NSLocalizedString(@"AddSnapshot", nil);
    
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if ([subView isKindOfClass:[CPNavigationBarView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(saveSnapshot:)];
}

#pragma mark - Private Methods

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)crop:(id)sender
{
    ImageCropEditor *editor = [[ImageCropEditor alloc] init];
    
    if ([SYSTEM_VERSION intValue] < 7) [self setWantsFullScreenLayout:YES];
    
    [editor setImage:self.captureImage];
    [editor setDelegate:self];
    
    [self.navigationController pushViewController:editor animated:YES];
}

- (void)saveSnapshot:(id)sender
{
    if (!self.browserTitle || [[self.browserTitle trim] isEqualToString:@""]) {
        return [Modules alert:@"" message:NSLocalizedString(@"AlertMsgNoTitle", nil)];
    }
    
    [self deleteSnapshot];
    [self updateSnapshot];
    
    [ALToastView toastInView:self.navigationController.view withText:NSLocalizedString(@"SnapShotSaveComplete", nil)];
    
    [self back:nil];
}

- (void)updateSnapshot
{
    NSError *error;
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SnapshotItem" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    [request setEntity:entity];
    
    SnapshotItem *listData = [NSEntityDescription insertNewObjectForEntityForName:@"SnapshotItem" inManagedObjectContext:managedObjectContext];
    
    if (listData) {
        [listData setTitle:self.browserTitle];
        [listData setUrl:self.browserUrl];
        [listData setDate:[dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]]];
        [listData setImage:UIImagePNGRepresentation(self.captureImage)];
        [listData setThumbnail:UIImagePNGRepresentation([Modules imageWithImage:self.captureImage scaledToSize:CGSizeMake(60.0f, 60.0f)])];
    }
    
    [managedObjectContext save:&error];
}

- (void)deleteSnapshot
{
    NSError *error;
    NSManagedObjectContext *managedObjectContext = [APP_DELEGATE managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SnapshotItem" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
    
    NSArray *datas = [managedObjectContext executeFetchRequest:request error:&error];
    
    if ([datas count] == 30)
    {
        NSManagedObject *object = [datas objectAtIndex:0];
        
        [managedObjectContext deleteObject:object];
    }
    
    [managedObjectContext save:&error];
}

- (void)clearTitleText:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITextField *textField = (UITextField *)[Modules findViewByClass:[UITextField class] view:button.superview.superview];
    
    [textField setText:nil];
    [textField becomeFirstResponder];
}

- (UIImage *)startCapturing
{
    if (!self.captureTargetView) return nil;
    
    CALayer *layer = self.captureTargetView.layer;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect rect = self.captureTargetView.frame;
    
    rect.origin.y = 0;
//    rect.size.height = rect.size.height - [Modules statusBarHeight];
    
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, scale);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    rect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], rect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef scale:screenshot.scale orientation:screenshot.imageOrientation];
    CGImageRelease(imageRef);
    
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    
    return [[UIImage alloc] initWithCGImage:croppedScreenshot.CGImage scale:croppedScreenshot.scale orientation:imageOrientation];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight;
    
    if (indexPath.section == 0) {
        cellHeight = ((self.captureImage.size.height / [UIScreen mainScreen].scale) < 60.0f ? 60.0f : self.captureImage.size.height / [UIScreen mainScreen].scale);
    }
    else if (indexPath.section == 1) {
        cellHeight = 100;
    }
    else {
        cellHeight = 50;
    }
    
    return cellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenBoundsWidth, 35)];
    
    if (section == 0) {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenBoundsWidth-20, 35)];
        [headerLabel setNumberOfLines:0];
        [headerLabel setTextColor:UIColorFromRGB(0x313c55)];
        [headerLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [headerLabel setText:NSLocalizedString(@"AddSnapshot", nil)];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerView addSubview:headerLabel];
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"snapshotCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (indexPath.section == 0) {
        
        CGFloat margin = [self groupedCellMarginWithTableWidth:tableView.frame.size.width], imageMargin = 4.0f;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.captureImage];
        [imageView setContentMode:UIViewContentModeCenter];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setFrame:CGRectMake(imageMargin, imageMargin, tableView.frame.size.width - imageMargin * 2 - margin * 2, self.captureImage.size.height / [UIScreen mainScreen].scale - imageMargin * 2)];
        [cell.contentView addSubview:imageView];
        
        UIImage *cropImage = [UIImage imageNamed:@"crop.png"];
        UIButton *cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cropButton setBackgroundImage:cropImage forState:UIControlStateNormal];
        [cropButton setFrame:CGRectMake(tableView.frame.size.width - cropImage.size.width - margin * 2 - 10, 10.0f, cropImage.size.width, cropImage.size.height)];
        [cropButton addTarget:self action:@selector(crop:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:cropButton];
    }
    
    if (indexPath.section == 1) {
        UIImage *clearBtnImg = [UIImage imageNamed:@"btn_cell_txt_delete.png"];
        UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearBtn setBackgroundImage:clearBtnImg forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(clearTitleText:) forControlEvents:UIControlEventTouchUpInside];
        [clearBtn setFrame:CGRectMake(0, 0, clearBtnImg.size.width, clearBtnImg.size.height)];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, kScreenBoundsWidth-20, 50)];
        [textField setTag:1000];
        [textField setDelegate:self];
        [textField setRightView:clearBtn];
        [textField setText:self.browserTitle];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setFont:[UIFont systemFontOfSize:16.0f]];
        [textField setRightViewMode:UITextFieldViewModeAlways];
        [textField setClearButtonMode:UITextFieldViewModeAlways];
        [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [cell.contentView addSubview:textField];
        
        UILabel *urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(textField.frame), kScreenBoundsWidth-20, 50)];
        [urlLabel setNumberOfLines:1];
        [urlLabel setText:self.browserUrl];
        [urlLabel setTextColor:UIColorFromRGB(0x999999)];
        [urlLabel setFont:[UIFont systemFontOfSize:13]];
        [urlLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:urlLabel];
    }
    
    if (indexPath.section == 2) {
        UIImage *accesoryImage = [UIImage imageNamed:@"btn_accesory_arro.png"];
        UIImageView *accesoryImageView = [[UIImageView alloc] initWithImage:accesoryImage];
        [accesoryImageView setFrame:CGRectMake(kScreenBoundsWidth-(accesoryImage.size.width+10), (50-accesoryImage.size.height)/2, accesoryImage.size.width, accesoryImage.size.height)];
        [cell.contentView addSubview:accesoryImageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenBoundsWidth-(accesoryImage.size.width+20), 50)];
        [titleLabel setNumberOfLines:1];
        [titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [titleLabel setText:NSLocalizedString(@"SnapshotList", nil)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:titleLabel];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        CPSnapshotListViewController *controller = [[CPSnapshotListViewController alloc] init];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UITextField Delegate

- (void)onTextDidChanged:(NSNotification *)notification
{
    self.browserTitle = ((UITextField *)[notification object]).text;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    selectCell = (UITableViewCell *)[Modules findSuperviewByClass:[UITableViewCell class] view:textField];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    self.browserTitle = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UIKeyboard Delegate

- (void)keyboardWillShow:(NSNotification *)noti
{
    CGRect keyboardFrame = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    NSIndexPath *indexPath = [self.snapshotTableView indexPathForCell:selectCell];
    
    if (keyboardFrame.size.width != screenFrame.size.width)
    {
        CGRect tempKeyboardFrame = keyboardFrame;
        
        tempKeyboardFrame.size.width = keyboardFrame.size.height;
        tempKeyboardFrame.size.height = keyboardFrame.size.width;
        
        keyboardFrame = tempKeyboardFrame;
    }
    
    [UIView animateWithDuration:[[[noti userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^(void) {
        [self.snapshotTableView setFrame:CGRectMake(0, self.snapshotTableView.frame.origin.y, self.snapshotTableView.frame.size.width, self.snapshotTableView.frame.size.height - keyboardFrame.size.height)];
    } completion:^(BOOL finished) {
        [self.snapshotTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    CGRect keyboardFrame = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    
    if (keyboardFrame.size.width != screenFrame.size.width)
    {
        CGRect tempKeyboardFrame = keyboardFrame;
        
        tempKeyboardFrame.size.width = keyboardFrame.size.height;
        tempKeyboardFrame.size.height = keyboardFrame.size.width;
        
        keyboardFrame = tempKeyboardFrame;
    }
    
    [UIView animateWithDuration:[[[noti userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^(void) {
        [self.snapshotTableView setFrame:CGRectMake(0, self.snapshotTableView.frame.origin.y, self.snapshotTableView.frame.size.width, self.snapshotTableView.frame.size.height + keyboardFrame.size.height)];
    } completion:^(BOOL finished) {
        [self.snapshotTableView setContentOffset:CGPointZero];
    }];
}

#pragma mark - ImageCropEditor Delegate

- (void)cropImageEditorDidFinished:(UIImage *)image
{
    [self setCaptureImage:image];
    
    [self.snapshotTableView reloadData];
}

@end


@interface ImageCropEditor ()

@end

@implementation ImageCropEditor

- (id)init
{
    if ((self = [super init])) {

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", nil)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(cropImage:)];
    
    NSLog(@"self : %@", NSStringFromCGRect(self.view.frame));
    [self initLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //스와이프 제스쳐로 페이지를 넘어왔을 경우 네비게이션바가 없어진 상태라면 복구시킨다.
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
    }
}

- (void)initLayout
{
    self.imageCropper = [[ImageCropEditorView alloc] initWithImage:self.image frame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - NAVIBAR_HEIGHT - [Modules statusBarHeight])];
    [self.imageCropper setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - NAVIBAR_HEIGHT - [Modules statusBarHeight])];
    [self.imageCropper.imageView setFrame:CGRectMake(0, 0, self.imageCropper.frame.size.width, self.imageCropper.frame.size.height)];
    [self.view addSubview:self.imageCropper];
    
    [self.imageCropper initCropViewPosition];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)cropImage:(id)sender
{
    UIImage *croppedImage = [self.imageCropper getCroppedImage];
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    
    if ([self.delegate respondsToSelector:@selector(cropImageEditorDidFinished:)]) {
        [self.delegate cropImageEditorDidFinished:[[UIImage alloc] initWithCGImage:croppedImage.CGImage scale:croppedImage.scale orientation:imageOrientation]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@interface ImageCropEditorView ()
{
    UIImageView *imageView;
    UIView *cropView;
    UIView *currentDragView;
    
    UIView *topView;
    UIView *bottomView;
    UIView *leftView;
    UIView *rightView;
    
    UIView *topLeftView;
    UIView *topRightView;
    UIView *bottomLeftView;
    UIView *bottomRightView;
    
    UIImageView *topDotImageView;
    UIImageView *leftDotImageView;
    UIImageView *rightDotImageView;
    UIImageView *bottomDotImageView;
    
    NSInteger currentTouches;
    
    CGFloat imageScale;
    CGPoint panTouch;
    CGFloat scaleDistance;
    
    BOOL isPanning;
}

@end

@implementation ImageCropEditorView

@dynamic crop, image;
@synthesize imageView;

- (id)init
{
    if ((self = [super init]))
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithImage:(UIImage *)newImage frame:(CGRect)frame
{
    if ((self = [super init])) {
        [self setFrame:frame];
        
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        [imageView setContentMode:UIViewContentModeCenter];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setImage:newImage];
        
        [self addSubview:imageView];
        
        [self setup];
    }
    
    return self;
}

- (UIImage *)image
{
    return imageView.image;
}

- (void)setImage:(UIImage *)image
{
    imageView.image = image;
}

- (void)constrainCropToImage
{
    CGRect frame = cropView.frame;
    
    if (CGRectEqualToRect(frame, CGRectZero)) return;
    
    BOOL change = NO;
    
    do
    {
        change = NO;
        
        if (frame.origin.x < 0)
        {
            frame.origin.x = 0;
            change = YES;
        }
        
        if (frame.size.width > cropView.superview.frame.size.width)
        {
            frame.size.width = cropView.superview.frame.size.width;
            change = YES;
        }
        
        if (frame.size.width < 150)
        {
            frame.size.width = 150;
            change = YES;
        }
        
        if (frame.origin.x + frame.size.width > cropView.superview.frame.size.width)
        {
            frame.origin.x = cropView.superview.frame.size.width - frame.size.width;
            change = YES;
        }
        
        if (frame.origin.y < 0)
        {
            frame.origin.y = 0;
            change = YES;
        }
        
        if (frame.size.height > cropView.superview.frame.size.height)
        {
            frame.size.height = cropView.superview.frame.size.height;
            change = YES;
        }
        
        if (frame.size.height < 150)
        {
            frame.size.height = 150;
            change = YES;
        }
        
        if (frame.origin.y + frame.size.height > cropView.superview.frame.size.height)
        {
            frame.origin.y = cropView.superview.frame.size.height - frame.size.height;
            change = YES;
        }
    }
    while (change);
    
    [cropView setFrame:frame];
}

- (void)updateBounds
{
    [self constrainCropToImage];
    
    UIImage *imageDot = [UIImage imageNamed:@"cropdot.png"];
    
    CGRect frame = cropView.frame;
    CGFloat x = frame.origin.x;
    CGFloat y = frame.origin.y;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    CGFloat selfWidth = self.imageView.frame.size.width;
    CGFloat selfHeight = self.imageView.frame.size.height;
    
    CGFloat dotWidth = imageDot.size.width;
    CGFloat dotHeight = imageDot.size.height;
    
    topView.frame = CGRectMake(x, -1, width + 1, y);
    bottomView.frame = CGRectMake(x, y + height, width, selfHeight - y - height);
    leftView.frame = CGRectMake(-1, y, x + 1, height);
    rightView.frame = CGRectMake(x + width, y, selfWidth - x - width, height);
    
    topLeftView.frame = CGRectMake(-1, -1, x + 1, y + 1);
    topRightView.frame = CGRectMake(x + width, -1, selfWidth - x - width, y + 1);
    bottomLeftView.frame = CGRectMake(-1, y + height, x + 1, selfHeight - y - height);
    bottomRightView.frame = CGRectMake(x + width, y + height, selfWidth - x - width, selfHeight - y - height);
    
    topDotImageView.frame = CGRectMake(leftView.frame.size.width + (topView.frame.size.width - dotWidth) / 2, topView.frame.origin.y + topView.frame.size.height - dotHeight / 2, dotWidth, dotHeight);
    leftDotImageView.frame = CGRectMake(leftView.frame.origin.x + leftView.frame.size.width - dotWidth / 2, topView.frame.origin.y + topView.frame.size.height + (height - dotHeight) / 2, dotWidth, dotHeight);
    rightDotImageView.frame = CGRectMake(x + width - dotWidth / 2, topView.frame.origin.y + topView.frame.size.height + (height - dotHeight) / 2, dotWidth, dotHeight);
    bottomDotImageView.frame = CGRectMake(leftView.frame.size.width + (bottomView.frame.size.width - dotWidth) / 2, y + height - dotHeight / 2, dotWidth, dotHeight);
}

- (CGRect)crop
{
    CGRect frame = cropView.frame;
    
    if (frame.origin.x <= 0) frame.origin.x = 0;
    if (frame.origin.y <= 0) frame.origin.y = 0;
    
    return CGRectMake(frame.origin.x / imageScale, frame.origin.y / imageScale, frame.size.width / imageScale, frame.size.height / imageScale);;
}

- (void)setCrop:(CGRect)crop
{
    cropView.frame = CGRectMake(crop.origin.x * imageScale, crop.origin.y * imageScale, crop.size.width * imageScale, crop.size.height * imageScale);
    
    [self updateBounds];
}

- (UIView *)newEdgeView
{
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    
    [self.imageView addSubview:view];
    
    return view;
}

- (UIView *)newCornerView
{
    UIView *view = [self newEdgeView];
    
    return view;
}

- (UIImageView *)newDotImageView
{
    UIImage *imageDot = [UIImage imageNamed:@"cropdot.png"];
    UIImageView *dotImageView = [[UIImageView alloc] initWithImage:imageDot];
    [dotImageView setOpaque:YES];
    
    [self.imageView addSubview:dotImageView];
    
    return dotImageView;
}

- (UIView *)initialCropViewForImageView:(UIImageView *)view
{
    UIView *crop = [[UIView alloc] initWithFrame:[self initCropFrame:view]];
    
    [crop.layer setBorderWidth:2.0f];
    [crop.layer setBorderColor:[[UIColor blueColor] CGColor]];
    [crop setBackgroundColor:[UIColor clearColor]];
    
    return crop;
}

- (CGRect)initCropFrame:(UIImageView *)view
{
    CGRect max = view.bounds;
    
    CGFloat width = max.size.width / 4 * 3;
    CGFloat height = max.size.height / 4 * 3;
    CGFloat x = (max.size.width - width) / 2;
    CGFloat y = (max.size.height - height) / 2;
    
    return CGRectMake(x, y, width, height);
}

- (void)initCropViewPosition
{
    [cropView setFrame:[self initCropFrame:self.imageView]];
    
    [self updateBounds];
}

- (void)setup
{
    [self setUserInteractionEnabled:YES];
    [self setMultipleTouchEnabled:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    cropView = [self initialCropViewForImageView:imageView];
    
    [self.imageView addSubview:cropView];
    
    topView = [self newEdgeView];
    bottomView = [self newEdgeView];
    leftView = [self newEdgeView];
    rightView = [self newEdgeView];
    topLeftView = [self newCornerView];
    topRightView = [self newCornerView];
    bottomLeftView = [self newCornerView];
    bottomRightView = [self newCornerView];
    topDotImageView = [self newDotImageView];
    leftDotImageView = [self newDotImageView];
    rightDotImageView = [self newDotImageView];
    bottomDotImageView = [self newDotImageView];
    
    [self updateBounds];
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    float x = toPoint.x - fromPoint.x;
    float y = toPoint.y - fromPoint.y;
    
    return sqrt(x * x + y * y);
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
    {
        case 1:
        {
            currentTouches = 1;
            isPanning = NO;
            
            CGFloat insetAmount = INSIDE_TOUCHABLE;
            CGPoint touch = [[allTouches anyObject] locationInView:self.imageView];
            
            if (CGRectContainsPoint(CGRectInset(cropView.frame, insetAmount, insetAmount), touch)) {
                isPanning = YES;
                panTouch = touch;
                
                return;
            }
            
            CGRect frame = cropView.frame;
            CGFloat x = touch.x;
            CGFloat y = touch.y;
            
            currentDragView = nil;
            
            if (CGRectContainsPoint(CGRectInset(topLeftView.frame, -insetAmount, -insetAmount), touch))
            {
                currentDragView = topLeftView;
                
                if (CGRectContainsPoint(topLeftView.frame, touch)) {
                    frame.size.width += frame.origin.x - x;
                    frame.size.height += frame.origin.y - y;
                    frame.origin = touch;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(topRightView.frame, -insetAmount, -insetAmount), touch))
            {
                currentDragView = topRightView;
                
                if (CGRectContainsPoint(topRightView.frame, touch))
                {
                    frame.size.height += frame.origin.y - y;
                    frame.origin.y = y;
                    frame.size.width = x - frame.origin.x;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomLeftView.frame, -insetAmount, -insetAmount), touch))
            {
                currentDragView = bottomLeftView;
                
                if (CGRectContainsPoint(bottomLeftView.frame, touch))
                {
                    frame.size.width += frame.origin.x - x;
                    frame.size.height = y - frame.origin.y;
                    frame.origin.x =x;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomRightView.frame, -insetAmount, -insetAmount), touch))
            {
                currentDragView = bottomRightView;
                
                if (CGRectContainsPoint(bottomRightView.frame, touch))
                {
                    frame.size.width = x - frame.origin.x;
                    frame.size.height = y - frame.origin.y;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(topView.frame, 0, -insetAmount), touch))
            {
                currentDragView = topView;
                
                if (CGRectContainsPoint(topView.frame, touch))
                {
                    frame.size.height += frame.origin.y - y;
                    frame.origin.y = y;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(bottomView.frame, 0, -insetAmount), touch))
            {
                currentDragView = bottomView;
                
                if (CGRectContainsPoint(bottomView.frame, touch))
                {
                    frame.size.height = y - frame.origin.y;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(leftView.frame, -insetAmount, 0), touch))
            {
                currentDragView = leftView;
                
                if (CGRectContainsPoint(leftView.frame, touch))
                {
                    frame.size.width += frame.origin.x - x;
                    frame.origin.x = x;
                }
            }
            else if (CGRectContainsPoint(CGRectInset(rightView.frame, -insetAmount, 0), touch))
            {
                currentDragView = rightView;
                
                if (CGRectContainsPoint(rightView.frame, touch))
                {
                    frame.size.width = x - frame.origin.x;
                }
            }
            
            cropView.frame = frame;
            
            [self updateBounds];
            
            break;
        }
        case 2:
        {
            CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.imageView];
            CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self.imageView];
            
            if (currentTouches == 0 && CGRectContainsPoint(cropView.frame, touch1) && CGRectContainsPoint(cropView.frame, touch2)) isPanning = YES;
            
            currentTouches = [allTouches count];
            
            break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
    {
        case 1:
        {
            CGPoint touch = [[allTouches anyObject] locationInView:self.imageView];
            
            if (isPanning)
            {
                CGPoint touchCurrent = [[allTouches anyObject] locationInView:self.imageView];
                CGFloat x = touchCurrent.x - panTouch.x;
                CGFloat y = touchCurrent.y - panTouch.y;
                
                cropView.center = CGPointMake(cropView.center.x + x, cropView.center.y + y);
                
                panTouch = touchCurrent;
            }
            else if ((CGRectContainsPoint(self.bounds, touch)))
            {
                CGRect frame = cropView.frame;
                CGFloat x = touch.x;
                CGFloat y = touch.y;
                
                if (x > self.imageView.frame.size.width) x = self.imageView.frame.size.width;
                if (y > self.imageView.frame.size.height) y = self.imageView.frame.size.height;
                
                
                if (currentDragView == topView)
                {
                    frame.size.height += frame.origin.y - y;
                    frame.origin.y = y;
                }
                else if (currentDragView == bottomView)
                {
                    frame.size.height = y - frame.origin.y;
                }
                else if (currentDragView == leftView)
                {
                    frame.size.width += frame.origin.x - x;
                    frame.origin.x = x;
                }
                else if (currentDragView == rightView)
                {
                    frame.size.width = x - frame.origin.x;
                }
                else if (currentDragView == topLeftView)
                {
                    frame.size.width += frame.origin.x - x;
                    frame.size.height += frame.origin.y - y;
                    frame.origin = touch;
                }
                else if (currentDragView == topRightView)
                {
                    frame.size.height += frame.origin.y - y;
                    frame.origin.y = y;
                    frame.size.width = x - frame.origin.x;
                }
                else if (currentDragView == bottomLeftView)
                {
                    frame.size.width += frame.origin.x - x;
                    frame.size.height = y - frame.origin.y;
                    frame.origin.x =x;
                }
                else if (currentDragView == bottomRightView)
                {
                    frame.size.width = x - frame.origin.x;
                    frame.size.height = y - frame.origin.y;
                }
                
                cropView.frame = frame;
            }
            
            break;
        }
        case 2:
        {
            CGPoint touch1 = [[[allTouches allObjects] objectAtIndex:0] locationInView:self.imageView];
            CGPoint touch2 = [[[allTouches allObjects] objectAtIndex:1] locationInView:self.imageView];
            
            if (isPanning)
            {
                CGFloat distance = [self distanceBetweenTwoPoints:touch1 toPoint:touch2];
                
                if (scaleDistance != 0)
                {
                    CGFloat scale = 1.0f + ((distance-scaleDistance)/scaleDistance);
                    CGPoint originalCenter = cropView.center;
                    CGSize originalSize = cropView.frame.size;
                    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
                    
                    if (newSize.width >= 50 && newSize.height >= 50 && newSize.width <= cropView.superview.frame.size.width && newSize.height <= cropView.superview.frame.size.height)
                    {
                        cropView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
                        cropView.center = originalCenter;
                    }
                }
                
                scaleDistance = distance;
            }
            else if (currentDragView == topLeftView || currentDragView == topRightView || currentDragView == bottomLeftView || currentDragView == bottomRightView)
            {
                CGFloat x = MIN(touch1.x, touch2.x);
                CGFloat y = MIN(touch1.y, touch2.y);
                CGFloat width = MAX(touch1.x, touch2.x) - x;
                CGFloat height = MAX(touch1.y, touch2.y) - y;
                
                cropView.frame = CGRectMake(x, y, width, height);
            }
            else if (currentDragView == topView || currentDragView == bottomView)
            {
                CGFloat y = MIN(touch1.y, touch2.y);
                CGFloat height = MAX(touch1.y, touch2.y) - y;
                
                if (height > 30 || cropView.frame.size.height < 45) cropView.frame = CGRectMake(cropView.frame.origin.x, y, cropView.frame.size.width, height);
            }
            else if (currentDragView == leftView || currentDragView == rightView)
            {
                CGFloat x = MIN(touch1.x, touch2.x);
                CGFloat width = MAX(touch1.x, touch2.x) - x;
                
                if (width > 30 || cropView.frame.size.width < 45) cropView.frame = CGRectMake(x, cropView.frame.origin.y, width, cropView.frame.size.height);
            }
            
            break;
        }
    }
    
    [self updateBounds];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    scaleDistance = 0;
    currentTouches = [[event allTouches] count];
}

- (UIImage *)getCroppedImage
{
    CALayer *layer = imageView.layer;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect rect = cropView.frame;
    
    [cropView setHidden:YES];
    [topDotImageView setHidden:YES];
    [leftDotImageView setHidden:YES];
    [rightDotImageView setHidden:YES];
    [bottomDotImageView setHidden:YES];
    
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, scale);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    rect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, (rect.size.width - 1) * scale, (rect.size.height - 1) * scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], rect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef scale:screenshot.scale orientation:screenshot.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedScreenshot;
}

@end

@implementation SnapshotItem

@dynamic title;
@dynamic url;
@dynamic thumbnail;
@dynamic image;
@dynamic date;

@end
