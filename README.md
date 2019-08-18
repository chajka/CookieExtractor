# Chrome Cookie Extractor

Framework for chrome cookie extract & decrypto for Mac.

## Version

Current version is 0.2.

## Usage - 1 Decrypt Chrome Cookie

* Import
	* `#import <CookieExtractor/ChromeCookieDecryptor.h>
* Class
	* `ChromeCookieDecryptor`
* Initialize (1)
	* `- (nonnull instancetype) initWithCookiePath:(NSString * _Nonnull)path`
		* path : path to chrome’s  under “Application Data” Folder without last “/”.
		* return : instance of Chrome cookie decrypter.
		* throw : Initialize error.
		* throw : Wrong path error.
* Initialize (2)
	* `- (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path`
		* name : Browser’s name.
		* path : path to chrome’s under “Application Data” Folder without last “/”.
		* throw : Initialize error.
		* throw : Wrong path error.
* Initialize (3)
	* `- (nonnull instancetype) initWithBrowserName:(NSString *_Nonnull)name cookiePath:(NSString * _Nonnull)path domainPrefix:(NSString * _Nonnull)domainPrefix`
		* name : Browser’s name.
		* path : path to chrome’s under “Application Data” Folder without last “/”.
		* domainPrefix : prefix string for each cookiesForDomain’s domain.
		* throw : Initialize error.
		* throw : Wrong path error.
* Get cookie
	* `- (nullable NSArray<NSHTTPCookie *> *)parseCookiesForMatchDomain:(NSString * _Nonnull)domain`
		* domain : reqeust domain name completely matched.
		* return : array of parsed NSHTTPCookie instance.
	* `- (nullable NSArray<NSHTTPCookie *> *)parseCookiesForLikeDomain:(NSString * _Nonnull)domain`
		* domain : reqeust domain name part of domain.
		* return : array of parsed NSHTTPCookie instance.

notice path is both fullpath. and tilde(~) prefixed user’s home relative path.

## Usage - 2 Parse and Convert Safari Cookie ##

* Import
	* `#import <CookieExtractor/SafariCookieReader.h>
* Class
	* `SafariCookieReader`
* Initialize
	* `- (nonnull instancetype) init`
		* return : instance of Safari Cookie parser for current safari cookies.
	* `- (nonnull instancetype) init`
		* data : contents of Safari’s .binarycookies file (for read other place cookies).
		* return : instance of Safari Cookie parser.
* Get Cookie
	* `-(NSArray<NSHTTPCookie *> *) paseCookies`
		* return : array of parsed NSHTTPCookie instance.
	* `- (nullable NSArray<NSHTTPCookie *> *)parseCookiesForMatchDomain:(NSString * _Nonnull)domain`
		* domain : reqeust domain name completely matched.
		* return : array of parsed NSHTTPCookie instance.
	* `- (nullable NSArray<NSHTTPCookie *> *)parseCookiesForLikeDomain:(NSString * _Nonnull)domain`
		* domain : reqeust domain name part of domain.
		* return : array of parsed NSHTTPCookie instance.

## Usage - 3 Extract and build for Firefox Cookie ##

* Import
	* `#import <CookieExtractor/FirefoxCookieReader.h>
* Class
	* `FirefoxCookieReader`
* Initialize
	* `- (nonnull instancetype) init`
		* return : instance of current active Firefox Cookie reader.
* Get Cookie
	* `- (nullable NSArray<NSHTTPCookie *> *)parseCookiesForMatchDomain:(NSString * _Nonnull)domain`
		* domain : reqeust domain name completely matched.
		* return : array of parsed NSHTTPCookie instance.
	* `- (nullable NSArray<NSHTTPCookie *> *)parseCookiesForLikeDomain:(NSString * _Nonnull)domain`
		* domain : reqeust domain name part of domain.
		* return : array of parsed NSHTTPCookie instance.
