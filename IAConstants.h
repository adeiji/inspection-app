//
//  IAConstants.h
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import <Foundation/Foundation.h>

// Parse
FOUNDATION_EXPORT NSString *const kParseClassCrane;
FOUNDATION_EXPORT NSString *const kParseHoistSrl;
FOUNDATION_EXPORT NSString *const kParseCustomer;
FOUNDATION_EXPORT NSString *const kObjectName;
FOUNDATION_EXPORT NSString *const kInspectionPoints;
FOUNDATION_EXPORT NSString *const kCoreDataClassCrane;
FOUNDATION_EXPORT NSString *const kCoreDataClassInspectionPoint;
FOUNDATION_EXPORT NSString *const kOptions;
FOUNDATION_EXPORT NSString *const kInspectionViewControllerPushed;
FOUNDATION_EXPORT NSString *const kCoreDataClassInspectionOption;
FOUNDATION_EXPORT NSString *const kCoreDataClassInspectedCrane;
FOUNDATION_EXPORT NSString *const kCoreDataClassAttributeHoistSrl;
FOUNDATION_EXPORT NSString *const kSelectedInspectedCrane;
FOUNDATION_EXPORT NSString *const kCoreDataClassCustomer;
FOUNDATION_EXPORT NSString *const kPrompts;


FOUNDATION_EXPORT NSString *const parseInspectionDetailsClassName;
FOUNDATION_EXPORT NSString *const parseInspectedCranesClassName;

FOUNDATION_EXPORT NSString *const kCoreDataClassPrompt;
FOUNDATION_EXPORT NSString *const kRequiresDeficiency;
FOUNDATION_EXPORT NSString *const kCoreDataClassCondition;

FOUNDATION_EXPORT NSString *const kParseToUser;
FOUNDATION_EXPORT NSString *const kParseFromUser;


// Notification Center
FOUNDATION_EXPORT NSString *const NOTIFICATION_CRANE_DETAILS_FINISHED_SAVING;
FOUNDATION_EXPORT NSString *const NOTIFICATION_HOISTSRL_SELECTED;
FOUNDATION_EXPORT NSString *const USER_INFO_SELECTED_CRANE_INSPECTION_POINTS;
FOUNDATION_EXPORT NSString *const NOTIFICATION_GOTO_CUSTOMER_INFO_PRESSED;
FOUNDATION_EXPORT NSString *const USER_INFO_SELECTED_INSPECTION_POINT;

FOUNDATION_EXPORT NSString *const UI_PROMPT_SHOWN;
FOUNDATION_EXPORT NSString *const UI_PROMPT_HIDDEN;
FOUNDATION_EXPORT NSString *const WATER_DISTRICT_CRANES_SAVED;
FOUNDATION_EXPORT NSString *const ELECTRIC_HOIST;

// Signature
FOUNDATION_EXPORT NSString *const SIGNATURE_IMAGE_FILENAME;
FOUNDATION_EXPORT NSString *const SIGNATURE_USER_DEFAULTS_KEY;

FOUNDATION_EXPORT NSString *const DOCUMENTS_FOLDER;

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
