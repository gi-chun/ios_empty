//
//  CPSnapshotListViewController.h
//  11st
//
//  Created by spearhead on 2014. 11. 20..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPSnapshotListViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *snapshotListArray;
@property (strong, nonatomic) UITableView *listTableView;

@end


@interface SnapshotPreview : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImage *previewImage;

@end
