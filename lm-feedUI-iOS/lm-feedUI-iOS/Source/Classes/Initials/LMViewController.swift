//
//  LMViewController.swift
//  LMFramework
//
//  Created by Devansh Mohata on 24/11/23.
//

import Kingfisher
import PDFKit
import SafariServices
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
    func showHideLoaderView(isShow: Bool, backgroundColor: UIColor)
    func showError(with message: String, isPopVC: Bool)
    func popViewController(animated: Bool)
    func showMessage(with title: String, message: String?)
}

public extension LMBaseViewControllerProtocol {
    func showHideLoaderView(isShow: Bool, backgroundColor: UIColor = .white) {
        showHideLoaderView(isShow: isShow, backgroundColor: backgroundColor)
    }
    
    func showError(with message: String, isPopVC: Bool = false) {
        showError(with: message, isPopVC: isPopVC)
    }
    
    func popViewController(animated: Bool = true) {
        popViewController(animated: animated)
    }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        setupObservers()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAppearance()
    }
    
    open func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Appearance.shared.colors.navigationBackgroundColor
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.barTintColor = Appearance.shared.colors.navigationBackgroundColor
        }
        
        navigationController?.navigationBar.isTranslucent = false
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
        titleView.pinSubView(subView: stackView, padding: .init(top: 2, left: 0, bottom: -2, right: 0))
        
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
    
    open func openURL(with url: URL) {
        if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let safariController = SFSafariViewController(url: url, configuration: config)
            present(safariController, animated: true)
            return
        } else if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return
        }
        
        
        if url.startAccessingSecurityScopedResource() {
            let document = UIDocumentInteractionController(url: url)
            document.delegate = self
            document.presentPreview(animated: true)
        }
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageCache.default.clearMemoryCache()
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
    
    /// This function handles the initialization of observers.
    open func setupObservers() { }
}


// MARK: LMBaseViewControllerProtocol
@objc
extension LMViewController: LMBaseViewControllerProtocol {
    open func presentAlert(with alert: UIAlertController, animated: Bool = true) {
        present(alert, animated: animated)
    }
    
    open func showError(with message: String, isPopVC: Bool) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if isPopVC {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        alert.addAction(action)
        presentAlert(with: alert)
    }
    
    open func showHideLoaderView(isShow: Bool, backgroundColor: UIColor) {
        if isShow {
            view.addSubview(loaderScreen)
            loaderScreen.backgroundColor = backgroundColor
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
    
    open func popViewController(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    open func showMessage(with title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


extension LMViewController: UIDocumentInteractionControllerDelegate {
    open func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController { self }
}
