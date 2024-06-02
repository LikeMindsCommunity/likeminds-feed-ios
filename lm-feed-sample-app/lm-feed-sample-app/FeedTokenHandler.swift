//
//  FeedTokenHandler.swift
//  lm-feed-sample-app
//
//  Created by Devansh Mohata on 02/06/24.
//

import LikeMindsFeedCore

final class FeedTokenHandler: LMFeedCoreCallback {
    func onAccessTokenExpiredAndRefreshed(accessToken: String, refreshToken: String) {
        print("\(#function)-\(#file)")
    }
    
    func onRefreshTokenExpired(_ completionHandler: (((accessToken: String, refreshToken: String)) -> Void)?) {
        print("\(#function)-\(#file)")
        Self.initiateSDK { tokens in
            completionHandler?(tokens)
        }
    }
    
    class func initiateSDK(_ completionHandler: (((accessToken: String, refreshToken: String)) -> Void)?) {
        // Create the URL
        guard let url = URL(string: "https://betaauth.likeminds.community/sdk/initiate") else {
            fatalError("Invalid URL")
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Add headers
        request.addValue("br;q=1.0, gzip;q=0.9, deflate;q=0.8", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("lm-feed-sample-app/1.0.2 (com.likeminds.lm-feed-sample-app; build:3; iOS 15.8.2) Alamofire/5.7.1", forHTTPHeaderField: "User-Agent")
        request.addValue("en-IN;q=1.0", forHTTPHeaderField: "Accept-Language")
        request.addValue("ios", forHTTPHeaderField: "x-platform-code")
        request.addValue("9", forHTTPHeaderField: "x-version-code")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("6b51af13-ce28-444b-a571-53a3fb125444", forHTTPHeaderField: "x-api-key")
        request.addValue("feed", forHTTPHeaderField: "x-sdk-source")

        // JSON body data
        let body: [String: Any] = [
            "is_guest": false,
            "api_key": "6b51af13-ce28-444b-a571-53a3fb125444",
            "uuid": "devansh",
            "token_expiry_beta": 1,
            "rtm_token_expiry_beta": 2
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        // Create the URLSession
        let session = URLSession.shared

        // Create the data task
        let task = session.dataTask(with: request) { data, response, error in
            // Handle response
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                print("No data or response")
                return
            }

            print("Status code: \(httpResponse.statusCode)")

            // Define a struct for the JSON response
            struct ResponseData: Codable {
                let success: Bool
                let data: DataClass
            }

            struct DataClass: Codable {
                let refreshToken: String
                let accessToken: String

                enum CodingKeys: String, CodingKey {
                    case refreshToken = "refresh_token"
                    case accessToken = "access_token"
                }
            }

            // Parse the JSON data
            do {
                let response = try JSONDecoder().decode(ResponseData.self, from: data)
                let accessToken = response.data.accessToken
                let refreshToken = response.data.refreshToken

                debugPrint("====Calling From \(#file)====")
                debugPrint("Access Token: \(accessToken)")
                debugPrint("Refresh Token: \(refreshToken)")
                debugPrint("====Calling From \(#file)====")
                
                completionHandler?((accessToken, refreshToken))
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }

        // Start the task
        task.resume()
    }
}
