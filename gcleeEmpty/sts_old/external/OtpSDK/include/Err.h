//
//  Err.h
//  ArcotOTPFrameWork
//
//  Created by developer on 8/3/09.
//  Copyright © 2012 CA All rights reserved.
//

#import <Foundation/Foundation.h>

// Default Errors (0-9)
/** An internal error has occurred **/
#define E_UNKNOWN 1
#define E_DATA_ERROR 3



// Storage Errors (10-19)
/** Error writing account. **/
#define E_STORE_WRITE 11
/** Error reading account. **/
#define E_STORE_READ 12
/** Error deleting account. **/
#define E_STORE_DELETE 13
/** Error accessing the storage. **/
#define E_STORE_ACCESS 14

#define E_CARD_EXPIRED 15

// I/O Errors (20-29)
#define E_NW_ERROR 20
#define E_NW_TIMEOUT 21
#define E_SERVER_FROM_ERROR 22
#define E_BAD_ACTIVATIONCODE 23
#define E_INVALID_CALLBACK 24

// Input Errors (30-39)
/** Invalid namespace. **/

#define E_BAD_NS 31
#define E_OTP_BAD_URL E_BAD_NS
#define E_WRONG_URL E_BAD_NS
/** Invalid XML. **/
#define E_BAD_XML 32
#define E_WRONG_XML E_BAD_XML
/** Invalid account identifier. **/
#define E_BAD_ID 33
#define E_WRONG_ID E_BAD_ID
/** Invalid account */
#define E_BAD_ACCOUNT 34
#define E_WRONG_ACCOUNT E_BAD_ACCOUNT
/** Invalid PIN **/
#define E_BAD_PIN 35
#define E_WRONG_PIN E_BAD_PIN
/** Invalid passcode algorithm. **/
#define E_BAD_ALGO 36
#define E_WRONG_ALGO E_BAD_ALGO
/** Invalid card string */
#define E_BAD_CS 37
#define E_WRONG_CS E_BAD_CS
/** Invalid card attribute */
#define E_BAD_ATTR 38
#define E_WRONG_KEY E_BAD_ATTR
#define E_WRONG_CONNECTION_OBJ 39

// Processing Errors (40-49)
/** Error processing device locking **/
#define E_OTP_PROC_DEVLOCK 43
/** The server threw an error **/
#define E_PROC_SERVER 41

/** Error processing account XML **/
#define E_PROC_XML 42

// HOTP/TOTP/CAP/DPA Input Errors (50-59)
/** Wrong TOTP time **/
#define E_TOTP_TIME 51
/** CAP wrong mode **/
#define E_CAP_MODE 52
/** AA missing, wrong length **/
#define E_CAP_AA 53
/** TDS missing, wrong size, wrong field length **/
#define E_CAP_TDS 54
/** TRCC missing, wrong length **/
#define E_CAP_TRCC 55
/** UN missing, wrong length **/
#define E_CAP_UN 56

// CAP Card Errors (70-79)
/** ATC missing, wrong length, at max value **/
#define E_CAP_ATC 71

/* FOLLOWING DECLARED PRIVATE AS NOT USED CURRENTLY */

// TOTP/HOTP Card Errors (60-69)

// CAP Card Errors (70-79)
/** AIP missing, wrong length **/
#define E_CAP_AIP 72
/** CID missing, wrong length **/
#define E_CAP_CID 73
/** CMK missing, wrong length **/
#define E_CAP_CMK 74
/** IAD missing, wrong length **/
#define E_CAP_IAD 75
/** IAF missing, wrong length **/
#define E_CAP_IAF 76
/** IPB missing, wrong length, does not map to data **/
#define E_CAP_IPB 77
/** PAN missing, wrong length **/
#define E_CAP_PAN 78
/** PSN missing, wrong length **/
#define E_CAP_PSN 79

// CAP Terminal Errors(80-89)
/** AO missing, wrong length **/
#define E_CAP_AO 81
/** CVR missing, wrong length **/
#define E_CAP_CVR 82
/** TD missing, wrong length **/
#define E_CAP_TD 83
/** TECC missing, wrong length **/
#define E_CAP_TECC 84
/** TT missing, wrong length **/
#define E_CAP_TT 85
/** TVR missing, wrong length **/
#define E_CAP_TVR 86

// Default error messages
#define S_UNKNOWN @"An internal error has occurred"
#define S_DATA_ERROR @"Error in data from server"

// Storage errors
#define S_STORE_WRITE @"Error writing account"
#define S_STORE_READ @"Error reading account"
#define S_STORE_DELETE @"Error deleting account"
#define S_STORE_ACCESS @"Error accessing storage"

// Input Errors
#define S_BAD_NS @"Invalid namespace"
#define S_BAD_XML @"Invalid XML"
#define S_BAD_ID @"Invalid account identifier"
#define S_BAD_ACCOUNT @"Invalid account"
#define S_BAD_PIN @"Invalid PIN"
#define S_BAD_ALGO @"Invalid passcode algorithm"
#define S_BAD_CS @"Invalid card string"
#define S_BAD_ATTR @"Invalid attribute"
#define S_CARD_EXPIRED @"Card Expired"
#define S_BAD_URL @"Invalid URL"
#define S_BAD_ACTIVATIONCODE @"Invalid activation code"
#define S_WRONG_CONNECTION_OBJ @"Invalid connection object"

// Processing Errors
#define S_PROC_DEVLOCK @"Error processing device locking"
#define S_PROC_SERVER @"The server threw an error"
#define S_PROC_XML @"Error processing account XML"


//IO error
#define S_NW_ERROR  @"Unexpected network error"
#define S_NW_TIMEOUT    @"Connection timeout error"
#define S_INVALID_CALLBACK  @"Invalid callback"


// HOTP/TOTP/CAP/DPA Input Errors
#define S_TOTP_TIME @"Wrong TOTP time"
#define S_CAP_MODE @"CAP wrong mode"
#define S_CAP_AA @"AA missing, wrong length"
#define S_CAP_TDS @"TDS missing, wrong size, wrong field length"
#define S_CAP_TRCC @"TRCC missing, wrong length"
#define S_CAP_UN @"UN missing, wrong length"

// CAP Card Errors
#define S_CAP_AIP @"AIP missing, wrong length"
#define S_CAP_ATC @"ATC missing, wrong length, at max value"
#define S_CAP_CID @"CID missing, wrong length"
#define S_CAP_CMK @"CMK missing, wrong length"
#define S_CAP_IAD @"IAD missing, wrong length"
#define S_CAP_IAF @"IAF missing, wrong length"
#define S_CAP_IPB @"IPB missing, wrong length, does not map to data"
#define S_CAP_PAN @"PAN missing, wrong length"
#define S_CAP_PSN @"PSN missing, wrong length"

// CAP Terminal Errors
#define S_CAP_AO @"AO missing, wrong length"
#define S_CAP_CVR @"CVR missing, wrong length"
#define S_CAP_TD @"TD missing, wrong length"
#define S_CAP_TECC @"TECC missing, wrong length"
#define S_CAP_TT @"TD missing, wrong length"
#define S_CAP_TVR @"TVR missing, wrong length"
#define S_SERVER_FROM_ERROR @"Error From Server"

#define Err AIDOTP_Err

@interface AIDOTP_Err : NSObject {
	
}

@end
