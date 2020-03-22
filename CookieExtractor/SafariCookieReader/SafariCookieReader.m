//
//  SafariCookieReader.m
//  Charleston
//
//  Created by Чайка on 4/21/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import "SafariCookieReader.h"
#import "BinaryReader.h"

static NSString * const SafariCookiePath = @"~/Library/Cookies/Cookies.binarycookies";

@implementation SafariCookieReader
#pragma mark - synthesize properties
#pragma mark - class method
#pragma mark - constructor / destructor
- (nonnull instancetype) init
{
	self = [super init];
	if (self) {
		isAccessible = NO;
		NSString *safariCookieFullPath = [SafariCookiePath stringByExpandingTildeInPath];
		cookieData = [[NSData alloc]initWithContentsOfFile:safariCookieFullPath];
		if (cookieData) isAccessible = YES;
	}// end if self

	return self;
}// end - (nonnull instancetype) init

- (nonnull id) initWithData:(NSData *)data
{
	self = [super init];
	if (self) {
		cookieData = [data copy];
		isAccessible = YES;
	}// end if self
	
	return self;
}// end - (nonnull id) initWithData:(NSData *)data

#pragma mark - override
#pragma mark - properties
#pragma mark - actions
#pragma mark - messages
- (nullable NSArray<NSHTTPCookie *> *)parseCookies
{
	NSMutableArray<NSHTTPCookie *> *cookies = [NSMutableArray array];
	PageSlicer *slicer = [[PageSlicer alloc] initWithData:cookieData];
	NSArray *pages = [slicer slicePage];
	
	for (CookiePage *page in pages) {
		NSArray *binaryCookies = [page parsePage];
		for (BinaryCookie *binaryCookie in binaryCookies) {
			@try {
				NSHTTPCookie *cookie = [binaryCookie parseCookie];
				[cookies addObject:cookie];
			} @catch (NSException *exception) {
				;
			}
		}// end foreach
	}// end foreach
	
	if (!cookies.count)
		return nil;
	else
		return [NSArray arrayWithArray:cookies];
}// end - (NSArray<NSHTTPCookie *> *)parseCookies

- (nullable NSArray<NSHTTPCookie *> *)parseCookiesForMatchDomain:(NSString * _Nonnull)domain
{
	NSMutableArray<NSHTTPCookie *> *cookies = [NSMutableArray array];
	PageSlicer *slicer = [[PageSlicer alloc] initWithData:cookieData];
	NSArray *pages = [slicer slicePage];
	
	for (CookiePage *page in pages) {
		NSArray *binaryCookies = [page parsePage];
		for (BinaryCookie *binaryCookie in binaryCookies) {
			@try {
				NSHTTPCookie *cookie = [binaryCookie parseCookie];
				if ([cookie.domain isEqualToString:domain])
					[cookies addObject:cookie];
			} @catch (NSException *exception) {
				;
			}
		}// end foreach
	}// end foreach
	
	if (!cookies.count)
		return nil;
	else
		return [NSArray arrayWithArray:cookies];
}// end - (nonnull NSArray<NSHTTPCookie *> *)parseCookiesForDomain:(NSString * _Nonnull)domain

- (nullable NSArray<NSHTTPCookie *> *)parseCookiesForLikeDomain:(NSString * _Nonnull)domain
{
	NSMutableArray<NSHTTPCookie *> *cookies = [NSMutableArray array];
	PageSlicer *slicer = [[PageSlicer alloc] initWithData:cookieData];
	NSArray *pages = [slicer slicePage];

	NSError *err = nil;
	NSRegularExpression *like = [NSRegularExpression regularExpressionWithPattern:[domain stringByAppendingString:@"$"] options:NSRegularExpressionAnchorsMatchLines error:&err];
	
	for (CookiePage *page in pages) {
		NSArray *binaryCookies = [page parsePage];
		for (BinaryCookie *binaryCookie in binaryCookies) {
			@try {
				NSHTTPCookie *cookie = [binaryCookie parseCookie];
				NSTextCheckingResult * res = [like firstMatchInString:cookie.domain options:NSMatchingReportCompletion range:NSMakeRange(0, cookie.domain.length)];
				if (res)
					[cookies addObject:cookie];
			} @catch (NSException *exception) {
				;
			}
		}// end foreach
	}// end foreach
	
	if (!cookies.count)
		return nil;
	else
		return [NSArray arrayWithArray:cookies];
}// end - (nullable NSArray<NSHTTPCookie *> *)parseCookiesForLikeDomain:(NSString * _Nonnull)domain

#pragma mark - private
#pragma mark - delegate
#pragma mark - C functions

@end
