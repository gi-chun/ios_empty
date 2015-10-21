//
//  ProductSmartOptionModel.h
//  ShockingDeal
//
//  Created by Hokun Baek on 2015. 6. 22..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ProductOptionType)
{
    ProductOptionTypeAllImages,
    ProductOptionTypeSmartOption
};

typedef NS_ENUM(NSUInteger, ProductSmartOptionSectionType)
{
    ProductSmartOptionSectionTypeHeaderImage,
    ProductSmartOptionSectionTypeOption,
    ProductSmartOptionSectionTypeOptionDetail,
    ProductSmartOptionSectionTypeDefaultImage
};

typedef NS_ENUM(NSUInteger, ProductSmartOptionCellType)
{
    ProductSmartOptionCellTypeList,
    ProductSmartOptionCellTypeGrid
};

static CGFloat const kProductInfoSmartOptionImageHeight = 155.0f;
static CGFloat const kProductInfoSmartOptionButtonHeight = 34.0f;
static CGFloat const kProductInfoSmartOptionLineHeight = 1.0f;
static CGFloat const kProductInfoSmartOptionCellMargin = 9.0f;

@interface ProductSmartOptionModel : NSObject

// mapping
@property (nonatomic, copy) NSURL *imageUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL soldOut;

// type
@property (nonatomic, assign) ProductOptionType optionType;
@property (nonatomic, assign) ProductSmartOptionSectionType sectionType;
@property (nonatomic, assign) ProductSmartOptionCellType cellType;

@end
