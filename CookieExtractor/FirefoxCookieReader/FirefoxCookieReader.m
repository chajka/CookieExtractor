//
//  FirefoxCookieReader.m
//  Charleston
//
//  Created by Чайка on 4/22/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import "FirefoxCookieReader.h"
#import "FMDatabase.h"

typedef NS_ENUM(NSUInteger, PeekMode) {
	PeekModeMatch,
	PeekModeLike
};

static NSString * const MultiProfileQuery =				@"^Path=Profiles/([^\\n]+)\\nDefault=1$";
static NSString * const SingleProfileQuery =			@"Path=Profiles/(.*\\..*)";
static NSString * const DefaultProfileRegex =			@"^Default=Profiles/(.*)$";
static NSString * const FirefoxINIPath =				@"~/Library/Application Support/Firefox/profiles.ini";
static NSString * const FirefoxCookiePath =				@"~/Library/Application Support/Firefox/Profiles/%@/cookies.sqlite";
static NSString * const FirefoxPeekableCookiePath =		@"~/Library/Application Support/Firefox/Profiles/%@/cookies_peek.sqlite";
static NSString * const CachePath =						@"~/Library/Caches/jp.iom.Charleston/cookies.sqlite";
static NSString * const SQLMatchString =				@"select * from moz_cookies where host is '%@' order by lastAccessed;";
static NSString * const SQLLikeString =					@"select * from moz_cookies where host like '%%%@' order by lastAccessed;";

static NSString * const ColumnNameHost =				@"host";
static NSString * const ColumnNamePath =				@"path";
static NSString * const ColumnNameName =				@"name";
static NSString * const ColumnNameValue =				@"value";

@interface FirefoxCookieReader ()
- (nullable FMDatabase *) openDatabase;
- (nullable NSArray<NSHTTPCookie *> *)peekCookiesForDomain:(NSString * _Nonnull)domain mode:(PeekMode)mode;
@end

@implementation FirefoxCookieReader
#pragma mark - synthesize stored properties
#pragma mark - class method
#pragma mark - constructor / destructor
- (nonnull instancetype) init
{
	self = [super init];
	db = [self openDatabase];

	return self;
}// end - (nonnull instancetype) init

- (void) dealloc
{
	[db close];
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm removeItemAtPath:databaseForPeek error:nil];
}// end - (void) dealloc
#pragma mark - override
#pragma mark - computed properties
#pragma mark - actions
#pragma mark - messages
- (nullable NSArray<NSHTTPCookie *> *)cookiesMatchDomain:(NSString * _Nonnull)domain
{
	return [self peekCookiesForDomain:domain mode:PeekModeMatch];
}// end - (nullable NSArray<NSHTTPCookie *> *)cookiesMatchDomain:(NSString * _Nonnull)domain
- (nullable NSArray<NSHTTPCookie *> *)cookiesLikeDomain:(NSString * _Nonnull)domain
{
	return [self peekCookiesForDomain:domain mode:PeekModeLike];
}// end - (nullable NSArray<NSHTTPCookie *> *)cookiesLikeDomain:(NSString * _Nonnull)domain

#pragma mark - private
- (nullable FMDatabase *) openDatabase
{
	NSError *err = nil;
	NSString *firefoxIniPath = [FirefoxINIPath stringByExpandingTildeInPath];
	NSString *firefoxIniFile = [NSString stringWithContentsOfFile:firefoxIniPath encoding:NSUTF8StringEncoding error:&err];
	
	err = nil;
	NSRange profileRange;
	NSRegularExpression *activeProfileRegex = [NSRegularExpression regularExpressionWithPattern:MultiProfileQuery options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines) error:&err];
	NSUInteger matchCount = [activeProfileRegex numberOfMatchesInString:firefoxIniFile options:NSMatchingWithTransparentBounds range:NSMakeRange(0, firefoxIniFile.length)];
	if (!matchCount) {
		activeProfileRegex = [NSRegularExpression regularExpressionWithPattern:SingleProfileQuery options:(NSRegularExpressionCaseInsensitive|NSRegularExpressionUseUnixLineSeparators) error:&err];
		NSTextCheckingResult *result = [activeProfileRegex firstMatchInString:firefoxIniFile options:NSMatchingWithTransparentBounds range:NSMakeRange(0, firefoxIniFile.length)];
		profileRange = [result rangeAtIndex:1];
	} else {
		NSTextCheckingResult *result = [activeProfileRegex firstMatchInString:firefoxIniFile options:NSMatchingWithTransparentBounds range:NSMakeRange(0, firefoxIniFile.length)];
		profileRange = [result rangeAtIndex:1];
	}// end if multi profile or single profile
	NSString *profileName = [firefoxIniFile substringWithRange:profileRange];
	NSString *profile = [NSString stringWithFormat:FirefoxCookiePath, profileName];
	NSString *peekableProfile = [NSString stringWithFormat:FirefoxPeekableCookiePath, profileName];
	NSString *cookiePath = [profile stringByExpandingTildeInPath];
	databaseForPeek = [peekableProfile stringByExpandingTildeInPath];
	NSFileManager *fm = [NSFileManager defaultManager];
	err = nil;
	[fm copyItemAtPath:cookiePath toPath:databaseForPeek error:&err];
	if (err) { return nil; }
	FMDatabase *database = [FMDatabase databaseWithPath:databaseForPeek];
	if (![database open])
		return nil;
	
	return database;
}// end - (nullable FMDatabase *) openDatabase

- (nullable NSArray<NSHTTPCookie *> *)peekCookiesForDomain:(NSString * _Nonnull)domain mode:(PeekMode)mode
{
	NSString *query = (mode == PeekModeMatch) ?
		[NSString stringWithFormat:SQLMatchString, domain] :
		[NSString stringWithFormat:SQLLikeString, domain];

	FMResultSet *result = [db executeQuery:query];
	NSHTTPCookie *cookie;
	NSMutableArray<NSHTTPCookie *> *tmpCookie = [NSMutableArray array];
	while ([result next]) {
		NSDictionary *cookieDict = [NSDictionary dictionaryWithObjectsAndKeys:
									[result stringForColumn:ColumnNameHost], NSHTTPCookieDomain,
									[result stringForColumn:ColumnNamePath], NSHTTPCookiePath,
									[result stringForColumn:ColumnNameName], NSHTTPCookieName,
									[result stringForColumn:ColumnNameValue], NSHTTPCookieValue, nil];
		cookie = [NSHTTPCookie cookieWithProperties:cookieDict];
		[tmpCookie addObject:cookie];
	}// end while found cookies

	if (tmpCookie.count)
		return [NSArray arrayWithArray:tmpCookie];
	else
		return nil;
}// end - (nullable NSArray<NSHTTPCookie *> *)peekCookiesForDomain:(NSString * _Nonnull)domain mode:(PeekMode)mode
#pragma mark - delegate
#pragma mark - C functions

@end
