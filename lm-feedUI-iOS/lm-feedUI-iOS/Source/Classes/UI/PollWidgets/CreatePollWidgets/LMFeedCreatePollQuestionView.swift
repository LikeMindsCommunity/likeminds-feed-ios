//
//  LMFeedCreatePollQuestionView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 06/06/24.
//

import UIKit

public protocol LMFeedCreatePollQuestionViewProtocol: AnyObject {
    func onCrossButtonTapped(for id: Int)
    func textValueChanged(for id: Int, newValue: String?)
    func onAddNewOptionTapped()
}

open class LMFeedCreatePollQuestionView: LMView {
    // MARK: UI Elements
    open private(set) lazy var containerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        return view
    }()
    
    open private(set) lazy var answerLabel: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Answer options"
        label.font = Appearance.shared.fonts.buttonFont2
        label.textColor = Appearance.shared.colors.appTintColor
        return label
    }()
    
    open private(set) lazy var optionStack: LMTableView = {
        let table = LMTableView().translatesAutoresizingMaskIntoConstraints()
        table.dataSource = self
        table.delegate = self
        table.isScrollEnabled = false
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.register(LMUIComponents.shared.createPollOptionCell)
        table.estimatedRowHeight = cellSize
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        return table
    }()
    
    open private(set) lazy var addOptionView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    open private(set) lazy var addOptionImage: LMImageView = {
        let image = LMImageView(image: Constants.shared.images.plusCircleIcon.withConfiguration(UIImage.SymbolConfiguration(font: Appearance.shared.fonts.buttonFont2)))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    open private(set) lazy var addOptionText: LMLabel = {
        let label = LMLabel().translatesAutoresizingMaskIntoConstraints()
        label.text = "Add an option..."
        label.font = Appearance.shared.fonts.buttonFont2
        label.textColor = Appearance.shared.colors.appTintColor
        return label
    }()
    
    
    // MARK: Data Variables
    open var addOptionImageSize: CGFloat { 20 }
    open var cellSize: CGFloat { 56 }
    public weak var delegate: LMFeedCreatePollQuestionViewProtocol?
    public var data: [LMFeedCreatePollOptionWidget.ContentModel] = []
    
    public var tableViewHeightConstraint: NSLayoutConstraint?
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        
        addSubview(containerView)
        containerView.addSubview(answerLabel)
        containerView.addSubview(optionStack)
        containerView.addSubview(addOptionView)
        addOptionView.addSubview(addOptionImage)
        addOptionView.addSubview(addOptionText)
    }
    
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: containerView)
        
        answerLabel.addConstraint(top: (containerView.topAnchor, 16),
                                  leading: (containerView.leadingAnchor, 16))
        answerLabel.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        optionStack.addConstraint(top: (answerLabel.bottomAnchor, 16),
                                leading: (containerView.leadingAnchor, 0),
                                trailing: (containerView.trailingAnchor, 0))
        
        addOptionView.addConstraint(top: (optionStack.bottomAnchor, 16),
                                    bottom: (containerView.bottomAnchor, -16),
                                    leading: (containerView.leadingAnchor, 0),
                                    trailing: (containerView.trailingAnchor, 0))
        addOptionImage.addConstraint(top: (addOptionView.topAnchor, 8),
                                     bottom: (addOptionView.bottomAnchor, -8),
                                     leading: (addOptionView.leadingAnchor, 16))
        addOptionImage.setWidthConstraint(with: addOptionImageSize)
        addOptionImage.setHeightConstraint(with: addOptionImage.widthAnchor)
        
        addOptionText.addConstraint(leading: (addOptionImage.trailingAnchor, 8),
                                    centerY: (addOptionImage.centerYAnchor, 0))
        addOptionText.trailingAnchor.constraint(greaterThanOrEqualTo: addOptionView.trailingAnchor, constant: -16).isActive = true
        
        tableViewHeightConstraint = optionStack.setHeightConstraint(with: cellSize * 2)
    }
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        
        containerView.backgroundColor = Appearance.shared.colors.white
        optionStack.backgroundColor = Appearance.shared.colors.clear
    }
    
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        addOptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapAddOptions)))
    }
    
    @objc
    open func onTapAddOptions() {
        delegate?.onAddNewOptionTapped()
    }
    
    // MARK: configure
    open func configure(with data: [LMFeedCreatePollOptionWidget.ContentModel], delegate: LMFeedCreatePollQuestionViewProtocol?) {
        self.delegate = delegate
        updateOptions(with: data)
    }
    
    open func updateOptions(with data: [LMFeedCreatePollOptionWidget.ContentModel]) {
        self.data = data
        optionStack.reloadData()
        tableViewHeightConstraint?.constant = CGFloat(data.count) * cellSize
    }
    
    open func retrieveTextFromOptions() -> [String?] {
        optionStack.visibleCells.map { cell in
            (cell as? LMFeedCreatePollOptionWidget)?.retriveText()
        }
    }
}

extension LMFeedCreatePollQuestionView: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(LMUIComponents.shared.createPollOptionCell) {
            let datum = data[indexPath.row]
            cell.configure(with: datum, isShowCrossIcon: data.count > 2) { [weak delegate] in
                delegate?.onCrossButtonTapped(for: datum.id)
            } onTextValueChanged: { [weak delegate] newValue in
                delegate?.textValueChanged(for: datum.id, newValue: newValue)
            }
            
            return cell
        }
        return UITableViewCell()
    }
}
