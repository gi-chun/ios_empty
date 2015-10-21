//
//  Account.h
//  arcotOTP
//
//  Created by developer on 8/3/09.
//  Copyright © 2012 CA All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Attribute for <i>"is amount required?"</i>. For CAP/DPA only.
 * {@link #getAttribute getAttribute} returns TRUE or FALSE if this
 * attribute is present, else NULL".
 */
#define A_IAF_AA  @"amount"
/**
 Attribute for <i>"is currency required?"</i>. For CAP/DPA only.
 {@link #getAttribute getAttribute} returns TRUE or FALSE if this
 attribute is present, else NULL".
 */
#define A_IAF_TRCC @"currency"
/**
 Attribute for <i>"is challenge required?"</i>. For CAP/DPA only.
 {@link #getAttribute getAttribute} returns TRUE or FALSE if this
 attribute is present, else NULL".
 */
#define A_IAF_UN  @"challenge"


#define A_DLTA  @"DLTA"
#define A_RESETSUPPORT @"RSUP"
#define A_PROTOCOLVER @"PVER"
#define A_MPL @"MPL_"
#define A_UIDS @"UIDS"

#define A_PINTYPE_NUMERIC 1
#define A_PINTYPE_ALPHANUMERIC 0
#define A_PINTYPE @"PTYP"

/**
 This class encapsulates an ArcotOTP and any other meta-information associated
 with it. Some information is directly available through public member
 variables, while other information can be set/retrieved through the following
 methods:
 <ul>
 <li>{@link #setAttribute(String, String)}</li>
 <li>{@link #getAttribute(String)}</li>
 </ul>
 */

#define Account AIDOTP_Account

@interface AIDOTP_Account : NSObject {
	
	
	NSString *accountID;
	NSString *name;	
	NSString *algo;
	NSString *card;	
    NSString *logoUrl;
	NSString *ns;
	NSString *provUrl;
	NSDate *objCreationTime;
	double creationTime;

	NSDate *objLastUsed;
	double lastUsed;

	NSDate *objExpiryTime;
	double expiryTime;

	double	uses;
	NSString *org;	
	NSString *key;
	NSMutableDictionary *dtls;
    

}

@property(retain, nonatomic) NSMutableDictionary *dtls;
/**
 The account identifier of the ArcotOTP.
 */
@property(retain, nonatomic) NSString *accountID;
/**
 The organization of the ArcotOTP.
 */
@property(retain, nonatomic) NSString *org;
/**
 The namespace of the ArcotOTP. This is typically the domain from where
 the ArcotOTP was obtained (For example, <code>domain.com</code>).
 */
@property(retain, nonatomic) NSString *ns;
/**
 A user friendly name
 */
@property(retain, nonatomic) NSString *name;

@property(retain, nonatomic) NSString *algo;

/**
 Time of creation, in milliseconds since January 1, 1970, 00:00:00 GMT
 */
@property(retain, nonatomic) NSDate *objCreationTime;
@property(nonatomic) double creationTime;

/**
 Time of expiry, in milliseconds since January 1, 1970, 00:00:00 GMT
 */
@property(retain, nonatomic) NSDate *objExpiryTime;
@property(nonatomic) double expiryTime;
/**
 Time of last use, in milliseconds since January 1, 1970, 00:00:00 GMT
 */
@property(retain, nonatomic) NSDate *objLastUsed;
@property(nonatomic) double lastUsed;


@property(retain, nonatomic) NSString *key;

/**
 This is the OTP card certificate (card key) string for this account.
 */
@property(retain, nonatomic) NSString *card;



/**
    URL for the logo. Depending on the server side image servlet, the client can add the following sample parameters 
	to fetch the respective logo.
	
	e.g. "lt=1&d=40x40&fmt=png" - this string is appended by the cleint to fetch logo type 1 (listing logo) of size (d=40x40)
	width=40 and height=40. By default PNG format rendered from the server, if the client wants in specific format
	it will have to add 'fmt' parameter
 
    lt=2&d=320x80 - is used to render banner logo (logo type is 2) of size 320p width and 80p as height.
 
 */
@property(retain, nonatomic) NSString *logoUrl;

/**
 This is the URL used for communcating to server to fetch the provisioning xml data.
 */
@property(retain, nonatomic) NSString *provUrl;


/**
 This method updates the number of times account being used
 
 @param uses account usage counter.
 @returns void
 
 e.g.
	double d = [account1 getUses];
	[account1 setUses:(d++)];	
  
 */

- (void) setUses:(double)n;

/**
 This method returns the number of times account being used. 
 @returns account usage counter 
 */

- (double) getUses;

/**
 Gets the value to which the specified name is mapped, or NULL if this
 object contains no mapping for the name. This is also useful for prior
 determination of requirements such as whether amount/currency/challenge
 are necessary for CAP/DPA Mode 1. The attributes currently supported are
 {@link #A_IAF_AA}, {@link #A_IAF_TRCC} , {@link #A_IAF_UN}
  
 @param name
            the name whose associated value is to be returned
 @return the value to which the specified name is mapped, or NULL if this
          map contains no mapping for the name.
 @throws OTPException
              if name is an internally used reserved key word.
 */
- (NSString *) getAttribute:(NSString *)key;

/**
 Associates the specified value with the specified name.
  
 @param name
             name with which the specified value is to be associated
 @param val
             value to be associated with the specified name
 @throws OTPException
              if name is an internally used reserved key word.
 */

- (void) setAttribute:(NSString *)key value:(NSString *)valuestr;

/**
 *
 * Gets the unique identifier of this instance.
 *
 * @returns  unique storage identifier for this account
 *
 */
- (NSString *)getId; 


- (void) extractDetailsFromCardString:(NSString *)cs;
- (void) internalSetAttribute:(NSString *)pkey value:(NSString *)valuestr;

/**
 *
 * This method is to return the minimum PIN length required for camouflaging key.
 *
 * @returns  minimum PIN length.
 *
 */
- (int) getMinPINLength;

/**
 *
 * This method is to return  PIN type numeric or alphanumeric. This is read from server policy attribute.
 *
 * @returns  returns PIN Type 1 for Numeric, 0 for Alphanumeric.
 *
 */
- (int) getPINType;



@end
