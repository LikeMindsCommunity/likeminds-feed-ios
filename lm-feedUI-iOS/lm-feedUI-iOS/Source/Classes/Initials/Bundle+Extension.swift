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
        return Bundle(for: BundleClass.self)
            .url(forResource: "LikeMindsFeedUIAssets", withExtension: "bundle")
            .flatMap(Bundle.init(url:)) ?? Bundle(for: BundleClass.self)
    }
}
