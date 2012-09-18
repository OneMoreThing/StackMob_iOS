# Release Notes

## 0.5.4
* Status code of an error is now available - use 'code' property of NSError.
* Fix OAuth2 nil info issue.

## 0.5.3
* Fix bugs for user based requests

## 0.5.2
* Push uses Oauth1

## 0.5.1
* Update user logout for OAuth2

## 0.5.0
* Add support for OAuth2

## 0.4.11
* Fix memory leaks

## 0.4.10
* Add support for atomic counter
* Add logs for testing server time diff function

## 0.4.9
* Fix bugs

## 0.4.7
* Inneractive integration

## 0.4.6
* Count methods
* Null and Not Equal Queries
* Logged-in user checks

## 0.4.5
* Update SecureUDID
* Minor fixes

## 0.4.4
* Remove apple UDID in favor of SecureUDID
* Switch to new-style urls

## 0.4.3
* Debug logs restricted to debug mode
* StackMobSessionDelegate
* Truncate base64 blobs in logs
* Persistent cookies
* Select query support

## 0.4.2
* fix for booleans in GET requests (Peter Stöckli)
* property and IVar cleanup (Daniel Brajkovic)
* fix for binary file upload

## 0.4.1
* Support for cascading delete in the Relations API
* SMFile for file uploads with different content types and file names
* Improved Memory Management
* Fix for lost auth cookie

## 0.4.0
* Support for Geo-Queries
* Relations API Extensions Support
* Deprecated put:withArguments:andCallback: in favor of new put:withId:andArguments:andCallback:
* Support for bulk insertion
* fixed encoding of double values in JSONKit
* improved URL encoding

## 0.3.2
* Improved Push Support including several Bug Fixes

## 0.3.1
* Removed dependency on CoreLocation
* Resolved handling of binary uploads with JSONKit
* Support for pagination and ordering in StackMobQuery
* setting expand depth in StackMobQuery now uses the X-StackMob-Expand header

## 0.3.0 - first versioned release
* SDK is now following semantic versioning scheme. This is the first versioned release
* Better error handling
* StackMobQuery class
* SDK is no longer built as a framework but instead included in applications as a library
* Switched to JSONKit for faster JSON parsing (this may be temporary since JSONKit does not currently support ARC)
* Minor bug fixes 
