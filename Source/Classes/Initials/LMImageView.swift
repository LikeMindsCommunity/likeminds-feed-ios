//
//  LMImageView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 04/12/23.
//

import UIKit

@IBDesignable
open class LMImageView: UIImageView { 
    open func translatesAutoresizingMaskIntoConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
