//
//  InspectionAppFactory.swift
//  Inspection Form App
//
//  Created by adeiji on 2/5/19.
//

import Foundation

@objc class InspectionAppFactory : NSObject {
    
    
    
    static func getDictionaryFromFirebaseDocuments (documents: [FirebaseDocument]) -> [[String:Any]] {
        var documentObjects = [[String:Any]]()
        
        documents.forEach { (document) in
            documentObjects.append(document.data)
        }
        
        return documentObjects
    }
    
    /// Convert a list of Firebase dictionary documents to CoreDataCondition objects
    ///
    /// - Parameter documents: The Firebase dictionary documents
    /// - Returns: The CoreDataCondition objects
    static func getConditionsFromFirebaseDocuments (documents:[FirebaseDocument], context:NSManagedObjectContext) -> [CoreDataCondition] {
        
        var conditions = [CoreDataCondition]();
        documents.forEach { (document) in
            conditions.append(getSingleConditionFromFirebaseDocument(document: document.data, context: context));
        }
        
        return conditions;
    }
    
    
    /// Convert a single Firebase Dictionary document to CoreDataCondition object
    ///
    /// - Parameter document: The Firebase dictionary document
    /// - Returns: The CoreDataCondition object
    @objc static func getSingleConditionFromFirebaseDocument (document:[String:Any], context:NSManagedObjectContext) -> CoreDataCondition {
        
        let entity = NSEntityDescription.entity(forEntityName: kCoreDataClassCondition, in: context)
        
        let condition = CoreDataCondition(entity: entity!, insertInto: context)
        
        if let isDeficient = document[FirebaseInspectionConstants.IsDeficient] as? Int {
            condition.isDeficient = NSNumber(value: isDeficient)
        }
        
        if let isApplicable = document[FirebaseInspectionConstants.IsApplicable] as? Int {
            condition.isApplicable = NSNumber(value: isApplicable)
        }
        
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
    static func getCranesFromFirebaseDocuments (documents:[FirebaseDocument], context:NSManagedObjectContext) -> [InspectedCrane] {
        var cranes = [InspectedCrane]()
        
        documents.forEach { (document) in
            cranes.append(getCraneFromFirebaseDocument(document: document.data, context:context))
        }
        
        return cranes
    }
    
    /// Convert a single Firebase Dictionary document to InspectedCrane object
    ///
    /// - Parameter document: The Firebase dictionary document
    /// - Returns: The CoreDataCondition object
    @objc static func getCraneFromFirebaseDocument (document:[String:Any], context:NSManagedObjectContext) -> InspectedCrane {
        // See if this crane has already been inspected on this device
        var crane = IACraneInspectionDetailsManager.shared()?.getCraneFromDatabase(withHoistSrl: (document[FirebaseInspectionConstants.HoistSrl] as! String), withContextOrNil: context)
        
        // If this crane has not been inspected on this device, than create a new Inspected Crane object
        if crane == nil {
            crane = IACraneInspectionDetailsManager.shared()?.getNewInspectedCraneObject(withHoistSrl: document[FirebaseInspectionConstants.HoistSrl] as? String, withContextOrNil: context);
        }
        
        // Fill all the information in for the new crane from the crane information stored in the dictionary from Firebase
        crane?.capacity = document[FirebaseInspectionConstants.Capacity] as? String
        crane?.craneDescription = document[FirebaseInspectionConstants.CraneDescription] as? String
        crane?.craneSrl = document[FirebaseInspectionConstants.CraneSrl] as? String
        crane?.hoistSrl = document[FirebaseInspectionConstants.HoistSrl] as? String
        crane?.equipmentNumber = document[FirebaseInspectionConstants.EquipmentNumber] as? String
        crane?.hoistMdl = document[FirebaseInspectionConstants.HoistMdl] as? String
        crane?.hoistMfg = document[FirebaseInspectionConstants.HoistMfg] as? String
        crane?.mfg = document[FirebaseInspectionConstants.Mfg] as? String
        crane?.type = document[FirebaseInspectionConstants.CraneType] as? String
        
        let conditions = document[FirebaseInspectionConstants.Conditions] as? [[String:Any]]
        IACraneInspectionDetailsManager.shared()?.removeAllConditions(for: crane!, using: context)
        var conditionObjects = [CoreDataCondition]()
        // Create the condition objects
        if let conditions = conditions {
            conditions.forEach { (condition) in
                let conditionCoreDataObject = self.getSingleConditionFromFirebaseDocument(document: condition, context:context)
                conditionObjects.append(conditionCoreDataObject)
            }
        }
        
        
        return crane!
    }
    
    
    
    /// Converts a PFCrane object to a Dictionary
    ///
    /// - Parameter crane: The crane to convert
    /// - Returns: The converted crane to dictionary object
    static func getFirebaseQueryDocumentFromInspectedCrane (crane: PFCrane, conditions: [PFObject]?) -> [String:Any] {
        
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
        
        var listOfConditions = [[String:Any]]()
        
        if let conditions = conditions as? [PFInspectionDetails] {
            conditions.forEach { (condition) in
                var conditionObject = [String:Any]()
                conditionObject[FirebaseInspectionConstants.IsDeficient] = condition.isDeficient
                conditionObject[FirebaseInspectionConstants.IsApplicable] = condition.isApplicable
                conditionObject[FirebaseInspectionConstants.Notes] = condition.notes
                conditionObject[FirebaseInspectionConstants.OptionSelectedIndex] = condition.optionSelectedIndex
                conditionObject[FirebaseInspectionConstants.OptionLocation] = condition.optionLocation
                conditionObject[FirebaseInspectionConstants.HoistSrl] = condition.hoistSrl
                
                if condition.toUser != nil {
                    conditionObject[FirebaseInspectionConstants.ToUser] = condition.toUser.objectId
                }
                
                if condition.fromUser != nil {
                    conditionObject[FirebaseInspectionConstants.User] = condition.fromUser.objectId
                }
                
                listOfConditions.append(conditionObject)
            }
        }
        
        craneObject[FirebaseInspectionConstants.Conditions] = listOfConditions
        
        do {
            if (crane.customer != nil) {
                try crane.customer.fetchIfNeeded()
                craneObject[FirebaseInspectionConstants.CustomerId] = crane.customer.objectId
            }
            if crane.fromUser != nil {
                try crane.fromUser.fetchIfNeeded()
                craneObject[FirebaseInspectionConstants.User] = crane.fromUser.objectId
            }
            if crane.toUser != nil {
                try crane.toUser.fetchIfNeeded()
                craneObject[FirebaseInspectionConstants.ToUser] = crane.toUser.objectId
            }
            
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
        
        do {
            try customer.fetch()
            
            if let name = customer["name"], let contact = customer["contact"], let address = customer["address"], let email = customer["email"], let id = customer.objectId {
                customerObject[FirebaseInspectionConstants.CustomerName] = name
                customerObject[FirebaseInspectionConstants.Contact] = contact
                customerObject[FirebaseInspectionConstants.Address] = address
                customerObject[FirebaseInspectionConstants.Email] = email
                customerObject[FirebaseInspectionConstants.Id] = id
                
                try customer.fromUser.fetchIfNeeded()
                if let userId = customer.fromUser.objectId {
                    customerObject[FirebaseInspectionConstants.User] = userId
                }
            }
        } catch {
            
        }
        
        return customerObject
    }
    
    static func getInspectionPointCoreDataObjects (object: [String:Any], context: NSManagedObjectContext, crane: InspectionCrane) -> [InspectionPoint]? {
        
        guard let entity = NSEntityDescription.entity(forEntityName: kCoreDataClassInspectionPoint, in: context) else {
            return nil
        }
        var inspectionPoints = [InspectionPoint]()
        
        let keys = object.keys.sorted { (key1, key2) -> Bool in
            return key1 < key2
        }
        
        keys.forEach { (key) in
            let inspectionPoint = InspectionPoint(entity: entity, insertInto: context)
            if key != "name" {
                inspectionPoint.name = key
                let inspectionPointFirebaseObject = object[key] as? [String:Any];
                
                if let options = inspectionPointFirebaseObject?[FirebaseInspectionConstants.Options] as? [String] {
                    inspectionPoint.inspectionOptions = getOptionCoreDataObjects(options: options, context: context)
                }
                
                if let prompts = inspectionPointFirebaseObject?[kPrompts] as? [Any] {
                    inspectionPoint.prompts = getPromptCoreDataObjects(prompts: prompts, context: context, inspectionPoint: inspectionPoint)
                }
                
                inspectionPoint.inspectionCrane = crane
                inspectionPoints.append(inspectionPoint)
            }
        }

        return inspectionPoints
    }
    
    static func getPromptCoreDataObjects (prompts: [Any], context: NSManagedObjectContext, inspectionPoint: InspectionPoint) -> NSOrderedSet? {
        
        var promptObjects = [Prompt]()
        
        prompts.forEach { (prompt) in
            
            guard let entity = NSEntityDescription.entity(forEntityName: kCoreDataClassPrompt, in: context) else {
                return
            }
            
            let promptCoreDataObject = Prompt.init(entity: entity, insertInto: context)
            if let title = prompt as? String {
                promptCoreDataObject.title = title
            } else if let promptObject = prompt as? [String:Any] {
                promptCoreDataObject.title = promptObject[kObjectName] as? String
                promptCoreDataObject.requiresDeficiency = promptObject[kRequiresDeficiency] == nil ? NSNumber(value: false) : NSNumber(value: true)
                promptCoreDataObject.inspectionPoint = inspectionPoint
            }
            
            promptObjects.append(promptCoreDataObject)
        }
        
        return NSOrderedSet(array: promptObjects)
        
    }
    
    static func getOptionCoreDataObjects (options: [String], context: NSManagedObjectContext) -> NSOrderedSet? {
        
        var inspectionOptions = [InspectionOption]()
        
        options.forEach { (option) in
            guard let entity = NSEntityDescription.entity(forEntityName: kCoreDataClassInspectionOption, in: context) else {
                return
            }
            
            let inspectionOptionObject = InspectionOption(entity: entity, insertInto: context)
            inspectionOptionObject.name = option
            inspectionOptions.append(inspectionOptionObject)
        }
        
        return NSOrderedSet(array: inspectionOptions)
    }
    
    static func getFirebaseQueryDocumentFromInspectedCrane (inspectedCrane: InspectedCrane, context:NSManagedObjectContext) -> [String:Any] {
        
        var craneObject = [String:Any]()
        
        craneObject[FirebaseInspectionConstants.Capacity] = inspectedCrane.capacity
        craneObject[FirebaseInspectionConstants.CraneDescription] = inspectedCrane.craneDescription
        craneObject[FirebaseInspectionConstants.CraneSrl] = inspectedCrane.craneSrl
        craneObject[FirebaseInspectionConstants.EquipmentNumber] = inspectedCrane.equipmentNumber
        craneObject[FirebaseInspectionConstants.HoistMdl] = inspectedCrane.hoistMdl
        craneObject[FirebaseInspectionConstants.HoistMfg] = inspectedCrane.hoistMfg
        craneObject[FirebaseInspectionConstants.HoistSrl] = inspectedCrane.hoistSrl
        craneObject[FirebaseInspectionConstants.Mfg] = inspectedCrane.mfg
        craneObject[FirebaseInspectionConstants.CraneType] = inspectedCrane.type
        
        var conditionObjects = [[String:Any]]()
        var conditions = IACraneInspectionDetailsManager.shared()?.getAllConditions(for: inspectedCrane, withContextOrNil: context)
        conditions?.forEach({ (condition) in
            if let condition = condition as? CoreDataCondition {
                conditionObjects.append(getFirebaseQueryDocumentFromCondition(condition: condition))
            }            
        })
        
        craneObject[FirebaseInspectionConstants.Conditions] = conditionObjects
        
        
        return craneObject
    }
    
    static func getFirebaseQueryDocumentFromCondition (condition: CoreDataCondition) -> [String:Any] {
        
        var conditionObject = [String:Any]()
        
        conditionObject[FirebaseInspectionConstants.IsDeficient] = condition.isDeficient == 1 ? true : false
        conditionObject[FirebaseInspectionConstants.IsApplicable] = condition.isApplicable == 1 ? true : false
        conditionObject[FirebaseInspectionConstants.Notes] = condition.notes
        conditionObject[FirebaseInspectionConstants.OptionSelectedIndex] = condition.optionSelectedIndex
        conditionObject[FirebaseInspectionConstants.OptionLocation] = condition.optionLocation
        conditionObject[FirebaseInspectionConstants.HoistSrl] = condition.hoistSrl
        
        return conditionObject
    }
}
