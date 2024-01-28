//
//  URL+Extension.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 22/01/24.
//

public extension URL {
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return [:] }
        
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
    
    func getFileSize() -> Int? {
        guard isFileURL else { return nil }
        
        do {
            return try resourceValues(forKeys: [.fileSizeKey]).fileSize
        } catch {
            print("File Size Failed")
        }
        
        return nil
    }
}
