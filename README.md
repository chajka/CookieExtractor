# Chrome Cookie Extractor

Framework for chrome cookie extract & decrypto for Mac.

## Version

Current version is 0.2.

## Useage

* Import
	* `#import <CookieDecryptor/ChromeCookieDecryptor.h>
* Class
	* `ChromeCookieDecryptor`
* Initialize (1)
	* `- (nonnull instancetype) initWithPath:(NSString * _Nonnull)path`
		* path : path to chrome’s cookie file path.
		* return : instance of Chrome cookie decrypter.
		* throw : Initialize error.
* Initialize (2)
	* `- (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path`
		* name : Browser’s name.
		* path : path to chrome’s cookie file path.
		* throw : Initialize error.
* Initialize (3)
	* `- (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path domainPrefix:(NSString * _Nonnull)domainPrefix`
		* name : Browser’s name.
		* path : path to chrome’s cookie file path.
		* domainPrefix : prefix string for each cookiesForDomain’s domain.
		* throw : Initialize error.
* Get cookie
	* `- (nullable NSArray<NSHTTPCookie *> *) cookiesForDomain:(NSString * _Nonnull)domain`
		* domain : domain for search cookies
		* return : array of NSHTTPCookie
		* throw : decrypto engine error.

notice path is only fullpath. tilda expand is need by caller.
