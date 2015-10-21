//
//  OTP.h
//  arcotOTP
//  
//  OTP is a client OTP API to provision, generate and manage the otp accounts.
//  This API implements EMV and HOTP and TOTP algorithms to generate the respective OTPs. 
//
//  Created by developer on 8/3/09.
//  Copyright © 2012 CA All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Account.h"
#import "Store.h"
#import "DeviceLock.h"
#import "IArcotAppCallback.h"

@class IArcotAppCallback;


#define PROVISION_REQUEST		@"provisioning"
#define SYNC_REQUEST			@"softsync"
#define GET_CHELLENGE_REQUEST	@"getchallenge"
#define RENEW_REQUEST			@"renew"
#define AUTH_REQUEST			@"auth"
#define NOAUTHPROV_REQUEST		@"noauthprov"
#define UPLOADKEY_REQUEST		@"uploadkey"
#define STATE_PINREQUIRED        @"PINREQUIRED"
#define STATE_DONE              @"DONE"
#define PARAM_ERR_CODE                @"ERR_CODE"
#define PARAM_ERR_MSG                 @"ERR_MSG"
#define STATUS_SUCCESS          @"success"
#define STATUS_FAIL             @"fail"
#define STATUS_WARNING          @"warning"
#define PARAM_PINVALUE          @"PINVALUE"
#define PARAM_XML               @"XML"
#define PARAM_DLTA               @"DLTA"
#define PARAM_MINPINLENGTH       @"MINPINLENGTH"
#define PARAM_STATE              @"STATE"
#define PARAM_PLATFORM_MSG         @"PLATFORM_MSG"
#define PARAM_URL               @"URL"
#define PARAM_ACCOUNTID         @"ACCOUNTID"
#define PARAM_ACTCODE           @"ACTCODE"
#define PARAM_ACCOUNT_KEY       @"ACCOUNT_KEY"
#define PARAM_ACCOUNT_OBJ       @"ACCOUNT_OBJ"
#define PARAM_CONN_OBJECT       @"CONN_OBJECT"
#define PARAM_PINTYPE           @"PINTYPE"
#define PARAM_ROAM_FLAG         @"ROAM"

#define DEFAULT_PIN				@"0"

#define RESPONSE				@"RESPONSE"
#define CHALLENGE				@"CHALLENGE"
#define CHALLENGEID				@"CHALLENGEID"
#define REQUESTTYPE				@"REQUESTTYPE"
#define SYNCVALUE				@"SYNCVALUE"
#define ROAMFLAG				@"roam"
#define UID                     @"uid"

//Reserved key definitions

#define kChallenge					@"challenge"
#define kAmount						@"amount"
#define kCurrency					@"currency"
#define kSIGN						@"sign"
#define kIDENTIFY					@"identify"
#define kRESPOND					@"respond"
#define kTRANSSIGN					@"tds"
#define kData						@"data"
#define  PAN_TYPE_VISA				@"VISA"
#define  PAN_TYPE_MASTERCARD		@"MC"
#define	 PAN_TYPE_HOTP				@"HOTP"
#define	 PAN_TYPE_TOTP				@"TOTP"
#define  CAP                        PAN_TYPE_MASTERCARD
#define  DPA                        PAN_TYPE_VISA
#define  HOTP                       PAN_TYPE_HOTP
#define  TOTP                       PAN_TYPE_TOTP

#define kMode						@"mode"

#define  kEmvType					@"EMV"
#define  kOtpType					@"OTP"
#define  EMV                        kEmvType



// Modes
/** 
 Parameter value to specify Mode1 
 */
#define M_1 kSIGN
/** 
 Parameter value to specify Mode2 
 */
#define M_2 kIDENTIFY
/** 
 Parameter value to specify Mode3 
 */
#define M_3 kRESPOND
/** 
 Parameter value to specify Mode2TDS 
 */
#define M_2_TDS kTRANSSIGN

// Keys for properties
/** 
 TOTP: Parameter key to specify time 
 **/
#define P_TIME @"time"

// Keys for properties
/** 
 TOTP: Parameter key to specify time 
 **/
#define P_ATVALUE @"atvalue"
#define P_VALUE P_ATVALUE


/** 
 CAP/DPA: Parameter key to specify mode 
 */
#define P_MODE kMode

/**
 CAP/DPA: Parameter key prefix to specify data. Actual keys are of the
 form "data0", "data1",....,"data9"
 */
#define P_DATA kData

/** 
 DPA/CAP: Parameter key to specify challenge 
 */
#define P_UN kChallenge
/** 
 CAP/DPA: Parameter key to specify amount 
 */
#define P_AA kAmount

/** 
 CAP/DPA: Parameter key to specify currency
 */
#define P_TRCC kCurrency

#define A_TIMELEFT @"TIMELEFT"

/**
 This class provides APIs for storage/removal/retrieval of ArcotOTP accounts,
 and, passcode generation using an account. 
 <p>
 It supports following passcode generation algorithms:
 <ul>
 <li>HOTP</li>
 <li>TOTP</li>
 <li>MasterCard CAP</li>
 <li>Visa DPA</li>
 </ul>
  
  <h3>General Usage</h3>
  
  <pre>
  NSMutableDictionary params = [[NSMutableDictionary alloc] init];
  //xml, ns are provided by the issuer
  Account acc = otpobj.provisionAccount(xml, ns);
  //pin is provided by the user.
  NSString *otp = api.generateOTP(acc.getId(), pin, params);
  </pre>
  
  <h3>HOTP/TOTP Usage</h3>
  With HOTP/TOTP, extra data can be specified as additional parameter to the
  {@link #generateOTP generateOTP} method, the key for which is {@link #P_DATA}.
  <p>
  <u>Example</u>
  
  <pre>
  NSMutableDictionary params = [[NSMutableDictionary alloc] init];
  add (API.P_DATA, &quot;Street City Country Zip&quot;) to params.
  NSString *otp = api.generateOTP(acc.getId(), &quot;1234&quot;, params);
  </pre>
  
  <h3>TOTP Usage</h3>
  With TOTP, time can given as additional parameter to the {@link #generateOTP
  generateOTP} method, the key for which is {@link #P_TIME}. The value of time
  must be a long value (msecs). If not given, then the current system time is used.
  <p>
  <u>Example</u>
  
  <pre>
  NSMutableDictionary params = [[NSMutableDictionary alloc] init];
  add (P_TIME, &quot;123456789&quot;) to params
  NSString *otp = api.generateOTP(acc.getId(), &quot;1234&quot;, params);
  </pre>
  
  <h3>CAP/DPA Usage</h3>
  With CAP/DPA, passcode can be generated in four modes, some of which may
  require extra data. The mode and extra data can be specified as additional
  parameters to the {@link #generateOTP generateOTP} method.
  <p>
  The mode is specified using the {@link #P_MODE} key, possible values for
  which are {@link #M_1}, {@link #M_2},{@link #M_3},{@link #M_2_TDS}
  <p>
  Depending upon the mode, extra data can be specified. This is described
  below:
  
  <table border="1">
  <tr>
  <td>Mode 1</td>
  <td>{@link #P_UN}, {@link #P_AA}, {@link #P_TRCC}</td>
  </tr>
  <tr>
  <td>Mode 2</td>
  <td>No extra data is rquired</td>
  </tr>
  <tr>
  <td>Mode 3</td>
  <td> {@link #P_UN}</td>
  </tr>
  <tr>
  <td>Mode 2 TDS</td>
  <td>Upto 10 entries are permitted. The key for each entry is of the form
  {@link #P_DATA}<i>d</i>, where <i>d</i> is in [0-9]</td>
  </tr>
  </table>
  
  <p>
  <u>Mode 1 example</u>
  
  <pre>
  NSMutableDictionary params = [[NSMutableDictionary alloc] init];
  params.put(P_MODE, M_1);
  params.put(P_AA, &quot;123.45&quot;);
  params.put(P_UN, &quot;0123456789&quot;);
  String otp = api.generateOTP(acc.getId(), pin, params);
  </pre>
  
  <u>Mode 2 TDS example</u>
  
  <pre>
  NSMutableDictionary params = [[NSMutableDictionary alloc] init];
  add (P_MODE, M_2_TDS) to params,
  add (P_DATA + &quot;0&quot;, &quot;123&quot;) to params,
  add (P_DATA + &quot;1&quot;, &quot;456&quot;) to params,
  add (P_DATA + &quot;2&quot;, &quot;789&quot;) to params,
  NSString *otp = [self generateOTP:acc.getId() pin:pin params:params]
  </pre>
  <p>
  
  <u>Properties required</u> <br>
  In case of Mode 1, the Issuer Authentication Flags (IAF) in the account's
  card specifies what parameters are required for passcode generation. This can
  be determined in advance using the  method.
  
  @see OTPException
  @see Account
  @see Err
 */
#define OTP AID_OTP




@interface AID_OTP : NSObject {
	Store *db;
	DeviceLock *devlock;
	NSString *totpInterval;
    NSString *cookieStr;
}

@property (nonatomic,retain) Store *db;
@property (nonatomic,retain) DeviceLock *devlock;
@property (nonatomic,retain) NSString *totpInterval;
@property (nonatomic,retain) NSString *cookieStr;




/**
	This method must be  used to initialize the class with custom storage class and device locker. 
    If this method is not invoked, OTP class uses  built-in sqllite database
	storage and built-in device locker implementation.  
 
	@param storage is a custom Storage implementation
	@param devicelock is a custom device locking mechanism. The DeviceLock implemention is used during the camouflaging the OTP account key.
	@returns id is the initialized object.

	e.g.  
		Store *custstorage = [[Store alloc] init];
		DeviceLock *customlock = [[DeviceLock alloc] init];
 
		OTP *otpobj = [[OTP alloc] initWithStorageType:custstorage devicelock:customlock];
 
 
 */
- (id) initWithStorageType:(Store *)storage devicelock:(DeviceLock *)devicelock;
- (id) initWithStorageType:(Store *)storage devicelock:(DeviceLock *)devicelock callback:(IArcotAppCallback *)cb;

/**
	provisionAccount stores the account information into the database. 
  
	@param data	 is the account information in xml format.
	@param provUrl	is a url used for connecting to the provisoning server using http method.
	@param code	 is provisioning authorization/activation code.
	@param newpin is new PIN for camouflaging the account on local device.
    @returns void
 
	This method re-camouflages if actCode (activation code) and newpin (user entered new pin) are passed as 
    not NULL values. If the actCode is nil and pin is not nil, this method will camouflage using the new 
    entered pin and store it in the database. 
	if actCode is not null and pin is null, this method throws exception.
 
	e.g.
	[otpobj provisionAccount:xmldata provUrl:@"https://otp.arcot.com/otp/cprov" code:@"223322" newpin:@"7682"];
 
 
 */
- (Account *) provisionAccount:(NSString *)data  provUrl:(NSString *)provUrl code:(NSString *)actCode newpin:(NSString *)pinVal;
- (Account *) provisionAccount:(NSString *)data  provUrl:(NSString *)provUrl code:(NSString *)actCode secpin:(NSMutableString *)pinVal;

/**
   This retrieves the OTP account for the given unique storage key and generates OTP. OTP is combination of numbers 
   and alphabets depeding on the server side algorithm configuration. The maximum number of digits in the OTP number 
   generated is controlled at server side configuration. 
 
	@param key	is unique key to identify the record, it's obtained from Account class.
	@param pin  PIN to generate OTP
	@param props is a dictionary of properties to be used for generating OTP.
	@returns otp  is generated number.

	e.g.
		NString *otpnumber = [otpobj generateOTP:@"otp.arcot.com::user1" pin:@"7682" props:nil]; 
 
 
	For Master Card, please populate props dictionary with the mode and dependent values. 
 
		mode="sign":
			populate mode="sign", challenge=<challenge from UI>, amount=<amount from UI>
 
		mode="identify":
			populate mode="identify"
 
		mode="respond"
			populate mode="respond", challenge=<challenge from UI>
 
		mode="tds"
			populate data=<array of 10 data UI element values in the same order as entered from 1..10>		
 
 */
- (NSString *)generateOTP:(NSString *)key pin:(NSString *)pin props:(NSDictionary *)propdic;

- (NSString *)generateOTP:(NSString *)key secpin:(NSMutableString *)pin props:(NSMutableDictionary *)propdic;
+ (BOOL) isDomainMatches:(NSString *)domainStr url:(NSString *)urlstr;
/**
   This method can be used to generate a otp for the given Account object.
 
	@param account	is an OTP account
	@param pin  is PIN to generate OTP
	@param props dictionary of properties to be used for generating OTP.
	@returns otp  is generated number.

	e.g.
	NString *otpnumber = [otpobj generateOTPForAccount:account1 pin:@"7682" props:nil];
 
 
 */
- (NSString *)generateOTPForAccount:(Account *)account pin:(NSString *)pin props:(NSDictionary *)propdic;
- (NSString *)generateOTPForAccount:(Account *)account secpin:(NSMutableString *)pin props:(NSMutableDictionary *)propdic;

/**
	This method is used to change the PIN an account on the device.

	@param key  is unique account key
	@param oldpin old PIN
	@param newpin New PIN to be used for generating OTP
	@returns void
 
	e.g.
		[otpobj resetPIN:@"otp.arcot.com::user1" oldpin:@"7682" newpin:@"3245"];
 
 */
- (void) resetPin:(NSString *)key oldpin:(NSString *)oldpin  newpin:(NSString *)newpin;
- (void) resetPin:(NSString *)key oldsecpin:(NSMutableString *)oldpin  newsecpin:(NSMutableString *)newpin; 


/**
	This method deletes the account from the device.
 
 
	@param key is unique key to identify the record, it's obtained from Account class.
	@returns void

	e.g.
		[otpobj deleteAccount:@"arcot.com::user1"];
 
 */
- (void) deleteAccount:(NSString *)key;

/**
	This method saves the account onto device storage.
 
	@param account  is an OTP account
	@returns void

	e.g.
	[otpobj saveAccount:account1];
 
 */
- (void) saveAccount:(Account *)account;

/**
  This method finds the account information for the given key
 
 
	@param key is unique key to identify the record, it's obtained from Account class.
	@returns otp Account object.
 

 */
- (Account *) getAccount:(NSString *)key;

/**
   This method returns an array of all accounts found on the device's storage system.
   
	@param nothing
	@returns array of Account objects 

 
 */
- (NSMutableArray *) getAllAccounts;

/**
 * This method returns version of the library.
 */
- (NSString *) getVersion;
- (void) setDeviceLock:(DeviceLock *)lock;


//ArcotOTP 2.1 changes
- (void) provisionRequest:(NSMutableDictionary *)args;
- (void) syncRequest:(NSMutableDictionary *)args;
- (void) setCallback:(IArcotAppCallback *)callback;
- (void) resync:(Account *)acc value:(NSString *)synvcalue;
- (NSString *) getRoamingKeys:(Account *)acc;




@end
