//
//  LocalPreferences.swift
//  likeminds-feed-iOS
//
//  Created by Devansh Mohata on 28/12/23.
//

import Foundation
import LikeMindsFeed

@propertyWrapper
public struct Storage<T: Codable> {
    private let key: String

    public init(key: String) {
        self.key = key
    }

    public var wrappedValue: T? {
        get {
            // Read value from UserDefaults
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return nil
            }
            
            // Convert data to the desire data type
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value
        }
        set {
            // Convert newValue to data
            let data = try? JSONEncoder().encode(newValue)
            
            // Set value to UserDefaults
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}


public struct LocalPreferences {
    public static var userObj: User? {
        LMFeedClient.shared.getUserDetails()
    }

    @Storage(key: "lm_member_state")
    public static var memberState: GetMemberStateResponse?
    
    @Storage(key: "lm_device_uuid")
    public static var deviceUUID: String?
    
    @Storage(key: "community_configuration")
    public static var communityConfiguration: CommunityConfig?
}

public struct CommunityConfig: Codable {
    public let configs: [CommunityConfiguration]
}
