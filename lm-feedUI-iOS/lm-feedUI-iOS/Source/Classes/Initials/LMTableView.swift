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
    
    func percentVisibility(of cell: UITableViewCell) -> CGFloat {
        guard let indexPathForCell = self.indexPath(for: cell) else {
            return CGFloat.leastNonzeroMagnitude
        }
        
        // Get the cell frame with respect to the table view
        let cellRectInTable = self.rectForRow(at: indexPathForCell)
        
        // Convert the cell frame to the table view's superview coordinate system if needed
        // This step may be necessary if you want to consider the cell's visibility relative to the table view's superview
        // However, if you're only interested in the visibility within the table view's bounds, this conversion is not needed
        // let cellRectInSuper = self.convert(cellRectInTable, to: self.superview)
        
        // Calculate the intersection of the cell's frame with the table view's visible rect
        let visibleRect = CGRect(x: self.contentOffset.x, y: self.contentOffset.y, width: self.bounds.size.width, height: self.bounds.size.height)
        let intersectionRect = cellRectInTable.intersection(visibleRect)
        
        // Calculate the percentage of the cell that is visible
        let percentOfIntersection: CGFloat = intersectionRect.height / cellRectInTable.height
        
        return max(0, min(1, percentOfIntersection)) // Ensure the percentage is between 0 and 1
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
    
    open func reloadTable(for index: IndexPath? = nil) {
        UIView.performWithoutAnimation { [weak self] in
            if let index {
                if index.row == NSNotFound {
                    self?.reloadSections(IndexSet(integer: index.section), with: .none)
                } else {
                    self?.reloadRows(at: [index], with: .none)
                }
            } else {
                self?.reloadData()
            }
        }
    }
}
