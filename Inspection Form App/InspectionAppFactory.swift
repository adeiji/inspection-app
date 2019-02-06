//
//  InspectionAppFactory.swift
//  Inspection Form App
//
//  Created by adeiji on 2/5/19.
//

import Foundation

@objc class InspectionAppFactory : NSObject {
    
    
    /// Convert a list of Firebase dictionary documents to CoreDataCondition objects
    ///
    /// - Parameter documents: The Firebase dictionary documents
    /// - Returns: The CoreDataCondition objects
    static func getConditionsFromFirebaseDocuments (documents:[FirebaseDocument]) -> [CoreDataCondition] {
        
        var conditions = [CoreDataCondition]();
        documents.forEach { (document) in
            conditions.append(getSingleConditionFromFirebaseDocument(document: document.data));
        }
        
        return conditions;
    }
    
    
    /// Convert a single Firebase Dictionary document to CoreDataCondition object
    ///
    /// - Parameter document: The Firebase dictionary document
    /// - Returns: The CoreDataCondition object
    @objc static func getSingleConditionFromFirebaseDocument (document:[String:Any]) -> CoreDataCondition {
        
        let condition = CoreDataCondition();
        
        condition.isDeficient = document[FirebaseInspectionConstants.IsDeficient] as? NSNumber
        condition.isApplicable = document[FirebaseInspectionConstants.IsApplicable] as? NSNumber
        condition.notes = document[FirebaseInspectionConstants.Notes] as? String ?? ""
        condition.optionSelectedIndex = document[FirebaseInspectionConstants.OptionSelectedIndex] as? NSNumber
        condition.hoistSrl = document[FirebaseInspectionConstants.HoistSrl] as? String ?? ""
        condition.optionLocation = document[FirebaseInspectionConstants.OptionLocation] as? NSNumber
        
        return condition;
    }
    
    
    /// Converts an array of Firebase Document objects to Inspected Crane Objects
    ///
    /// - Parameter documents: The Firebase Document objects
    /// - Returns: The Inspected Crane objects converted from the Firebase Document objects
    static func getCranesFromFirebaseDocuments (documents:[FirebaseDocument]) -> [InspectedCrane] {
        var cranes = [InspectedCrane]()
        
        documents.forEach { (document) in
            cranes.append(getCraneFromFirebaseDocument(document: document.data))
        }
        
        return cranes
    }
    
    /// Convert a single Firebase Dictionary document to InspectedCrane object
    ///
    /// - Parameter document: The Firebase dictionary document
    /// - Returns: The CoreDataCondition object
    @objc static func getCraneFromFirebaseDocument (document:[String:Any]) -> InspectedCrane {
        
        let crane = InspectedCrane();
        
        crane.capacity = document[FirebaseInspectionConstants.Capacity] as? String
        crane.craneDescription = document[FirebaseInspectionConstants.CraneDescription] as? String
        crane.craneSrl = document[FirebaseInspectionConstants.CraneSrl] as? String
        crane.equipmentNumber = document[FirebaseInspectionConstants.EquipmentNumber] as? String
        crane.hoistMdl = document[FirebaseInspectionConstants.HoistMdl] as? String
        crane.hoistMfg = document[FirebaseInspectionConstants.HoistMfg] as? String
        crane.mfg = document[FirebaseInspectionConstants.Mfg] as? String
        crane.type = document[FirebaseInspectionConstants.CraneType] as? String
        
        return crane
    }
    
    
    /// Converts a PFCrane object to a Dictionary
    ///
    /// - Parameter crane: The crane to convert
    /// - Returns: The converted crane to dictionary object
    static func getFirebaseQueryDocumentFromInspectedCrane (crane: PFCrane) -> [String:Any] {
        
        var craneObject = [String:Any]()
        
        craneObject[FirebaseInspectionConstants.Capacity] = crane.capacity
        craneObject[FirebaseInspectionConstants.CraneDescription] = crane.craneDescription
        craneObject[FirebaseInspectionConstants.CraneSrl] = crane.craneSrl
        craneObject[FirebaseInspectionConstants.EquipmentNumber] = crane.equipmentNumber
        craneObject[FirebaseInspectionConstants.HoistMdl] = crane.hoistMdl
        craneObject[FirebaseInspectionConstants.HoistMfg] = crane.hoistMfg
        craneObject[FirebaseInspectionConstants.HoistSrl] = crane.hoistSrl
        craneObject[FirebaseInspectionConstants.Mfg] = crane.mfg
        craneObject[FirebaseInspectionConstants.CraneType] = crane.type
        craneObject[FirebaseInspectionConstants.Id] = crane.objectId
        
        do {
            try crane.customer.fetchIfNeeded()
            try crane.fromUser.fetchIfNeeded()
            try crane.toUser.fetchIfNeeded()
            
            craneObject[FirebaseInspectionConstants.CustomerId] = crane.customer.objectId
            craneObject[FirebaseInspectionConstants.User] = crane.fromUser.objectId
            craneObject[FirebaseInspectionConstants.ToUser] = crane.toUser.objectId
        } catch {
            print("InspectionAppFactory.getFirebaseQueryDocumentFromInspectedCrane Trying to fetch object but object does not exist");
        }
        
        return craneObject
    }
    
    static func getFirebaseQueryDocumentFromUser (user: PFUser) -> [String:Any] {
        
        var userObject = [String:Any]()
        
        userObject[FirebaseInspectionConstants.Username] = user.username
        userObject[FirebaseInspectionConstants.Id] = user.objectId
        
        return userObject
        
    }
    
    static func getFirebaseQueryDocumentFromCustomer (customer: PFCustomer) -> [String:Any] {
        
        var customerObject = [String:Any]()
        
        customerObject[FirebaseInspectionConstants.CustomerName] = customer.name
        customerObject[FirebaseInspectionConstants.Contact] = customer.contact
        customerObject[FirebaseInspectionConstants.Address] = customer.address
        customerObject[FirebaseInspectionConstants.Email] = customer.email
        customerObject[FirebaseInspectionConstants.Id] = customer.objectId
        
        do {
            try customer.fromUser.fetchIfNeeded()
        } catch {
            customerObject[FirebaseInspectionConstants.User] = customer.fromUser.objectId
        }
        
        return customerObject
    }
    
}
