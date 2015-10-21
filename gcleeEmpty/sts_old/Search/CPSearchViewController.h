//
//  CPSearchViewController.h
//  11st
//
//  Created by spearhead on 2014. 9. 19..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPSearchViewControllerDelegate;

@interface CPSearchViewController : UIViewController

@property (nonatomic, strong) NSString *defaultText;
@property (nonatomic, strong) NSString *defaultUrl;
@property (nonatomic, assign) BOOL isSearchText;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id<CPSearchViewControllerDelegate> delegate;

@end

@protocol CPSearchViewControllerDelegate <NSObject>
@optional

- (void)searchWithAdvertisement:(NSString *)url;
- (void)searchWithKeyword:(NSString *)keyword;

@end