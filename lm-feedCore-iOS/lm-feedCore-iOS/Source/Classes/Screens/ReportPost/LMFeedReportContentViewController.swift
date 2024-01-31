//
//  LMFeedReportContentViewController.swift
//  lm-feedCore-iOS
//
//  Created by Devansh Mohata on 31/01/24.
//

import lm_feedUI_iOS
import UIKit

public protocol LMFeedReportContentViewModelProtocol: LMBaseViewControllerProtocol {
    func updateView(with tags: [(name: String, tagID: Int)], selectedTag: Int, showTextView: Bool)
}

@IBDesignable
open class LMFeedReportContentViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Please specify the problem to continue"
        label.font = Appearance.shared.fonts.headingFont1
        label.textColor = Appearance.shared.colors.gray51
        return label
    }()
    
    open private(set) lazy var subtitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "You would be able to report this comment after selecting a problem."
        label.numberOfLines = 0
        label.textColor = Appearance.shared.colors.gray102
        label.font = Appearance.shared.fonts.textFont1
        return label
    }()
    
    open private(set) lazy var stackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var collectionView: LMCollectionView = {
        let collection = LMFeedTopicCollectionView(frame: .zero, collectionViewLayout: TagsLayout()).translatesAutoresizingMaskIntoConstraints()
        collection.isScrollEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = Appearance.shared.colors.clear
        collection.registerCell(type: LMUIComponents.shared.reportCollectionCell)
        return collection
    }()
    
    open private(set) lazy var otherReasonTextView: LMTextView = {
        let textView = LMTextView().translatesAutoresizingMaskIntoConstraints()
        textView.delegate = self
        return textView
    }()
    
    open private(set) lazy var submitButton: LMButton = {
        let button = LMButton.createButton(with: "REPORT", image: nil, textColor: .white, textFont: Appearance.shared.fonts.buttonFont3, contentSpacing: .init(top: 8, left: 16, bottom: 8, right: 16))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = Appearance.shared.colors.appTintColor
        return button
    }()
    
    
    // MARK: Data Variables
    public var collectionHeightConstraint: NSLayoutConstraint?
    public var textViewHeightConstraint: NSLayoutConstraint?
    public var tags: [(String, Int)] = []
    public var selectedTag = -1
    public var placeholderText = "Write Description!"
    public var viewmodel: LMFeedReportContentViewModel?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(stackView)
        containerView.addSubview(submitButton)
        
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(otherReasonTextView)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.pinSubView(subView: containerView)
        
        titleLabel.addConstraint(top: (containerView.topAnchor, 16),
                                 leading: (containerView.leadingAnchor, 16))
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        subtitleLabel.addConstraint(top: (titleLabel.bottomAnchor, 16),
                                 leading: (titleLabel.leadingAnchor, 0))
        subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        stackView.addConstraint(top: (subtitleLabel.bottomAnchor, 16),
                                leading: (containerView.leadingAnchor, 16),
                                trailing: (containerView.trailingAnchor, -16))
        
        let constraint = collectionView.heightAnchor.constraint(lessThanOrEqualTo: stackView.widthAnchor, multiplier: 0.5)
        constraint.priority = .required
        constraint.isActive = true
        
        textViewHeightConstraint = otherReasonTextView.setHeightConstraint(with: 40)
        
        submitButton.addConstraint(bottom: (containerView.bottomAnchor, -16),
                                   centerX: (containerView.centerXAnchor, 0))
        
        submitButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor, constant: 16).isActive = true
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = Appearance.shared.colors.white
//        otherReasonTextView.addBottomBorderWithColor(color: Appearance.shared.colors.appTintColor, width: 1)
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        otherReasonTextView.text = placeholderText
        otherReasonTextView.textColor = Appearance.shared.colors.gray155
        otherReasonTextView.font = Appearance.shared.fonts.textFont1
//        otherReasonTextView.isHidden = true
        
        initialSetup(isHidden: true)
        
        viewmodel?.fetchReportTags()
    }
    
    open func initialSetup(isHidden: Bool) {
        titleLabel.isHidden = isHidden
        subtitleLabel.isHidden = isHidden
        stackView.isHidden = isHidden
        submitButton.isHidden = isHidden
    }
}


// MARK: UICollectionView
extension LMFeedReportContentViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { tags.count }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.reportCollectionCell, for: indexPath) {
            let name = tags[indexPath.row].0
            let tagID = tags[indexPath.row].1
            
            cell.configure(with: name, isSelected: tagID == selectedTag) { [weak self] in
                self?.viewmodel?.updateSelectedTag(with: tagID)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = tags[indexPath.row].0.sizeOfString(with: Appearance.shared.fonts.textFont1).width + 32
        return .init(width: width, height: 50)
    }
}


// MARK: UITextViewDelegate
extension LMFeedReportContentViewController: UITextViewDelegate {
    open func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == placeholderText {
            textView.text = nil
            textView.textColor = Appearance.shared.colors.gray51
            textView.font = Appearance.shared.fonts.textFont1
        }
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholderText
            textView.textColor = Appearance.shared.colors.gray155
            textView.font = Appearance.shared.fonts.textFont1
        }
    }
}


// MARK: LMFeedReportContentViewModelProtocol
extension LMFeedReportContentViewController: LMFeedReportContentViewModelProtocol {
    public func updateView(with tags: [(name: String, tagID: Int)], selectedTag: Int, showTextView: Bool) {
        initialSetup(isHidden: false)
        
        self.tags = tags
        self.selectedTag = selectedTag
        collectionView.reloadData()
        
        otherReasonTextView.isHidden = !showTextView
    }
}
