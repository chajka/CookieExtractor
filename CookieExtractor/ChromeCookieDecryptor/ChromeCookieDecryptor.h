//
//  ChromeCookieDecryptor.h
//  Charleston
//
//  Created by Чайка on 4/21/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@interface ChromeCookieDecryptor : NSObject {
	BOOL													isAccessible;

	FMDatabase												*db;
	
	NSData													*password;
	
	NSString												*serviceName;
	
	NSMutableData											*key;

	NSString												*cookiePath;
}
#pragma mark - constructor

/**
 Initialize with Chrome cookie file’s path

 @param path A path to cookie file of Google Chrome
 @return Instance of ChromeCookieDecryptor
 */
- (nonnull instancetype) initWithCookiePath:(NSString * _Nonnull)path;

/**
 Initialize with Browser name and its cookie file’s path

 @param name Name of Chrome style cookie encrypted browser
 @param path A path to cookie file of browser specified by name
 @return Instance of ChromeCookieDecryptor
 */
- (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path;

#pragma mark - message
/**
 Decrypto Chrome cookies for specific domain

 @param domain Domain for need cookies
 @return An array of NSHTTPCookie instance
 */
- (nullable NSArray<NSHTTPCookie *> *) cookiesForMatchDomain:(NSString * _Nonnull)domain;

/**
 Decrypto Chrome cookies for like a specific domain

 @param domain Domain for need cookies
 @return An array of NSHTTPCookie instance
 */
- (nullable NSArray<NSHTTPCookie *> *) cookiesForLikeDomain:(NSString * _Nonnull)domain;
@end

@interface ChromeCookieExtractorException : NSException

@end

@interface CookieDecryptorException : ChromeCookieExtractorException

@end
