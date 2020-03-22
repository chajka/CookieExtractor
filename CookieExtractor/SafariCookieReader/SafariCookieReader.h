//
//  SafariCookieReader.h
//  Charleston
//
//  Created by Чайка on 4/21/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SafariCookieReader : NSObject {
	BOOL					isAccessible;
	NSData					*cookieData;
}

#pragma mark - messages

/**
 Initialize SafariCookieReader.

 @return An Initialized object for extract HTTPCookie(s).
 */
- (nonnull instancetype) init;

/**
 Initialize SafariCookieReader.

 @param data Contents of Cookie.binarycookies.
 @return An Initialized object for extract HTTPCookie(s).
 */
- (nonnull id) initWithData:(nonnull NSData *)data;

/**
 Extract all cookies.

 @return An array of NSHTTPCookie or nil.
 */
- (nullable NSArray<NSHTTPCookie *> *)parseCookies;

/**
 Extract domain specific cookies.

 @param domain search cookies for domain.
 @return An array of cookies for domain or nil.
 */
- (nullable NSArray<NSHTTPCookie *> *)parseCookiesForMatchDomain:(NSString * _Nonnull)domain;

/**
 Extract domain specific cookies.

 @param domain domain search cookies for domain.
 @return An array of NSHTTPCookie or nil.
 */
- (nullable NSArray<NSHTTPCookie *> *)parseCookiesForLikeDomain:(NSString * _Nonnull)domain;
@end
