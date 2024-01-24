//
//  LMViewController.swift
//  LMFramework
//
//  Created by Devansh Mohata on 24/11/23.
//

import UIKit

public extension UIViewController {
    
    /// Adds child view controller to the parent.
    ///
    /// - Parameter child: Child view controller.
    func add(child: UIViewController, to subView: UIView) {
        addChild(child)
        subView.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    /// It removes the child view controller from the parent.
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

public protocol LMBaseViewControllerProtocol: AnyObject {
    func presentAlert(with alert: UIAlertController, animated: Bool)
    func showHideLoaderView(isShow: Bool)
}

/// Base LM View Controller Class with LM Life Cycle Methods
@IBDesignable
open class LMViewController: UIViewController {
    // MARK: UI Elements
    open private(set) lazy var loaderScreen: LMView = {
        let view = LMView(frame: view.bounds).translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var loaderView: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.tintColor = Appearance.shared.colors.gray51
        return loader
    }()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func loadView() {
        super.loadView()
        setupViews()
        setupLayouts()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupNavigationBar()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAppearance()
    }
    
    open func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = Appearance.shared.colors.navigationBackgroundColor
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    open func setNavigationTitleAndSubtitle(with title: String?, subtitle: String?, alignment: UIStackView.Alignment = .leading) {
        let titleView = LMView().translatesAutoresizingMaskIntoConstraints()
        let widthConstraint = NSLayoutConstraint.init(item: titleView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width)
        widthConstraint.priority = .defaultLow
        widthConstraint.isActive = true
        
        let stackView = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.alignment = alignment
        stackView.distribution = .fillProportionally
        
        titleView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: titleView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor)
        ])
        
        if let title,
           !title.isEmpty {
            let titleLabel = LMLabel().translatesAutoresizingMaskIntoConstraints()
            titleLabel.text = title
            titleLabel.textColor = Appearance.shared.colors.gray51
            titleLabel.font = Appearance.shared.fonts.navigationTitleFont
            stackView.addArrangedSubview(titleLabel)
        }
        
        if let subtitle,
           !subtitle.isEmpty {
            let subtitleLabel = LMLabel().translatesAutoresizingMaskIntoConstraints()
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = Appearance.shared.colors.gray51
            subtitleLabel.font = Appearance.shared.fonts.navigationSubtitleFont
            stackView.addArrangedSubview(subtitleLabel)
        }
        
        navigationItem.titleView = titleView
    }
    
    open func showHideLoaderView(isShow: Bool) {
        if isShow {
            view.addSubview(loaderScreen)
            loaderScreen.addSubview(loaderView)
            
            NSLayoutConstraint.activate([
                loaderScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loaderScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                loaderScreen.topAnchor.constraint(equalTo: view.topAnchor),
                loaderScreen.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                loaderView.centerXAnchor.constraint(equalTo: loaderScreen.centerXAnchor),
                loaderView.centerYAnchor.constraint(equalTo: loaderScreen.centerYAnchor),
                loaderView.heightAnchor.constraint(equalToConstant: 50),
                loaderView.widthAnchor.constraint(equalTo: loaderView.heightAnchor, multiplier: 1)
            ])
            view.bringSubviewToFront(loaderScreen)
            loaderView.startAnimating()
        } else if loaderView.isDescendant(of: view) {
            view.sendSubviewToBack(loaderScreen)
            loaderView.stopAnimating()
            loaderView.removeFromSuperview()
            loaderScreen.removeFromSuperview()
        }
    }
}


// MARK: LMViewLifeCycle
extension LMViewController: LMViewLifeCycle {
    /// This function handles the initialization of views.
    open func setupViews() { }
    
    /// This function handles the initialization of autolayouts.
    open func setupLayouts() { }
    
    /// This function handles the initialization of actions.
    open func setupActions() { }
    
    /// This function handles the initialization of styles.
    open func setupAppearance() { }
}


// MARK: LMBaseViewControllerProtocol
@objc
extension LMViewController: LMBaseViewControllerProtocol {
    open func presentAlert(with alert: UIAlertController, animated: Bool = true) {
        present(alert, animated: animated)
    }
}
