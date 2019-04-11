//
//  StorageHelper.swift
//  HaventecAuthenticate
//
//  Created by Justin Crosbie on 13/2/19.
//

import Foundation
import SwiftKeychainWrapper
import HaventecCommon

public class StorageHelper {
    
    private static var haventecDataCache: HaventecData!
    
    public static func initialise(username: String) throws {
        let normalisedUsername = username.lowercased()
        
        try setCurrentUser(normalisedUsername: normalisedUsername)
        
        try initialiseUserPersistedData(normalisedUsername: normalisedUsername)
        
        try initialiseUserCacheData(normalisedUsername: normalisedUsername)
    }
    
    public static func updateStorage(data: Data) throws {
        guard let thisData = try? JSONDecoder().decode(HaventecData.self, from: data) else {
            throw HaventecAuthenticateError.storageHelper("Error decoding storage JSON")
        }
        
        do {
            if let deviceUuid = thisData.deviceUuid, !deviceUuid.isEmpty {
                haventecDataCache.deviceUuid = deviceUuid
                try updateKeychainStorage(field: Constants.keyDeviceUuid, value: deviceUuid)
            }
            
            if let authKey = thisData.authKey, !authKey.isEmpty {
                haventecDataCache.authKey = authKey
                try updateKeychainStorage(field: Constants.keyAuthKey, value: authKey)
            }
            
            if let accessToken = thisData.accessToken {
                haventecDataCache.accessToken = accessToken
            }
        } catch {
            throw HaventecAuthenticateError.storageHelper("Error updating the keychain with the data given")
        }
    }
    
    public static func updateKeychainStorage(field: String, value: String) throws {
        if let username = KeychainWrapper.standard.string(forKey: Constants.keyLastUser) {
            try persist(key: field + username, value: value)
        } else {
            throw HaventecAuthenticateError.storageHelper("The SDK has not been initialised. Please run the initialise function")
        }
    }
    
    public static func getData() -> HaventecData {
        return haventecDataCache
    }
    
    public static func getSalt() throws -> [UInt8] {
        if let salt = haventecDataCache.salt {
            return salt
        } else {
            throw HaventecAuthenticateError.storageHelper("The SDK has not been initialised. Please run the initialise function")
        }
    }
    
    public static func getAccessToken() throws -> String? {
        if let accessToken = haventecDataCache.accessToken {
            return accessToken.token
        } else {
            throw HaventecAuthenticateError.storageHelper("No access token set")
        }
    }
    
    public static func clearAccessToken() {
        haventecDataCache.accessToken = nil
    }
    
    public static func getCurrentUserUuid() throws -> String? {
        if let accessToken = haventecDataCache.accessToken, let value = accessToken.token {
            return try TokenHelper.getUserUuidFromJWT(jwtToken: value)
        } else {
            throw HaventecAuthenticateError.storageHelper("No access token set")
        }
    }
    
    public static func getDeviceUuid() throws -> String {
        if let deviceUuid = haventecDataCache.deviceUuid {
            return deviceUuid
        } else {
            throw HaventecAuthenticateError.storageHelper("The SDK has not been initialised. Please run the initialise function")
        }
    }
    
    private static func initialiseUserCacheData(normalisedUsername: String) throws {
        guard let salt = KeychainWrapper.standard.string(forKey: Constants.keySalt + normalisedUsername) else {
            throw HaventecAuthenticateError.storageHelper("No salt value set in the keyChain for the given user")
        }
        
        haventecDataCache = HaventecData()
        haventecDataCache.username = normalisedUsername
        haventecDataCache.deviceUuid = KeychainWrapper.standard.string(forKey: Constants.keyDeviceUuid + normalisedUsername)
        haventecDataCache.authKey = KeychainWrapper.standard.string(forKey: Constants.keyAuthKey + normalisedUsername)
        haventecDataCache.salt = Data(base64Encoded: salt)?.bytes
    }
    
    private static func initialiseUserPersistedData(normalisedUsername: String) throws {
        try persist(key: Constants.keyUsername + normalisedUsername, value: normalisedUsername)
        
        let salt: String? = KeychainWrapper.standard.string(forKey: Constants.keySalt + normalisedUsername)
        
        if let salt = salt, !salt.isEmpty {
            throw HaventecAuthenticateError.storageHelper("User storage is already initalised")
        }
        
        try persistNewSalt(normalisedUsername: normalisedUsername)
    }
    
    private static func persistNewSalt(normalisedUsername: String) throws {
        let salt: [UInt8] = try HaventecCommon.generateSalt()
        
        let saltBase64String = Data(salt).base64EncodedString()
        
        try persist(key: Constants.keySalt + normalisedUsername, value: saltBase64String)
    }
    
    private static func setCurrentUser(normalisedUsername: String) throws {
        try persist(key: Constants.keyLastUser, value: normalisedUsername)
    }
    
    private static func persist(key: String, value: String?) throws {
        guard let value = value else {
            throw HaventecAuthenticateError.storageHelper("The SDK has not been initialised. Please run the initialise function")
        }
        
        if !KeychainWrapper.standard.set(value, forKey: key) {
            throw HaventecAuthenticateError.storageHelper("Error setting the key pair value in KeyChain")
        }
    }
}
