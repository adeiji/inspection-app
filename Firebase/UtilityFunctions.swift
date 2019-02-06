//
//  UtilityFunctions.swift
//  Graffiti
//
//  Created by adeiji on 4/10/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import UIKit
import MapKit

@objc class UtilityFunctions: NSObject{
    
    static var finishedTaskView:UIView!
    static let imageCache = NSCache<NSString, UIImage>()
    static let kUsername = "username"
    static let kUserId = "userId"
    
    class func downloadImageFromHTTPS (url: URL, completion: @escaping (Error?, UIImage?) -> Void) {
        let session = URLSession(configuration: .default)
        //creating a dataTask
        let getImageFromUrl = session.dataTask(with: url) { (data, response, error) in
            //if there is any error
            if let e = error {
                //displaying the message
                print("Error Occurred: \(e)")
                DispatchQueue.main.sync {
                    completion(error, nil)
                }
            } else {
                //in case of now error, checking wheather the response is nil or not
                if (response as? HTTPURLResponse) != nil {
                    //checking if the response contains an image
                    if let imageData = data {
                        //getting the image
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.sync {
                            completion(nil, image)
                        }
                    } else {
                        print("Image file is currupted")
                    }
                } else {
                    print("No response from server for https request: \(url.absoluteString)")
                }
            }
        }
        
        //starting the download task
        getImageFromUrl.resume()
    }
    
    class func removeTaskCompletedView () {
        self.finishedTaskView.removeFromSuperview()
    }
    
    class func getTagsFromString (text: String) -> [String] {
        let words = text.split(separator: " ")
        var hashTags = [String]()
        for word in words {
            if word.hasPrefix("#") {
                let wordWithNoHashtag = word.replacingOccurrences(of: "#", with: "")
                hashTags.append(String(wordWithNoHashtag.lowercased()))
            }
        }
        
        return hashTags
    }
    
    class func tagObjectsToArray (tags: [String:Bool]?) -> [String] {
        if tags == nil {
            return [String]()
        }
        var tagsArray = [String]()
        for tag in (tags?.keys)! {
            tagsArray.append(tag)
        }
        
        return tagsArray
    }
    
    class func nextLetter(_ letter: String) -> String? {
        // Check if string is build from exactly one Unicode scalar:
        guard let uniCode = UnicodeScalar(letter) else {
            return nil
        }
        switch uniCode {
        case "a" ..< "z":
            return String(UnicodeScalar(uniCode.value + 1)!)
        default:
            return "a"
        }
    }
    
    class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @objc class func saveUser (name: String, userId: String) {
        let defaults = UserDefaults.standard;
        defaults.set(name, forKey: kUsername);
        defaults.set(userId, forKey: kUserId);
        defaults.synchronize();
    }
    
    @objc class func getUserId () -> String? {
        let defaults = UserDefaults.standard;
        let userId = defaults.string(forKey: kUserId)
        
        return userId;
    }
}

