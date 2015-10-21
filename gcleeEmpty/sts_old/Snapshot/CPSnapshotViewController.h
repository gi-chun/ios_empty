//
//  CPSnapshotViewController.h
//  11st
//
//  Created by spearhead on 2014. 11. 20..
//  Copyright (c) 2014년 Commerce Planet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INSIDE_TOUCHABLE	30
#define OUTSIDE_TOUCHABLE	10

@class ImageCropEditorView;

@protocol ImageCropEditorDelegate <NSObject>
@optional
- (void)cropImageEditorDidFinished:(UIImage *)image;

@end

@interface CPSnapshotViewController : UIViewController

@property (nonatomic, strong) UIView *captureTargetView;
@property (nonatomic, strong) NSString *browserTitle;
@property (nonatomic, strong) NSString *browserUrl;
@property (strong, nonatomic) UITableView *snapshotTableView;
@property (strong, nonatomic) UIImage *captureImage;

@end

@interface SnapshotItem : NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSData *thumbnail;
@property (nonatomic, strong) NSData *image;
@property (nonatomic, strong) NSDate *date;

@end

@interface ImageCropEditor : UIViewController

@property (nonatomic, weak) id<ImageCropEditorDelegate> delegate;
@property (nonatomic, strong) ImageCropEditorView *imageCropper;
@property (nonatomic, strong) UIImage *image;

@end


@interface ImageCropEditorView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic) CGRect crop;

- (id)initWithImage:(UIImage *)newImage frame:(CGRect)frame;
- (void)initCropViewPosition;

- (CGRect)initCropFrame:(UIImageView *)view;
- (UIImage *)getCroppedImage;

@end
