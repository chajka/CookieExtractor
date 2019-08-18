//
//  ChromeCookieExtractorTests.m
//  CookieExtractor
//
//  Created by Чайка on 4/18/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <XCTest/XCTest.h>
@import CookieExtractor;

@interface ChromeCookieExtractorTests : XCTestCase

@end

@implementation ChromeCookieExtractorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) test01_Chrome {
	ChromeCookieDecryptor *decryptor = [[ChromeCookieDecryptor alloc] initWithCookiePath:@"~/Library/Application Support/Google/Chrome"];
	XCTAssertNotNil(decryptor);
	@try {
		NSArray<NSHTTPCookie *> *cookies = [decryptor cookiesForMatchDomain:@".nicovideo.jp"];
		for (NSHTTPCookie *cookie in cookies) {
			XCTAssertNotNil(cookie.domain);
			XCTAssertNotNil(cookie.path);
			XCTAssertNotNil(cookie.value);
			NSLog(@"Cookie : domain [%@] value [%@]", cookie.domain, cookie.value);
		}
	} @catch (NSException *exception) {
		NSLog(@"Error");
	}
}

- (void) test02_Chromium_without_prefix {
	ChromeCookieDecryptor *decryptor = [[ChromeCookieDecryptor alloc] initWithCookiePath:@"~/Library/Application Support/Google/Chrome"];
	XCTAssertNotNil(decryptor);
	@try {
		NSArray<NSHTTPCookie *> *cookies = [decryptor cookiesForMatchDomain:@".nicovideo.jp"];
		for (NSHTTPCookie *cookie in cookies) {
			XCTAssertNotNil(cookie.domain);
			XCTAssertNotNil(cookie.path);
			XCTAssertNotNil(cookie.value);
			NSLog(@"Cookie : domain [%@] value [%@]", cookie.domain, cookie.value);
		}
	} @catch (NSException *exception) {
		NSLog(@"Error");
	}
}

- (void) test03_Chromium_with_prefix {
	ChromeCookieDecryptor *decryptor = [[ChromeCookieDecryptor alloc] initWithBrowserName:@"Chromium" cookiePath:@"~/Library/Application Support/Chromium"];
	XCTAssertNotNil(decryptor);
	@try {
		NSArray<NSHTTPCookie *> *cookies = [decryptor cookiesForMatchDomain:@"nicovideo.jp"];
		for (NSHTTPCookie *cookie in cookies) {
			XCTAssertNotNil(cookie.domain);
			XCTAssertNotNil(cookie.path);
			XCTAssertNotNil(cookie.value);
			NSLog(@"Cookie : domain [%@] value [%@]", cookie.domain, cookie.value);
		}
	} @catch (NSException *exception) {
		NSLog(@"Error");
	}
}

- (void) test04_Opera_with_prefix {
	ChromeCookieDecryptor *decryptor = [[ChromeCookieDecryptor alloc] initWithBrowserName:@"Opera" cookiePath:@"~/Library/Application Support/com.operasoftware.Opera/Cookies"];
	XCTAssertNotNil(decryptor);
	@try {
		NSArray<NSHTTPCookie *> *cookies = [decryptor cookiesForMatchDomain:@"nicovideo.jp"];
		for (NSHTTPCookie *cookie in cookies) {
			XCTAssertNotNil(cookie.domain);
			XCTAssertNotNil(cookie.path);
			XCTAssertNotNil(cookie.value);
			NSLog(@"Cookie : domain [%@] value [%@]", cookie.domain, cookie.value);
		}
	} @catch (NSException *exception) {
		NSLog(@"Error");
	}
}

- (void) test05_Vivaldi_with_prefix {
	ChromeCookieDecryptor *decryptor = [[ChromeCookieDecryptor alloc] initWithBrowserName:@"Chrome" cookiePath:@"~/Library/Application Support/Vivaldi/Default/Cookies"];
	XCTAssertNotNil(decryptor);
	@try {
		NSArray<NSHTTPCookie *> *cookies = [decryptor cookiesForMatchDomain:@"nicovideo.jp"];
		for (NSHTTPCookie *cookie in cookies) {
			XCTAssertNotNil(cookie.domain);
			XCTAssertNotNil(cookie.path);
			XCTAssertNotNil(cookie.value);
			NSLog(@"Cookie : domain [%@] value [%@]", cookie.domain, cookie.value);
		}
	} @catch (NSException *exception) {
		NSLog(@"Error");
	}
}

@end
