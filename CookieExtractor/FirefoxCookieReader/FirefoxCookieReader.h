//
//  FirefoxCookieReader.h
//  Charleston
//
//  Created by Чайка on 4/22/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@interface FirefoxCookieReader : NSObject {
	BOOL												isAccessible;
	FMDatabase											*db;
	NSString											*databaseForPeek;
}

/**
 Correct cookies for domain use by is statement

 @param domain domain name to correct
 @return An array of NSHTTPCookie or nil
 */
- (nullable NSArray<NSHTTPCookie *> *)cookiesMatchDomain:(NSString * _Nonnull)domain;

/**
 Correct cookies for domain use by like statement with prefixed `%`

 @param domain domain name to correct
 @return An array of NSHTTPCookie or nil
 */
- (nullable NSArray<NSHTTPCookie *> *)cookiesLikeDomain:(NSString * _Nonnull)domain;
@end
