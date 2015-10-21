//
//  CPProductThumbnailView.h
//  11st
//
//  Created by spearhead on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPProductThumbnailViewViewDelegate;

@interface CPProductThumbnailView : UIView

@property (nonatomic, weak) id<CPProductThumbnailViewViewDelegate> delegate;

- (void)releaseItem;
- (id)initWithFrame:(CGRect)frame product:(NSDictionary *)aProduct;

@end

@protocol CPProductThumbnailViewViewDelegate <NSObject>
@optional
- (void)didTouchPreviewButton:(NSString *)url;
@end