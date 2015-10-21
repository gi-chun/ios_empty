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

#import "JSTokenField.h"
#import "JSTokenButton.h"
#import "JSBackspaceReportingTextField.h"
#import <QuartzCore/QuartzCore.h>

NSString *const JSTokenFieldFrameDidChangeNotification = @"JSTokenFieldFrameDidChangeNotification";
NSString *const JSTokenFieldNewFrameKey = @"JSTokenFieldNewFrameKey";
NSString *const JSTokenFieldOldFrameKey = @"JSTokenFieldOldFrameKey";
NSString *const JSDeletedTokenKey = @"JSDeletedTokenKey";

#define HEIGHT_PADDING  5
#define WIDTH_PADDING   5

#define DEFAULT_HEIGHT  56
#define MEDIUM_HEIGHT   84
#define MAX_HEIGHT      117
#define LINE_HEIGHT     36

@interface JSTokenField ();

- (JSTokenButton *)tokenWithRepresentedObject:(id)obj;
- (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)obj;
- (void)deleteHighlightedToken;

- (void)commonSetup;
@end


@implementation JSTokenField

@synthesize tokens = _tokens;
@synthesize textField = _textField;
@synthesize label = _label;
@synthesize tokenDelegate = _tokenDelegate;

- (id)initWithFrame:(CGRect)frame
{
	if (frame.size.height < DEFAULT_HEIGHT) {
		frame.size.height = DEFAULT_HEIGHT;
	}
	
    if ((self = [super initWithFrame:frame])) {
        [self commonSetup];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup
{
    CGRect frame = self.frame;
//    [self setBounces:NO];
    [self setScrollEnabled:YES];
    [self setContentInset:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setContentSize:CGSizeMake(CGRectGetWidth(self.frame) - 10.0f, DEFAULT_HEIGHT)];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
    [_label setBackgroundColor:[UIColor clearColor]];
    [_label setTextColor:UIColorFromRGB(0x666666)];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [_label setFont:[UIFont systemFontOfSize:15]];
    [self addSubview:_label];
    
    _tokens = [NSMutableArray array];
    
    frame.origin.y += HEIGHT_PADDING;
    frame.size.height = LINE_HEIGHT;
    frame.size.width -= 20.0f;
    
    UIImage *searchImage = [UIImage imageNamed:@"search_inputbox.png"];
    searchImage = [searchImage resizableImageWithCapInsets:UIEdgeInsetsMake(searchImage.size.height / 2, searchImage.size.width / 2, searchImage.size.height / 2, searchImage.size.width / 2)];
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, LINE_HEIGHT)];
    
    _textField = [[JSBackspaceReportingTextField alloc] init];
    [_textField setFrame:frame];
    [_textField setBackground:searchImage];
    [_textField setDelegate:self];
    [_textField setBorderStyle:UITextBorderStyleNone];
    [_textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_textField setLeftViewMode:UITextFieldViewModeAlways];
    [_textField setLeftView:spacerView];
    [self addSubview:_textField];
    
    [self.textField addTarget:self action:@selector(textFieldWasUpdated:) forControlEvents:UIControlEventEditingChanged];
}

- (void)addTokenWithRepresentedObject:(id)obj
{
    NSString *aString = nil;
    if ([obj class] == [CPAddressBookInfo class]) {
        aString = [[(CPAddressBookInfo *)obj name] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    else {
        aString = @"";
    }
    
	if ([aString length]) {
		JSTokenButton *token = [self tokenWithRepresentedObject:obj];
        token.parentField = self;
		[_tokens addObject:token];
		
		if ([self.tokenDelegate respondsToSelector:@selector(tokenField:didAddToken:representedObject:)]) {
			[self.tokenDelegate tokenField:self didAddToken:aString representedObject:obj];
		}
		
		[self redrawSubviews];
	}
    
}

- (void)addTokenWithTitle:(NSString *)string representedObject:(id)obj
{
	NSString *aString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
	if ([aString length]) {
		JSTokenButton *token = [self tokenWithString:aString representedObject:obj];
        token.parentField = self;
		[_tokens addObject:token];
		
		if ([self.tokenDelegate respondsToSelector:@selector(tokenField:didAddToken:representedObject:)])
		{
			[self.tokenDelegate tokenField:self didAddToken:aString representedObject:obj];
		}
		
		[self redrawSubviews];
	}
}

- (void)removeTokenWithTest:(BOOL (^)(JSTokenButton *token))test
{
    JSTokenButton *tokenToRemove = nil;
    for (JSTokenButton *token in [_tokens reverseObjectEnumerator]) {
        if (test(token)) {
            tokenToRemove = token;
            break;
        }
    }
    
    if (tokenToRemove) {
        if (tokenToRemove.isFirstResponder) {
            [_textField becomeFirstResponder];
        }
        [tokenToRemove removeFromSuperview];
//        [[tokenToRemove retain] autorelease]; // removing it from the array will dealloc the object, but we want to keep it around for the delegate method below
        
        if ([self.tokenDelegate respondsToSelector:@selector(tokenField:didRemoveToken:representedObject:)]) {
            NSString *tokenName = [tokenToRemove titleForState:UIControlStateNormal];
            [self.tokenDelegate tokenField:self didRemoveToken:tokenName representedObject:tokenToRemove.representedObject];
            
		}
        [_tokens removeObject:tokenToRemove];
	}
	
	[self redrawSubviews];
}

- (void)removeTokenForString:(NSString *)string
{
    [self removeTokenWithTest:^BOOL(JSTokenButton *token) {
        return [[token titleForState:UIControlStateNormal] isEqualToString:string];
    }];
}

- (void)removeTokenWithRepresentedObject:(id)representedObject
{
    [self removeTokenWithTest:^BOOL(JSTokenButton *token) {
        return [[token representedObject] isEqual:representedObject];
    }];
}

- (void)removeAllTokens
{
	NSArray *tokensCopy = [_tokens copy];
	for (JSTokenButton *button in tokensCopy) {
		[self removeTokenWithTest:^BOOL(JSTokenButton *token) {
			return token == button;
		}];
	}
//	[tokensCopy release];
}

- (void)deleteHighlightedToken
{
	for (int i = 0; i < [_tokens count]; i++) {
		_deletedToken = [_tokens objectAtIndex:i];
		if ([_deletedToken isToggled]) {
			NSString *tokenName = [_deletedToken titleForState:UIControlStateNormal];
			if ([self.tokenDelegate respondsToSelector:@selector(tokenField:shouldRemoveToken:representedObject:)]) {
				BOOL shouldRemove = [self.tokenDelegate tokenField:self
											shouldRemoveToken:tokenName
											representedObject:_deletedToken.representedObject];
				if (shouldRemove == NO) {
					return;
				}
			}
			
			[_deletedToken removeFromSuperview];
			[_tokens removeObject:_deletedToken];
			
			if ([self.tokenDelegate respondsToSelector:@selector(tokenField:didRemoveToken:representedObject:)]) {
				[self.tokenDelegate tokenField:self didRemoveToken:tokenName representedObject:_deletedToken.representedObject];
			}
			
			[self redrawSubviews];
		}
	}
}

- (JSTokenButton *)tokenWithRepresentedObject:(id)obj
{
	JSTokenButton *token = [JSTokenButton tokenWithRepresentedObject:obj];
	CGRect frame = [token frame];
	
	if (frame.size.width > self.frame.size.width) {
		frame.size.width = self.frame.size.width - (WIDTH_PADDING * 2);
	}
	
	[token setFrame:frame];
	
	[token addTarget:self
			  action:@selector(toggle:)
	forControlEvents:UIControlEventTouchUpInside];
	
	return token;
}


- (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)obj
{
	JSTokenButton *token = [JSTokenButton tokenWithString:string representedObject:obj];
	CGRect frame = [token frame];
	
	if (frame.size.width > self.frame.size.width) {
		frame.size.width = self.frame.size.width - (WIDTH_PADDING * 2);
	}
	
	[token setFrame:frame];
	
	[token addTarget:self
			  action:@selector(toggle:)
	forControlEvents:UIControlEventTouchUpInside];
	
	return token;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)scrollViewDidScroll
{
    //
}

- (void)toggle:(id)sender
{
    // 누르면 토큰 삭제
    JSTokenButton *toggleToken = (JSTokenButton *)sender;
    
    [self removeTokenWithRepresentedObject:[toggleToken representedObject]];
    
//    BOOL isDeleted = NO;
//    // 이미 토글 되어 있는 토큰을 한 번 더 누르면 삭제
//    JSTokenButton *toggleToken = (JSTokenButton *)sender;
//    if ([toggleToken isToggled]) {
//        isDeleted = YES;
//        [self removeTokenWithRepresentedObject:[toggleToken representedObject]];
//    }
//    
//    for (JSTokenButton *token in _tokens) {
//        [token setToggled:NO];
//    }
//    
//    if (!isDeleted) {
//        JSTokenButton *token = (JSTokenButton *)sender;
//        [token setToggled:YES];
//        [token becomeFirstResponder];
//    }
}

- (void)setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    
    [super setFrame:frame];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSValue valueWithCGRect:frame] forKey:JSTokenFieldNewFrameKey];
    [userInfo setObject:[NSValue valueWithCGRect:oldFrame] forKey:JSTokenFieldOldFrameKey];
    if (_deletedToken) {
        [userInfo setObject:_deletedToken forKey:JSDeletedTokenKey];
        _deletedToken = nil;
    }
    
    if (CGRectEqualToRect(oldFrame, frame) == NO) {
        [[NSNotificationCenter defaultCenter] postNotificationName:JSTokenFieldFrameDidChangeNotification object:self userInfo:[userInfo copy]];
    }
}

#pragma mark - redrawSubviews

- (void)redrawSubviews
{
	CGRect currentRect = CGRectZero;
	
	[_label sizeToFit];
	[_label setFrame:CGRectMake(WIDTH_PADDING, HEIGHT_PADDING, [_label frame].size.width, [_label frame].size.height + HEIGHT_PADDING)];
	
	currentRect.origin.x = _label.frame.origin.x;
	if (_label.frame.size.width > 0) {
		currentRect.origin.x += _label.frame.size.width + WIDTH_PADDING;
	}
    
	for (UIButton *token in _tokens) {
		CGRect frame = [token frame];
		
		if ((currentRect.origin.x + frame.size.width) > self.frame.size.width) {
			currentRect.origin = CGPointMake(WIDTH_PADDING, (currentRect.origin.y + frame.size.height + HEIGHT_PADDING));
		}
		
		frame.origin.x = currentRect.origin.x;
		frame.origin.y = currentRect.origin.y + HEIGHT_PADDING;
		
		[token setFrame:frame];
		
		if (![token superview]) {
			[self addSubview:token];
		}
		
		currentRect.origin.x += frame.size.width + WIDTH_PADDING;
		currentRect.size = frame.size;
	}

	CGRect textFieldFrame = [_textField frame];
	textFieldFrame.origin = currentRect.origin;
	
//	if ((self.frame.size.width - textFieldFrame.origin.x) >= 60) {
//		textFieldFrame.size.width = self.frame.size.width - textFieldFrame.origin.x - 20.0f;
//	}
//	else {
//		[lastLineTokens removeAllObjects];
		textFieldFrame.size.width = self.frame.size.width - 20.0f - WIDTH_PADDING * 2;
        textFieldFrame.origin = CGPointMake(WIDTH_PADDING * 2,
                                            (currentRect.origin.y + currentRect.size.height + HEIGHT_PADDING));
//	}
	
	textFieldFrame.origin.y += HEIGHT_PADDING;
//    NSLog(@"textFieldFrame:%@", NSStringFromCGRect(textFieldFrame));
	[_textField setFrame:textFieldFrame];
    
    NSUInteger currentLineCount = (CGRectGetMinY(textFieldFrame) / (LINE_HEIGHT + WIDTH_PADDING)) + 1;
//    NSLog(@"currentLineCount: %i, %f, %f", currentLineCount, CGRectGetMaxY(textFieldFrame), LINE_HEIGHT * currentLineCount + 10.0f);
    if (CGRectGetMaxY(textFieldFrame) > (LINE_HEIGHT * currentLineCount + 10.0f)) {
        currentLineCount++;
    }

	CGRect selfFrame = [self frame];
	selfFrame.size.height = textFieldFrame.origin.y + textFieldFrame.size.height + HEIGHT_PADDING;
	
    if (self.layer.presentationLayer == nil) {
        [self setFrame:CGRectMake(0, CGRectGetMinY(self.frame), kScreenBoundsWidth, DEFAULT_HEIGHT)];
    }
    else {
        if (currentLineCount == 1) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 [self setFrame:CGRectMake(0, CGRectGetMinY(self.frame), kScreenBoundsWidth, DEFAULT_HEIGHT)];
                             }];
            [self setContentSize:CGSizeMake(CGRectGetWidth(selfFrame) - 10.0f, DEFAULT_HEIGHT)];
        }
        else if (currentLineCount == 2) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 [self setFrame:CGRectMake(0, CGRectGetMinY(self.frame), kScreenBoundsWidth, MEDIUM_HEIGHT)];
                             }];
            [self setContentSize:CGSizeMake(CGRectGetWidth(selfFrame) - 10.0f, MEDIUM_HEIGHT)];
        }
        else {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 [self setFrame:CGRectMake(0, CGRectGetMinY(self.frame), kScreenBoundsWidth, MAX_HEIGHT)];
                             }];
            
            [self setContentSize:CGSizeMake(CGRectGetWidth(selfFrame) - 10.0f, 46 + (28 * (currentLineCount - 1)) + (5 * currentLineCount))];
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentSize.height - self.bounds.size.height) animated:NO];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldWasUpdated:(UITextField *)sender {
    if ([self.tokenDelegate respondsToSelector:@selector(tokenFieldTextDidChange:)]) {
        [self.tokenDelegate tokenFieldTextDidChange:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""] && NSEqualRanges(range, NSMakeRange(0, 0)))
	{
        JSTokenButton *token = [_tokens lastObject];
		if (!token) {
			return NO;
		}
		
		NSString *name = [token titleForState:UIControlStateNormal];
		// If we don't allow deleting the token, don't even bother letting it highlight
		BOOL responds = [self.tokenDelegate respondsToSelector:@selector(tokenField:shouldRemoveToken:representedObject:)];
		if (responds == NO || [self.tokenDelegate tokenField:self shouldRemoveToken:name representedObject:token.representedObject]) {
			[token becomeFirstResponder];
		}
		return NO;
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_textField == textField) {
        if ([self.tokenDelegate respondsToSelector:@selector(tokenFieldShouldReturn:)]) {
            return [self.tokenDelegate tokenFieldShouldReturn:self];
        }
    }
	
	return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.tokenDelegate respondsToSelector:@selector(tokenFieldDidEndEditing:)]) {
        [self.tokenDelegate tokenFieldDidEndEditing:self];
        return;
    }
//    else if ([[textField text] length] > 1)
//    {
//        [self addTokenWithTitle:[textField text] representedObject:[textField text]];
//        [textField setText:nil];
//    }
}

@end
