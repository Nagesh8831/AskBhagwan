//
//  UserDAO.swift
//  ProjectAlex
//
//  Created by Mac on 14/04/18.
//  Copyright © 2018 Ravi Deshmukh. All rights reserved.
//

import UIKit
enum UserDefaultKeys: String {
   
    case userId = "id"
    case username = "username"
    case email = "email"
    case password = "password"
    case phone_number = "phone_number"
    case country_id = "country_id"
    case state_id = "state_id"
    case city = "city"
    case sanyas_name = "sanyas_name"
    case about_me = "about_me"
    case profile_photo = "profile_photo"
    case background_photo = "background_photo"
    case is_banned = "is_banned"
    case status = "status"
    case added = "added"
    case updated = "updated"
    case subscriptionEndDate = "subscriptionEndDate"
    case subscriptionStatus = "subscriptionStatus"
    


    
    // All keys need to be removed when user log out
    static func allKeys() -> [String] {
        let keyArray: [UserDefaultKeys] = [
            .userId,
            .username,
            .email,
            .password,
            .phone_number,
            .country_id,
            .state_id,
            .city,
            .sanyas_name,
            .about_me,
            .profile_photo,
            .background_photo,
            .is_banned,
            .status,
            .added,
            .updated,
            .subscriptionEndDate,
            .subscriptionStatus
        ]
        return keyArray.flatMap({ $0.rawValue })
    }
}
class UserDAO: NSObject {

    /// A user class to represent registered user in system.
        var userId : String?
        var username: String?
        var email: String?
        var phone_number: String?
        var country_id: String?
        var password: String?
        var state_id: String?
        var city: String?
        var sanyas_name: String?
        var about_me: String?
        var profile_photo: String?
        var background_photo: String?
        var is_banned: String?
        var status: String?
        var added: String?
        var updated: String?
        var subscriptionEndDate: String?
        var subscriptionStatus: String?
 
        
        required public init?(response: Any) {
            guard let userData = response as? [String: Any],
                let userId = userData["id"] as? String,
                let email = userData["email"] as? String else { return nil }
            self.userId = userId
            self.email = email
            if let username = userData["username"] as? String{self.username = username}
            if let phone_number = userData["phone_number"] as? String{self.phone_number = phone_number}
            if let country_id = userData["country_id"] as? String{self.country_id = country_id}
            if let password = userData["password"] as? String{self.password = password}
            if let state_id = userData["state_id"] as? String{self.state_id = state_id}
            if let city = userData["city"] as? String{self.city = city}
            if let sanyas_name = userData["sanyas_name"] as? String{self.sanyas_name = sanyas_name}
            if let about_me = userData["about_me"] as? String{self.about_me = about_me}
            if let profile_photo = userData["profile_photo"] as? String{self.profile_photo = profile_photo}
            if let background_photo = userData["background_photo"] as? String{self.background_photo = background_photo}
            if let is_banned = userData["is_banned"] as? String{self.is_banned = is_banned}
            if let status = userData["status"] as? String{   self.status = status}
            if let added = userData["added"] as? String{
                let added = added.replacingOccurrences(of: "-", with: ":")
                self.added = added
            }
            if let updated = userData["updated"] as? String{self.updated = updated}
            if let subscriptionEndDate = userData["subscriptionEndDate"] as? String{self.subscriptionEndDate = subscriptionEndDate}
            if let subscriptionStatus = userData["subscriptionStatus"] as? String {self.subscriptionStatus = subscriptionStatus}
         
            
        }
        init(userId: String, email: String) {
            self.userId = userId
            self.email = email
            super.init()
        }
        func saveAsDefaultUser() {
            let userDefault = UserDefaults.standard
            userDefault.set(userId, forKey: UserDefaultKeys.userId.rawValue)
            userDefault.set(username, forKey: UserDefaultKeys.username.rawValue)
            userDefault.set(email, forKey: UserDefaultKeys.email.rawValue)
            userDefault.set(phone_number, forKey: UserDefaultKeys.phone_number.rawValue)
            userDefault.set(country_id, forKey: UserDefaultKeys.country_id.rawValue)
            userDefault.set(password, forKey: UserDefaultKeys.password.rawValue)
            userDefault.set(state_id, forKey: UserDefaultKeys.state_id.rawValue)
            userDefault.set(city, forKey: UserDefaultKeys.city.rawValue)
            userDefault.set(sanyas_name, forKey: UserDefaultKeys.sanyas_name.rawValue)
            userDefault.set(about_me, forKey: UserDefaultKeys.about_me.rawValue)
            userDefault.set(profile_photo, forKey: UserDefaultKeys.profile_photo.rawValue)
            userDefault.set(background_photo, forKey: UserDefaultKeys.background_photo.rawValue)
            userDefault.set(is_banned, forKey: UserDefaultKeys.is_banned.rawValue)
            userDefault.set(status, forKey: UserDefaultKeys.status.rawValue)
            userDefault.set(added, forKey: UserDefaultKeys.added.rawValue)
            userDefault.set(updated, forKey: UserDefaultKeys.updated.rawValue)
            userDefault.set(subscriptionEndDate, forKey: UserDefaultKeys.subscriptionEndDate.rawValue)
            userDefault.set(subscriptionStatus, forKey: UserDefaultKeys.subscriptionStatus.rawValue)
            userDefault.synchronize()
        }
        
        static func loadDefaultUser() -> UserDAO? {
            let userDefault = UserDefaults.standard
            guard let userId = userDefault.string(forKey: UserDefaultKeys.userId.rawValue),
                let email = userDefault.string(forKey: UserDefaultKeys.email.rawValue) else { return nil }
            let user = UserDAO(userId: userId, email: email)
            if let userId = userDefault.string(forKey: UserDefaultKeys.userId.rawValue){user.userId = userId}
            if let email = userDefault.string(forKey: UserDefaultKeys.email.rawValue){ user.email =  email }
            if let username = userDefault.string(forKey: UserDefaultKeys.username.rawValue) { user.username = username }
            if let country_id = userDefault.string(forKey: UserDefaultKeys.country_id.rawValue) { user.country_id = country_id }
            if let password = userDefault.string(forKey: UserDefaultKeys.password.rawValue) { user.password = password }
             if let phone_number = userDefault.string(forKey: UserDefaultKeys.phone_number.rawValue) { user.phone_number = phone_number }
            if let state_id = userDefault.object(forKey: UserDefaultKeys.state_id.rawValue) { user.state_id = (state_id as! String)}
            if let city = userDefault.string(forKey: UserDefaultKeys.city.rawValue){user.city = city}
            if let sanyas_name = userDefault.string(forKey: UserDefaultKeys.sanyas_name.rawValue){ user.sanyas_name =  sanyas_name }
            if let about_me = userDefault.string(forKey: UserDefaultKeys.about_me.rawValue) { user.about_me = about_me }
            if let profile_photo = userDefault.string(forKey: UserDefaultKeys.profile_photo.rawValue) { user.profile_photo = profile_photo }
            if let background_photo = userDefault.string(forKey: UserDefaultKeys.background_photo.rawValue) { user.background_photo = background_photo }
            if let is_banned = userDefault.object(forKey: UserDefaultKeys.is_banned.rawValue) { user.is_banned = (is_banned as! String)}
            if let added = userDefault.string(forKey: UserDefaultKeys.added.rawValue){user.added = added}
            if let status = userDefault.string(forKey: UserDefaultKeys.status.rawValue){ user.status =  status }
            if let updated = userDefault.string(forKey: UserDefaultKeys.updated.rawValue) { user.updated = updated }
            if let subscriptionEndDate = userDefault.string(forKey: UserDefaultKeys.subscriptionEndDate.rawValue) { user.subscriptionEndDate = subscriptionEndDate }
            if let subscriptionStatus = userDefault.string(forKey: UserDefaultKeys.subscriptionStatus.rawValue) { user.subscriptionStatus = subscriptionStatus }
            return user
        }
        
        
            static func clearDefaultUser() -> Bool {
                let userDefault = UserDefaults.standard
                for key in UserDefaultKeys.allKeys() {
                    userDefault.removeObject(forKey: key)
                }
                return true
            }
    }

