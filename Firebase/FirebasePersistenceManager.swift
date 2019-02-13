//
//  FirebasePersistenceManager.swift
//  Graffiti
//
//  Created by adeiji on 4/6/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI
import FirebaseFunctions
import FirebaseFirestore

/*
 
 This class handles all network request to Firebase Firestore and Google Docs
 
 */

class FirebasePersistenceManager: NSObject {
    
    static var timer:Timer!
    static let imageCache = NSCache<NSString, UIImage>()
    static var kBucketName:String! = "temp_bucket"
    
    /// Get the current user as a GRUser object
    ///
    /// - Returns: The current user as a GRUser object
    class func user () -> GRUser? {
        return GRUser()
    }

    
    /// The user id for the current logged in user
    ///
    /// - Returns: String - If there is a user logged in than that user's id if not, than nil
    class func getUserId () -> String! {
        if (Auth.auth().currentUser != nil) {
            return (Auth.auth().currentUser?.uid)!
        }
        
        let userDefaults = UserDefaults.standard
        if let userId = userDefaults.object(forKey: UserDefaultKeys.kUserId) as? String {
            return userId
        }
        
        return nil
    }
    
    /**
     Sets the profile image for the current user
     
     - parameters:
        - imageData: Data The data representation of the UIImage that you want to save
     */
    class func setProfileImage (imageData: Data) {
        if let user = self.user() {
            self.uploadImage(fullPath: "\(user.userId)/images/profile.jpg", imageData: imageData) { (url, error) in
                if let error = error {
                    print("Error uploading profile image with error: \(error)")
                } else {
                    FirebasePersistenceManager.user()?.profilePictureUrl = url
                    if let user = Auth.auth().currentUser {
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.photoURL = url
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                print("Error commiting photoURL change request with error: \(error)")
                            }
                        })
                    }
                    if let url = url {
                        self.updateDocument(withId: user.userId, collection: GRDatabaseCollectionConstants.kUserCollection, updateDoc: [GRUserCollectionConstants.kProfilePictureUrl:url.absoluteString], completion: { (error) in
                            if let error = error {
                                print("Error saving user document with error: \(error)")
                            }
                        })
                    }
                }
            }
        }
    }
    
    /// The current logged in user's profile picture
    ///
    /// - Returns: A String object representing the current user's profile picture url or nil if a user is not logged in
    class func getProfilePictureURL () -> String! {
        if (Auth.auth().currentUser != nil) {
            return Auth.auth().currentUser?.photoURL?.absoluteString
        }
        
        return nil

    }
    
    
    /// Checks whether someone is logged in or not
    ///
    /// - Returns: True if a user is logged in, false if no user logged in
    class func isLoggedIn () -> Bool {
        return Auth.auth().currentUser?.displayName != nil
    }
    
    
    /// Gets the username of the current logged in user
    ///
    /// - Returns: The username of the logged in user or nil if there is no user logged in
    class func getUsername () -> String {
        if let username = FirebasePersistenceManager.user()?.username {
            return username
        }
        
        return "Anonymous"
    }
    
    class func uploadImage (fullPath:String, imageData: Data, completion: @escaping (URL?, Error?) -> Void) {
        let storage = Storage.storage(url: "gs://\(kBucketName)")
        // Root reference
        let storageRef = storage.reference()
        let imageRef = storageRef.child(fullPath)
        
        let _ = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                // Error occurred
                if let error = error {
                    completion(nil, error)
                }
                
                return
            }
            storageRef.downloadURL(completion: { (url, error) in
                guard let downloadURL = url else {
                    return;
                }
                
                completion(downloadURL, error)
            })
        }
    }
    
    /**
     Description Add a document with an image that is stored with Firebase in a Google Files Bucket
     - parameters:
        - fullPath: String The path to where you want to save ex: images/{UUID}/picture.jpg
        - imageData: Data The Data object for the image
        - collection: String The collection in database to store to
        - data: [String:Any] The document that you want to save
        - completion: FirebaseRequestClosure? The block to run amongst completion
    ````
    FirebasePersistenceManager.addDocumentWithImage(fullPath: "userId/\(kImagesUrl)/\(NSUUID().uuidString)", imageData: imageData, collection: kTagsCollection, data: data )
     ````
     */
    class func addDocumentWithImage (fullPath: String, imageData: Data, collection:String, data:[String:Any], withId id:String? = nil, completion: FirebaseRequestClosure?) {
        let storage = Storage.storage(url: "gs://\(kBucketName)")
        // Root reference
        let storageRef = storage.reference()
        let imageRef = storageRef.child(fullPath)
        let _ = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                // Error occurred
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                guard let downloadUrl = url else {
                    return;
                }
                
                var myData = data;
                myData[kPictureUrl] = downloadUrl.absoluteString
                
                if let id = id {
                    self.addDocument(withCollection: collection, data: myData, withId: id, completion: { (error, document) in
                        completion?(error, document)
                    })
                } else {
                    self.addDocument(withCollection: collection, data: myData, completion: { (error, document) in
                        completion?(error, document)
                    })
                }
            })
        }
    }
    
    /// Loads an image from url and assigns it to an image view
    ///
    /// - Parameters:
    ///   - imageView: UIImageView The imageview to load the image on
    ///   - url: String The url of the image
    ///   - placeholderImage: The image that you want as a placeholder while the image is downloaded from URL
    class func loadImage (toImageView imageView: UIImageView, url: String, placeholderImage: UIImage!) {
        
        if url.range(of: "firebasestorage") == nil {
            imageView.sd_setImage(with: URL(string: url), completed: { (image, error, cacheType, url) in
                if let error = error {
                    print("Error showing image \(error) - FirebasePersistenceManager.loadImage")
                }
            })
        } else {
            let storage = Storage.storage(url: "gs://\(kBucketName)")
            let gsReference = storage.reference(forURL: url)
            let downloadTask = imageView.sd_setImage(with: gsReference, placeholderImage: placeholderImage)
            downloadTask?.observe(.failure, handler: { (snapshot) in
                guard let errorCode = (snapshot.error as NSError?)?.code else {
                    return
                }
                guard let error = StorageErrorCode(rawValue: errorCode) else {
                    return
                }
                switch (error) {
                case .objectNotFound:
                    // File doesn't exist
                    // Really need to make sure to finish this stuff
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    break
                case .cancelled:
                    // User cancelled the download
                    break
                    
                    /* ... */
                    
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // Another error occurred. This is a good place to retry the download.
                    break
                }
            })
        }
    }
    
    private class func saveImageToCache (url: URL?, image:UIImage?) {
        if let url = url {
            if let image = image {
                self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
            }
        }
    }
    
    /// Gets an image from a url
    ///
    /// - todo:
    /// If the user doesn't provide a URL than throw an error
    /// - Parameters:
    ///   - url: URL The url of the image
    ///   - completion: Closure of type <Error?, UIImage?>
    class func downloadImage (url: URL?, completion: @escaping (Error?, UIImage?) -> Void) {
        if let url = url {
            if let cachedImage = self.imageCache.object(forKey: url.absoluteString as NSString) {
                completion(nil, cachedImage)
            }
            else if url.absoluteString.range(of: "firebasestorage") == nil {
                UtilityFunctions.downloadImageFromHTTPS(url: url) { (error, image) in
                    if let error = error {
                        print("Error downloading image with error - \(error.localizedDescription)")
                    } else {
                        self.saveImageToCache(url: url, image: image)
                        completion(error, image)
                    }
                }
            } else {
                // Reference from a Google Cloud Storage URI
                let storage = Storage.storage(url: "gs://\(kBucketName)")
                let gsReference = storage.reference(forURL: url.absoluteString)
                gsReference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                    if let error = error {
                        // Uh-oh, an error occurred!
                        print("Error downloading image at url \(url): \(error)")
                        completion(error, nil)
                    } else {
                        if let data = data {
                            // Data is returned
                            let image = UIImage(data: data)
                            self.saveImageToCache(url: url, image: image)
                            completion(error, image)
                        }
                    }
                }
            }
        }
    }
    
    /**
     Adds a document to the Firebase Firestore with given
     - parameters:
        - collection: Name of the collection in Firebase database
        - data: The data to store in the Database
        - id: (Optional) The id that you want to set for the document's id.  If this is set than setData will be called as opposed to addDocument.  See Firebase Firestore docs for info on the difference between setData and addDocument
        - shouldMerge: (Optional) Boolean value indicating whether we should overwrite the data if it exists on the server or merge the data.  If shouldMerge is set to true, make sure that you also provide an id
        - completion: The closure to get results, of type FirebaseRequestClosure? Returns the created document
     */
    class func addDocument (withCollection collection:String, data:[String:Any], withId id:String? = nil, shouldMerge:Bool = false, completion: FirebaseRequestClosure?) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        self.startTimer()
        
        if id == nil {
            ref = db.collection(collection).addDocument(data: data) { (err) in
                if let err = err {
                    print ("Error adding document to collection \(collection): \(err)" )
                    return
                } else {
                    print("Document added to collection \(collection) with ID: \(ref!.documentID)")
                    completion?(nil, FirebaseDocument(documentId: ref!.documentID, data: data))
                }
            }
        } else {
            if shouldMerge {
                if id == nil {
                    fatalError("If you're going to merge than you need to make sure that you set the id, ex: withId: (id)")
                } else {
                    db.collection(collection).document(id!).setData(data, merge: true) { err in
                        if let err = err {
                            completion?(err, nil)
                        } else {
                            completion?(nil, FirebaseDocument(documentId: id!, data: data))
                        }
                    }
                }
            } else {
                db.collection(collection).document(id!).setData(data) { err in
                    if let err = err {
                        completion?(err, nil)
                    } else {
                        completion?(nil, FirebaseDocument(documentId: id!, data: data))
                    }
                }
            }
        }
    }

    class private func startTimer () {
        if self.timer != nil {
            self.timer.invalidate()
        }
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(multipleWriteFinished), userInfo: nil, repeats: false)
    }
    
    @objc class func multipleWriteFinished () {
        // Show the finished banner
//        UtilityFunctions.showTaskCompleted(title: "Finished Importing From Instagram")
    }
    
    /**
    Check to see if this document already has a document with the given key value.  If it's not a duplicate than it will be added to the db
     - parameters:
        - collection The collection to check
        - key - The key in the collection to see if is duplicate
        - value - The value of the key to check to see if is duplicate
        - document - The document that you want to store in firestore
        - id - (Optional) The id that you want to set for the document
        - completion - Closure of type <Error?, FirebaseDocument?>
     */
    class func addDocumentIfNotDuplicate (withCollection collection: String, key: String, value: Any, document:[String:Any], withId id:String? = nil, completion: FirebaseRequestClosure?) {
        let db = Firestore.firestore()
        let docRef = db.collection(collection).whereField(key, isEqualTo: value)
        docRef.getDocuments { (querySnapshot, err) in
            if querySnapshot!.documents.count == 0 {
                FirebasePersistenceManager.addDocument(withCollection: collection, data: document, withId: id, completion: { (error, document
                    ) in
                    completion?(error, document)
                })
            } else {
                completion?(nil, nil)
            }
        }
    }
    
    /**
     Gets the documents from firebase along with their respective user documents
     - parameters:
        - collection: The collection to check
        - key: - The key in the collection to see if is duplicate
        - value: - The value of the key to check to see if is duplicate
        - searchContainsString: - (Optional) a BOOL value indicating whether or not this is a prefix string search ie. "for" would return "for, fortress, forty"
        - completion: - <Error?, FirebaseDocument?> The completion closure returning the results of the query
     */
    class func getDocumentsWithUser (withCollection collection: String, key: String, value: Any, searchContainsString:Bool = false, completion: FirebaseRequestMultiDocClosure?)
    {
        let functions = Functions.functions()
        functions.httpsCallable(GRCloudFunctions.kGetDocumentsWithUser).call(["collection": collection, "key": key, "value": value]) { (docsWithUser, error) in
            if docsWithUser != nil && error == nil {
                let firebaseDocuments = self.convertUserDocumentsArrayToFirebaseDocuments(docsWithUser: docsWithUser!)
                completion?(nil, firebaseDocuments)
            } else {
                completion?(error, nil)
            }
        }
    }
    
    class private func convertUserDocumentsArrayToFirebaseDocuments (docsWithUser: HTTPSCallableResult) -> [FirebaseDocument]? {
        var firebaseDocuments = [FirebaseDocument]()
        
        // First check to see if the Document structure is of type Array of Dictionaries
        var docWithUserDataArray = docsWithUser.data as? [[String:Any]]
        
        // If it's not of type Array of Dictionaries than get the value for key tags which should contain a type Dictionary of arrays
        if docWithUserDataArray == nil {
            if let dict = docsWithUser.data as? [String:Any] {
                if dict.keys.count == 0 {
                    return firebaseDocuments
                }
                
                docWithUserDataArray = dict["tags"] as? [[String:Any]]
                // This means the data is all in the wrong format
                if docWithUserDataArray == nil {
                    fatalError("If the document is in the incorrect format, this is a very big problem because than we can't parse it properly")
                }
            } else {
                return firebaseDocuments
            }
        }
        
        for docWithUserData in docWithUserDataArray! {
            let user = docWithUserData["user"] as! [String:Any]
            var actualDocument = docWithUserData["document"] as! [String:Any]            
            actualDocument["user"] = user
            let firebaseDocument = FirebaseDocument(documentId: actualDocument[kDocumentId] as! String, data: actualDocument)
            firebaseDocuments.append(firebaseDocument)
        }
        return firebaseDocuments
        
    }
    
    
    /// Deletes documents from a Firebase collection
    ///
    /// - Parameters:
    ///   - collection: The collections which to
    ///   - queryDocument: The key, values of the field you want deleted
    ///   - documentId: Optional String - The ID of the document that you want to delete if that is known
    class func deleteDocuments (withCollection collection: String, queryDocument:[String:Any]? = nil, documentId:String? = nil)  {
        if let documentId = documentId {
            let db = Firestore.firestore()
            db.collection(collection).document(documentId).delete() { err in
                if let err = err {
                    print("Error removing document from collection \(collection) with id \(documentId): \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        } else {
            if let queryDocument = queryDocument {
                let keyValues = self.getKeyValues(queryDocument: queryDocument)
                let functions = Functions.functions()
                functions.httpsCallable(GRCloudFunctions.kDeleteDocuments).call(["collection": collection, "keys": keyValues.keys, "values": keyValues.values]) { (result, error) in
                    if let error = error {
                        print("FirebasePersistenceManager.deleteDocuments Error deleting document with key values: \(error.localizedDescription) ")
                    } else {
                        print(result?.data as? String ?? "Deleted document successfully from the server")
                    }
                }
            } else {
                print("You must enter a value either for documentId or for queryDocument")
            }
        }
    }
    
    /// Takes a dictionary of key values and turns it into a FirebaseKeyValues object which consists of a keys of type [String] and values of type [String]
    ///
    /// - Parameter queryDocument: The key values as a dictionary
    /// - Returns: FirebaseKeyValues - The queryDocument converted into seperate key value arrays
    private class func getKeyValues (queryDocument:[String:Any]) -> FirebaseKeyValues {
        var keys = [String]()
        var values = [Any]()
        for key in queryDocument.keys {
            keys.append(key)
            values.append(queryDocument[key]!)
        }
        
        return FirebaseKeyValues(keys: keys, values: values)
    }
    
    
    /// Check to see if the document exists in a Firebase collection
    ///
    /// - Parameters:
    ///   - collection: String The collection to search
    ///   - queryDocument: [String:Any] The key values to search for
    ///   - completion: Closure of type (Bool?, Error?) if Bool? is true than the document exists
    class func checkIfDocumentDoesExists (withCollection collection: String, queryDocument:[String:Any], completion: @escaping (Bool?, Error?) -> Void) {
        let functions = Functions.functions()
        var keys = [String]()
        var values = [Any]()
        for key in queryDocument.keys {
            keys.append(key)
            values.append(queryDocument[key]!)
        }
        functions.httpsCallable(GRCloudFunctions.kCheckIfDocumentExists).call(["collection": collection, "keys": keys, "values": values]) { (result, error) in
            if let error = error {
                print("FirebasePersistenceManager.CheckIfDocumentDoesExists failed with error: \(error.localizedDescription) for keys - \(keys) and values - \(values) for collection - \(collection)")
                completion(nil, error)
            } else {
                if let data = result?.data as? [String:Bool] {
                    if let _ = data["doesExists"] {
                        completion(true, nil) // Document does not exists
                    } else {
                        completion(false, nil) // Document exists
                    }
                }
            }
        }
    }
    
    
    /// Gets documents from a collection that match multiple key values
    ///
    /// - Parameters:
    ///   - collection: String The collection of which to search on
    ///   - queryDocument: [String:Any] The object containing the key values to search on
    ///   - completion: A closure of type FirebaseRequestMultiDocClosure - contains the documents received from Firebase Firestore collection
    class func queryWithMultipleKeyValues (withCollection collection: String, queryDocument:[String:Any], completion: @escaping FirebaseRequestMultiDocClosure) {
        let db = Firestore.firestore()
        let collectionRef = db.collection(collection)
        var query:Query!
        
        for key in queryDocument.keys {
            query = collectionRef.whereField(key, isEqualTo: queryDocument[key]!)
        }
        
        query.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("FirebasePersistenceManager.queryWithMultipleKeyValues Error retrieving documents with error: \(err.localizedDescription)")
                completion(err, nil)
            } else {
                completion(nil, convertSnapshotToFirebaseDocuments(querySnapshot: querySnapshot!))
            }
        }
    }
    
    class func convertSnapshotToFirebaseDocuments (querySnapshot: QuerySnapshot) -> [FirebaseDocument] {
        var documents = [FirebaseDocument]()
        for doc in querySnapshot.documents {
            print("\(doc.documentID) => \(doc.data())")
            documents.append(FirebaseDocument(documentId: doc.documentID, data: doc.data()))
        }
        return documents
    }
    
    class func getSearchQuery(value:String, collection:String, key:String) -> Query {
        let db = Firestore.firestore()
        var myValue = value
        let lastCharacter = myValue.last
        let nextLetter = UtilityFunctions.nextLetter(String(describing: lastCharacter!).lowercased())
        myValue.removeLast()
        myValue = myValue + nextLetter!
        
        let docRef = db.collection(collection).whereField(key, isGreaterThanOrEqualTo: value.lowercased()).whereField(key, isLessThan: myValue.lowercased())
        return docRef
    }
    
    class func getAllDocuments (count: Int? = nil, collection: String, completion: @escaping FirebaseRequestMultiDocClosure) {
        let db = Firestore.firestore()
        var docRef:Query!
        
        docRef = db.collection(collection)
        if let count = count {
            docRef.limit(to: count)
        }
        
        docRef.getDocuments { (querySnapshot, err) in
            docRef.getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion(err, nil)
                } else {
                    var documents = [FirebaseDocument]()
                    for doc in querySnapshot!.documents {
                        print("\(doc.documentID) => \(doc.data())")
                        documents.append(FirebaseDocument(documentId: doc.documentID, data: doc.data()))
                    }
                    completion(nil, documents)
                }
            }
        }
    }
    
    class func getDocuments (withCollection collection: String, key: String! = nil, value: Any! = nil, queryDocument:[String:Any]! = nil, searchContainString:Bool = false, completion: @escaping FirebaseRequestMultiDocClosure ) {
        if queryDocument != nil {
            queryWithMultipleKeyValues(withCollection: collection, queryDocument: queryDocument!, completion: completion)
        } else {
            if collection == kTagsCollection || collection == GRDatabaseCollectionConstants.kActivity {
                getDocumentsWithUser(withCollection: collection, key: key, value: value, completion: completion)
                return                
            }
            
            let db = Firestore.firestore()
            var docRef:Query!
            if searchContainString {
                docRef = self.getSearchQuery(value: value as! String, collection: collection, key: key)
            } else {
                docRef = db.collection(collection).whereField(key, isEqualTo: value)
            }
            
            docRef.getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion(err, nil)
                } else {
                    var documents = [FirebaseDocument]()
                    for doc in querySnapshot!.documents {
                        documents.append(FirebaseDocument(documentId: doc.documentID, data: doc.data()))
                    }
                    completion(nil, documents)
                }
            }
        }
    }
    
    class func getCurrentUser (userId: String, completion: @escaping FirebaseRequestClosure) {
        let db = Firestore.firestore()
        db.collection(GRDatabaseCollectionConstants.kUserCollection).document(userId)
            .addSnapshotListener { (document, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let document = document {
                    let firebaseDocument = self.convertDocSnapshotToFirebaseDoc(document: document)
                    completion(error, firebaseDocument)
                }
        }
    }
    
    class func convertDocSnapshotToFirebaseDoc (document: DocumentSnapshot) -> FirebaseDocument {
        return FirebaseDocument(documentId: document.documentID, data: document.data())
    }
    
    class func getDocumentsForUser (withCollection collection: String, userId: String, completion: @escaping (Error?, [FirebaseDocument]?) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection(collection).whereField(kUserId, isEqualTo: userId)
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(err, nil)
            } else {
                var documents = [FirebaseDocument]()
                for doc in querySnapshot!.documents {                    
                    documents.append(FirebaseDocument(documentId: doc.documentID, data: doc.data()))
                }
                completion(nil, documents)
            }
        }
    }
    
    class private func getToken(result: HTTPSCallableResult) -> String? {
        if let result = result.data as? [String:Any] {
            let token = result["token"] as? String
            return token
        }
        
        return nil
    }
    
    /**
     Removes only a field from a given collection with a given document ID
     
     - parameters:
        - collection: String The Firestore collection to delete from
        - field: String The field/key to delete
        - documentID: String the document ID of the document to remove the field from
     */
    class func deleteField(collection:String, field:String, documentId:String) {
        let db = Firestore.firestore()
        db.collection(collection).document(documentId).updateData([field : FieldValue.delete()]) { (error) in
            if let _ = error {
                print("FirebasePersistenceManager.deleteField Error deleting field \(field) from collection \(collection) with document ID \(documentId)")
            } else {
                print("FirebasePersistenceManager.deleteField \(field) deleted from collection \(collection) with document ID \(documentId)")
            }
        }
    }
    
    /**
     Gets all the documents nearby a user
     
     - Parameters:
         - latitude: Double The current latitude of the user
         - longitude: Double The current longitude of the user
         - forCollection: String The collection in which to get the documents from
         - userId: String The userId whom we're getting the locations near for
         - hashtags: [String] The hashtags that a user is following
         - completion: @escaping (Error?, Any?, String?) -> Void - The closure to execute upon completion
     - todo:
        - Right now we're getting an entire User Document with the document returned which is probably a little excessive
        - On the server side we need to only provide the user information necessary to be displayed which is username and profilePictureUrl
     */
    class func getNearbyDocuments (latitude:Double, longitude:Double, forCollection collection:String, userId: String, hashtags:[String], background:Bool? = false, completion: @escaping (Error?, [FirebaseDocument]?, String?) -> Void) {
        let functions = Functions.functions()
        var params = ["collection": collection, "user_id": userId, "hashtags":hashtags, "latitude": latitude, "longitude": longitude] as [String:Any]
        if let _ = background {
            params["isBackground"] = true
        }
        
        functions.httpsCallable(GRCloudFunctions.kGetNearbyDocuments).call(params) { (result, error) in
            if result != nil && error == nil {
                let firebaseDocuments = self.convertUserDocumentsArrayToFirebaseDocuments(docsWithUser: result!)
                let token = getToken(result: result!)
                completion(nil, firebaseDocuments, token)
            } else {
                completion(error, nil, nil)
            }
        }
    }
    
    class func testHTTPSFunction (latitude:Double, longitude:Double) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "localhost"
        urlComponents.path = "/graffiti-6cf5a/us-central1/getDocumentsNearLocationHTTPS"
        urlComponents.port = 8010
        let userId = URLQueryItem(name: "user_id", value: "\(self.getUserId()!)")
        let latitudeParam = URLQueryItem(name: "latitude", value: String(latitude))
        let longitudeParam = URLQueryItem(name: "longitude", value: String(longitude))
        let hashtags = URLQueryItem(name: "hashtags", value: ["apple", "california", "highway"].joined(separator: ","))
        urlComponents.queryItems = [userId, latitudeParam, longitudeParam, hashtags]
        guard let url = urlComponents.url else {
            fatalError("Could not create URL from components")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                print(response)
            }
        }
        
        task.resume()
    }
    
    /**
     Updates a document in a Firebase collection
     */
    class func updateDocument (withId documentId:String, collection: String, updateDoc:[String:Any], completion: ((Error?) -> Void)?) {
        let db = Firestore.firestore()
        let docRef = db.collection(collection).document(documentId)
        let batch = db.batch()
        
        batch.updateData(updateDoc, forDocument: docRef)
        batch.commit { (err) in
            if let err = err {
                print("Error writing batch \(err)")
                if completion != nil { completion!(err) }
            } else {
                print("Batch write succeeded.")
                if completion != nil { completion!(nil) }
            }
        }
    }
        
}

struct FirebaseDocument {
    var documentId:String!
    var data:[String: Any]!
}

struct FirebaseKeyValues {
    var keys:[String]
    var values:[Any]
}

typealias FirebaseRequestClosure = (Error?, FirebaseDocument?) -> Void
typealias FirebaseRequestMultiDocClosure = (Error?, [FirebaseDocument]?) -> Void
typealias FirebaseHTTPSRequestClosure = (Error?, HTTPSCallableResult?) -> Void
