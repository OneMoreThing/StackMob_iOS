//
//  InneractiveAd.h
//	InneractiveAdSDK
//
//  Created by Inneractive LTD.
//  Copyright 2011 Inneractive LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 * IaAdType enumeration
 *
 * IaAdType_Banner		- Banner only ad
 * IaAdType_Text		- Text only ad
 * IaAdType_Interstitial	- Interstitial ad
 */
typedef enum {
	IaAdType_Banner = 1,
	IaAdType_Text,
	IaAdType_Interstitial
} IaAdType;

/*
 * IaOptionalParams
 *
 * Key_Age				- User's age
 * Key_Gender			- User's gender (allowed values: M, m, F, f, Male, Female)
 * Key_Gps_Coordinates	- GPS ISO code location data in latitude,longitude format. For example: 53.542132,-2.239856 (w/o spaces)
 * Key_Keywords			- Keywords relevant to this user's specific session (comma separated)
 * Key_Location			- Comma separted list of country,state/province,city. For example: US,NY,NY (w/o spaces)
 */
typedef enum {
	Key_Age = 1,
	Key_Gender,
	Key_Gps_Coordinates,
	Key_Keywords,
	Key_Location
} IaOptionalParams;

@protocol InneractiveAdDelegate;

@interface InneractiveAd : UIView {
    id <InneractiveAdDelegate> delegate;
}

@property (nonatomic, assign) id <InneractiveAdDelegate> delegate;

/*
 * Initialize InneractiveAd view
 *
 * (NSString*)appId		Application ID - provided by inneractive at the application registration
 * (IaAdType)adType		Ad type - can be banner only, text only, or interstitial ad
 * (int)reloadTime		Reload time - the ad refresh time (not relevant for interstitial ad)
 */
- (id)initWithAppId:(NSString*)appId withType:(IaAdType)adType withReload:(int)reloadTime;

/*
 * Initialize InneractiveAd view
 *
 * (NSString*)appId		Application ID - provided by inneractive at the application registration
 * (IaAdType)adType		Ad type - can be banner only, text only, or interstitial ad
 * (int)reloadTime		Reload time - the ad refresh time (not relevant for interstitialn ad)
 * (NSMutableDictionary*)optionalParams		Optional parameters for the ad request
 */
- (id)initWithAppId:(NSString*)appId withType:(IaAdType)adType withReload:(int)reloadTime withParams:(NSMutableDictionary*)optionalParams;

/*
 * DisplayAd function displays an ad
 *
 * (NSString*)appId		Application ID - provided by inneractive at the application registration
 * (IaAdType)adType		Ad type - can be banner only, text only, or interstitial ad
 * (UIView*)root		Root view - the view in which the ad will be displayed
 * (int)reloadTime		Reload time - the ad refresh time (not relevant for interstitial ad)
 *
 * Returns YES if succeeded, or NO if failed
 * Can fail in the following cases:
 *  - No network connection available
 *  - appId is null or an empty string
 *  - root is null
 */
+ (BOOL)DisplayAd:(NSString*)appId withType:(IaAdType)adType withRoot:(UIView*)root withReload:(int)reloadTime;

/*
 * DisplayAd function displays an ad
 *
 * (NSString*)appId							Application ID - provided by inneractive at the application registration
 * (IaAdType)adType							Ad type - can be banner only, text only, or interstitial ad
 * (UIView*)root							Root view - the view in which the ad will be displayed
 * (int)reloadTime							Reload time - the ad refresh time (not relevant for interstitial ad)
 * (NSMutableDictionary*)optionalParams		Optional parameters for the ad request
 *
 * Returns YES if succeeded, or NO if failed
 * Can fail in the following cases:
 *  - No network connection available
 *  - appId is null or an empty string
 *  - root is null
 */
+ (BOOL)DisplayAd:(NSString*)appId withType:(IaAdType)adType withRoot:(UIView*)root withReload:(int)reloadTime withParams:(NSMutableDictionary*)optionalParams;

/*
 * DisplayAd function displays an ad
 *
 * (NSString*)appId							Application ID - provided by inneractive at the application registration
 * (IaAdType)adType							Ad type - can be banner only, text only, or interstitial ad
 * (UIView*)root							Root view - the view in which the ad will be displayed
 * (int)reloadTime							Reload time - the ad refresh time (not relevant for interstitial ad)
 * (NSMutableDictionary*)optionalParams		Optional parameters for the ad request
 * (id<InneractiveAdDelegate>)delegateObj	InneractiveAd delegate
 *
 * Returns YES if succeeded, or NO if failed
 * Can fail in the following cases:
 *  - No network connection available
 *  - appId is null or an empty string
 *  - root is null
 */
+ (BOOL)DisplayAd:(NSString*)appId withType:(IaAdType)adType withRoot:(UIView*)root withReload:(int)reloadTime withParams:(NSMutableDictionary*)optionalParams withDelegate:(id<InneractiveAdDelegate>)delegateObj;

@end

@protocol InneractiveAdDelegate <NSObject>

@optional
    - (void)IaAdReceived;
    - (void)IaDefaultAdReceived;
    - (void)IaAdFailed;
    - (void)IaAdClicked;
    - (void)IaAdWillShow;
    - (void)IaAdDidShow;
    - (void)IaAdWillHide;
    - (void)IaAdDidHide;
    - (void)IaAdWillClose;
    - (void)IaAdDidClose;
    - (void)IaAdWillResize;
    - (void)IaAdDidResize;
    - (void)IaAdWillExpand;
    - (void)IaAdDidExpand;
    - (void)IaAppShouldSuspend;
    - (void)IaAppShouldResume;

@end
