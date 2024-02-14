//
//  Bundle+Extension.swift
//  LMFramework
//
//  Created by Devansh Mohata on 13/12/23.
//

import Foundation

private class BundleClass { }

extension Bundle {
    static var LMBundleIdentifier: Bundle {
        Bundle(for: BundleClass.self)
    }
}
