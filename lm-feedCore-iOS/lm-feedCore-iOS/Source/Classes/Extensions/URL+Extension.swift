//
//  URL+Extension.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 22/01/24.
//

public extension URL {
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
