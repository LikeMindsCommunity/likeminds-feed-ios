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
    
    open private(set) lazy var containerScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    open private(set) lazy var stackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
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
        textView.addDoneButtonOnKeyboard()
        return textView
    }()
    
    open private(set) lazy var submitButton: LMButton = {
        let button = LMButton.createButton(with: "REPORT", image: nil, textColor: .white, textFont: Appearance.shared.fonts.buttonFont3, contentSpacing: .init(top: 16, left: 60, bottom: 16, right: 60))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = Appearance.shared.colors.appTintColor
        return button
    }()
    
    
    // MARK: Data Variables
    public var textViewHeightConstraint: NSLayoutConstraint?
    public var textInputHeight: CGFloat = 100
    public var tags: [(String, Int)] = []
    public var selectedTag = -1
    public var placeholderText = "Write Description!"
    public var viewmodel: LMFeedReportContentViewModel?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        
        containerView.addSubview(containerScrollView)
        containerView.addSubview(submitButton)
        
        containerScrollView.addSubview(stackView)
        
        [titleLabel, subtitleLabel, collectionView, otherReasonTextView].forEach { subview in
            stackView.addArrangedSubview(subview)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.pinSubView(subView: containerView, padding: .init(top: 16, left: 0, bottom: 0, right: 0))
        
        containerScrollView.addConstraint(top: (containerView.topAnchor, 0),
                                          leading: (containerView.leadingAnchor, 0),
                                          trailing: (containerView.trailingAnchor, 0))
        
        submitButton.addConstraint(top: (containerScrollView.bottomAnchor, 16),
                                   bottom: (containerView.bottomAnchor, -16),
                                   centerX: (containerView.centerXAnchor, 0))
        
        containerScrollView.pinSubView(subView: stackView)
        
        stackView.setHeightConstraint(with: 50, priority: .defaultLow)
        stackView.setWidthConstraint(with: containerView.widthAnchor)
        
        collectionView.setHeightConstraint(with: stackView.widthAnchor, relatedBy: .lessThanOrEqual, multiplier: 0.5)
        
        otherReasonTextView.setHeightConstraint(with: textInputHeight)
        
        submitButton.addConstraint(top: (containerScrollView.bottomAnchor, 16),
                                   bottom: (containerView.bottomAnchor, -16),
                                   centerX: (containerView.centerXAnchor, 0))
        
        [titleLabel, subtitleLabel, collectionView, otherReasonTextView].forEach { subview in
            subview.addConstraint(leading: (stackView.leadingAnchor, 16),
                                  trailing: (stackView.trailingAnchor, -16))
        }
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = Appearance.shared.colors.white
        submitButton.layer.cornerRadius = submitButton.frame.height / 2
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
    }
    
    @objc
    open func didTapSubmitButton() {
        guard selectedTag != -1 else { return }
        
        if selectedTag == 11 {
            let reason = otherReasonTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !reason.isEmpty,
               reason != placeholderText {
                viewmodel?.reportContent(reason: otherReasonTextView.text)
            } else {
                showError(with: "Please Enter Valid Reason", isPopVC: false)
            }
        } else {
            viewmodel?.reportContent(reason: nil)
        }
    }
    
    // MARK: setupObservers
    open override func setupObservers() {
        super.setupObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitleAndSubtitle(with: "Report Abuse", subtitle: nil, alignment: .center)
        
        otherReasonTextView.text = placeholderText
        otherReasonTextView.textColor = Appearance.shared.colors.gray155
        otherReasonTextView.font = Appearance.shared.fonts.textFont1
        
        setupButton(isEnabled: false)
        viewmodel?.fetchReportTags()
    }
    
    open func setupButton(isEnabled: Bool) {
        submitButton.isEnabled = isEnabled
        if isEnabled {
            submitButton.backgroundColor = Appearance.shared.colors.appTintColor
        } else {
            submitButton.backgroundColor = Appearance.shared.colors.gray4
        }
    }
    
    
    @objc
    open func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrameKey = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = view.convert(keyboardFrameKey.cgRectValue, from: nil)
        
        var contentInset = containerScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        containerScrollView.contentInset = contentInset
        loadViewIfNeeded()
    }

    @objc 
    open func keyboardWillHide(notification: NSNotification){
        containerScrollView.contentInset.bottom = 0
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
        self.tags = tags
        self.selectedTag = selectedTag
        collectionView.reloadData()
        
        otherReasonTextView.isHidden = !showTextView
        setupButton(isEnabled: selectedTag != -1)
        
        if showTextView {
            otherReasonTextView.becomeFirstResponder()
        } else {
            otherReasonTextView.resignFirstResponder()
        }
    }
}
