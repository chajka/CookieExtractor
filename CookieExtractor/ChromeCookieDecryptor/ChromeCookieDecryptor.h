//
//  ChromeCookieDecryptor.h
//  CookieExtractor
//
//  Created by Чайка on 4/18/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import <Foundation/Foundation.h>

@class FMDatabase;
@interface ChromeCookieDecryptor : NSObject {
	FMDatabase												*db;

	NSData													*password;
	
	NSString												*prefix;
	NSString												*serviceName;
	
	CCCryptorRef											cryptor;
	NSMutableData											*key;
}
#pragma mark - constructor

- (nonnull instancetype) initWithCookiePath:(NSString * _Nonnull)path;
- (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path;
- (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path domainPrefix:(NSString * _Nonnull)domainPrefix;
#pragma mark - message
- (nullable NSArray<NSHTTPCookie *> *) cookiesForDomain:(NSString * _Nonnull)domain;
@end

@interface ChromeCookieExtractorException : NSException

@end

@interface CookieDecryptorException : ChromeCookieExtractorException

@end
