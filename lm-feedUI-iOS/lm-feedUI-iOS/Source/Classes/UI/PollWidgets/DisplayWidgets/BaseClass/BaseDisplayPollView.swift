//
//  BaseDisplayPollView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 13/06/24.
//

import UIKit

open class BaseDisplayPollView: LMView {
    public protocol Content {
        var question: String { get }
        var expiryDate: Date { get }
        var optionState: String { get }
        var optionCount: Int { get }
        var expiryDateFormatted: String { get }
        var optionStringFormatted: String { get }
        var isShowOption: Bool { get }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var questionContainerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var questionTitle: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.numberOfLines = 0
        label.textColor = Appearance.shared.colors.gray51
        label.font = Appearance.shared.fonts.headingFont1
        return label
    }()
    
    open private(set) lazy var optionSelectCountLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray155
        label.font = Appearance.shared.fonts.buttonFont1
        label.numberOfLines = 0
        return label
    }()
    
    open private(set) lazy var optionStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }()
    
    open private(set) lazy var expiryDateLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = Appearance.shared.colors.gray102
        label.font = Appearance.shared.fonts.subHeadingFont1
        label.numberOfLines = 0
        return label
    }()
}

public extension BaseDisplayPollView.Content {
    var expiryDateFormatted: String {
        if expiryDate < Date() {
            return "Poll Ended"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"

        let dateString = dateFormatter.string(from: expiryDate)
        
        return "Expires on \(dateString)"
    }
    
    var optionStringFormatted: String {
        "*Select \(optionState.lowercased()) \(optionCount) \(optionCount == 1 ? "option" : "options")"
    }
    
    var isShowOption: Bool {
        !(optionState.lowercased() == "exactly" && optionCount == 1)
    }
}
