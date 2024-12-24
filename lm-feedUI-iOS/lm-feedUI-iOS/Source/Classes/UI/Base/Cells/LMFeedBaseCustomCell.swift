//
//  LMFeedBaseCustomCell.swift
//  Pods
//
//  Created by Anurag Tyagi on 16/12/24.
//


open class LMFeedBaseCustomCell: LMPostWidgetTableViewCell{
    
    var indexPath: IndexPath?
    var data: LMFeedPostContentModel?
    
    open func configure(for indexPath: IndexPath, with data: LMFeedPostContentModel){
        self.data = data
        self.indexPath = indexPath
    }
}
