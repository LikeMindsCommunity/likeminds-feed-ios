//
//  LMFeedDocumentPreview.swift
//  LMFramework
//
//  Created by Devansh Mohata on 13/12/23.
//

import UIKit

public protocol LMFeedDocumentPreviewProtocol: AnyObject {
    func didTapCrossButton(documentID: URL)
    func didTapDocument(documentID: URL)
}

public extension LMFeedDocumentPreviewProtocol {
    func didTapCrossButton(documentID: URL) { }
}

@IBDesignable
open class LMFeedDocumentPreview: LMView {
    public struct ViewModel {
        public let title: String
        public let documentURL: URL
        public let size: Int?
        public let pageCount: Int?
        public let docType: String?
        public let isShowCrossButton: Bool
        
        public init(title: String, documentURL: URL, size: Int?, pageCount: Int?, docType: String?, isShowCrossButton: Bool = false) {
            self.title = title
            self.documentURL = documentURL
            self.size = size
            self.pageCount = pageCount
            self.docType = docType
            self.isShowCrossButton = isShowCrossButton
        }
    }
    
    
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var outerStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.clipsToBounds = true
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var documentIcon: LMImageView = {
        let image = LMImageView().translatesAutoresizingMaskIntoConstraints()
        image.contentMode = .scaleAspectFit
        image.image = Constants.shared.images.pdfIcon
        return image
    }()
    
    open private(set) lazy var labelContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    open private(set) lazy var labelStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var titleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Title Text"
        label.font = Appearance.shared.fonts.headingFont1
        label.textColor = Appearance.shared.colors.gray102
        return label
    }()
    
    open private(set) lazy var subtitleLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Subtitle Text"
        label.font = Appearance.shared.fonts.subHeadingFont2
        label.textColor = Appearance.shared.colors.gray102
        return label
    }()
    
    open private(set) lazy var crossButton: LMButton = {
        let button = LMButton()
        button.setTitle(nil, for: .normal)
        button.setTitle(nil, for: .selected)
        button.setImage(Constants.shared.images.crossIcon, for: .normal)
        button.setImage(Constants.shared.images.crossIcon, for: .selected)
        return button
    }()
    
    
    // MARK: Data Variables
    public weak var delegate: LMFeedDocumentPreviewProtocol?
    public var documentID: URL?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(outerStackView)
        
        [documentIcon, labelContainerView, crossButton].forEach { subView in
            outerStackView.addArrangedSubview(subView)
        }
        
        labelContainerView.addSubview(labelStackView)
        
        [titleLabel, subtitleLabel].forEach { subView in
            labelStackView.addArrangedSubview(subView)
        }
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            outerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            outerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            outerStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            outerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            documentIcon.heightAnchor.constraint(equalTo: documentIcon.widthAnchor, multiplier: 1),
            documentIcon.topAnchor.constraint(equalTo: outerStackView.topAnchor),
            documentIcon.bottomAnchor.constraint(equalTo: outerStackView.bottomAnchor),
            
            labelContainerView.topAnchor.constraint(equalTo: outerStackView.topAnchor),
            labelContainerView.bottomAnchor.constraint(equalTo: outerStackView.bottomAnchor),
            
            labelStackView.topAnchor.constraint(greaterThanOrEqualTo: labelContainerView.topAnchor),
            labelStackView.bottomAnchor.constraint(greaterThanOrEqualTo: labelContainerView.bottomAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: labelContainerView.leadingAnchor),
            labelStackView.trailingAnchor.constraint(greaterThanOrEqualTo: labelContainerView.trailingAnchor),
            labelStackView.centerYAnchor.constraint(equalTo: labelContainerView.centerYAnchor),
            
            crossButton.heightAnchor.constraint(equalToConstant: 44),
            crossButton.widthAnchor.constraint(equalTo: crossButton.heightAnchor, multiplier: 1)
        ])
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = Appearance.shared.colors.sepratorColor.cgColor
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        crossButton.addTarget(self, action: #selector(didTapCrossButton), for: .touchUpInside)
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDocumentCell)))
    }
    
    @objc
    open func didTapCrossButton() {
        guard let documentID else { return }
        delegate?.didTapCrossButton(documentID: documentID)
    }
    
    @objc
    open func didTapDocumentCell() {
        guard let documentID else { return }
        delegate?.didTapDocument(documentID: documentID)
    }
    
    
    // MARK: Configure
    open func configure(with data: ViewModel, delegate: LMFeedDocumentPreviewProtocol?) {
        self.delegate = delegate
        self.documentID = data.documentURL
        
        titleLabel.text = data.title
        
        var subtitle = ""
        
        if let pageCount = data.pageCount {
            subtitle.append("\(pageCount) \(pageCount > 1 ? "Pages" : "Page")")
        }
        
        if let size = data.size {
            if !subtitle.isEmpty {
                subtitle.append(" • ")
            }
            
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
            formatter.countStyle = .file
            
            subtitle.append(formatter.string(fromByteCount: Int64(size)))
        }
        
        if let docType = data.docType {
            if !subtitle.isEmpty {
                subtitle.append(" • ")
            }
            
            subtitle.append(docType)
        }
        
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle.isEmpty
        
        crossButton.isHidden = !data.isShowCrossButton
    }
}
