//
//  Constants.swift
//  Graffiti
//
//  Created by adeiji on 4/7/18.
//  Copyright © 2018 Dephyned. All rights reserved.
//

import Foundation

let kImagesUrl = "images/"
let kAsiaBucket = "asia-graffiti"

// CollectionName
let kTagsCollection = "tags"
let kUsername = "username"
let kProfilePictureUrl = "profile_picture_url"
let kPictureUrl = "picture_url"
let kComments = "comments"
let kUserId = "user_id"
let kLikeCount = "like_count"
let kAddress = "address"
let kCity = "city"
let kCountry = "country"
let kState = "state"
let kZipCode = "zipCode"
let kTags = "hashtags"
let kShareWithFacebook = "isSharedWithFacebook"
let kName = "name"
let kComment = "comment"
let kTagId = "tagId"
let kProfilePictureData = "profile_picture_data"
let kCreatedAt = "created_at"
let kPieceCount = "piece_count"

let kUsersCollection = "users"
let kPhone = "phone_number"
let kOSVersion = "os_version"
let kFollowers = "followers"
let kFollowing = "following"
let kFirstName = "first_name"
let kLastName = "last_name"
let kIsBlocked = "isBlocked"
let kIsReported = "isReported"
let kIsActive = "isActive"
let kGroups = "groups"
let kDeviceId = "device_id"
let kIsLinkedWithFacebook = "isLinkedWithFacebook"
let kLikedTags = "liked_tags"

let kNotificationImageDownloaded = "com.notification.imageDownloaded"
let kNotificationImageUrl = "com.notification.imageUrl"

let kHashTagsCollection = "hashtags"
let kTagName = "name"

let kDocumentId = "document_id"

public class UserDefaultKeys {
    public static let kUserDefaultsProfileImageData = "userdefaults.profileimagedata"
    public static let kUserDefaultsProviderID = "userdefaults.providerid"
    public static let kUserDefaultsProfileImageURL = "userdefaults.profileimageurl"
    public static let kHashtags = "userdefaults.hashtags"
    public static let kUserId = "userdefaults.userid"
    public static let kLocation = "userdefaults.location"
    public static let kTimeSinceUsingApp = "userdefaults.timesinceusingapp"
    public static let kPieceScreen = "userdefaults.piecescreen"
    public static let kSpotScreen = "userdefaults.spotscreen"
    public static let kViewPiecesScreen = "userdefaults.viewpiecesscreen"
}

public class GRButtonTitles {
    public static let kFollow = "Follow"
    public static let kUnfollow = "Unfollow"
    public static let kEditProfile = "Edit Profile"
}

public class GRTagCollection {
    public static let kIsInstagram = "is_instagram"
    public static let kIsSpot = "is_spot"
    public static let kLocation = "location"
    public static let kLongitude = "longitude"
    public static let kLatitude = "latitude"
    public static let kDescription = "description"
    public static let kTextContent = "text_content"
    public static let kTagId = "tagId"
    public static let kHashtags = "hashtags"
    public static let kComments = "comments"
    public static let kReportedReason = "reported_reason"
}

public class GRUserCollectionConstants {
    public static let kFollowingCount = "following_count"
    public static let kFollowerCount = "follower_count"
    public static let kLocation = "location"
    public static let kBio = "bio"
    public static let kUserId = "user_id"
    public static let kUsername = "username"
    public static let kHashtagsFollowing = "tagsFollowing"
    public static let kProfilePictureUrl = "profile_picture_url"
    public static let kBlockedUsers = "blocked_users"
    public static let kIsReported = "is_reported"
}

public class GRRelationships {
    public static let kFollowee = "followee"
    public static let kFollower = "follower"
}

public class GRDatabaseCollectionConstants {
    public static let kActivity = "activities"
    public static let kRelationships = "relationships"
    public static let kUserCollection = "users"
    public static let kTags = "tags"
    public static let kFCMTokens = "fcm_tokens"
}

public class GRFCMTokens {
    public static let kToken = "token"
    public static let kUserId = "user_id"
}

public class GRCloudFunctions {
    public static let kGetDocumentsWithUser = "getDocumentsWithUser"
    public static let kCheckIfDocumentExists = "checkIfDocumentExists"
    public static let kDeleteDocuments = "deleteDocuments"
    public static let kGetNearbyDocuments = "getDocumentsNearLocation"
}

public class GRActivityConstants
{
    public static let kAction = "action"
    public static let kFromUserId = "user_id"
    public static let kToUserId = "to_user_id"
    public static let kMessage = "message"
    public static let kTagId = "tag_id"
    
    public enum ActivityType:String {
        case Like = "like"
        case Comment = "comment"
        case WentTo = "wentto"
        case Follow = "follow"
    }
}
