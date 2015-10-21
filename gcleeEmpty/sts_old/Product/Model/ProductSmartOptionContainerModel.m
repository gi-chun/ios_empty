//
//  ProductSmartOptionContainerModel.m
//  ShockingDeal
//
//  Created by Hokun Baek on 2015. 6. 24..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "ProductSmartOptionContainerModel.h"
#import "ProductSmartOptionModel.h"

@interface ProductSmartOptionContainerModel ()
{
}

- (void)mappingSmartOptionAtOptionInfo:(NSDictionary *)optionInfo;
- (void)mappingProductImageAtImages:(NSArray *)images;

@end

@implementation ProductSmartOptionContainerModel

#pragma mark - Lifecycle

- (instancetype)initWithOptionInfo:(NSDictionary *)optionInfo
{
    self = [super init];
    if (self)
    {
        [self mappingSmartOptionAtOptionInfo:optionInfo];
    }

    return self;
}

- (instancetype)initWithProductImages:(NSArray *)images
{
    self = [super init];
    if (self)
    {
        [self mappingProductImageAtImages:images];
    }

    return self;
}

#pragma mark - Property

- (BOOL)hasItem
{
    return (_allItems && _allItems.count > 0);
}

#pragma mark - Private Methods

- (void)mappingSmartOptionAtOptionInfo:(NSDictionary *)optionInfo
{
    // 각 Cell에 뿌려질 Data
    NSMutableArray *newAllItems = [NSMutableArray new];
    NSMutableArray *newDetailOptions = [NSMutableArray new];
    NSMutableArray *newRealDetailOptions = [NSMutableArray new];

    // header
    NSString *headerImageUrlString = [optionInfo[@"optTaggingHeaderImg"] trim];
    if (headerImageUrlString && headerImageUrlString.length > 0)
    {
        ProductSmartOptionModel *headerItem = [[ProductSmartOptionModel alloc] init];

        headerItem.imageUrl = [NSURL URLWithString:headerImageUrlString];
        headerItem.soldOut = NO;
        headerItem.optionType = ProductOptionTypeSmartOption;
        headerItem.sectionType = ProductSmartOptionSectionTypeHeaderImage;
        headerItem.cellType = ProductSmartOptionCellTypeList;
        [newAllItems addObject:@[ headerItem ]];
    }

    // option : list(1) or grid(2)
    NSMutableArray *gridGroup = [[NSMutableArray alloc] initWithCapacity:0];
    NSUInteger maxGridItems = 2;
    NSUInteger gridPair = 0;

    NSArray *optionItems = optionInfo[@"optTaggingItems"];
    for (NSUInteger i = 0; i < optionItems.count; i++)
    {
        NSDictionary *option = optionItems[i];

        NSString *optionImageUrlString = [option[@"optionImg"] trim];
        if (optionImageUrlString && optionImageUrlString.length > 0)
        {
            ProductSmartOptionCellType cellType = [option[@"optionViewType"] isEqualToString:@"list"] ? ProductSmartOptionCellTypeList : ProductSmartOptionCellTypeGrid;

            ProductSmartOptionModel *optionItem = [[ProductSmartOptionModel alloc] init];

            optionItem.imageUrl = [NSURL URLWithString:optionImageUrlString];
            optionItem.name = option[@"optionNm"];
            optionItem.soldOut = [option[@"isSoldOut"] isEqualToString:@"Y"] ? YES : NO;
            optionItem.optionType = ProductOptionTypeSmartOption;
            optionItem.sectionType = ProductSmartOptionSectionTypeOption;
            optionItem.cellType = cellType;

            if (cellType == ProductSmartOptionCellTypeList)
            {
                if (gridPair == 1)
                {
                    [newAllItems addObject:[gridGroup copy]];

                    gridPair = 0;
                    [gridGroup removeAllObjects];
                }

                [newAllItems addObject:@[ optionItem ]];
            }
            else
            {
                gridPair++;
                [gridGroup addObject:optionItem];

                if (gridPair == maxGridItems)
                {
                    [newAllItems addObject:[gridGroup copy]];

                    gridPair = 0;
                    [gridGroup removeAllObjects];
                }
            }
        }
    }

    // option detail
    for (NSDictionary *option in optionInfo[@"optTaggingItems"])
    {
        NSString *optionDetailImageUrlString = [option[@"detailImg"] trim];
        if (optionDetailImageUrlString && optionDetailImageUrlString.length > 0)
        {
            ProductSmartOptionModel *optionItem = [[ProductSmartOptionModel alloc] init];

            optionItem.imageUrl = [NSURL URLWithString:optionDetailImageUrlString];
            optionItem.name = option[@"optionNm"];
            optionItem.soldOut = [option[@"isSoldOut"] isEqualToString:@"Y"] ? YES : NO;
            optionItem.optionType = ProductOptionTypeSmartOption;
            optionItem.sectionType = ProductSmartOptionSectionTypeOptionDetail;
            optionItem.cellType = ProductSmartOptionCellTypeList;
            [newAllItems addObject:@[ optionItem ]];
            [newDetailOptions addObject:@[ optionItem ]];
            [newRealDetailOptions addObject:optionItem];
        }
    }

    // footer
    NSString *footerImageUrlString = [optionInfo[@"optTaggingFooterImg"] trim];
    if (footerImageUrlString && footerImageUrlString.length > 0)
    {
        ProductSmartOptionModel *footerItem = [[ProductSmartOptionModel alloc] init];

        footerItem.imageUrl = [NSURL URLWithString:footerImageUrlString];
        footerItem.soldOut = NO;
        footerItem.optionType = ProductOptionTypeSmartOption;
        footerItem.sectionType = ProductSmartOptionSectionTypeDefaultImage;
        footerItem.cellType = ProductSmartOptionCellTypeList;
        [newAllItems addObject:@[ footerItem ]];
    }

    _allItems = newAllItems;
    _detailOptions = newDetailOptions;
    _realDetailOptions = newRealDetailOptions;
}

- (void)mappingProductImageAtImages:(NSArray *)images
{
    // 각 Cell에 뿌려질 Data
    NSMutableArray *newAllItems = [NSMutableArray new];

    for (NSString *image in images)
    {
        ProductSmartOptionModel *imageItem = [[ProductSmartOptionModel alloc] init];

        imageItem.imageUrl = [NSURL URLWithString:image];
        imageItem.soldOut = NO;
        imageItem.optionType = ProductOptionTypeAllImages;
        imageItem.sectionType = ProductSmartOptionSectionTypeDefaultImage;
        imageItem.cellType = ProductSmartOptionCellTypeList;
        [newAllItems addObject:@[ imageItem ]];
    }

    _allItems = newAllItems;
}

- (NSInteger)detailOptionIndexAtOption:(ProductSmartOptionModel *)option
{
    BOOL found = NO;

    NSUInteger index = 0;
    for (NSArray *compare in _detailOptions)
    {
        ProductSmartOptionModel *compareOption = compare[0];
        if ([compareOption.name isEqualToString:option.name])
        {
            found = YES;
            break;
        }

        index++;
    }

    return found ? index : -1;
}

@end
