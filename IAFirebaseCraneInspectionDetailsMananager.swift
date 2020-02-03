//
//  IAFirebaseCraneInspectionDetailsMananager.swift
//  Inspection Form App
//
//  Created by adeiji on 2/1/19.
//

import Foundation

@objc class IAFirebaseCraneInspectionDetailsManager : NSObject {
    
    let INSPECTIONS_COLLECTION = "inspections"
    
    /// Get the option information for an inspection point
    ///
    /// - Parameter inspectionPoint: Inspection Point to get the options for
    /// - Returns: A list of options
    @objc private func getOptions (inspectionPoint: PFObject) -> [Any]? {
        guard let options = inspectionPoint["options"] as? [PFObject] else {
            return nil;
        }
        var optionObjects = [Any]();
        
        options.forEach({ (option) in
            do {
                try option.fetchIfNeeded();
            } catch {
                print(error.localizedDescription);
                return;
            }

            optionObjects.append(option["name"])
        })
        
        return optionObjects;
    }
    
    private func getPrompts (inspectionPoint: PFObject) -> [String:Any]? {
        guard let prompts = inspectionPoint[kPrompts] as? [String:Any] else {
            return nil;
        }

        return prompts;
    }
    
    
    /// Saves the cranes to Firebase using the crane parse objects
    ///
    /// - Parameter cranes: The cranes to save to the database
    @objc func saveCranes (cranes: [PFObject]) {
        cranes.forEach { (crane) in
            // Make sure this is an NSOrderedSet so that we keep the order of the inspection points
            let inspectionPoints = crane["inspectionPoints"] as? NSOrderedSet;
            var craneObject = [String:Any]();
            craneObject["name"] = crane["name"];
            var position = 0
            
            inspectionPoints?.forEach({ (inspectionPoint) in
                if let inspectionPoint = inspectionPoint as? PFObject {
                    do {
                        try inspectionPoint.fetchIfNeeded();
                    } catch {
                        print(error.localizedDescription);
                        return;
                    }
                    
                    var inspectionPointObject = [String: Any]();
                    
                    inspectionPointObject["id"] = UUID().uuidString;
                    inspectionPointObject[FirebaseInspectionConstants.Position] = position
                    
                    position = position + 1
                    
                    let options = getOptions(inspectionPoint: inspectionPoint);
                    if let options = options {
                        inspectionPointObject["options"] = options;
                    }
                    
                    guard let inspectionPointName = inspectionPoint["name"] as? String else {
                        // The inspection  name is not a string
                        return;
                    }
                    
                    inspectionPointObject[kPrompts] = self.getPrompts(inspectionPoint: inspectionPoint)
                    craneObject[inspectionPointName] = inspectionPointObject;
                }
            })
            
            let craneId = UUID().uuidString;
            // Save to Firebase
            FirebasePersistenceManager.addDocumentIfNotDuplicate(withCollection: "cranes", key:"name", value:crane["name"], document: craneObject, withId: craneId, completion: { (error, document) in
                if (error != nil) {
                    print(error?.localizedDescription ?? "");
                }
            })
        }
    }
    
    @objc func saveInspectedCranesFromParseCraneObject (cranes: [PFCrane]) {
        cranes.forEach { (crane) in
            
            let conditions = IACraneInspectionDetailsManager.shared()?.getAllConditionsFromServer(forCrane: crane)
            var craneObject = InspectionAppFactory.getFirebaseQueryDocumentFromInspectedCrane(crane: crane, conditions: conditions as? [PFObject]);
            
            do {
                if let customerId = crane.customer?.objectId {
                    try crane.customer?.fetchIfNeeded()
                    let customerObject = InspectionAppFactory.getFirebaseQueryDocumentFromCustomer(customer: crane.customer)
                    craneObject[FirebaseInspectionConstants.Customer] = customerObject
                    FirebasePersistenceManager.addDocumentIfNotDuplicate(withCollection: FirebaseInspectionConstants.CustomerCollectionName, key: FirebaseInspectionConstants.Id, value: customerId, document: customerObject, withId: customerId, completion: nil)
                }
            } catch {}
            
            do {
                if let fromUserId = crane.fromUser?.objectId {
                    try crane.fromUser?.fetchIfNeeded()
                    let fromUser = InspectionAppFactory.getFirebaseQueryDocumentFromUser(user: crane.fromUser)
                    FirebasePersistenceManager.addDocumentIfNotDuplicate(withCollection: FirebaseInspectionConstants.CustomerCollectionName, key: FirebaseInspectionConstants.Id, value: fromUserId, document: fromUser, withId: fromUserId, completion: nil)
                }
            } catch {}
            
            do {
                if let toUserId = crane.toUser?.objectId {
                    try crane.toUser?.fetchIfNeeded()
                    let toUser = InspectionAppFactory.getFirebaseQueryDocumentFromUser(user: crane.toUser)
                    FirebasePersistenceManager.addDocumentIfNotDuplicate(withCollection: FirebaseInspectionConstants.CustomerCollectionName, key: FirebaseInspectionConstants.Id, value: toUserId, document: toUser, withId: toUserId, completion: nil)
                }
                
            } catch {}
            
            if let craneId = crane.objectId {
                FirebasePersistenceManager.addDocumentIfNotDuplicate(withCollection: FirebaseInspectionConstants.InspectedCraneCollectionName, key: FirebaseInspectionConstants.Id, value: craneId, document: craneObject, withId: craneId, completion: nil)
            }
        }
    }
    
    /// Save an inspection along with all it's details to the server
    ///
    /// - Parameters:
    ///   - hoistSrl: The hoist serial number of the crane being inspected
    ///   - inspectionDetails: The inspection details and conditions
    ///   - userId: The user id of the one who did the inspection
    @objc func saveInspection (hoistSrl: String, inspectionDetails: [CoreDataCondition], userId: String) {
        var detailsArray = [[String:Any]]();
        inspectionDetails.forEach { (detail) in
            var detailsObject = [String:Any]();
            detailsObject["isDeficient"] = detail.isDeficient;
            detailsObject["isApplicable"] = detail.isApplicable;
            detailsObject["notes"] = detail.notes;
            detailsObject["optionSelectedIndex"] = detail.optionSelectedIndex;
            detailsObject["optionSelected"] = detail.optionSelected;
            detailsObject["hoistSrl"] = detail.hoistSrl;
            detailsObject["optionLocation"] = detail.optionLocation;
            detailsObject["user"] = userId;
            
            detailsArray.append(detailsObject);
        }
        
        var inspection = [String:Any]();
        inspection["details"] = detailsArray;
        FirebasePersistenceManager.addDocument(withCollection: "inspections", data: inspection, withId: "\(userId)-\(hoistSrl)") { (error, documents) in
            if (error != nil) {
                print(error?.localizedDescription ?? "");
            }
        }
    }
    
    
    /// Get all the conditions from the server for a crane
    ///
    /// - Parameters:
    ///   - hoistSrl: The hoist serial number of the crane
    ///   - completion: The completion block when done getting data
    @objc func getAllConditions(withHoistSrl hoistSrl: String, completion: @escaping (Error?, [CoreDataCondition]?) -> Void) {
        var query = [String:Any]();
        
        query["toUser"] = nil;
        query["user"] = UtilityFunctions.getUserId();
        query["hoistSrl"] = hoistSrl;
        
        FirebasePersistenceManager.getDocuments(withCollection: INSPECTIONS_COLLECTION, queryDocument: query) { (error, documents) in
            
            if let documents = documents {
                let conditions = InspectionAppFactory.getConditionsFromFirebaseDocuments(documents: documents);
                completion(error, conditions);
            } else {
                completion(error, nil);
            }
            
        }
    }
    
    @objc func getAllCranes (completion: @escaping (Error?, [[String:Any]]?) -> Void) {
        
        FirebasePersistenceManager.getDocuments(withCollection: FirebaseInspectionConstants.Cranes) { (error, documents) in
            var documentDataList = [[String:Any]]()
            if let documents = documents {
                documents.forEach({ (document) in
                    documentDataList.append(document.data)
                })
                
                completion(error, documentDataList)
            } else {
                completion(error, nil);
            }
        }
    }
    
    @objc func getAllInspectedCranes(forUser userId: String, completion: @escaping (Error?, [InspectedCrane]?) -> Void) {
        
        FirebasePersistenceManager.getDocuments(withCollection: FirebaseInspectionConstants.InspectedCranes, key: FirebaseInspectionConstants.User, value: userId) { (error, documents) in
            if let documents = documents {
                let cranes =  InspectionAppFactory.getCranesFromFirebaseDocuments(documents: documents)
                completion(error, cranes);
            }
            else {
                completion(error, nil);
            }
        }
    }
    
    /// Adds a new user to Firebase
    ///
    /// - Parameter name: The username
    /// - Returns: A generated id for the user
    @objc func addUser (name: String) -> String {
        var user = [String: String]();
        
        user["name"] = name;
        user["id"] = UUID().uuidString;
        
        FirebasePersistenceManager.addDocument(withCollection: "users", data: user) { (error, documents) in
            if (error != nil) {
                print(error?.localizedDescription ?? "");
            }
        }
        
        return user["id"]!;
    }
    
    @objc func deleteAllDataFromCollection (collectionName name: String, userId: String) {
        FirebasePersistenceManager.deleteDocuments(withCollection: name, queryDocument: [FirebaseInspectionConstants.User: userId])
    }
    
    @objc func updateInspection (craneId: String, userId: String, values: [String:Any]) {
        FirebasePersistenceManager.updateDocument(withId: craneId, collection: FirebaseInspectionConstants.InspectionDetailsCollectionName, updateDoc: values) { (error) in
            if let error = error {
                // LOG THIS
            }
        }
    }
    
    @objc func saveDocuments (inCollection collection: String, documents: [[String: Any]]) {
        documents.forEach { (document) in
            FirebasePersistenceManager.addDocument(withCollection: collection, data: document, completion: { (error, document) in
                if let _ = error {
                    print("Error saving document");
                } else {
                    print("Document saved successfully");
                }
            })
        }
    }
}

public class FirebaseInspectionConstants {
    static let IsDeficient = "isDeficient"
    static let IsApplicable = "isApplicable"
    static let Notes = "notes";
    static let OptionSelectedIndex = "optionSelectedIndex"
    static let HoistSrl = "hoistSrl"
    static let OptionLocation = "optionLocation"
    static let User = "user"
    static let Cranes = "cranes"
    static let InspectedCranes = "inspectedCranes"
    static let Conditions = "conditions"
    static let Position = "position"
    static let Options = "options"
    
    static let Capacity = "capacity"
    static let CraneDescription = "craneDescription"
    static let CraneSrl = "craneSrl"
    static let EquipmentNumber = "equipmentNumber"
    static let HoistMdl = "hoistMdl"
    static let HoistMfg = "hoistMfg"
    
    static let Mfg = "mfg"
    static let CraneType = "type"
    static let CustomerId = "customerId"
    static let ToUser = "toUser"
    
    static let Customer = "customer"
    static let CustomerName = "name"
    static let Username = "username"
    static let Contact = "contact"
    static let Address = "address"
    static let Email = "email"
    
    static let CustomerCollectionName = "customers"
    static let CraneCollectionName = "cranes"
    static let UserCollectionName = "users"
    static let InspectedCraneCollectionName = "inspectedCranes"
    static let InspectionDetailsCollectionName = "inspectionDetails"
    static let Id = "id"
    static let Name = "name"
}
