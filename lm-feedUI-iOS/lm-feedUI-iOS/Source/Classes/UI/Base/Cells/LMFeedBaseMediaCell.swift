//
//  LMFeedBaseMediaCell.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 23/07/24.
//

import UIKit

open class LMFeedBaseMediaCell: LMPostWidgetTableViewCell {
    // MARK: UI Elements
    open private(set) lazy var mediaCollectionView: LMCollectionView = {
        let collection = LMCollectionView(frame: .zero, collectionViewLayout: LMCollectionView.mediaFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.bounces = false
        collection.backgroundColor = LMFeedAppearance.shared.colors.clear
        collection.registerCell(type: LMUIComponents.shared.imagePreview)
        collection.registerCell(type: LMUIComponents.shared.videoPreview)
        return collection
    }()
    
    open private(set) lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isEnabled = false
        pageControl.numberOfPages = mediaCellsData.count
        pageControl.currentPageIndicatorTintColor = LMFeedAppearance.shared.colors.appTintColor
        pageControl.pageIndicatorTintColor = LMFeedAppearance.shared.colors.gray155
        pageControl.hidesForSinglePage = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    
    //MARK: Data Variables
    public var mediaCellsData: [LMFeedMediaProtocol] = []
    public weak var delegate: LMFeedPostMediaCellProtocol?
    private var mediaCollectionViewHeightConstraint: NSLayoutConstraint?
    
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = LMFeedAppearance.shared.colors.clear
        contentView.backgroundColor = LMFeedAppearance.shared.colors.clear
        containerView.backgroundColor = LMFeedAppearance.shared.colors.white
    }
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        pageControl.addTarget(self, action: #selector(didChangePageControl), for: .primaryActionTriggered)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        mediaCollectionView.setWidthConstraint(with: contentStack.widthAnchor)
        mediaCollectionViewHeightConstraint = mediaCollectionView.setHeightConstraint(with: mediaCollectionView.widthAnchor)
    }
    
    @objc
    open func didChangePageControl(_ sender: UIPageControl) {
        guard mediaCellsData.indices.contains(sender.currentPage) else { return }
        mediaCollectionView.scrollToItem(at: .init(row: sender.currentPage, section: .zero), at: .centeredHorizontally, animated: true)
    }
    
    open func tableViewScrolled(isPlay: Bool = false) {
        for case let cell as LMFeedVideoCollectionCell in mediaCollectionView.visibleCells {
            cell.pauseVideo()
        }
        
        if isPlay,
           mediaCollectionView.indexPathsForFullyVisibleItems().count == 1,
           let visibleIndex = mediaCollectionView.indexPathsForFullyVisibleItems().first {
            (mediaCollectionView.cellForItem(at: visibleIndex) as? LMFeedVideoCollectionCell)?.playVideo()
        }
    }
    
    
    // MARK: Configure Function
    open func configure(with data: LMFeedPostContentModel, delegate: LMFeedPostMediaCellProtocol?) {
        actionDelegate = delegate
        self.delegate = delegate
        postID = data.postID
        userUUID = data.userUUID
        
        setupPostText(text: data.postText, showMore: data.isShowMore)
        topicFeed.configure(with: data.topics)
        
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        mediaCellsData = data.mediaData
        setupMediaCells(mediaHaveSameAspectRatio: data.mediaHaveSameAspectRatio, aspectRatio: data.aspectRatio)
    }
    
    private func updateMediaCollectionViewHeight(mediaHaveSameAspectRatio: Bool, aspectRatio: Double) {
        if let existingHeightConstraint = mediaCollectionViewHeightConstraint {
            mediaCollectionView.removeConstraint(existingHeightConstraint)
            mediaCollectionViewHeightConstraint = nil
        }
        
        let heightFactor: Double
        
        if mediaHaveSameAspectRatio {
            // Handle aspect ratios from 1.91:1 to 4:5
            let minAspectRatio: Double = 4/5 // Corresponding to 1.91:1
            let maxAspectRatio: Double = 1.91 // Corresponding to 4:5
            
            // Clamp the aspect ratio within the valid range
            heightFactor = 1/min(max(aspectRatio, minAspectRatio), maxAspectRatio)
        } else {
            // Set the aspect ratio to 1:1 when mediaHaveSameAspectRatio is false
            heightFactor = 1.0
        }
        
        // Create and add the new height constraint
        mediaCollectionViewHeightConstraint = mediaCollectionView.setHeightConstraint(with: mediaCollectionView.widthAnchor, multiplier: heightFactor)
        mediaCollectionViewHeightConstraint?.priority = .defaultHigh
        mediaCollectionViewHeightConstraint?.isActive = true
        
        // Animate the layout change
        UIView.animate(withDuration: 0.2, animations: {
            self.mediaCollectionView.layoutIfNeeded()
        })
    }
    
    
    
    open func setupMediaCells(mediaHaveSameAspectRatio: Bool, aspectRatio: Double) {
        mediaCollectionView.isHidden = mediaCellsData.isEmpty
        pageControl.isHidden = mediaCellsData.count < 2
        
        guard !mediaCellsData.isEmpty else {
            return
        }
        
        updateMediaCollectionViewHeight(mediaHaveSameAspectRatio: mediaHaveSameAspectRatio, aspectRatio: aspectRatio)
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            self.mediaCollectionView.reloadData()
            
            self.pageControl.isHidden = self.mediaCellsData.count < 2
            self.pageControl.numberOfPages = self.mediaCellsData.count
            
            self.tableViewScrolled()
        }
    }
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
@objc
extension LMFeedBaseMediaCell: UICollectionViewDataSource,
                               UICollectionViewDelegate,
                               UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mediaCellsData.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let data = mediaCellsData[indexPath.row] as? LMFeedImageCollectionCell.ContentModel,
           let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.imagePreview, for: indexPath) {
            cell.configure(with: data, didTapImage: {
                guard let postID = self.postID else{
                    return
                }
                self.delegate?.didTapMedia(postID: postID, index: indexPath.row)
            })
            return cell
        } else if let data = mediaCellsData[indexPath.row] as? LMFeedVideoCollectionCell.ContentModel,
                  let cell = collectionView.dequeueReusableCell(with: LMUIComponents.shared.videoPreview, for: indexPath) {
            cell.configure(with: data, index: indexPath.row, didTapVideo: {
                guard let postID = self.postID else{
                    return
                }
                self.delegate?.didTapMedia(postID: postID, index: indexPath.row)
            })
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingFinished()
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollingFinished()
        }
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableViewScrolled()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? LMFeedVideoCollectionCell)?.pauseVideo()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let postID else { return }
        delegate?.didTapMedia(postID: postID, index: indexPath.row)
    }
    
    public func scrollingFinished() {
        pageControl.currentPage = Int(mediaCollectionView.contentOffset.x / mediaCollectionView.frame.width)
        
        if mediaCollectionView.visibleCells.count == 1 {
            (mediaCollectionView.visibleCells.first as? LMFeedVideoCollectionCell)?.playVideo()
        }
    }
}
