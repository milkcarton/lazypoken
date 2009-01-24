#import "NSError+Easy.h"

@implementation NSError (Easy) 

+ (NSError*)errorWithLocalizedDetails:(NSString*)localizedDetails
								 code:(int)code
							   sender:(id)sender
							 selector:(SEL)selector {
	if (localizedDetails == nil) {
		localizedDetails = @"unspecified" ;
	}
	if (sender != nil) {
		localizedDetails = [localizedDetails stringByAppendingFormat:@"\n   Object Class: %@",
							NSStringFromClass([sender class])] ;

	}
	if (selector != NULL) {
		localizedDetails = [localizedDetails stringByAppendingFormat:@"\n   Method: %@",
							NSStringFromSelector(selector)] ;
	}
	NSDictionary* userInfo = [NSDictionary dictionaryWithObject:localizedDetails
														 forKey:NSLocalizedDescriptionKey] ;
	NSString* domain = [[NSBundle mainBundle] bundleIdentifier] ;
	return [NSError errorWithDomain:domain
							   code:code
						   userInfo:userInfo] ;
}

+ (NSError*)errorWithHTTPStatusCode:(int)code
							 sender:(id)sender 
						   selector:(SEL)selector {
	NSString* localizedDetails = [NSString stringWithFormat:@"HTTP Status Code: %d %@",
								  code,
								  [NSHTTPURLResponse localizedStringForStatusCode:code]] ;
	return [self errorWithLocalizedDetails:localizedDetails
									  code:code
									sender:sender
								  selector:selector] ;
}

- (NSError*)errorByAddingUserInfoObject:(id)object
								 forKey:(NSString*)key {
	NSMutableDictionary* userInfo = [[self userInfo] mutableCopy] ;
	if (object != nil) {
		if (userInfo) {
			id existingObject = [userInfo objectForKey:key] ;
			if (
				[existingObject isKindOfClass:[NSString class]]
				&& [object isKindOfClass:[NSString class]]) {
				object = [NSString stringWithFormat:@"%@\n\n%@",
									 existingObject, object] ;
			}
		}
		else {
			userInfo = [[NSMutableDictionary alloc] initWithCapacity:1] ;
		}
		[userInfo setObject:object forKey:key] ;
	}
	int code = [self code] ;
	NSString* domain = [self domain] ;
	NSError* newError = [NSError errorWithDomain:domain
											code:code
										userInfo:userInfo] ;
	[userInfo release] ;
	return newError ;
}

- (NSError*)errorByAddingLocalizedDescription:(NSString*)newText {
	return [self errorByAddingUserInfoObject:newText
									  forKey:NSLocalizedDescriptionKey] ;
}

- (NSError*)errorByAddingLocalizedFailureReason:(NSString*)newText {
	return [self errorByAddingUserInfoObject:newText
									  forKey:NSLocalizedFailureReasonErrorKey] ;
}

- (NSError*)errorByAddingLocalizedRecoverySuggestion:(NSString*)newText {
	return [self errorByAddingUserInfoObject:newText
									  forKey:NSLocalizedRecoverySuggestionErrorKey] ;
}

- (NSError*)errorByAddingLocalizedRecoveryOptions:(NSArray*)recoveryOptions {
	return [self errorByAddingUserInfoObject:recoveryOptions
									  forKey:NSLocalizedRecoveryOptionsErrorKey] ;
}

- (NSError*)errorByAddingUnderlyingError:(NSError*)underlyingError {
	return [self errorByAddingUserInfoObject:underlyingError
									  forKey:NSUnderlyingErrorKey] ;
}

- (NSError*)errorByAddingUnderlyingException:(NSException*)exception {
	NSMutableDictionary* additions = [NSMutableDictionary dictionary] ;
	id value ;
	
	value = [exception name] ;
	if (value) {
		[additions setObject:value
					  forKey:@"Name"] ;
	}
	
	value = [exception reason] ;
	if (value) {
		[additions setObject:value
					  forKey:@"Reason"] ;
	}

	value = [exception userInfo] ;
	if (value) {
		[additions setObject:value
					  forKey:@"User Info"] ;
	}
	
	return [self errorByAddingUserInfoObject:additions
									  forKey:@"Underlying Exception"] ;
}

@end