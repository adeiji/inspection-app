//
//  IACraneInspectionDetailsManager.swift
//  Inspection Form App
//
//  Created by adeiji on 2/7/19.
//

import Foundation

@objc class IACraneInspectionDetailsManagerSwift : NSObject {
    
    @objc func saveInspectionDetails () {
        DispatchQueue.main.async {
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = AppDelegate().managedObjectContext.persistentStoreCoordinator;
            
            let manager = IAFirebaseCraneInspectionDetailsManager()
            IACraneInspectionDetailsManager.shared()?.resetInspectionDetailsDatabase()
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
                
                guard let _ = try? context.save() else {
                    print("com.inspectionapp.coredata - Error saving crane details from Firebase \(String(describing: error?.localizedDescription))");
                    return
                }
                
                guard let _ = try? self.getAllCurrentUsersInspectionsFromServerUsingManagedObjectContext(context: context) else {
                    print("com.inspectionapp.coredata - There is no user logged in");
                    return
                }
                
                IACraneInspectionDetailsManager.shared()?.loadAllInspectionDetails()
                try? context.save()
            }
        }
    }
    
    
    /// Get all the inspections that the current user has done from the database
    ///
    /// - Parameter context: The context for Core Data
    /// - Throws: UserError.noUserLoggedIn
    @objc func getAllCurrentUsersInspectionsFromServerUsingManagedObjectContext (context: NSManagedObjectContext) throws {
        guard let userId = UtilityFunctions.getUserId() else {
            throw UserError.noUserLoggedIn
        }
        
        IAFirebaseCraneInspectionDetailsManager().getAllInspectedCranes(forUser: userId, context: context) { (error, inspectedCranes) in
            if let inspectedCranes = inspectedCranes {
                inspectedCranes.forEach({ (crane) in
                    let craneFromDb = IACraneInspectionDetailsManager.shared()?.getCraneFromDatabase(withHoistSrl: crane.hoistSrl, withContextOrNil: context)
                    if let inspectedCrane = craneFromDb {
                        inspectedCrane.conditions = crane.conditions
                    }
                })
                
                NotificationCenter.default.post(name: .CraneDetailsFinishedSaving, object: nil)
                try? context.save()
            }
        }
    }
    
    /// Share an inspection with another user
    ///
    /// - Parameters:
    ///   - hoistSrl: The hoist serial number of the crane that you are sharing the inspection of
    ///   - userId: The user id of the user to share the crane with
    @objc func shareInspection (hoistSrl: String, userId: String) {
        IAFirebaseCraneInspectionDetailsManager().updateInspection(craneId: hoistSrl, userId: userId, values: ["toUser":userId])
    }
    
    /// Backup all the cranes that are store don the device to the database
    @objc func backupCranesToFirebase (context: NSManagedObjectContext) {
        if let inspectedCranes = IACraneInspectionDetailsManager.shared()?.getAllInspectedCranes() as? [InspectedCrane] {
            inspectedCranes.forEach { (inspectedCrane) in
                var craneObject = InspectionAppFactory.getFirebaseQueryDocumentFromInspectedCrane(inspectedCrane: inspectedCrane, context: context)
                craneObject[FirebaseInspectionConstants.User] = UtilityFunctions.getUserId()
                FirebasePersistenceManager.addDocument(withCollection: FirebaseInspectionConstants.InspectedCraneCollectionName, data: craneObject, withId: (craneObject[FirebaseInspectionConstants.HoistSrl] as! String), shouldMerge: true, completion: { (error, document) in
                })
            }
        }
    }
    
    
    /// Get all the inspections that were sent to the current user of this device
    ///
    /// - Parameters:
    ///   - context: The context for Core Data
    ///   - completion: Returns either an error or the inspected crane objects
    @objc public func getAllCranesSentToCurrentUser (context:NSManagedObjectContext, completion: @escaping(Error?, [InspectedCrane]?) -> Void) {
        if let userId = UtilityFunctions.getUserId() {
            FirebasePersistenceManager.getDocuments(withCollection: FirebaseInspectionConstants.InspectedCranes, queryDocument: ["fromUser": userId], searchContainString: false) { (error, documents) in
                if let documents = documents {
                    let inspectedCranes = InspectionAppFactory.getCranesFromFirebaseDocuments(documents: documents, context:context)
                    completion(error, inspectedCranes)
                } else {
                    completion(error, nil)
                }
            }
        }
    }
    
    
    /// Gets all the users from the server using this application
    ///
    /// - Parameter completion: The users as dictionary values
    @objc func getAllUsers (completion:@escaping (Error?, [[String:Any]]) -> Void) {
        FirebasePersistenceManager.getDocuments(withCollection: FirebaseInspectionConstants.UserCollectionName) { (error, users) in
            if let users = users {
                completion(error, InspectionAppFactory.getDictionaryFromFirebaseDocuments(documents: users))
            }
        }
    }
}
