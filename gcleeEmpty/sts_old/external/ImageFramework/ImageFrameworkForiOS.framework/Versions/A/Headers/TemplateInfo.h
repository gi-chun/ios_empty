//
//  TemplateInfo.h
//  ImageFrameworkBy11st
//
//  Created by kiwiple on 13. 4. 23..
//  Copyright (c) 2013년 kiwiple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateInfo : NSObject

@property (nonatomic, assign, getter = getId) NSInteger mId;
@property (nonatomic, retain, getter = getTitle) NSString *title;
@property (nonatomic, retain, getter = getThumbnail) NSString *thumbnailPath;
@property (nonatomic, assign, getter = getAspectRatio) NSInteger aspectRatio;
@property (nonatomic, assign, getter = getFrameCount) NSInteger frameCount;
@property (nonatomic, retain, getter = getFrameInfo) NSArray *frameInfo;
@property (nonatomic, assign, getter = getWidth) NSInteger width;
@property (nonatomic, assign, getter = getHeight) NSInteger height;

@property (nonatomic, retain, getter = getTemplateInfo) NSDictionary *templateInfo;

@end
