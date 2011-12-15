# Release Notes

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