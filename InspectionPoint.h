//
//  InspectionPoint.h
//  Inspection Form App
//
//  Created by adeiji on 4/3/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InspectionCrane, InspectionOption;

@interface InspectionPoint : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSSet *inspectionOptions;
@property (nonatomic, retain) InspectionCrane *inspectionCrane;
@end

@interface InspectionPoint (CoreDataGeneratedAccessors)

- (void)addInspectionOptionsObject:(InspectionOption *)value;
- (void)removeInspectionOptionsObject:(InspectionOption *)value;
- (void)addInspectionOptions:(NSSet *)values;
- (void)removeInspectionOptions:(NSSet *)values;

@end
