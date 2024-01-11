//
//  LMTableView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 01/12/23.
//

import UIKit

public extension UITableView {
    func register(_ type: UITableViewCell.Type) {
        let className = String(describing: type)
        register(type, forCellReuseIdentifier: className)
    }
    
    func registerHeaderFooter(_ type: UITableViewHeaderFooterView.Type) {
        let className = String(describing: type)
        register(type, forHeaderFooterViewReuseIdentifier: className)
    }
    
    func dequeueReusableCell<T>(_ type: T.Type) -> T? {
        let className = String(describing: type)
        return dequeueReusableCell(withIdentifier: className) as? T
    }
    
    func dequeueReusableHeaderFooterView<T>(_ type: T.Type) -> T? {
        let className = String(describing: type)
        return dequeueReusableHeaderFooterView(withIdentifier: className) as? T
    }
}

public class LMTableView: UITableView {
    public var tableViewHeight: CGFloat {
        layoutIfNeeded()
        return contentSize.height
    }
    
    open func translatesAutoresizingMaskIntoConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    open func showHideFooterLoader(isShow: Bool) {
        switch isShow {
        case true:
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: 70)
            spinner.startAnimating()
            tableFooterView = spinner
        case false:
            tableFooterView = nil
        }
    }
}
