# Chrome Cookie Extractor

Framework for chrome cookie extract & decrypto for Mac.

## Version

Current version is 0.1.

## Useage

* Import
	* `#import #import <CookieExtractor/ChromeCookieDecryptor.h>
* Class
	* `ChromeCookieDecryptor`
* Initialize (1)
	* `- (nonnull instancetype) initWithCookiePath:(NSString * _Nonnull)path`
		* path : path to chrome’s cookie file path.
		* return : instance of Chrome cookie decrypter.
		* throw : Initialize error.
		* throw : Wrong path error.
* Initialize (2)
	* `- (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path`
		* name : Browser’s name.
		* path : path to chrome’s cookie file path.
		* throw : Initialize error.
		* throw : Wrong path error.
* Initialize (3)
	* `- (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path domainPrefix:(NSString * _Nonnull)domainPrefix`
		* name : Browser’s name.
		* path : path to chrome’s cookie file path.
		* domainPrefix : prefix string for each cookiesForDomain’s domain.
		* throw : Initialize error.
		* throw : Wrong path error.
* Get cookie
	* `- (nullable NSArray<NSHTTPCookie *> *) cookiesForDomain:(NSString * _Nonnull)domain`
		* domain : domain for search cookies
		* return : array of NSHTTPCookie
		* throw : decrypto engine error.

notice path is both fullpath. and tilde(~) prefixed user’s home relative path.
