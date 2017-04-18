//
//  CookieParser.h
//  binarycookies
//
//  Created by Чайка on 3/23/16.
//  Copyright © 2016 Instrumentality of Mankind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BinaryReader.h"

@interface CookieParser : NSObject {
	NSData					*cookieData;
}

#pragma mark - messages
- (nonnull id) initWithData:(nonnull NSData *)data;

- (nonnull NSArray<NSHTTPCookie *> *)parseCookies;
@end
