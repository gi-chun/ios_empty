//
//	Copyright 2011 James Addyman (JamSoft). All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//		1. Redistributions of source code must retain the above copyright notice, this list of
//			conditions and the following disclaimer.
//
//		2. Redistributions in binary form must reproduce the above copyright notice, this list
//			of conditions and the following disclaimer in the documentation and/or other materials
//			provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JAMES ADDYMAN (JAMSOFT) ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMES ADDYMAN (JAMSOFT) OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of James Addyman (JamSoft).
//

#import "JSTokenButton.h"
#import "JSTokenField.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+WebCache.h"

@implementation JSTokenButton

@synthesize toggled = _toggled;
@synthesize normalBg = _normalBg;
@synthesize highlightedBg = _highlightedBg;
@synthesize representedObject = _representedObject;
@synthesize parentField = _parentField;

+ (JSTokenButton *)tokenWithRepresentedObject:(id)obj
{
	JSTokenButton *button = (JSTokenButton *)[self buttonWithType:UIButtonTypeCustom];
    [button setNormalBg:[[UIImage imageNamed:@"btn_name.png"] stretchableImageWithLeftCapWidth:26.0f topCapHeight:0.0f]];
    [button setImage:[UIImage imageNamed:@"btn_delete.png"] forState:UIControlStateNormal];
	[button setAdjustsImageWhenHighlighted:NO];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 45, 0, 0)];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [button setBackgroundColor:[UIColor clearColor]];
	
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 45, 24)];
    [nameLabel setFont:[UIFont systemFontOfSize:13]];
    [nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [nameLabel setTextColor:UIColorFromRGB(0xffffff)];
    [button addSubview:nameLabel];
    
    if ([obj class] == [CPAddressBookInfo class]) {
        CPAddressBookInfo *data = obj;
        [nameLabel setText:data.name];
    
//        UIImage *image = [(CPAddressBookInfo *)obj thumbnail];
//        UIImage *synthesizedImage = [self imageWithRoundedCorners:image];
//
//        [button setImage:synthesizedImage forState:UIControlStateNormal];
    }
    
//    [button sizeToFit];
    [button setFrame:CGRectMake(10, 0, 70, 24)];
    
//	CGRect frame = [button frame];
//	frame.size.width += 13.0f;
//	frame.size.height = 28.0f;
//	[button setFrame:frame];
	
	[button setToggled:NO];
	
	[button setRepresentedObject:obj];
	
	return button;
}

+ (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)obj
{
	JSTokenButton *button = (JSTokenButton *)[self buttonWithType:UIButtonTypeCustom];
	[button setAdjustsImageWhenHighlighted:NO];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[[button titleLabel] setFont:[UIFont fontWithName:@"Helvetica Neue" size:15]];
	[[button titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
	[button setTitleEdgeInsets:UIEdgeInsetsMake(2, 10, 0, 10)];
	
	[button setTitle:string forState:UIControlStateNormal];
	[button sizeToFit];
    
	CGRect frame = [button frame];
	frame.size.width += 20.0f;
	frame.size.height = 28.0f;
	[button setFrame:frame];
	
	[button setToggled:NO];
	
	[button setRepresentedObject:obj];
	
	return button;
}

- (void)setToggled:(BOOL)toggled
{
	_toggled = toggled;
	
	if (_toggled)
	{
		[self setBackgroundImage:self.highlightedBg forState:UIControlStateNormal];
	}
	else
	{
		[self setBackgroundImage:self.normalBg forState:UIControlStateNormal];
	}
}

- (void)dealloc
{
	self.representedObject = nil;
	self.highlightedBg = nil;
	self.normalBg = nil;
}

- (BOOL)becomeFirstResponder {
    BOOL superReturn = [super becomeFirstResponder];
    if (superReturn) {
        self.toggled = YES;
    }
    return superReturn;
}

- (BOOL)resignFirstResponder {
    BOOL superReturn = [super resignFirstResponder];
    if (superReturn) {
        self.toggled = NO;
    }
    return superReturn;
}

#pragma mark - UIKeyInput
- (void)deleteBackward {
    id <JSTokenFieldDelegate> delegate = _parentField.tokenDelegate;
    if ([delegate respondsToSelector:@selector(tokenField:shouldRemoveToken:representedObject:)]) {
        NSString *name = [self titleForState:UIControlStateNormal];
        BOOL shouldRemove = [delegate tokenField:_parentField shouldRemoveToken:name representedObject:self.representedObject];
        if (!shouldRemove) {
            return;
        }
    }
    [_parentField removeTokenForString:[self titleForState:UIControlStateNormal]];
}

- (BOOL)hasText {
    return NO;
}
- (void)insertText:(NSString *)text {
    return;
}


- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Private Methods

+ (UIImage *)imageWithRoundedCorners:(UIImage *)original
{
    if (original == nil) {
        return [UIImage imageNamed:@"share_thumb_profile01.png"];
    }
    
    UIImage *frameImage = [UIImage imageNamed:@"share_thumb_profile02.png"];
    
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(frameImage.size, NO, 0.0f);
    }
//    else {
//        UIGraphicsBeginImageContext(frameImage.size);
//    }
    
    UIImage *resizedProfileImage = [UIImage image:original fillSize:CGSizeMake(28.0f, 28.0f)];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(1.5f, 1.5f, 25.0f, 25.0f)
                                cornerRadius:15.5f] addClip];
    [resizedProfileImage drawInRect:CGRectMake(1.5f, 1.5f, 25.0f, 25.0f)];
    
    [frameImage drawInRect:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    UIImage *synthesizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return synthesizedImage;
}

@end
