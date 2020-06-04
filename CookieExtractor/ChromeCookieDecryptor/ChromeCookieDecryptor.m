//
//  ChromeCookieDecryptor.m
//  Charleston
//
//  Created by Чайка on 4/21/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>
#import "ChromeCookieDecryptor.h"
#import "FMDatabase.h"

typedef NS_ENUM(NSUInteger, PeekMode) {
	PeekModeMatch,
	PeekModeLike
};

NS_ASSUME_NONNULL_BEGIN
static NSString * const ServiceName = @" Safe Storage";
static NSString * const ChromeAccountName = @"Chrome";

static NSString * const ColumnNameHost = @"host_key";
static NSString * const ColumnNamePath = @"path";
static NSString * const ColumnNameName = @"name";
static NSString * const ColumnNameValue = @"value";
static NSString * const ColumnNameEncValue = @"encrypted_value";
static NSString * const ChromeLocalSite = @"/Local State";
static NSString * const ChromeCookiePath = @"/%@/Cookies";
static NSString * const SQLMatchString = @"select * from cookies where host_key is '%@' and name is 'user_session' order by last_access_utc desc;";
static NSString * const SQLLikeString = @"select * from cookies where host_key like '%%%@' and name is 'user_session' order by last_access_utc desc;";

static NSString * const ProfileFolderStartAnchor1 = @"\"profile\":{\"info_cache\":{\"";
static NSString * const ProfileFolderStartAnchor2 = @"\"info_cache\":{\"";
static NSString * const ProfileFolderEndAnchor2 = @"\":{\"";
static NSString * const ProfileFolderEndAnchor = @"\"last_active_profiles\":[\"";
static const NSString *saltString = @"saltysalt";
static const NSString *IV = @"                ";
NS_ASSUME_NONNULL_END

@interface ChromeCookieDecryptor ()
- (BOOL) checkDatabasePath:(NSString * _Nonnull)path;
- (nonnull NSData *) getChromePassword;
- (nonnull NSData *) getBrowserPassword:(NSString * _Nonnull)browserName;
- (nullable NSString *) decrypt:(NSData * _Nonnull)encrypted;
- (NSArray<NSHTTPCookie *> *)peekCookiesForDomain:(NSString * _Nonnull)domain mode:(PeekMode)mode;
@end

@implementation ChromeCookieDecryptor
#pragma mark - synthesize stored properties
#pragma mark - class method
#pragma mark - constructor / destructor
- (nonnull instancetype) initWithCookiePath:(NSString * _Nonnull)path
{
	self = [super init];
	if (!self)
		@throw [ChromeCookieExtractorException exceptionWithName:@"Initialize error" reason:@"Super returned nil" userInfo:nil];
	isAccessible = NO;
	serviceName = [ChromeAccountName stringByAppendingString:ServiceName];

	if ((path.length > 1) && ([@"~" isEqualToString:[path substringWithRange:NSMakeRange(0, 1)]]))
		path = [path stringByExpandingTildeInPath];
	if (![self checkDatabasePath:path])
		@throw [ChromeCookieExtractorException exceptionWithName:@"File not found" reason:@"cookie file not found" userInfo:@{@"Path" : path}];

	db = [FMDatabase databaseWithPath:cookiePath];
	if (![db open])
		@throw [CookieDecryptorException exceptionWithName:@"Database can not open" reason:@"Chrome Cookie Database Open failed" userInfo:@{@"Database" : db}];
	isAccessible = YES;

	password = [self getChromePassword];

	return self;
}// end - (nonnull instancetype) initWithCookiePath:(NSString * _Nonnull)path

- (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path
{
	self = [super init];
	if (!self)
		@throw [CookieDecryptorException exceptionWithName:@"Initialize error" reason:@"Super returned nil" userInfo:nil];
	isAccessible = NO;
	serviceName = [name stringByAppendingString:ServiceName];

	if ((path.length > 1) && ([@"~" isEqualToString:[path substringWithRange:NSMakeRange(0, 1)]]))
		path = [path stringByExpandingTildeInPath];
	if (![self checkDatabasePath:path])
		@throw [CookieDecryptorException exceptionWithName:@"File not found" reason:@"cookie file not found" userInfo:@{@"Path" : cookiePath}];

	db = [FMDatabase databaseWithPath:cookiePath];
	if (![db open])
		@throw [CookieDecryptorException exceptionWithName:@"Database can not open" reason:@"Chrome Cookie Database Open failed" userInfo:@{@"Database" : db}];
	isAccessible = YES;

	password = [self getBrowserPassword:name];

	return self;
}// end - (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path

- (void) dealloc
{
	[db close];
}// end - (void) dealloc

#pragma mark - messages
- (nullable NSArray<NSHTTPCookie *> *) cookiesForMatchDomain:(NSString * _Nonnull)domain
{
	if (!isAccessible) return nil;

	return [self peekCookiesForDomain:domain mode:PeekModeMatch];
}// end - (nullable NSArray<NSHTTPCookie *> *) cookiesForLikeDomain:(NSString * _Nonnull)domain

- (nullable NSArray<NSHTTPCookie *> *) cookiesForLikeDomain:(NSString * _Nonnull)domain
{
	if (!isAccessible) return nil;

	return [self peekCookiesForDomain:domain mode:PeekModeLike];
}// end - (nullable NSArray<NSHTTPCookie *> *) cookiesForLikeDomain:(NSString * _Nonnull)domain

#pragma mark - private
- (BOOL) checkDatabasePath:(NSString * _Nonnull)path
{
	NSFileManager * const fm = [NSFileManager defaultManager];
	NSString * const localSiteFilePath = [path stringByAppendingString:ChromeLocalSite];
	NSError *err = nil;
	NSString * const localSite = [NSString stringWithContentsOfFile:localSiteFilePath encoding:NSUTF8StringEncoding error:&err];
	if (!err && localSite) {
		NSRange searchRange = NSMakeRange(0, localSite.length);
		NSRange startRange = [localSite rangeOfString:ProfileFolderStartAnchor1 options:(NSLiteralSearch) range:searchRange];
		if (startRange.location == NSNotFound) {
			startRange = [localSite rangeOfString:ProfileFolderStartAnchor2 options:(NSLiteralSearch + NSBackwardsSearch) range:searchRange];
			if (startRange.location == NSNotFound) { return NO; }
		}// end if anchor1 string is not found

		NSUInteger startLocation = startRange.location + startRange.length;
		NSRange endSearchRange = NSMakeRange(startLocation, searchRange.length - startLocation);
		NSString *tailString = [localSite substringWithRange:endSearchRange];
		NSRange endRange = [tailString rangeOfString:ProfileFolderEndAnchor options:NSLiteralSearch];
		NSRange profileFolderRange = NSMakeRange(0, tailString.length);
		if (endRange.location != NSNotFound) {
			profileFolderRange.length = endRange.location;
		} else {
			endRange = [tailString rangeOfString:ProfileFolderEndAnchor2 options:(NSLiteralSearch)];
			if (endRange.location != NSNotFound) {
				profileFolderRange.length = endRange.location;
			} else {
				return NO;
			}// end if found anchor 2 or not
		}// end if anchor 1 or not
		

		NSString *profileFolder = [tailString substringWithRange:profileFolderRange];
		cookiePath = [path stringByAppendingString:[NSString stringWithFormat:ChromeCookiePath, profileFolder]];

		return [fm fileExistsAtPath:cookiePath];
	}// end if noerror
	
	return NO;
}// end - (BOOL) checkDatabasePath:(NSString * _Nonnull)path

- (nonnull NSData *) getChromePassword
{
	OSStatus result;
	UInt32 passwordLength;
	void *passwordData;
	result = SecKeychainFindGenericPassword(NULL,
											(UInt32)serviceName.length, serviceName.UTF8String,
											(UInt32)ChromeAccountName.length, ChromeAccountName.UTF8String,
											&passwordLength, &passwordData, NULL);
	if (result != noErr)
		@throw [CookieDecryptorException exceptionWithName:@"Password not found" reason:@"No password in keychain" userInfo:nil];
	
	NSData *pass = [[NSData alloc] initWithBytes:passwordData length:passwordLength];
	SecKeychainItemFreeContent(NULL, passwordData);

	return pass;
}// end - (nonnull NSString *) getChromePassword

- (nonnull NSData *) getBrowserPassword:(NSString * _Nonnull)browserName
{
	OSStatus result;
	UInt32 passwordLength;
	void *passwordData;
	result = SecKeychainFindGenericPassword(NULL,
											(UInt32)serviceName.length, serviceName.UTF8String,
											(UInt32)browserName.length, browserName.UTF8String,
											&passwordLength, &passwordData, NULL);
	if (result != noErr)
		@throw [CookieDecryptorException exceptionWithName:@"Password not found" reason:@"No password in keychain" userInfo:nil];

	NSData *pass = [[NSData alloc] initWithBytes:passwordData length:passwordLength];
	SecKeychainItemFreeContent(NULL, passwordData);

	return pass;
}// end - (nonnull NSString *) getBrowserPassword:(NSString * _Nonnull)browserName;

- (nullable NSString *) decrypt:(NSData * _Nonnull)encrypted
{
	NSData *chiper = [NSData dataWithBytes:([encrypted bytes] + 3) length:([encrypted length] - 3)];
	
	// key for password
	CCCryptorRef											cryptor;

	NSData *salt = [saltString dataUsingEncoding:NSUTF8StringEncoding];
	key = [NSMutableData dataWithLength:16];
	int result = CCKeyDerivationPBKDF(kCCPBKDF2, password.bytes, password.length, salt.bytes, salt.length, kCCPRFHmacAlgSHA1, 1003, key.mutableBytes, key.length);
	NSAssert(result == kCCSuccess, @"Unable to create AES key for password: %d", result);
	if (result != kCCSuccess)
		@throw [NSException exceptionWithName:@"Cryptor Fail" reason:@"Cryptor create fail" userInfo:nil];

	NSData *iv = [IV dataUsingEncoding:NSUTF8StringEncoding];
	
	CCCryptorStatus status = CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, key.bytes, key.length, iv.bytes, &cryptor);
	if (status != kCCSuccess || cryptor == NULL)
		@throw [NSException exceptionWithName:@"Cryptor Fail" reason:@"Cryptor create fail" userInfo:nil];

	size_t available;
	NSMutableData *buffer = [NSMutableData dataWithLength:1024];
	CCCryptorUpdate(cryptor, chiper.bytes, chiper.length, buffer.mutableBytes, buffer.length, &available);
	NSData *data = [buffer subdataWithRange:NSMakeRange(0, available)];
	NSMutableString *decodedString = [NSMutableString string];
	[decodedString appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];

	CCCryptorFinal(cryptor, buffer.mutableBytes, buffer.length, &available);
	if (available) {
		data = [buffer subdataWithRange:NSMakeRange(0, available)];
		[decodedString appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	}// end if remain string data available

	return [NSString stringWithString:decodedString];
}// end - (void) setupDecrypt

- (nullable NSArray<NSHTTPCookie *> *)peekCookiesForDomain:(NSString * _Nonnull) domain mode:(PeekMode)mode
{
	NSString *query = (mode == PeekModeMatch) ?
		[NSString stringWithFormat:SQLMatchString, domain] :
		[NSString stringWithFormat:SQLLikeString, domain];
	FMResultSet *results = [db executeQuery:query];

	NSMutableArray<NSHTTPCookie *> *cookies = [NSMutableArray array];
	while([results next]) {
		NSData *encrypted = [results dataForColumn:ColumnNameEncValue];
		NSString *decrypted = [self decrypt:encrypted];

		NSDictionary<NSHTTPCookiePropertyKey, NSString *>
		*properties = @{
						NSHTTPCookieDomain : [results stringForColumn:ColumnNameHost],
						NSHTTPCookiePath : [results stringForColumn:ColumnNamePath],
						NSHTTPCookieName : [results stringForColumn:ColumnNameName],
						NSHTTPCookieValue : decrypted
						};
		[cookies addObject:[NSHTTPCookie cookieWithProperties:properties]];
	}
	if (cookies.count)
		return [NSArray arrayWithArray:cookies];

	return nil;
}// end - (NSArray<NSHTTPCookie *> *)peekCookiesForDomain:(NSString * _Nonnull)domain

@end

@implementation ChromeCookieExtractorException

@end

@implementation CookieDecryptorException

@end
