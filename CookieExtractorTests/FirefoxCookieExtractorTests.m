//
//  FirefoxCookieExtractorTests.m
//  CookieExtractorTests
//
//  Created by Я Чайка on 2019/07/06.
//  Copyright © 2019 Instrumentality of Mankind. All rights reserved.
//

#import <XCTest/XCTest.h>
@import CookieExtractor;

@interface FirefoxCookieExtractorTests : XCTestCase

@end

@implementation FirefoxCookieExtractorTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
	FirefoxCookieReader *reader = [[FirefoxCookieReader alloc] init];
	XCTAssertNotNil(reader);
	@try {
		NSArray<NSHTTPCookie *> *cookies = [reader cookiesMatchDomain:@".nicovideo.jp"];
		XCTAssertNotEqual(cookies.count, 0);
		for (NSHTTPCookie *cookie in cookies) {
			XCTAssertNotNil(cookie.domain);
			XCTAssertNotNil(cookie.path);
			XCTAssertNotNil(cookie.name);
			XCTAssertNotNil(cookie.value);
		}
	} @catch (NSException *exception) {
		NSLog(@"Error");
	}
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
