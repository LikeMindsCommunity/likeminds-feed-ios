//
//  LMFeedPickerView.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 09/06/24.
//

import UIKit

public protocol LMFeedPickerViewDelegate: AnyObject {
    func didTapDone()
    func didTapCancel()
}

public class LMFeedPickerView: UIPickerView {
    public private(set) var toolbar: UIToolbar?
    public weak var toolbarDelegate: LMFeedPickerViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        self.toolbar = toolBar
    }

    @objc func doneTapped() {
        self.toolbarDelegate?.didTapDone()
    }

    @objc func cancelTapped() {
        self.toolbarDelegate?.didTapCancel()
    }
}
