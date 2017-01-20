//
//  IAConstants.m
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import "IAConstants.h"

NSString *const kParseClassCrane = @"Crane";
NSString *const kParseInspectionDetailsHoistSrl = @"hoistSrl";
NSString *const kObjectName = @"name";
NSString *const kInspectionPoints = @"inspectionPoints";
NSString *const kOptions = @"options";
NSString *const kPrompts = @"prompts";
NSString *const kRequiresDeficiency = @"requiresDeficiency";

// Core Data
NSString *const kCoreDataClassCrane = @"InspectionCrane";
NSString *const kCoreDataClassInspectionPoint = @"InspectionPoint";
NSString *const kCoreDataClassInspectionOption = @"InspectionOption";
NSString *const kInspectionViewControllerPushed = @"com.inspection.app.inspection.view.controller.pushed";
NSString *const kCoreDataClassInspectedCrane = @"InspectedCrane";
NSString *const kCoreDataClassAttributeHoistSrl = @"hoistSrl";
NSString *const kSelectedInspectedCrane = @"selectedInspectedCrane";
NSString *const kCoreDataClassCustomer = @"Customer";
NSString *const kCoreDataClassPrompt = @"Prompt";
NSString *const kCoreDataClassCondition = @"Condition";
NSString *const ELECTRIC_HOIST = @"Electric Hoist";

// Notification Center
NSString *const NOTIFICATION_CRANE_DETAILS_FINISHED_SAVING = @"com.inspection.app.crane.details.finished.downloading";
NSString *const NOTIFICATION_HOISTSRL_SELECTED = @"com.inspection.app.hoistsrl.selected";
NSString *const NOTIFICATION_GOTO_CUSTOMER_INFO_PRESSED = @"com.inspection.app.goto.customer.info.pressed";
NSString *const USER_INFO_SELECTED_CRANE_INSPECTION_POINTS = @"com.inspection.app.selected.crane.inspection.points";
NSString *const USER_INFO_SELECTED_INSPECTION_POINT = @"com.inspection.app.selected.inspection.point";
NSString *const UI_PROMPT_SHOWN = @"com.inspection.app.prompt.shown";
NSString *const UI_PROMPT_HIDDEN = @"com.inspection.app.prompt.hidden";
NSString *const WATER_DISTRICT_CRANES_SAVED = @"com.inspection.app.water.district.cranes.saved";

// Signature
NSString *const SIGNATURE_IMAGE_FILENAME = @"signature";
NSString *const SIGNATURE_USER_DEFAULTS_KEY = @"com.signature.key";
