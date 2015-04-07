//
//  IAConstants.m
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import "IAConstants.h"

NSString *const kParseClassCrane = @"Crane";
NSString *const kObjectName = @"name";
NSString *const kInspectionPoints = @"inspectionPoints";
NSString *const kOptions = @"options";


// Core Data
NSString *const kCoreDataClassCrane = @"InspectionCrane";
NSString *const kCoreDataClassInspectionPoint = @"InspectionPoint";
NSString *const kCoreDataClassInspectionOption = @"InspectionOption";
NSString *const kInspectionViewControllerPushed = @"com.inspection.app.inspection.view.controller.pushed";
NSString *const kCoreDataClassInspectedCrane = @"InspectedCrane";
NSString *const kCoreDataClassAttributeHoistSrl = @"hoistSrl";
NSString *const kSelectedInspectedCrane = @"selectedInspectedCrane";
NSString *const kCoreDataClassCustomer = @"Customer";
// Notification Center
NSString *const NOTIFICATION_CRANE_DETAILS_FINISHED_SAVING = @"com.inspection.app.crane.details.finished.downloading";
NSString *const NOTIFICATION_HOISTSRL_SELECTED = @"com.inspection.app.hoistsrl.selected";
NSString *const USER_INFO_SELECTED_CRANE_INSPECTION_POINTS = @"com.inspection.app.selected.crane.inspection.points";