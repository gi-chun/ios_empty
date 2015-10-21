//
//  CPSchemeManager.m
//  11st
//
//  Created by spearhead on 2015. 5. 19..
//  Copyright (c) 2015년 Commerce Planet. All rights reserved.
//

#import "CPSchemeManager.h"
#import "CPCommonInfo.h"
#import "RegexKitLite.h"
#import "SBJSON.h"
#import "NSString+SBJSON.h"

@implementation CPSchemeManager

+ (CPSchemeManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static CPSchemeManager *sharedInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CPSchemeManager alloc] init];
    });
    
    return sharedInstance;
}

- (BOOL)openUrlScheme:(NSString *)url sender:(id)sender changeAnimated:(BOOL)animated
{
    if (!url || [[url trim] isEqualToString:@""]) {
        return YES;
    }
    
    if (![url isMatchedByRegex:URL_PATTERN]) {
        return NO;
    }
    
    NSString *command = [url stringByMatching:URL_PATTERN capture:1];
    NSString *option = [url stringByMatching:URL_PATTERN capture:2];
    
    NSLog(@"command : %@", command);
    
    // 팝업 브라우저(상품상세, 스타일등)
    if ([command isEqualToString:@"popupBrowser"])	{
        [self popupBrowser:option];
        return YES;
    }
    
    // json 포맷으로 custom alert 노출
    if ([command isEqualToString:@"popup"])	{
        [self popup:option];
        return YES;
    }
    
    // 상품상세 페이지 확대보기 버튼
    if ([command isEqualToString:@"zoomViewer"]) {
        [self zoomViewer:option];
        return YES;
    }
    
    // 포토리뷰
    if ([command isEqualToString:@"photoReview"]) {
        [self photoReview:option];
        return YES;
    }
    
    // 서랍
    if ([command isEqualToString:@"product"]) {
        [self product:option];
        return YES;
    }
    
    // 검색어
    if ([command isEqualToString:@"ads"]) {
        [self advertisement:option];
        return YES;
    }
    
    // 자바스크립트 호출 canOpenApplication()
    if ([command isEqualToString:@"canOpenApp"]) {
        if ([self.delegate respondsToSelector:@selector(executeCanOpenApplication:)]) {
            [self.delegate executeCanOpenApplication:option];
        }
        return YES;
    }
    
    // app-url : third pary 앱이 설치 되어 있으면, 해당 앱을 실행
    // store-url : app-url key가 없을 경우, 해당 앱 스토어 및 마켓으로 이동
    if ([command isEqualToString:@"callapp"]) {
        [self callApp:option];
        return YES;
    }
    
    // 이미지 URL을 이미지 화면 노출
    if ([command isEqualToString:@"imageview"]) {
        [self imageView:option];
    }
    
    // 하단 툴바 더보기>브라우저 실행시
    if ([command isEqualToString:@"openBrowser"]) {
        [self openBrowser:option];
        return YES;
    }
    
    // deprecated : 툴바 (네이티브로 대체)
    if ([command isEqualToString:@"browser"]) {
        [self browser:option];
        return YES;
    }
    
    //copy 옵션일 경우 url을 주소창에 복사
    if ([command isEqualToString:@"clipboard"]) {
        [self clipboard:option];
        return YES;
    }
    
    // 동영상 팝업
    if ([command isEqualToString:@"moviepopup"]) {
        [self moviePopup:option];
        return YES;
    }
    
    // 홈탭 이동
    if ([command isEqualToString:@"gopage"]) {
        if ([self.delegate respondsToSelector:@selector(goToPageAction:)]) {
            [self.delegate goToPageAction:option];
        }
        return YES;
    }
    
    // 홈탭에서 로그인/로그아웃
    if ([command isEqualToString:@"move"]) {
        if ([self.delegate respondsToSelector:@selector(moveToHomeAction:)]) {
            [self.delegate moveToHomeAction:option];
        }
        return YES;
    }
    
    // 웹뷰내의 스와이프
    if ([command isEqualToString:@"viewPager"]) {
        if ([self.delegate respondsToSelector:@selector(doNotInterceptSwipe:)]) {
            [self.delegate doNotInterceptSwipe:option];
        }
        return YES;
    }
    
    // 설정
    if ([command isEqualToString:@"user"]) {
        [self setting:option sender:sender animated:animated];
        return YES;
    }
    
    // OTP
    if ([command isEqualToString:@"otp"]) {
        [self otp:option];
        return YES;
    }
    
    // 새로운 흔들기
    if ([command isEqualToString:@"shakemotion"]) {
        if ([self.delegate respondsToSelector:@selector(shakemotion:)]) {
            [self.delegate shakemotion:option];
        }
        return YES;
    }
    
    // redirect
    if ([command isEqualToString:@"redirect"]) {
        option = [option stringByReplacingOccurrencesOfString:@"${requestTime}" withString:[Modules stringFromDate:[NSDate date] format:@"yyyyMMddHHmmss"]];
        
        if (sender && [sender isKindOfClass:[UIButton class]]) {
            if ([sender isEnabled]) {
                option = [NSString stringWithFormat:@"%@%@requestTime=%@", option, [option indexOf:@"?"] > 0 ? @"&" : @"?", [Modules stringFromDate:[NSDate date] format:@"yyyyMMddHHmmss"]];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(openWebView:)]) {
            [self.delegate openWebView:option];
        }
        return YES;
    }
    
    // 웹뷰 히스토리
    if ([command isEqualToString:@"history"]) {
        [self history:option];
        return YES;
    }
    
    // 연관검색어 최근검색어에 저장
    if ([command isEqualToString:@"recent"]) {
        [self addRecentKeyword:option];
        return YES;
    }
    
    // 로컬 노티피케이션 (이벤트 알람)
    if ([command isEqualToString:@"localalarm"]) {
        [self eventAlarmSetting:option];
        return YES;
    }
    
    // 연락처
    if ([command isEqualToString:@"contact"]) {
        [self contact:option];
        return YES;
    }

    
    // deprecated :
    if ([command isEqualToString:@"motion"]) {
        
    }
    
    // deprecated :
    if ([command isEqualToString:@"gesture"]) {
        
    }
    
    // deprecated :
    if ([command isEqualToString:@"effect"]) {
        
    }
    
    // deprecated : Component는 제거
    if ([command isEqualToString:@"remove"] || [command isEqualToString:@"delete"]) {
        
    }
    
    // deprecated : 구 searchBar, addressBar, toggleMenu
    if ([command hasPrefix:@"properties"]) {
        
    }
    
    // deprecated :
    if ([command isEqualToString:@"changeBrowser"]) {
        
    }
    
    // deprecated : 즐겨찾기
    if ([command isEqualToString:@"capture"]) {
        
    }
    
    // deprecated : 공유(delegate로 대체)
    if ([command isEqualToString:@"share"]) {
        
    }
    
    // 액션시트? 사용중인지 확인 필요
    if ([command isEqualToString:@"action"]) {
        //        [[UrlScheme sharedInstance] action:option];
    }
    
    // deprecated : 포토리뷰 이전에 사용(v5.0.0)
    if ([command isEqualToString:@"photo"]) {
        
    }
    
    // deprecated : GNB에서 최근본상품은 없어짐
    if ([command isEqualToString:@"lastProduct"]) {
        
    }
    
    // deprecated : 바로마트
    if ([command isEqualToString:@"offering"]) {
        
    }
    
    return YES;
}

// ads 스킴.
// popup : 광고페이지를 전면
// searchKeywords : JSON 데이터 중 랜덤으로 검색창에 노출.
// searchText : 전달된 텍스를 검색창에 노출
- (void)advertisement:(NSString *)option
{
    //    NSLog(@"option:%@", option);
    
    SBJSON *json = [[SBJSON alloc] init];
    NSArray *separatedOption = [option componentsSeparatedByString:@"/"];
    
    if (separatedOption && [separatedOption count] < 2) {
        return;
    }
    
    if ([[separatedOption objectAtIndex:0] isEqualToString:@"popup"]) {
        if ([separatedOption count] > 1) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *props = [json objectWithString:URLDecode([separatedOption objectAtIndex:1])];
            
            if (props && [[props objectForKey:@"errCode"] intValue] == 0) {
                NSMutableArray *inAppPopUpMgr = [[NSMutableArray alloc] initWithArray:[userDefaults objectForKey:@"inAppPopUpId"]];
                
                if (inAppPopUpMgr) {
                    for (NSMutableDictionary *dic in inAppPopUpMgr) {
                        if ([[dic objectForKey:@"adPopupId"] isEqualToString:[props objectForKey:@"id"]]) {
                            return;
                        }
                    }
                }
                
                //타입이 03 : 풀스크린 팝업일 경우만 보여준다.
                if ([[props objectForKey:@"dispType"] isEqualToString:@"03"]) {
                    NSString *linkUrl = [props objectForKey:@"linkUrl"];
                    
                    if ([self.delegate respondsToSelector:@selector(openPopupViewController:)]) {
                        [self.delegate openPopupViewController:linkUrl];
                    }
                }
                
                //일정 시간이 지난 ID는 저장된 데이터에서 삭제한다.
                NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
                
                [object setObject:[props objectForKey:@"id"] forKey:@"adPopupId"];
                [object setObject:[props objectForKey:@"expiredTime"] forKey:@"expiredTime"];
                
                [inAppPopUpMgr addObject:object];
                
                [userDefaults setObject:inAppPopUpMgr forKey:@"inAppPopUpId"];
                [userDefaults synchronize];
                
                for (NSMutableDictionary *dic in inAppPopUpMgr) {
                    if ([[dic objectForKey:@"adPopupId"] isEqualToString:[props objectForKey:@"id"]]) {
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        
                        NSDate *date = [dateFormat dateFromString:[dic objectForKey:@"expiredTime"]];;
                        
                        if ([date timeIntervalSinceNow] < 0) {
                            [inAppPopUpMgr removeObject:dic];
                        }
                    }
                }
                
                [userDefaults setObject:inAppPopUpMgr forKey:@"inAppPopUpId"];
                [userDefaults synchronize];
            }
        }
    }
    else if([[separatedOption objectAtIndex:0] isEqualToString:@"searchKeywords"]) {
        NSDictionary *props = [json objectWithString:URLDecode([separatedOption objectAtIndex:1])];
        
        if (props) {
            NSString *clickLogUrl = [props objectForKey:@"clickLogUrl"];
            NSString *viewLogUrl = [props objectForKey:@"viewLogUrl"];
            NSArray *list = [props objectForKey:@"list"];
            
            if(!list || [list count] == 0) {
                return;
            }
            
            NSUInteger maxNum = [list count];
            NSUInteger randNo = rand() % maxNum;
            
            if(randNo > maxNum) {
                return;
            }
            
            NSString *keywordSearchLinkUrl = [[list objectAtIndex:randNo] objectForKey:@"link"];
            NSString *keywordSearchName = [[list objectAtIndex:randNo] objectForKey:@"name"];
            keywordSearchName = [Modules decodeFromPercentEscapeString:keywordSearchName];
            
            viewLogUrl = [viewLogUrl stringByReplacingOccurrencesOfString:@"{{idx}}" withString:[NSString stringWithFormat:@"%lu", (unsigned long)randNo]];
            clickLogUrl = [clickLogUrl stringByReplacingOccurrencesOfString:@"{{idx}}" withString:[NSString stringWithFormat:@"%lu", (unsigned long)randNo]];
            
            NSMutableDictionary *searchKeyWordInfo = [NSMutableDictionary dictionary];
            searchKeyWordInfo[@"link"] = keywordSearchLinkUrl;
            searchKeyWordInfo[@"clickLogUrl"] = clickLogUrl;
            searchKeyWordInfo[@"viewLogUrl"] = viewLogUrl;
            searchKeyWordInfo[@"name"] = keywordSearchName;
            
            [[CPCommonInfo sharedInfo] setSearchKeyWordInfo:searchKeyWordInfo];
            [[CPCommonInfo sharedInfo] setCurrentAdKeyword:keywordSearchName];

            //ViewLog를 호출한다.
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:viewLogUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
            
            [request setHTTPMethod:@"GET"];
            
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                       //
                                   }];
            
            if ([self.delegate respondsToSelector:@selector(setSearchTextField:)]) {
                [self.delegate setSearchTextField:keywordSearchName];
            }
        }
    }
    else if([[separatedOption objectAtIndex:0] isEqualToString:@"searchText"]) {
        NSDictionary *props = [json objectWithString:URLDecode([separatedOption objectAtIndex:1])];
        
        if(props && [[props objectForKey:@"list"] count] > 0) {
            NSString *searchText = props [@"list"][0][@"name"];
            searchText = [Modules decodeFromPercentEscapeString:searchText];
            
            [CPCommonInfo addRecentSearchItems:searchText];
            [[CPCommonInfo sharedInfo] setCurrentAdKeyword:searchText];
            
            if ([self.delegate respondsToSelector:@selector(setSearchTextField:)]) {
                [self.delegate setSearchTextField:searchText];
            }
        }
    }
}

// 팝업 브라우저(상품상세, 스타일등)
- (void)popupBrowser:(NSString *)option
{    
    NSArray *separatedOption = [option componentsSeparatedByString:@"/"];
    
    if (separatedOption && [separatedOption count] == 2) {
        SBJSON *json = [[SBJSON alloc] init];
        
        NSDictionary *props = [json objectWithString:URLDecode([separatedOption objectAtIndex:1])];
        
        if ([[separatedOption objectAtIndex:0] isEqualToString:@"open"]) {
            if ([self.delegate respondsToSelector:@selector(openPopupBrowserView:)]) {
                [self.delegate openPopupBrowserView:props];
            }
        }
        else if ([[separatedOption objectAtIndex:0] isEqualToString:@"close"]) {
            
            if ([self.delegate respondsToSelector:@selector(closePopupBrowserView:)]) {
                [self.delegate closePopupBrowserView:props];
            }
        }
    }
}

// json 포맷으로 custom alert 노출
- (void)popup:(NSString *)option
{
    SBJSON *json = [[SBJSON alloc] init];
    NSMutableDictionary *props = option ? [NSMutableDictionary dictionaryWithDictionary:[json objectWithString:URLDecode(option)]] : nil;
    
    CGFloat statusBarHeight = [[UIApplication sharedApplication] isStatusBarHidden] ? 0 : [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    if (option && !props) {
        [(props = [[NSMutableDictionary alloc] init]) setObject:option forKey:@"url"];
    }
    
    if (![props objectForKey:@"url"]) {
        return;
    }
    
    if (![props objectForKey:@"left"]) {
        [props setObject:[NSString stringWithFormat:@"%f", 0.0f] forKey:@"left"];
    }
    
    if (![props objectForKey:@"top"]) {
        [props setObject:[NSString stringWithFormat:@"%f", statusBarHeight] forKey:@"top"];
    }
    
    if (![props objectForKey:@"width"]) {
        [props setObject:[NSString stringWithFormat:@"%f", [UIScreen mainScreen].bounds.size.width] forKey:@"width"];
    }
    
    if (![props objectForKey:@"height"]) {
        [props setObject:[NSString stringWithFormat:@"%f", [UIScreen mainScreen].bounds.size.height - statusBarHeight] forKey:@"height"];
    }
    
    if (![props objectForKey:@"direction"]) {
        [props setObject:@"top" forKey:@"direction"];
    }
    
    if (![props objectForKey:@"closeButton"]) {
        [props setObject:NSLocalizedString(@"Close", nil) forKey:@"closeButton"];
    }
}

// 상품상세 페이지 확대보기 버튼
- (void)zoomViewer:(NSString *)option
{
    if (!option || [[option trim] isEqualToString:@""]) {
        return;
    }
    
    NSArray *separatedOption = [option componentsSeparatedByString:@"/"];
    
    if (separatedOption && [separatedOption count] == 2) {
        
        if ([self.delegate respondsToSelector:@selector(setZoomViewer:)]) {
            [self.delegate setZoomViewer:separatedOption];
        }
    }
}

// 포토리뷰
- (void)photoReview:(NSString *)option
{
    SBJSON *json = [[SBJSON alloc] init];
    
    //    option = @"%7B%22uploadUrl%22:%22http://m.11st.co.kr/MW/MyPage/ablePostScriptInputSend.tmall%22,%22pageRedirect%22:%20%22%22,%22satisfaction%22:%20%7B%22label%22:%22%EC%83%81%ED%92%88%EC%9D%98%20%EB%A7%8C%EC%A1%B1%EB%8F%84%EB%A5%BC%20%EC%84%A0%ED%83%9D%ED%95%B4%EC%A3%BC%EC%84%B8%EC%9A%94.%22,%22type%22:%22radio%22,%22selectedIndex%22:%220%22,%22name%22:%22prdEvlPnt%22,%22options%22:%5B%7B%22text%22:%22%EC%A0%81%EA%B7%B9%EC%B6%94%EC%B2%9C%22,%22value%22:%223%22%7D,%7B%22text%22:%22%EC%B6%94%EC%B2%9C%22,%22value%22:%222%22%7D,%7B%22text%22:%22%EB%B3%B4%ED%86%B5%22,%22value%22:%221%22%7D,%7B%22text%22:%22%EC%B6%94%EC%B2%9C%EC%95%88%ED%95%A8%22,%22value%22:%220%22%7D%5D%7D,%22title%22:%20%7B%22hint%22:%22%EC%A0%9C%EB%AA%A9%EC%9D%84%20%EC%9E%85%EB%A0%A5%ED%95%B4%20%EC%A3%BC%EC%84%B8%EC%9A%94.%22,%22type%22:%22text%22,%22name%22:%22title%22,%22min%22:%221%22,%22max%22:%2250%22,%22satisfaction%22:%7B%223%22:%5B%22%EB%84%88%EB%AC%B4%EB%A7%88%EC%9D%8C%EC%97%90%EB%93%AD%EB%8B%88%EB%8B%A4.%EC%A0%81%EA%B7%B9%EC%B6%94%EC%B2%9C%ED%95%A9%EB%8B%88%EB%8B%A4.%22,%22%EB%8B%A4%EB%A5%B8%EA%B3%B3%EB%B3%B4%EB%8B%A4%EC%A0%95%EB%A7%90%EC%8B%B8%EA%B2%8C%EC%83%80%EC%96%B4%EC%9A%94!%22,%22%EC%99%84%EC%A0%84%EA%B0%95%EC%B6%94%ED%95%A9%EB%8B%88%EB%8B%A4!%22%5D,%222%22:%5B%22%EC%A2%8B%EC%95%84%EC%9A%94!%EB%A7%88%EC%9D%8C%EC%97%90%EB%93%A4%EC%96%B4%EC%9A%94~%22,%22%EC%83%81%ED%92%88,%EB%B0%B0%EC%86%A1%EA%B4%9C%EC%B0%AE%EC%8A%B5%EB%8B%88%EB%8B%A4!%22,%22%EC%A2%8B%EC%9D%80%EC%83%81%ED%92%88%EC%9E%85%EB%8B%88%EB%8B%A4.%EC%B6%94%EC%B2%9C%ED%95%A0%EA%B2%8C%EC%9A%94.%22%5D,%221%22:%5B%22%EB%82%98%EC%81%98%EC%A7%80%EC%95%8A%EC%95%84%EC%9A%94!%22,%22%EA%B7%B8%EB%9F%AD%EC%A0%80%EB%9F%AD%EB%A7%8C%EC%A1%B1%ED%95%A9%EB%8B%88%EB%8B%A4.%22,%22%EC%93%B8%EB%A7%8C%ED%95%9C%EC%83%81%ED%92%88%EC%9D%B4%EB%84%A4%EC%9A%94.%22%5D,%220%22:%5B%22%EC%83%81%ED%92%88%EC%9D%B4%EB%AC%B8%EC%A0%9C%EA%B0%80%EC%9E%88%EC%8A%B5%EB%8B%88%EB%8B%A4.%22,%22%EB%B0%B0%EC%86%A1%EB%95%8C%EB%AC%B8%EC%97%90%ED%99%94%EA%B0%80%EB%82%A9%EB%8B%88%EB%8B%A4.%22,%22%EC%A0%95%EB%A7%90%EB%84%88%EB%AC%B4%ED%95%98%EB%84%A4%EC%9A%94!%22%5D%7D%7D,%22content%22:%7B%22type%22:%22textarea%22,%22name%22:%22content%22,%22min%22:%220%22,%22max%22:%223000%22,%22rows%22:%223%22,%22hint%22:%22%EC%83%81%ED%92%88%EC%9D%84%20%EC%82%AC%EC%9A%A9%ED%95%98%EC%8B%A0%20%ED%9B%84%20%EB%8A%90%EB%82%80%20%EA%B2%BD%ED%97%98%EC%9D%84%20%EC%84%B1%EC%9D%98%EC%9E%88%EA%B2%8C%20%EC%9E%91%EC%84%B1%ED%95%B4%EC%A3%BC%EC%84%B8%EC%9A%94.%20(3000%EC%9E%90%20%EB%AF%B8%EB%A7%8C)%22%7D,%22hiddenItems%22:%5B%7B%22type%22:%22hidden%22,%22name%22:%22prdNo%22,%22value%22:%22958497931%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22sort%22,%22value%22:%225%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22memNo%22,%22value%22:%2212054882%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22contNo%22,%22value%22:%22%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22rootType%22,%22value%22:%222%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22pageNo%22,%22value%22:%221%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22editType%22,%22value%22:%221%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22gdsNo%22,%22value%22:%22%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22ordNo%22,%22value%22:%22201412308011277%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22dispCtgr1NoDe%22,%22value%22:%22160994%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22dispCtgr2NoDe%22,%22value%22:%22165263%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22dispSCtgrNo%22,%22value%22:%22%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22ordPrdSeq%22,%22value%22:%221%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22weScoreYn%22,%22value%22:%22N%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22beautyCtg%22,%22value%22:%22N%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22appPhotoReview%22,%22value%22:%22Y%22%7D,%7B%22type%22:%22hidden%22,%22name%22:%22pageRedirect%22,%22value%22:%22http://m.11st.co.kr/MW/MyPage/orderList.tmall%22%7D%5D%7D";
    
    NSString *string = [option stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    string = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"&#92;"];
    
    NSDictionary *props = string ? [json objectWithString:string] : nil;
    
    if (props) {
        if ([self.delegate respondsToSelector:@selector(openPhotoReviewController:)]) {
            [self.delegate openPhotoReviewController:props];
        }
    }
}

// 바로마트
- (void)offering:(NSString *)option
{
    NSLog(@"command : %@ \n option", option);
}

// 서랍
- (void)product:(NSString *)option
{
    SBJSON *json = [[SBJSON alloc] init];
    NSArray *separatedTemp = [option componentsSeparatedByString:@"/"];
    NSDictionary *productOptionData = [separatedTemp count] > 0 ? [json objectWithString:URLDecode([separatedTemp objectAtIndex:1])] : nil;
    
    BOOL isOptionEnable = [[productOptionData objectForKey:@"enable"] boolValue];
    
    if ([self.delegate respondsToSelector:@selector(setProductOption:)]) {
        [self.delegate setProductOption:isOptionEnable];
    }
}

// app-url, store-url은 한가지 프로퍼티에 한해서 적용되며, app-url key가 우선권을 갖는다.
// app-url : third pary 앱이 설치 되어 있으면, 해당 앱을 실행
// store-url : app-url key가 없을 경우, 해당 앱 스토어 및 마켓으로 이동
- (void)callApp:(NSString *)option
{
    SBJSON *json = [[SBJSON alloc] init];
    NSDictionary *props = option ? [json objectWithString:URLDecode(option)] : nil;
    
    if (props) {
        NSString *appUrlString = [props objectForKey:@"app-url"];
        NSString *storeUrlString = [props objectForKey:@"store-url"];
        
        if (appUrlString && ![[appUrlString trim] isEqualToString:@""]) {
            NSURL *appUrl = [NSURL URLWithString:appUrlString];
            
            if ([[UIApplication sharedApplication] canOpenURL:appUrl]) {
                [[UIApplication sharedApplication] openURL:appUrl];
            }
            else {
                if (storeUrlString && ![[storeUrlString trim] isEqualToString:@""]) {
                    if ([self.delegate respondsToSelector:@selector(openWebView:)]) {
                        [self.delegate openWebView:storeUrlString];
                    }
                }
            }
        }
    }
}

// 이미지 URL을 이미지 화면 노출
- (void)imageView:(NSString *)option
{
    SBJSON *json = [[SBJSON alloc] init];
    NSDictionary *props = option ? [json objectWithString:URLDecode(option)] : nil;
    
    if (props) {
        
        if ([self.delegate respondsToSelector:@selector(openImageView:)]) {
            [self.delegate openImageView:props];
        }
    }
}

// 하단 툴바 더보기>브라우저 실행시
- (void)openBrowser:(NSString *)option
{
    if (option) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLDecode(option)]];
    }
}

- (void)browser:(NSString *)option
{
    if (!option || [[option trim] isEqualToString:@""]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(webViewToolbarAction:)]) {
        [self.delegate webViewToolbarAction:option];
    }
}

//copy 옵션일 경우 url을 주소창에 복사
- (void)clipboard:(NSString *)option
{
    if (!option || [[option trim] isEqualToString:@""]) {
        return;
    }
    
    NSArray *values = [option componentsSeparatedByString:@"/"];
    
    if ([values count] < 2) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(pasteClipBoard:)]) {
        [self.delegate pasteClipBoard:values];
    }
}

// 설정
- (void)setting:(NSString *)option sender:(id)sender animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(setSettingViewController:animated:)]) {
        [self.delegate setSettingViewController:option animated:animated];
    }
}

// OTP
- (void)otp:(NSString *)option
{
    if (!option || [[option trim] isEqualToString:@""]) {
        return;
    }
    
    NSArray *optionArr = [option componentsSeparatedByString:@"/"];
    
    if ([[optionArr objectAtIndex:0] isEqualToString:@"generator"]) {
        NSString *otpStr = [option stringByReplacingOccurrencesOfString:@"generator/" withString:@""];
        
        //전화기능 확인
        if ([[DEVICE_MODEL lowercaseString] indexOf:@"phone"] < 0) {
            return [Modules alert:NSLocalizedString(@"AlertTitle", nil) message:NSLocalizedString(@"SetupOtpNoConnectCall", nil)];
        }
        
        if ([self.delegate respondsToSelector:@selector(setOtp:)]) {
            [self.delegate setOtp:otpStr];
        }
    }
}

- (void)moviePopup:(NSString *)option
{
    NSArray *separatedOption = [option componentsSeparatedByString:@"/"];
    
    if (separatedOption && separatedOption.count == 2) {
        SBJSON *json = [[SBJSON alloc] init];
        
        NSDictionary *productInfo = [json objectWithString:URLDecode([separatedOption objectAtIndex:1])];
        
        if (!productInfo) {
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(openVideoPopupView:)]) {
            [self.delegate openVideoPopupView:productInfo];
        }
    }
}

- (void)share:(id)sender
{
    if (sender && [sender isKindOfClass:[NSDictionary class]]) {
        if ([sender objectForKey:@"request"]) {
            if ([self.delegate respondsToSelector:@selector(executeJavascript:)]) {
                [self.delegate executeJavascript:[sender objectForKey:@"request"]];
            }
        }
    }
}

- (void)history:(NSString *)option
{
    if (!option || [[option trim] isEqualToString:@""]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(webViewToolbarAction:)]) {
        [self.delegate webViewToolbarAction:option];
    }
}

- (void)addRecentKeyword:(NSString *)option
{
    // 연관검색어 최근검색어에 저장
    NSArray *separatedOption = [option componentsSeparatedByString:@"/"];
    
    if (separatedOption && separatedOption.count == 2) {
        SBJSON *json = [[SBJSON alloc] init];
        
        NSString *keyword = [json objectWithString:URLDecode([separatedOption objectAtIndex:1])];
        
        if (keyword) {
            [CPCommonInfo addRecentSearchItems:keyword];
        }
    }
}

- (void)eventAlarmSetting:(NSString *)option
{
    if ([option isMatchedByRegex:@"^add/"]) {
        NSString *notiString = [option stringByReplacingOccurrencesOfString:@"add/" withString:@""];
        notiString = [notiString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonData = [notiString JSONValue];
        
        if (jsonData) {
            if ([self.delegate respondsToSelector:@selector(eventAlarmAddAction:)]) {
                [self.delegate eventAlarmAddAction:jsonData];
            }
        }
    }
    else if ([option isMatchedByRegex:@"^remove/"]) {
        NSString *notiString = [option stringByReplacingOccurrencesOfString:@"remove/" withString:@""];
        notiString = [notiString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonData = [notiString JSONValue];
        
        if (jsonData) {
            if ([self.delegate respondsToSelector:@selector(eventAlarmRemoveAction:)]) {
                [self.delegate eventAlarmRemoveAction:jsonData];
            }
        }
    }
}

- (void)contact:(NSString *)option
{
    NSArray *separatedOption = [option componentsSeparatedByString:@"/"];
    
    if (separatedOption && separatedOption.count == 2) {
        SBJSON *json = [[SBJSON alloc] init];
        
        NSDictionary *contactInfo = [json objectWithString:URLDecode([separatedOption objectAtIndex:1])];
        
        if ([[separatedOption objectAtIndex:0] isEqualToString:@"open"]) {
            
            if ([self.delegate respondsToSelector:@selector(openContactViewController:)]) {
                [self.delegate openContactViewController:contactInfo];
            }
        }
        else if ([[separatedOption objectAtIndex:0] isEqualToString:@"close"]) {
            if ([self.delegate respondsToSelector:@selector(closeContactViewController)]) {
                [self.delegate closeContactViewController];
            }
        }
    }
}

@end
