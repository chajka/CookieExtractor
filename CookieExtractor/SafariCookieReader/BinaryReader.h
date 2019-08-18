//
//  BinaryReader.h
//  Charleston
//
//  Created by Чайка on 4/21/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BinaryReader : NSObject {
	NSData							*data;
	NSUInteger						position;
}
@property (readwrite) NSUInteger	position;


- (nonnull id) initWithData:(nonnull NSData *)data;

- (nonnull NSData *) slice:(NSUInteger)location length:(NSUInteger)length;
- (nonnull NSData *) readSlice:(NSInteger)length;
- (SInt64) readDoubleBigEndian;
- (UInt32) readIntBigEndian;
- (SInt64) readDoubleLittleEndian;
- (UInt32) readIntLittleEndian;
- (UInt32) readIntLittleEndian:(NSUInteger)offset;
@end

@interface BinaryCookie : BinaryReader
- (nonnull NSHTTPCookie *) parseCookie;
@end

@interface CookiePage : BinaryReader
@property (readonly) NSUInteger pageSize;
- (nonnull NSArray<BinaryCookie *> *)parsePage;
@end

@interface PageSlicer : BinaryReader
- (nonnull NSArray<CookiePage *> *)slicePage;
@end

@interface NSData (String)
- (nonnull NSString *) toString:(NSStringEncoding)encoding;
@end

