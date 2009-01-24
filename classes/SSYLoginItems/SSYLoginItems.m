#import "SSYLoginItems.h"
#import "NSError+Easy.h"

/*
 Unlike [object release], which is a no-op if object is nil,
 CFRelease(itemRef) will cause a crash if itemRef is NULL.
 So, we use this idea, same as CFQRelease() in MoreCFQ.
 */
static void CFSafeRelease(CFTypeRef item) {
	if (item != NULL) {
		CFRelease(item) ;
	}
}

@implementation SSYLoginItems

/*
 Note "create" in name.  Invoker must release the result.
 */
+ (BOOL)createLoginItemsList:(LSSharedFileListRef*)list_p 
					   error:(NSError**)error_p {
	SSYInitErrorP
	BOOL ok = NO ;
	
	if (list_p != NULL) {
		ok = YES ;
		*list_p = LSSharedFileListCreate(
										 kCFAllocatorDefault,
										 kLSSharedFileListSessionLoginItems,
										 NULL) ;
		if (*list_p == NULL) {
			SSYMakeAssignGeekyErrorP(reqFailed, @"LSSharedFileListCreate returned NULL")
			ok = NO ;
		}
	}
	
	return ok ;
}

/*
 Note "copy" in name.  Invoker must release the result.
*/
+ (BOOL)copySnapshotOfLoginItems:(CFArrayRef*)snapshot_p 
						   error:(NSError**)error_p {
	SSYInitErrorP
	
	LSSharedFileListRef list ;
	BOOL ok = [self createLoginItemsList:&list
								   error:error_p] ;
	if (!ok) {
		// error_p has already been assigned
		goto end ;
	}
	
	if (snapshot_p != NULL) {
		UInt32 seed ;
		*snapshot_p = LSSharedFileListCopySnapshot(
												 list,
												 &seed) ;
		//NSLog(@"Snapshot seed = %x (What the hell is this used for?)", seed) ;
	}
	
end:
	CFSafeRelease(list) ;

	return ok ;
}

/*
 If *ref_p is found and returned, it will be retained.
 Invoker must release it.
 (This is because CF does not feature autorelease.  Before
 I started retaining it, I was getting crashes.)
 */
+ (BOOL)loginItemWithURL:(NSURL*)url
					 ref:(LSSharedFileListItemRef*)ref_p
				   error:(NSError**)error_p {
	SSYInitErrorP
	BOOL ok ;
	
	LSSharedFileListItemRef targetItem = NULL ;
	if (url == nil) {
		goto end ;
	}
	
	CFArrayRef snapshot;
	ok = [self copySnapshotOfLoginItems:&snapshot
								  error:error_p] ;
	if (!ok) {
		// error_p has already been assigned
		goto end ;
	}
	
	OSStatus status = noErr ;
	for (id item in (NSArray*)snapshot) {
		NSURL* aURL ;
		BOOL breakAfterCleanup = NO ;
		status = LSSharedFileListItemResolve(
											  (LSSharedFileListItemRef)item,
											  0,
											  (CFURLRef*)&aURL,
											  NULL) ;
		if (status == noErr) {
			if ([aURL isEqual:url]) {
				CFRetain(item) ;
				targetItem = (LSSharedFileListItemRef)item ;
				breakAfterCleanup = YES ;
			}
		}
		else {
			breakAfterCleanup = YES ;
		}
		
		// Documentation says to release this (maybe because CF does not feature autorelease?)
		CFSafeRelease(aURL) ;
		
		if (breakAfterCleanup) {
			break ;
		}
	}
	
	if (status != noErr) {
		NSString* msg = [NSString stringWithFormat:@"LSSharedFileListItemResolve returned error for url '%@'.  ref_p=%p",
						 url,
						 ref_p] ;
		SSYMakeAssignGeekyErrorP(status, msg)
		ok = NO ;
		goto end ;
	}

end:
	CFSafeRelease(snapshot) ;
			
	if (ref_p != NULL) {
		*ref_p = (LSSharedFileListItemRef)targetItem ;
	}
	
	return (ok) ;
}

+ (BOOL)isURL:(NSURL*)url
	loginItem:(NSNumber**)loginItem_p
	   hidden:(NSNumber**)hidden_p
		error:(NSError**)error_p {
	SSYInitErrorP
	BOOL answer = NO ;
	if (url == nil) {
		answer = NO ;
		goto end ;
	}
	
	LSSharedFileListItemRef targetItem = NULL ;
	
	BOOL ok = [self loginItemWithURL:url
								 ref:&targetItem
							   error:error_p] ;
	if (!ok) {
		// error_p has already been assigned
		goto end ;
	}
	
	BOOL isLoginItem = (targetItem != nil) ;
	
	if (loginItem_p != NULL) {
		*loginItem_p = [NSNumber numberWithBool:isLoginItem] ;
	}

	if (isLoginItem) {
		if (hidden_p != NULL) {
			*hidden_p = (NSNumber*)LSSharedFileListItemCopyProperty(
																	(LSSharedFileListItemRef)targetItem,
																	kLSSharedFileListItemHidden) ;
			// Documentation says to release this
			CFSafeRelease(*hidden_p) ;
		}
	}
	
end:
	if (*error_p) {
		*error_p = [*error_p errorByAddingUserInfoObject:NSStringFromSelector(_cmd)
												  forKey:@"Next_caller_down"] ;
		*error_p = [*error_p errorByAddingUserInfoObject:url
												  forKey:@"arg_url"] ;
	}
	CFSafeRelease(targetItem) ;
	return ok ;
}

+ (BOOL)addLoginURL:(NSURL*)url
			 hidden:(NSNumber*)hidden
			  error:(NSError**)error_p {
	SSYInitErrorP
	NSDictionary* propsToSet = [NSDictionary dictionaryWithObject:hidden
														   forKey:(id)kLSSharedFileListItemHidden] ;
	LSSharedFileListRef loginItems ;
	BOOL ok = [self createLoginItemsList:&loginItems
								   error:error_p] ;
	
	if (!ok) {
		// error_p has already been assigned
		goto end ;
	}
	
	LSSharedFileListItemRef item ;
	item = LSSharedFileListInsertItemURL(
										 loginItems,
										 kLSSharedFileListItemLast,
										 NULL,
										 NULL,
										 (CFURLRef)url,
										 (CFDictionaryRef)propsToSet,
										 NULL) ;
	
	if (item == NULL) {
		SSYMakeAssignGeekyErrorP(writErr, @"LSSharedFileListInsertItemURL returned error")
	}
	else {
		// Documentation for LSSharedFileListInsertItemURL says I should release
		// (Maybe because CF does not feature autorelease?)
		CFRelease(item) ;
	}

end:
	CFSafeRelease(loginItems) ;
	
	return ok ;
}

+ (BOOL)removeLoginItemRef:(LSSharedFileListItemRef)item
					 error:(NSError**)error_p {
	SSYInitErrorP
	BOOL ok ;
	
	LSSharedFileListRef loginItems ;
	ok = [self createLoginItemsList:&loginItems
							  error:error_p] ;
	if (!ok) {
		// error_p has already been assigned
		goto end ;
	}
	
	OSStatus status ;
	status = LSSharedFileListItemRemove(
										loginItems,
										item) ;
	if (status != noErr) {
		SSYMakeAssignGeekyErrorP(status, @"LSSharedFileListItemRemove returned error")
		ok = NO ;
		goto end ;
	}
	
end:
	CFSafeRelease(loginItems) ;
	
	return (ok) ;
}

+ (BOOL)removeLoginURL:(NSURL*)url
				 error:(NSError**)error_p {
	SSYInitErrorP

	LSSharedFileListItemRef item = NULL ;
	BOOL ok = [self loginItemWithURL:url
								ref:&item
							  error:error_p] ;

	if (ok && (item != NULL)) {
		[self removeLoginItemRef:item
						   error:error_p] ;
	}
	else {
		// error_p has already been assigned
		// We are already at the end goto end ;
	}
	
	CFSafeRelease(item) ;
	
	if (*error_p) {
		*error_p = [*error_p errorByAddingUserInfoObject:NSStringFromSelector(_cmd)
												  forKey:@"Next_caller_down"] ;
		*error_p = [*error_p errorByAddingUserInfoObject:url
												  forKey:@"arg_url"] ;
	}
	return ok ;	
}

/*
 If dontDeletePath is nil, will delete all of current user's
 login items with name
 */
+ (BOOL)loginItemsWithAppName:(NSString*)name
					notInPath:(NSString*)dontDeletePath
						 refs:(NSArray**)refs_p
						error:(NSError**)error_p {
	SSYInitErrorP
	
	CFArrayRef snapshot;
	BOOL ok = [self copySnapshotOfLoginItems:&snapshot
									   error:error_p] ;
	if (!ok) {
		// error_p has already been assigned
		goto end ;
	}
		
	OSStatus status = noErr ;
	name = [name stringByDeletingPathExtension] ;
	NSMutableArray* mutableRefs = [NSMutableArray array] ;
	for (id item in (NSArray*)snapshot) {
		NSURL* aURL ;
		BOOL breakAfterCleanup = NO ;
		status = LSSharedFileListItemResolve(
											  (LSSharedFileListItemRef)item,
											  0,
											  (CFURLRef*)&aURL,
											  NULL) ;
		if (status == noErr) {
			NSString* aPath = [aURL path]  ;
			if ((dontDeletePath == nil) || ![dontDeletePath isEqualToString:aPath]) {
				NSString* aName = [[aPath lastPathComponent] stringByDeletingPathExtension]  ;
				if ([aName isEqual:name]) {
					[mutableRefs addObject:(id)item] ;
				}
			}
		}
		else {
			breakAfterCleanup = YES ;
		}

		// Documentation says to release this
		// (Maybe because CF does not feature autorelease?)
		CFSafeRelease(aURL) ;
		
		if (breakAfterCleanup) {
			break ;
		}
	}
	
	if (status != noErr) {
		SSYMakeAssignGeekyErrorP(status, @"LSSharedFileListItemResolve returned error")
		ok = NO ;
		goto end ;
	}
	
end:
	CFSafeRelease(snapshot) ;
	
	if (refs_p != NULL) {
		*refs_p = [NSArray arrayWithArray:mutableRefs] ;
	}
	
	return (ok) ;
}


+ (enum SSYSharedFileListResult)synchronizeLoginItemPath:(NSString*)path
									   shouldBeLoginItem:(BOOL)shouldBeLoginItem
											   setHidden:(BOOL)setHidden 
												   error:(NSError**)error_p {
	SSYInitErrorP
	enum SSYSharedFileListResult result ;
	result = SSYSharedFileListResultNoAction ;

	LSSharedFileListItemRef existingItemRef = nil ;
	if (path == nil) {
		SSYMakeAssignGeekyErrorP(34516, @"Cannot synchronize login item for nil path.") ;
		goto end ;
	}
	
	NSURL* url = [NSURL fileURLWithPath:path] ;
	BOOL ok = [self loginItemWithURL:url
								 ref:&existingItemRef
							   error:error_p] ;
	if (!ok) {
		// error_p has already been assigned
		goto end ;
	}
	
	// We'll change the result if we find it necessary to do some action
	if (shouldBeLoginItem) {
		if (existingItemRef == NULL) {
			// path needs to be added to login items
			ok = [self addLoginURL:url
							hidden:[NSNumber numberWithBool:setHidden]
							 error:error_p] ;
			if (ok) {
				result = SSYSharedFileListResultAdded ;
			}
			else {
				result = SSYSharedFileListResultFailed ;
				// error_p has already been assigned
				goto end ;
			}
		}
	}
	else {
		if (existingItemRef != NULL) {
			// existingItemRef needs to be removed
			ok = [self removeLoginItemRef:existingItemRef
									error:error_p] ;
			if (ok) {
				result = SSYSharedFileListResultRemoved ;
			}
			else {
				result = SSYSharedFileListResultFailed ;
				// error_p has already been assigned
				goto end ;
			}
		}
	}

end:
	if (*error_p) {
		*error_p = [*error_p errorByAddingUserInfoObject:NSStringFromSelector(_cmd)
												  forKey:@"Next_caller_down"] ;
		*error_p = [*error_p errorByAddingUserInfoObject:path
												  forKey:@"arg_path"] ;
	}
	
	CFSafeRelease(existingItemRef) ;
	return result ;
}


+ (enum SSYSharedFileListResult)removeAllLoginItemsWithName:(NSString*)name
										   thatAreNotInPath:(NSString*)path
													  error:(NSError**)error_p {
	SSYInitErrorP
	enum SSYSharedFileListResult result ;
	
	NSArray* loginItemRefsToRemove ;
	BOOL ok = [self loginItemsWithAppName:name
								notInPath:path
									 refs:&loginItemRefsToRemove
									error:error_p] ;
	if (ok) {
		if ([loginItemRefsToRemove count] == 0) {
			result = SSYSharedFileListResultNoAction ;
		}
		else {
			for (id item in loginItemRefsToRemove) {
				ok = [self removeLoginItemRef:(LSSharedFileListItemRef)item
										error:error_p] ;
				if (ok) {
					result = SSYSharedFileListResultRemoved ;
				}
				else {
					result = SSYSharedFileListResultFailed ;
					// error_p has already been set
					goto end ;
				}
			}
		}
		
	}
	else {
		result = SSYSharedFileListResultFailed ;
	}
	
end:
	return result ;
}

@end