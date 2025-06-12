//
//  LMFeedVideoReportScreen.swift
//  lm-feedCore-iOS
//
//  Created by Arpit Verma on 12/06/2025.
//

import LikeMindsFeedUI
import UIKit


@IBDesignable
open class LMFeedVideoReportScreen: LMFeedViewController {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.clear
        return view
    }()
    
    open private(set) lazy var containerScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    open private(set) lazy var stackView: LMFeedStackView = {
        let stack = LMFeedStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var titleLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Please specify the problem to continue"
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray51
        return label
    }()
    
    open private(set) lazy var subtitleLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "You would be able to report this video after selecting a problem."
        label.numberOfLines = 0
        label.textColor = LMFeedAppearance.shared.colors.gray102
        label.font = LMFeedAppearance.shared.fonts.textFont1
        return label
    }()
    
    open private(set) lazy var reportCollectionView: LMFeedCollectionView = {
        let collection = LMFeedTopicCollectionView(frame: .zero, collectionViewLayout: TagsLayout()).translatesAutoresizingMaskIntoConstraints()
        collection.isScrollEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = LMFeedAppearance.shared.colors.clear
        collection.registerCell(type: LMUIComponents.shared.reportItem)
        return collection
    }()
    
    open private(set) lazy var otherReasonTextView: LMFeedTextView = {
        let textView = LMFeedTextView().translatesAutoresizingMaskIntoConstraints()
        textView.delegate = self
        textView.addDoneButtonOnKeyboard()
        textView.backgroundColor = LMFeedAppearance.shared.colors.gray4
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 0
        textView.layer.borderColor = LMFeedAppearance.shared.colors.gray155.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView
    }()
    
    open private(set) lazy var reasonTitleLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Reason"
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray51
        return label
    }()
    
    open private(set) lazy var reasonSubtitleLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Help us to understand the problem"
        label.font = LMFeedAppearance.shared.fonts.textFont1
        label.textColor = LMFeedAppearance.shared.colors.gray102
        return label
    }()
    
    
    open private(set) lazy var submitButton: LMFeedButton = {
        let button = LMFeedButton.createButton(with: "Submit Report", image: nil, textColor: .white, textFont: LMFeedAppearance.shared.fonts.buttonFont3, contentSpacing: .init(top: 16, left: 60, bottom: 16, right: 60))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = LMFeedAppearance.shared.colors.green 
        return button
    }()
    
    open private(set) lazy var thankYouView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
        view.isHidden = true
        return view
    }()
    
    open private(set) lazy var thankYouCircleView: LMFeedView = {
        let view = LMFeedView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = LMFeedAppearance.shared.colors.red.withAlphaComponent(0.1)
        view.layer.cornerRadius = 15 // Will be set to half of width/height
        return view
    }()
    
    open private(set) lazy var thankYouImageView: LMFeedImageView = {
        let imageView = LMFeedImageView().translatesAutoresizingMaskIntoConstraints()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = LMFeedAppearance.shared.colors.red
        if let exclamationImage = UIImage(systemName: "exclamationmark") {
            imageView.image = exclamationImage
        }
        return imageView
    }()
    
    open private(set) lazy var thankYouLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Thank you for submitting a report"
        label.font = LMFeedAppearance.shared.fonts.headingFont1
        label.textColor = LMFeedAppearance.shared.colors.gray51
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    open private(set) lazy var thankYouSubLabel: LMFeedLabel = {
        let label = LMFeedLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "We take reports seriously and after a through review, will take appropriate action."
        label.font = LMFeedAppearance.shared.fonts.textFont1
        label.textColor = LMFeedAppearance.shared.colors.gray102
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: Data Variables
    public var textInputHeight: CGFloat = 100
    public var tagsData: [(String, Int)] = []
    public var selectedTag = -1
    public var placeholderText = "Write Description!"
    public var viewmodel: LMFeedVideoReportViewModel?
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        view.addSubview(containerView)
        view.addSubview(thankYouView)
        
        containerView.addSubview(containerScrollView)
        containerView.addSubview(submitButton)
        
        containerScrollView.addSubview(stackView)
        
        [titleLabel, subtitleLabel, reportCollectionView, reasonTitleLabel, reasonSubtitleLabel, otherReasonTextView].forEach { subview in
            stackView.addArrangedSubview(subview)
        }
        
        thankYouView.addSubview(thankYouCircleView)
        thankYouCircleView.addSubview(thankYouImageView)
        thankYouView.addSubview(thankYouLabel)
        thankYouView.addSubview(thankYouSubLabel)
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        view.pinSubView(subView: containerView, padding: .init(top: 16, left: 0, bottom: 0, right: 0))
        view.pinSubView(subView: thankYouView)
        
        containerScrollView.addConstraint(top: (containerView.topAnchor, 0),
                                          leading: (containerView.leadingAnchor, 0),
                                          trailing: (containerView.trailingAnchor, 0))
        
        submitButton.addConstraint(top: (containerScrollView.bottomAnchor, 16),
                                   bottom: (containerView.bottomAnchor, -32),
                                   leading: (containerView.leadingAnchor, 16),
                                   trailing: (containerView.trailingAnchor, -16))
        
        containerScrollView.pinSubView(subView: stackView)
        
        stackView.setHeightConstraint(with: 50, priority: .defaultLow)
        stackView.setWidthConstraint(with: containerView.widthAnchor)
        
        reportCollectionView.setHeightConstraint(with: stackView.widthAnchor, relatedBy: .lessThanOrEqual, multiplier: 0.5)
        
        otherReasonTextView.setHeightConstraint(with: textInputHeight)
        
        [titleLabel, subtitleLabel, reportCollectionView, reasonTitleLabel, reasonSubtitleLabel, otherReasonTextView].forEach { subview in
            subview.addConstraint(leading: (stackView.leadingAnchor, 16),
                                  trailing: (stackView.trailingAnchor, -16))
        }
        
        NSLayoutConstraint.activate([
            thankYouCircleView.centerXAnchor.constraint(equalTo: thankYouView.centerXAnchor),
            thankYouCircleView.centerYAnchor.constraint(equalTo: thankYouView.centerYAnchor, constant: -60),
            thankYouCircleView.widthAnchor.constraint(equalToConstant: 30),
            thankYouCircleView.heightAnchor.constraint(equalToConstant: 30),
            
            thankYouImageView.centerXAnchor.constraint(equalTo: thankYouCircleView.centerXAnchor),
            thankYouImageView.centerYAnchor.constraint(equalTo: thankYouCircleView.centerYAnchor),
            thankYouImageView.widthAnchor.constraint(equalToConstant: 15),
            thankYouImageView.heightAnchor.constraint(equalToConstant: 15),
            
            thankYouLabel.centerXAnchor.constraint(equalTo: thankYouView.centerXAnchor),
            thankYouLabel.topAnchor.constraint(equalTo: thankYouCircleView.bottomAnchor, constant: 16),
            thankYouLabel.leadingAnchor.constraint(equalTo: thankYouView.leadingAnchor, constant: 32),
            thankYouLabel.trailingAnchor.constraint(equalTo: thankYouView.trailingAnchor, constant: -32),
            
            thankYouSubLabel.centerXAnchor.constraint(equalTo: thankYouView.centerXAnchor),
            thankYouSubLabel.topAnchor.constraint(equalTo: thankYouLabel.bottomAnchor, constant: 8),
            thankYouSubLabel.leadingAnchor.constraint(equalTo: thankYouView.leadingAnchor, constant: 32),
            thankYouSubLabel.trailingAnchor.constraint(equalTo: thankYouView.trailingAnchor, constant: -32)
        ])
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = LMFeedAppearance.shared.colors.white
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
        
        // Setup navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isHidden = false
        
        // Create custom title view with exclamation icon and title
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create circle view for exclamation icon
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = LMFeedAppearance.shared.colors.black.withAlphaComponent(0.1)
        circleView.layer.cornerRadius = 15 // Will be set to half of width/height
        
        // Create exclamation icon
        let exclamationImageView = UIImageView()
        exclamationImageView.translatesAutoresizingMaskIntoConstraints = false
        exclamationImageView.contentMode = .scaleAspectFit
        exclamationImageView.tintColor = LMFeedAppearance.shared.colors.black
        if let exclamationImage = UIImage(systemName: "exclamationmark") {
            exclamationImageView.image = exclamationImage
        }
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Report Abuse"
        titleLabel.font = LMFeedAppearance.shared.fonts.headingFont1
        titleLabel.textColor = LMFeedAppearance.shared.colors.black
        
        // Add subviews
        circleView.addSubview(exclamationImageView)
        titleView.addSubview(circleView)
        titleView.addSubview(titleLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            circleView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            circleView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 30),
            circleView.heightAnchor.constraint(equalToConstant: 30),
            
            exclamationImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            exclamationImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            exclamationImageView.widthAnchor.constraint(equalToConstant: 15),
            exclamationImageView.heightAnchor.constraint(equalToConstant: 15),
            
            titleLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor)
        ])
        
        // Set the custom title view with left alignment
        navigationItem.titleView = titleView
        navigationItem.titleView?.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
        
        // Set left bar button item to nil to remove any default spacing
        navigationItem.leftBarButtonItem = nil
        
        // Add close button
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(didTapCloseButton))
        closeButton.tintColor = LMFeedAppearance.shared.colors.gray51
        navigationItem.rightBarButtonItem = closeButton
        
        // Hide back button
        navigationItem.hidesBackButton = true
        
        otherReasonTextView.text = "Write a message"
        otherReasonTextView.textColor = LMFeedAppearance.shared.colors.gray155
        otherReasonTextView.font = LMFeedAppearance.shared.fonts.textFont1
        
        setupButton(isEnabled: false)
        subtitleLabel.text = LMStringConstants.shared.reportSubtitle(isComment: false)
        
        viewmodel?.fetchReportTags()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc
    private func didTapCloseButton() {
        navigationController?.popViewController(animated: true)
    }
    
    open func setupButton(isEnabled: Bool) {
        submitButton.isEnabled = isEnabled
        submitButton.backgroundColor = isEnabled ? LMFeedAppearance.shared.colors.green : LMFeedAppearance.shared.colors.gray4
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
    
    // MARK: Public Methods
    public func showThankYouMessage() {
        // Hide the report form
        containerView.isHidden = true
        
        // Show thank you message
        thankYouView.isHidden = false
        
        // Pop back after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: UICollectionView
extension LMFeedVideoReportScreen: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { tagsData.count }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.reportItem, for: indexPath) as? LMFeedReportItem {
            let name = tagsData[indexPath.row].0
            let tagID = tagsData[indexPath.row].1
            
            // Configure cell with custom colors
            cell.configure(with: name, isSelected: tagID == selectedTag) { [weak self] in
                self?.viewmodel?.updateSelectedTag(with: tagID)
            }

            
            // Force layout update
            cell.layoutIfNeeded()
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = tagsData[indexPath.row].0.sizeOfString(with: LMFeedAppearance.shared.fonts.textFont1).width + 32
        return .init(width: width, height: 50)
    }
}

// MARK: UITextViewDelegate
extension LMFeedVideoReportScreen: UITextViewDelegate {
    open func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == placeholderText {
            textView.text = nil
            textView.textColor = LMFeedAppearance.shared.colors.gray51
            textView.font = LMFeedAppearance.shared.fonts.textFont1
        }
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholderText
            textView.textColor = LMFeedAppearance.shared.colors.gray155
            textView.font = LMFeedAppearance.shared.fonts.textFont1
        }
    }
}

// MARK: LMFeedReportViewModelProtocol
extension LMFeedVideoReportScreen: LMFeedReportViewModelProtocol {
    public func updateView(with tags: [(name: String, tagID: Int)], selectedTag: Int, showTextView: Bool) {
        self.tagsData = tags
        self.selectedTag = selectedTag
        reportCollectionView.reloadData()
        
        otherReasonTextView.isHidden = !showTextView
        reasonTitleLabel.isHidden = !showTextView
        reasonSubtitleLabel.isHidden = !showTextView
        
        setupButton(isEnabled: selectedTag != -1)
        
        if showTextView {
            otherReasonTextView.becomeFirstResponder()
        } else {
            otherReasonTextView.resignFirstResponder()
        }
    }
} 
