//
//  NetFunnelResult.h
//  NetFUNNEL
//
//  Created by jacojang on 13. 6. 14..
//  Copyright (c) 2013년 jacojang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 응답 결과 값을 저장하는 Class
 */
@interface NetFunnelResult : NSObject {
    /**
     응답코드
        - 200     : Success
        - 201/202 : Continue
        - 300     : Bypass
        - 301     : Block
        - 302     : IpBlock
        - 303     : Express Member
        - > 500   : Error
     */
    NSInteger _retcode;
    /**
     응답 Data 저장
     */
    NSMutableDictionary *_data;
}
@property NSInteger _retcode;
@property NSMutableDictionary *_data;

/**
 Constructor
 @param data 응답으로 전달받은 문자열
 @return id self
 */
-(id)initWithData:(NSString *)data;
/**
 Data 추가 및 수정
 @param obj 저장될 객체
 @param key 저장될 객체의 key
 @return NULL
 */
-(void)setValue:(id)obj forKey:(NSString *)key;
/**
 Data 가져오기
 @param key 가져오고자 하는 Data의 key값
 @return id 원하는 Data객체
 */
-(id)getValue:(NSString *)key;
@end
