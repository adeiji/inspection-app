//
//  IACraneInspectionDetailsManager.swift
//  Inspection Form App
//
//  Created by adeiji on 2/7/19.
//

import Foundation

class IACraneInspectionDetailsManagerSwift {

    func saveInspectionDetails () {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = AppDelegate().managedObjectContext.persistentStoreCoordinator;
        
        let manager = IAFirebaseCraneInspectionDetailsManager()
        manager.getAllCranes { (error, cranes) in
            if let cranes = cranes {
                cranes.forEach({ (crane) in
                    guard let entity = NSEntityDescription.entity(forEntityName: kCoreDataClassCrane, in: context) else {
                        return
                    }
                    
                    let craneObject = InspectionCrane.init(entity: entity, insertInto: context)
                    let inspectionPoints = InspectionAppFactory.getInspectionPointCoreDataObjects(object: crane, context: context, crane: craneObject)
                    
                    if let name = crane[FirebaseInspectionConstants.Name] as? String {
                        craneObject.name = name
                    }
                    if let inspectionPoints = inspectionPoints {
                        craneObject.inspectionPoints = NSOrderedSet(array: inspectionPoints)
                    }
                })
            }
        }
    }
}
