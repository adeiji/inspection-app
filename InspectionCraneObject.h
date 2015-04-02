//
//  InspectionCraneObject.h
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import <CoreData/CoreData.h>

@interface InspectionCraneObject : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSSet *inspectionPoints;
@end

@interface InspectionCraneObject (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(NSManagedObject *)value;
- (void)removeRelationshipObject:(NSManagedObject *)value;
- (void)addRelationship:(NSSet *)values;
- (void)removeRelationship:(NSSet *)values;

@end
