//
//  GRUser.swift
//  Graffiti
//
//  Created by adeiji on 4/10/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation
import UIKit

class GRUser: NSObject {
    
    var profilePicture:UIImage!
    
    var username:String?
    var profilePictureUrl:URL?
    var userId:String!
    var pieceCount:Int!
    var phone:String!
    var firstName:String!
    var lastName:String!
    var isBlocked:Bool!
    var isReported:Bool!
    var isActive:Bool!
    var deviceId:String!
    var isLinkedWithFacebook:Bool!
    var likedTags:[String]!
    var followingCount:Int!
    var followerCount:Int!
    var location:String?
    var bio:String?
    var documentId:String!
    var hashtags:[String] = [String]()
    var blockedUsers:[String] = [String]()
    
    func userFromDict(dict: [String:Any], id: String) -> GRUser {

        self.username = dict[kUsername] as? String
        let url = dict[kProfilePictureUrl] as? String
        if let url = url {
            self.profilePictureUrl = URL(string:url)
        }
        
        self.userId = dict[kUserId] as? String
        self.pieceCount = dict[kPieceCount] as? Int ?? 0
        self.phone = dict[kPhone] as? String
        self.firstName = dict[kFirstName] as? String
        self.lastName = dict[kLastName] as? String
        self.isBlocked = dict[kIsBlocked] as? Bool
        self.isReported = dict[kIsReported] as? Bool
        self.isActive = dict[kIsActive] as? Bool
        self.deviceId = dict[kDeviceId] as? String
        self.isLinkedWithFacebook = dict[kIsLinkedWithFacebook] as? Bool
        self.likedTags = dict[kLikedTags] as? [String]
        self.followingCount = dict[GRUserCollectionConstants.kFollowingCount] as? Int ?? 0
        self.followerCount = dict[GRUserCollectionConstants.kFollowerCount] as? Int ?? 0
        self.location = dict[GRUserCollectionConstants.kLocation] as? String ?? ""
        self.bio = dict[GRUserCollectionConstants.kBio] as? String ?? ""
        self.blockedUsers = dict[GRUserCollectionConstants.kBlockedUsers] as? [String] ?? [String]()
        
        if let hashtags = dict[GRUserCollectionConstants.kHashtagsFollowing] as? [String:Any] {
            for key in hashtags.keys {
                self.hashtags.append(key)
            }
        }
        
        if self.likedTags == nil { self.likedTags = [String]() }
        self.documentId = id
        if dict[kProfilePictureData] != nil {
            self.profilePicture = UIImage(data: (dict[kProfilePictureData] as? Data)!)
        }
        if self.profilePicture == nil {
            if self.profilePictureUrl != nil {
                FirebasePersistenceManager.downloadImage(url: self.profilePictureUrl!, completion: { (error, image) in
                    if error == nil {
                        self.profilePicture = image
                    }
                })
            }
        }
        
        return self
    }
}
