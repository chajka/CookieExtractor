//
//  CookieParser.m
//  binarycookies
//
//  Created by Чайка on 3/23/16.
//  Copyright © 2016 Instrumentality of Mankind. All rights reserved.
//

#import "CookieParser.h"

@interface NSData (String)
- (nonnull NSString *) toString:(NSStringEncoding)encoding;
@end

@implementation NSData (String)
- (nonnull NSString *) toString:(NSStringEncoding)encoding
{
	return [[NSString alloc] initWithData:self encoding:encoding];
}// end - (nonnull NSString *) toString:(NSStringEncoding)encoding
@end

@interface CookieParser ()
@end

@implementation CookieParser
#pragma mark - synthesize properties
#pragma mark - class method
#pragma mark - constructor / destructor
- (nonnull id) initWithData:(NSData *)data
{
	self = [super init];
	if (self) {
		cookieData = [data copy];
	}// end if self

	return self;
}// end - (nonnull id) initWithData:(NSData *)data

#pragma mark - override
#pragma mark - properties
#pragma mark - actions
#pragma mark - messages
- (nonnull NSArray<NSHTTPCookie *> *)parseCookies
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

	return [NSArray arrayWithArray:cookies];
}// end - (NSArray<NSHTTPCookie *> *)parseCookies
#pragma mark - private
#pragma mark - delegate
#pragma mark - C functions

@end
