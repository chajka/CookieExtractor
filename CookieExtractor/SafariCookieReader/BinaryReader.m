//
//  BinaryReader.m
//  Charleston
//
//  Created by Чайка on 4/21/17.
//  Copyright © 2017 Instrumentality of Mankind. All rights reserved.
//

#import "BinaryReader.h"

NSUInteger static SingleByteLength =									4;
NSUInteger static DoubleByteLength =									8;

@interface BinaryReader ()
- (SInt64) readDoubleBigEndian:(NSUInteger)offset;
- (UInt32) readIntBigEndian:(NSUInteger)offset;
- (SInt64) readDoubleLittleEndian:(NSUInteger)offset;
- (UInt32) readIntLittleEndian:(NSUInteger)offset;

- (nonnull NSData *) slice:(NSUInteger)location length:(NSUInteger)length;
@end

@implementation BinaryReader
#pragma mark - synthesize properties
@synthesize position;
#pragma mark - class method
#pragma mark - constructor / destructor
- (nonnull id) initWithData:(nonnull NSData *)data_
{
	self = [super init];
	if (self) {
		data = [[NSData alloc] initWithData:data_];
		position = 0;
	}// end if self
	
	return self;
}// end - (nonnull id) init
#pragma mark - override
#pragma mark - properties
#pragma mark - actions
#pragma mark - messages
- (nonnull NSData *) slice:(NSUInteger)location length:(NSUInteger)length
{
	NSRange	rangeSlice = NSMakeRange(location, length);
	
	return [data subdataWithRange:rangeSlice];
}// end - (nonnull NSData *) slice:(NSUInteger)location length:(NSUInteger)length

- (nonnull NSData *) readSlice:(NSInteger)length
{
	NSRange rangeSlice = NSMakeRange(position, length);
	NSData *slice = [data subdataWithRange:rangeSlice];
	position += length;
	
	return slice;
}// end - (nonnull NSData *) readSlice:(NSInteger)length

- (SInt64) readDoubleBigEndian
{
	SInt64 result = [self readDoubleBigEndian:position];
	position += DoubleByteLength;
	
	return result;
}// end - (SInt64) readDoubleBigEndian

- (UInt32) readIntBigEndian
{
	UInt32 result = [self readIntBigEndian:position];
	position += SingleByteLength;
	
	return result;
}// end - (UInt32) readIntBigEndian

- (SInt64) readDoubleLittleEndian
{
	SInt64 result = [self readDoubleLittleEndian:position];
	position += DoubleByteLength;
	
	return result;
}// end - (SInt64) readDoubleLittleEndian

- (UInt32) readIntLittleEndian
{
	UInt32 result = [self readIntLittleEndian:position];
	position += SingleByteLength;
	
	return result;
}// end - (uint32) readIntLittleEndian

- (UInt32) readIntLittleEndian:(NSUInteger)offset
{
	NSData *sliced = [self slice:offset length:SingleByteLength];
	UInt32 buffer = 0;
	[sliced getBytes:&buffer length:sizeof(UInt32)];
	
	return (UInt32)CFSwapInt32LittleToHost(buffer);
}// end - (UInt32) readIntLittleEndian:(NSUInteger)offset

#pragma mark - private
- (SInt64) readDoubleBigEndian:(NSUInteger)offset
{
	NSData *sliced = [self slice:offset length:DoubleByteLength];
	double_t buffer = 0;
	memcpy(&buffer, sliced.bytes, sizeof(double_t));
	
	return (SInt64)CFSwapInt64BigToHost(buffer);
}// end - (SInt64) readDoubleBigEndian:(NSUInteger)offset

- (UInt32) readIntBigEndian:(NSUInteger)offset
{
	NSData *sliced = [self slice:offset length:SingleByteLength];
	UInt32 buffer = 0;
	[sliced getBytes:&buffer length:SingleByteLength];
	
	return CFSwapInt32BigToHost(buffer);
}// end - (UInt32) readIntBigEndian:(NSUInteger)offset

- (SInt64) readDoubleLittleEndian:(NSUInteger)offset
{
	NSData *sliced = [self slice:offset length:DoubleByteLength];
	double_t buffer = 0;
	memcpy(&buffer, sliced.bytes, sizeof(double_t));
	
	return (SInt64)CFSwapInt64LittleToHost(buffer);
}// end - (SInt64) readDoubleLittleEndian:(NSUInteger)offset

#pragma mark - delegate
#pragma mark - C functions
@end


@implementation BinaryCookie
- (nonnull NSHTTPCookie *) parseCookie
{		// check size
	UInt32 length = [self readIntLittleEndian];
	if (length != data.length)
		@throw [NSException exceptionWithName:@"length invalid" reason:nil userInfo:nil];
	
	// unknkown
	[self readIntLittleEndian];
	NSMutableDictionary *cookie = [NSMutableDictionary dictionary];
	// parse flags
	UInt32 flags = [self readIntLittleEndian];
	// unknown
	[self readIntLittleEndian];
	// URL Offset
	UInt32 urlOffset = [self readIntLittleEndian];
	// name offset and URL length
	UInt32 nameOffset = [self readIntLittleEndian];
	UInt32 urlLength = nameOffset - urlOffset;
	// path offset and name length
	UInt32 pathOffset = [self readIntLittleEndian];
	UInt32 nameLength = pathOffset - nameOffset;
	// Value offset and value length
	UInt32 valueOffset = [self readIntLittleEndian];
	UInt32 pathLength = valueOffset - pathOffset;
	UInt32 valueLength = (UInt32)data.length - valueOffset;
	// enf of cookie
	UInt32 endOfCookie = [self readIntLittleEndian];
	if (endOfCookie != 0x0000)
		@throw [NSException exceptionWithName:@"End of Cookie invalid" reason:nil userInfo:nil];
	UInt64 expirationDate = [self readDoubleLittleEndian];
	[self readDoubleLittleEndian];	// cookie creation date unused
	// check secure
	if (flags & 0x01)
		[cookie setValue:@"TRUE" forKey:NSHTTPCookieSecure];
	else
		[cookie setValue:@"FALSE" forKey:NSHTTPCookieSecure];
	// end if cookie is secure
	// get url, name, path and value
	// domain
	NSData *stringBuffer;
	stringBuffer = [data subdataWithRange:NSMakeRange(urlOffset, urlLength)];
	NSString *url = [stringBuffer toString:NSUTF8StringEncoding];
	[cookie setValue:url forKey:NSHTTPCookieDomain];
	// name
	stringBuffer = [data subdataWithRange:NSMakeRange(nameOffset, nameLength)];
	NSString *name = [stringBuffer toString:NSUTF8StringEncoding];
	[cookie setValue:name forKey:NSHTTPCookieName];
	// path
	stringBuffer = [data subdataWithRange:NSMakeRange(pathOffset, pathLength)];
	NSString *path = [stringBuffer toString:NSUTF8StringEncoding];
	[cookie setValue:path forKey:NSHTTPCookiePath];
	// value
	stringBuffer = [data subdataWithRange:NSMakeRange(valueOffset, valueLength)];
	NSString *value = [stringBuffer toString:NSUTF8StringEncoding];
	[cookie setValue:value forKey:NSHTTPCookieValue];
	stringBuffer = nil;
	
	NSDate *MacEpochOffset = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:0];
	
	NSDate *expiration = [NSDate dateWithTimeInterval:expirationDate sinceDate:MacEpochOffset];
	[cookie setValue:expiration forKey:NSHTTPCookieExpires];
	
	return [NSHTTPCookie cookieWithProperties:cookie];
}// end - (nonnull NSHTTPCookie *) parseCookie

@end

@implementation CookiePage

- (NSUInteger) pageSize { return [data length]; }

- (nonnull NSArray<BinaryCookie *> *)parsePage
{		// check cookie header
	SInt32 pageHeader = [self readIntBigEndian];
	if (pageHeader != 0x0100)
		@throw [NSException exceptionWithName:@"Bad page Header" reason:nil userInfo:nil];
	// Number of Cookies
	SInt32 numberOfCookies = [self readIntLittleEndian];
	NSMutableArray<BinaryCookie *> *binaryCookies = [NSMutableArray array];
	// each cookies
	SInt32 offset = 0;
	SInt32 length = 0;
	SInt32 currentCookie = 0;
	for (currentCookie = 0; currentCookie < numberOfCookies; currentCookie++) {
		offset = [self readIntLittleEndian];
		length = [self readIntLittleEndian:offset];
		NSData *subdata = [self slice:offset length:length];
		[binaryCookies addObject:[[BinaryCookie alloc] initWithData:subdata]];
	}// end for each cookie pages
	
	return [NSArray arrayWithArray:binaryCookies];
}// end - (nonnull NSArray<BinaryCookie *> *)parsePage

@end

@implementation PageSlicer

- (nonnull NSArray<CookiePage *> *)slicePage
{
	NSString *signature = [[self readSlice:4] toString:NSUTF8StringEncoding];
	if ([signature isEqualToString:@"cook"]) {
		NSUInteger numberOfPages = [self readIntBigEndian];
		// get page sizes
		NSMutableArray<NSNumber *> *pageSizes = [NSMutableArray arrayWithCapacity:numberOfPages];
		NSUInteger currentPage = 0;
		NSUInteger currentPageSize = 0;
		for (currentPage = 0; currentPage < numberOfPages; currentPage++) {
			currentPageSize = [self readIntBigEndian];
			pageSizes[currentPage] = [NSNumber numberWithInteger:currentPageSize];
		}// end for each page size
		// slice pages
		NSMutableArray<CookiePage *> *cookiePages = [NSMutableArray arrayWithCapacity:numberOfPages];
		NSData *pageData = nil;
		for (NSNumber *pageSize in pageSizes) {
			currentPageSize = [pageSize unsignedIntegerValue];
			pageData = [self readSlice:currentPageSize];
			[cookiePages addObject:[[CookiePage alloc] initWithData:pageData]];
		}// end foreach slice page
		
		return [NSArray arrayWithArray:cookiePages];
	} else {
		@throw [NSException exceptionWithName:@"Bad Cookie Header" reason:nil userInfo:nil];
	}// end if page header is valid
}// end - (nonnull NSArray<CookiePage *> *)slicePage

@end
