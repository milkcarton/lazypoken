#import <Cocoa/Cocoa.h>

// Macros for making NSErrors

/*
 Quick macros to make a simple error without much thinking
 First argument is int, second is NSString*.
 */
#define SSYMakeError(_code,_localizedDetails) [NSError errorWithLocalizedDetails:_localizedDetails code:_code sender:nil selector:NULL]
#define SSYMakeHTTPError(_code) [NSError errorWithHTTPStatusCode:_code sender:nil selector:NULL]

/*
 Adds sender class and method name to the localized description,
 as described in errorWithLocalizedDetails:code:sender:selector below.
 This is good for errors which are not often expected; if you have a 
 "Copy to Clipboard" button or "Email this error to Support"
 on your alert users may copy and send it to your support email.
 This macro will only compile within an Objective-C method because
 it needs the local variables _cmd and self.
 First argument is int, second is NSString*.
*/ 
#define SSYMakeGeekyError(_code,_localizedDetails) [NSError errorWithLocalizedDetails:_localizedDetails code:_code sender:self selector:_cmd]
#define SSYMakeGeekyHTTPError(_code) [NSError errorWithHTTPStatusCode:_code sender:self selector:_cmd]

// Macros for initializing and assigning an NSError** named error_p

/*
 These are useful within functions that get an argument (NSError**)error_p
 Use SSYInitErrorP to assign it to *error_p to nil at beginning of function.
 (This is optional.  Apple doesn't do it in their methods that take NSError**,
 but I don't like the idea of leaving it unassigned.)
 Then, use the other three to assign to *error_p if/when an error occurs.
 Benefit: All of these macros check that error_p != NULL before assigning.
*/
#define SSYAssignErrorP(_error) if (error_p != NULL) {*error_p = _error ;}
#define SSYInitErrorP SSYAssignErrorP(nil) ;
#define SSYMakeAssignErrorP(_code,_localizedDetails) SSYAssignErrorP(SSYMakeError(_code,_localizedDetails))
#define SSYMakeAssignGeekyErrorP(_code,_localizedDetails) SSYAssignErrorP(SSYMakeGeekyError(_code,_localizedDetails))



@interface NSError (Easy) 

/*
 If sender != nil, will add the following line to localized description:
     "   Object Class: <name of sender's class>"
 If selector != nil, will add the following line to localized description:
     "   Method: <name of method>"
 */ 
+ (NSError*)errorWithLocalizedDetails:(NSString*)localizedDetails
								 code:(int)code
							   sender:(id)sender 
							 selector:(SEL)selector ;

/*
 If sender != nil, will add the following line to localized description:
 "   Object Class: <name of sender's class>"
 If selector != nil, will add the following line to localized description:
 "   Method: <name of method>"
 */ 
+ (NSError*)errorWithHTTPStatusCode:(int)code
							 sender:(id)sender 
						   selector:(SEL)selector ;


#pragma mark * Methods for adding userInfo keys to errors already created

/*!
 @brief    Adds or changes a string value for string key NSLocalizedDescriptionKey to userInfo 
 of a copy of the receiver and returns the copy
 @details  This may be used to change an error's localized description.
 @param    newText  The string value to be added for key NSLocalizedDescriptionKey
 @result   A new NSError object, identical to the receiver except for the localized description
 */
- (NSError*)errorByAddingLocalizedDescription:(NSString*)newText ;

/*!
 @brief    Adds a string value for string key NSLocalizedFailureReasonErrorKey to userInfo 
 a copy of the receiver and returns the copy
 @param    newText  The string value to be added for key NSLocalizedFailureReasonErrorKey
 @result   A new NSError object, identical to the receiver except for the additional key/value pair in userInfo
 */
- (NSError*)errorByAddingLocalizedFailureReason:(NSString*)newText ;

/*!
 @brief    Adds a string value for string key NSLocalizedRecoverySuggestionErrorKey to userInfo of a copy of
 the receiver and returns the copy
 @param    newText  The string value to be added for key NSLocalizedRecoverySuggestionErrorKey
 @result   A new NSError object, identical to the receiver except for the additional key/value pair in userInfo
 */
- (NSError*)errorByAddingLocalizedRecoverySuggestion:(NSString*)newText ;

/*!
 @brief    Adds an array value for string key NSLocalizedRecoveryOptionsErrorKey to userInfo of a copy of
 the receiver and returns the copy
 @param    options  The array of strings which will be added for key NSLocalizedRecoverySuggestionErrorKey
 @result   A new NSError object, identical to the receiver except for the additional key/value pair in userInfo
 */
- (NSError*)errorByAddingLocalizedRecoveryOptions:(NSArray*)recoveryOptions ;
	
	/*!
 @brief    Adds an error for string key NSUnderlyingErrorKey to userInfo of a copy of 
 the receiver and returns the copy
 @param    underlyingError  The error value to be added for key NSUnderlyingErrorKey
 @result   A new NSError object, identical to the receiver except for the additional key/value pair in userInfo
 */
- (NSError*)errorByAddingUnderlyingError:(NSError*)underlyingError ;

/*!
 @brief    Adds object for key into the userInfo of a copy of the receiver and
 returns the copy
 @details  If the given key already has a value in the receiver's userInfo, then...
 If both existing and given values are NSStrings, the given is concatentated to the
 existing value with two newlines in between.  For other data types, the new value
 overwrites the existing value.
 @param    object  of the pair to be added
 @param    key  of the pair to be added
 @result   A new NSError object, identical to the receiver except for the additional key/value pair in userInfo
 */
- (NSError*)errorByAddingUserInfoObject:(id)object
								 forKey:(NSString*)key ;

/*!
 @brief    Adds keys and values explaining a given exception to the userInfo
 of a copy of the receiver and returns the copy.

 @param    exception  The exception whose info is to be added
 @result   A new NSError object, identical to the receiver except for the additional key/value pairs in userInfo
*/
- (NSError*)errorByAddingUnderlyingException:(NSException*)exception ;

@end
