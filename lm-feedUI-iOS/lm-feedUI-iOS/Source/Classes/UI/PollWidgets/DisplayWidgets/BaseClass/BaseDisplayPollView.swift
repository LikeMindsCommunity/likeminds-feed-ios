//
//  BaseDisplayPollView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 13/06/24.
//

import UIKit

open class BaseDisplayPollView: LMFeedView {
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
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var questionContainerStackView: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var questionTitle: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.numberOfLines = 0
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        return label
    }()
    
    open private(set) lazy var optionSelectCountLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = LMFeedAppearance.shared.colors.gray155
        label.font = LMFeedAppearance.shared.fonts.buttonFont1
        label.numberOfLines = 0
        return label
    }()
    
    open private(set) lazy var optionStackView: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 16
        return stack
    }()
    
    open private(set) lazy var expiryDateLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.textColor = LMFeedAppearance.shared.colors.gray102
        label.font = LMFeedAppearance.shared.fonts.subHeadingFont1
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
