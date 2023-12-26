//
//  LMTableView.swift
//  LMFramework
//
//  Created by Devansh Mohata on 01/12/23.
//

import UIKit

extension UITableView {
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
    open func translatesAutoresizingMaskIntoConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
