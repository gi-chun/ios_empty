//
//  NetFunnelDefine.h
//  NetFUNNEL
//
//  Created by jacojang on 13. 6. 14..
//  Copyright (c) 2013년 jacojang. All rights reserved.
//

#ifndef NetFUNNEL_NetFunnelDefine_h
#define NetFUNNEL_NetFunnelDefine_h

// Version Info
#define NETFUNNEL_IOS_API_VER_MAJOR 2
#define NETFUNNEL_IOS_API_VER_MINOR 1
#define NETFUNNEL_IOS_API_VER_MICRO 0


#ifdef __IPHONE_6_0
#define ALIGN_CENTER NSTextAlignmentCenter
#define ALIGN_LEFT NSTextAlignmentLeft
#define ALIGN_RIGHT NSTextAlignmentRight
#else
#define ALIGN_CENTER UITextAlignmentCenter
#define ALIGN_LEFT UITextAlignmentLeft
#define ALIGN_RIGHT UITextAlignmentRight
#endif

// ---------------------------------------------------------------------
// Default Config Value
// ---------------------------------------------------------------------
/** 
	Default value for NetFunnel Server Hostname(or IP)      
 */
#define NETFUNNEL_DEF_HOST              @"test.netfunnel.co.kr"

/** 
	Default value for NetFunnel Server Port Number          
*/
#define NETFUNNEL_DEF_PORT              80

/** 
	Default value for network protocol ( http | https )     
*/
#define NETFUNNEL_DEF_PROTO             @"http"

/** 
	Default value for URI prefix                            
*/
#define NETFUNNEL_DEF_QUERY             @"ts.wseq"

/** 
	Default value for Service ID ( Server version 2 only )  
*/
#define NETFUNNEL_DEF_SERVICE_ID        @"service_1"

/** 
	Default value for Action ID ( Server version 2 only )   
*/
#define NETFUNNEL_DEF_ACTION_ID         @"act_1"

/** 
	Default connection timeout ( second )                   
*/
#define NETFUNNEL_DEF_CONN_TIMEOUT      3.0

/** 
	Default connection retry count                          
*/
#define NETFUNNEL_DEF_CONN_RETRY        1

/** 
	Default IPBlock wait time                               
*/
#define NETFUNNEL_DEF_IPBLOCK_WAIT_TIME 10.0
// ---------------------------------------------------------------------

#endif
