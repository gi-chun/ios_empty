//
//  NetFunnel.h
//  NetFUNNEL
//
//  Created by jacojang on 13. 6. 14..
//  Copyright (c) 2013년 jacojang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetFunnelResult.h"
#import "NetFunnelWaitView.h"

#define NetFUNNEL_VERSION "2.1.2"

// ---------------------------------------------------------------------
// NetFunnel
// ---------------------------------------------------------------------
typedef enum {
    NetFunnelRequestNone        = 0,	/**< Request Type None				*/
    NetFunnelRequestAction,				/**< Request Type Action - 5101		*/
    NetFunnelRequestActionCont,			/**< Request Type Continue - 5002	*/
    NetFunnelRequestAliveNotice,		/**< Request Type Alive	- 5003		*/
    NetFunnelRequestAliveNoticeCont,	/**< Request Type AliveCont - 5003	*/
    NetFunnelRequestComplete			/**< Request Type Complete - 5004	*/
} NetFunnelRequestType;


@protocol NetFunnelDelegate;

/**
	NetFunnel Client Main Class
 		NetFunnel Server와 통신을 담당한다.
		응답에대한 대기처리 및 Callback(Delegate)호출을 담당한다.
*/
@interface NetFunnel : NSObject <NSURLConnectionDelegate> {
    NSMutableData *_receivedData;
    id<NetFunnelDelegate> _delegate;
    UIView *_pview;
    NSDictionary *_localConfig;
    BOOL _runFlag;
    BOOL _isStop;
    NSLock *_statusLock;
    NSTimer *_timer;
    
    NSString *_nid;
    NetFunnelRequestType _rType;
    NSInteger _retryCount;
}

/**
	Contructor(생성자)
	
	@param delegate NetFUNNEL 서버 접속 실패시에 호출될 Callback함수집합
	@param view 대기창이 출력될 화면(UIView)
	@return id self
*/
-(id) initWithDelegate:(id<NetFunnelDelegate>)delegate pView:(UIView *)view;

/**
	Contructor(생성자)
	
	@param delegate NetFUNNEL 서버 접속 실패시에 호출될 Callback함수집합
	@param view 대기창이 출력될 화면(UIView)
	@param config 설정값 전달
	@return id self
*/
-(id) initWithDelegate:(id<NetFunnelDelegate>)delegate pView:(UIView *)view withConfig:(NSDictionary *)config;

// Local Function
-(id)getConfig:(NSString *)key;
-(id)getWaitView;
-(void)setGlobalConfig:(id)obj forKey:(NSString *)key;
-(BOOL)sendRequest:(NSString *)url;
//-(void)connectError;

-(void)getTidChkEnter;
-(void)chkEnter;
-(void)aliveNotice;
-(void)setComplete;

/**
	Global Config에 값을 추가하거나 수정 한다.

	@param obj 저장되거나 수정될 정보
	@param key 저장되거나 수정될 정보의 Key값
	@param nid 요청셋을 구분하기 위한 ID값
	@return null
*/
+(void)setGlobalConfigObject:(id)obj forKey:(NSString *)key withId:(NSString *)nid;

@end



/**
	사용자가 사용하게되는 Service Interface만 포함된 Category
*/
@interface NetFunnel (ServiceInterface)

/**
	대기중이거나 AliveNotice 중에 더이상 진행을 하고 싶지 않을때 호출되는 함수 이다.
        - 대기 창이 없어지고 명령이 종료되며 Stop Delegate를 호출해 준다.
*/
-(void)stop;

/**
	자원사용 허가를 NetFUNNEL 서버에 요청한다. 
		- 대기를 해야한다면 화면에 대기창을 출력하고 Request를 대기 시켜준다.
	
 @return 요청전송 성공여부 (응답결과값에 상관없이 요청 자체가 전송되면 True를 Return한다. - 응답결과에서 Error발생하면 Delegate를 통해서 전달된다.)
*/
-(BOOL)action;

/**
	자원사용 허가를 NetFUNNEL 서버에 요청한다. 
		- 대기를 해야한다면 화면에 대기창을 출력하고 Request를 대기 시켜준다.

    @param aid Action ID
	@return 요청전송 성공여부
*/
-(BOOL)actionWithAid:(NSString *)aid;

/**
	자원사용 허가를 NetFUNNEL 서버에 요청한다. 
		- 대기를 해야한다면 화면에 대기창을 출력하고 Request를 대기 시켜준다.

	@param sid Service ID
	@param aid Action ID
	@return 요청전송 성공여부
*/
-(BOOL)actionWithSid:(NSString *)sid aid:(NSString *)aid;

/**
	자원사용 허가를 NetFUNNEL 서버에 요청한다. 
		- 대기를 해야한다면 화면에 대기창을 출력하고 Request를 대기 시켜준다.

	@param nid 요청셋을 구분하기 위한 ID값 
	@param config Global Config값 Override
	@return 요청전송 성공여부
*/
-(BOOL)actionWithNid:(NSString *)nid config:(NSDictionary *)config;

/**
	자원 계속사용 요청

	@return 요청전송 성공여부
*/
-(BOOL)alive;

/**
	자원 계속사용 요청

	@param nid 요청셋을 구분하기 위한 ID값 
	@param config Global Config값 Override
	@return 요청전송 성공여부
*/
-(BOOL)aliveWithNid:(NSString *)nid config:(NSDictionary *)config;

/**
	자원사용 완료 요청
		- action 요청후 서비스 요청이 완료되면 꼭 완료요청을 전달해 줘야 한다.

	@return 요청전송 성공여부
*/
-(BOOL)complete;

/**
	자원사용 완료 요청
		- action 요청후 서비스 요청이 완료되면 꼭 완료요청을 전달해 줘야 한다.

	@param nid 요청셋을 구분하기 위한 ID값 
	@param config Global Config값 Override
	@return 요청전송 성공여부
*/
-(BOOL)completeWithNid:(NSString *)nid config:(NSDictionary *)config;

@end




/**
 요청에 대한 NetFUNNEL 응답에 따른 결과값을 전달하기 위한 Delegate
 */
@protocol NetFunnelDelegate <NSObject>

@required
/**
 Action요청 성공시에 호출되는 method (required)
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return NULL
 */
-(void)NetFunnelActionSuccess:(NSString *)nid withResult:(NetFunnelResult *)result;
/**
 Complete요청 성공시에 호출되는 method (required)
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return NULL
 */
-(void)NetFunnelCompleteSuccess:(NSString *)nid withResult:(NetFunnelResult *)result;

@optional
/**
 Action요청 - Continue 응답시에 호출되는 method (optional)
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return BOOL WaitView를 보여줄지 말지를 결정한다. NO로 전달되면 대기창이 보여지지 않는다.
 */
-(BOOL)NetFunnelActionContinue:(NSString *)nid withResult:(NetFunnelResult *)result;
/**
 Action요청 - Error 응답시에 호출되는 method (optional)
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return NULL
 */
-(void)NetFunnelActionError:(NSString *)nid withResult:(NetFunnelResult *)result;
/**
 Action요청 - Block 응답시에 호출되는 method (optional)
    - WebAdmin에서 Service나 Action 설정을 Block으로 선택한경우에 전달되는 응답이다.
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return BOOL Default 차단 메세지를 보여줄지 말지를 결정한다. NO로 전달되면 메세지가 보여지지 않는다.
 */
-(BOOL)NetFunnelActionBlock:(NSString *)nid withResult:(NetFunnelResult *)result;
/**
 Action요청 - IpBlock 응답시에 호출되는 method (optional)
    - Access Control에 의해서 차단된 사용자에게 전달되는 응답.
    - Default로 가상대기창을 출력한다.
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return BOOL Default 차단 메세지를 보여줄지 말지와 대기후 재시도를 할지를 결정한다. NO로 전달되면 메세지가 보여지지 않고 대기후 재시도도 하지 않는다.
 */
-(BOOL)NetFunnelActionIpBlock:(NSString *)nid withResult:(NetFunnelResult *)result;

/**
 Alive요청 - Continue 응답시에 호출되는 method (optional)
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return NULL
 */
-(void)NetFunnelAliveNoticeContinue:(NSString *)nid withResult:(NetFunnelResult *)result;
/**
 Alive요청 - Error 응답시에 호출되는 method (optional)
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return NULL
 */
-(void)NetFunnelAliveNoticeError:(NSString *)nid withResult:(NetFunnelResult *)result;
/**
 Alive요청 - Bloc 응답시에 호출되는 method (optional)
     - WebAdmin에서 Service나 Action 설정을 Block으로 선택한경우에 전달되는 응답이다.
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return NULL
 */
-(void)NetFunnelAliveNoticeBlock:(NSString *)nid withResult:(NetFunnelResult *)result;
/**
 Action요청 - IpBlock 응답시에 호출되는 method (optional)
 - Access Control에 의해서 차단된 사용자에게 전달되는 응답.
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return NULL
 */
-(void)NetFunnelAliveNoticeIpBlock:(NSString *)nid withResult:(NetFunnelResult *)result;

/**
 Complete요청 - Error 응답시에 호출되는 method (optional)
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @param result NetFUNNEL 호출 결과 값
 @return NULL
 */
-(void)NetFunnelCompleteError:(NSString *)nid withResult:(NetFunnelResult *)result;

/**
 Stop 요청이 호출되었을때 실행되는 method (optional)
 @param nid 요청구분을 위해 요청시에 전달했던 요청ID값
 @return NULL
 */
-(void)NetFunnelStop:(NSString *)nid;

@end

