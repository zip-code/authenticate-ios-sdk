import Foundation
import HaventecCommon

public class HaventecAuthenticate {
    
    public enum HaventecAuthenticateError: Error {
        case commonError(String)
        case storageError(String)
        case initialiseError(String)
        case jsonError(String)
    }
    
    /**
     It creates a Hash of the pin, along with the salt that is in Storage
     
     - Parameter pin: The PIN code.
     
     - Throws: `HaventecAuthenticateError.initialiseError`
     if the initialiseStorage function has not been called.

     - Returns: String Base64-encoded representation of the SHA-512 hashed `pin` and stored salt.
    */
    public static func hashPin(pin: String) throws -> String? {
        
        if let saltBytes = StorageHelper.getData().salt {
            return try HaventecCommon.hashPin(saltBytes: saltBytes, pin: pin);
        } else {
            throw HaventecAuthenticateError.initialiseError(AuthenticateErrorCodes.not_initialised_error.rawValue);
        }
    }

    /**
     It initialises Haventec data storage for the username
     
     - Parameter username
     
     - Throws: `HaventecAuthenticateError.storageError`
     if there was an error persisting to storage.
    */
    public static func initialiseStorage(username: String) throws {
        try StorageHelper.initialise(username: username);
    }

    
    /**
     It updates Haventec data storage for the username with the JSON data
     
     - Parameter username
     
     - Throws: `HaventecAuthenticateError.jsonError`
     if there was an error parsing the Data as JSON.
     - Throws: `HaventecAuthenticateError.storageError`
     if there was an error persisting to storage.
    */
    public static func updateStorage(data: Data) throws {
        try StorageHelper.updateStorage(data: data);
    }
    
    /**
     It retrieves the Haventec authKey
     
     - Returns: String Haventec authKey
     */
    public static func getAuthKey() -> String? {
        return StorageHelper.getData().authKey;
    }

    /**
     It retrieves the Haventec JWT token
     
     - Returns: String Haventec Authenticate JWT token
     */
    public static func getAccessToken() -> String? {
        return StorageHelper.getData().accessToken?.token;
    }

    
    /**
     It retrieves the Haventec username
     
     - Returns: String Haventec username
     */
    public static func getUsername() -> String? {
        return StorageHelper.getData().username;
    }
    
    /**
     It retrieves the Haventec deviceUuid
     
     - Returns: String Haventec deviceUuid
     */
    public static func getDeviceUuid() -> String? {
        return StorageHelper.getData().deviceUuid;
    }
}
