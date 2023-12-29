//
//  LMFeedPostMediaCell.swift
//  LMFramework
//
//  Created by Devansh Mohata on 29/11/23.
//

import AVKit
import UIKit

public protocol LMFeedMediaProtocol { }

@IBDesignable
open class LMFeedPostMediaCell: LMPostWidgetTableViewCell {
    // MARK: Data Model
    public struct ViewModel: LMFeedPostTableCellProtocol {
        let headerData: LMFeedPostHeaderView.ViewModel
        let postText: String
        let topics: LMFeedTopicView.ViewModel
        let mediaData: [LMFeedMediaProtocol]
        var footerData: LMFeedPostFooterView.ViewModel
        
        public init(headerData: LMFeedPostHeaderView.ViewModel, postText: String, topics: LMFeedTopicView.ViewModel?, mediaData: [LMFeedMediaProtocol], footerData: LMFeedPostFooterView.ViewModel) {
            self.headerData = headerData
            self.postText = postText
            self.topics = topics ?? .init()
            self.mediaData = mediaData
            self.footerData = footerData
        }
    }
    
    // MARK: UI Elements
    open private(set) lazy var mediaCollectionView: LMCollectionView = {
        let collection = LMCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.collectionViewLayout = imageCollectionViewLayout
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.bounces = false
        collection.backgroundColor = Appearance.shared.colors.clear
        return collection
    }()
    
    open private(set) lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isEnabled = false
        pageControl.numberOfPages = mediaCellsData.count
        pageControl.currentPageIndicatorTintColor = .gray
        pageControl.pageIndicatorTintColor = .purple
        pageControl.hidesForSinglePage = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    open private(set) lazy var imageCollectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        return layout
    }()
    
    open private(set) lazy var videoPlayer: AVPlayerViewController = {
        let player = AVPlayerViewController()
        player.view.translatesAutoresizingMaskIntoConstraints = false
        player.showsPlaybackControls = true
        return player
    }()
    
    
    //MARK: Data Variables
    private var mediaCellsData: [LMFeedMediaProtocol] = []

    
    // MARK: View Hierachy
    open override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(headerView)
        containerView.addSubview(contentStack)
        containerView.addSubview(footerView)
        containerView.addSubview(postText)
        
        contentStack.addArrangedSubview(topicFeed)
        contentStack.addArrangedSubview(postText)
        contentStack.addArrangedSubview(mediaCollectionView)
        contentStack.addArrangedSubview(pageControl)
    }
    
    // MARK: Constraints
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: contentStack.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Constants.shared.number.postHeaderSize),
            
            contentStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            
            postText.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            postText.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16),
            
            topicFeed.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            topicFeed.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16),
            
            mediaCollectionView.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            mediaCollectionView.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            mediaCollectionView.widthAnchor.constraint(equalTo: mediaCollectionView.heightAnchor, multiplier: 3/2),
            
            pageControl.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            
            
            footerView.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 0),
            footerView.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16),
            footerView.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16),
            footerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            footerView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    open override func setupActions() {
        super.setupActions()
        
        headerView.delegate = self
        footerView.delegate = self
        pageControl.addTarget(self, action: #selector(didChangePageControl), for: .primaryActionTriggered)
        
        mediaCollectionView.registerCell(type: Components.shared.imageCollectionCell)
        mediaCollectionView.registerCell(type: Components.shared.videoCollectionCell)
    }
    
    // MARK: Appearance
    open override func setupAppearance() {
        super.setupAppearance()
        backgroundColor = Appearance.shared.colors.clear
        contentView.backgroundColor = Appearance.shared.colors.clear
        containerView.backgroundColor = Appearance.shared.colors.white
    }
    
    // MARK: Action
    @objc
    open func didChangePageControl(_ sender: UIPageControl) {
        guard mediaCellsData.indices.contains(sender.currentPage) else { return }
        mediaCollectionView.scrollToItem(at: .init(row: sender.currentPage, section: .zero), at: .centeredHorizontally, animated: true)
    }
    
    open func tableViewScrolled(isPlay: Bool) {
        for case let cell as LMFeedPostVideoCollectionCell in mediaCollectionView.visibleCells {
            if let indexPath = mediaCollectionView.indexPath(for: cell),
               let itemRect = mediaCollectionView.layoutAttributesForItem(at: indexPath)?.frame{
                let convertedRect = mediaCollectionView.convert(itemRect, to: mediaCollectionView.superview)
                
                if mediaCollectionView.bounds.contains(convertedRect) {
                    cell.playVideo()
                } else {
                    cell.pauseVideo()
                }
            }
        }
    }
    
    // MARK: Configure Function
    open func configure(with data: ViewModel, delegate: LMFeedTableCellToViewControllerProtocol) {
        actionDelegate = delegate
        
        headerView.configure(with: data.headerData)
        postText.attributedText = GetAttributedTextWithRoutes.getAttributedText(from: data.postText)
        postText.isHidden = data.postText.isEmpty
        
        topicFeed.configure(with: data.topics)
        topicFeed.isHidden = data.topics.topics.isEmpty
        
        mediaCellsData = data.mediaData
        setupMediaCells()
        
        footerView.configure(with: data.footerData)
    }
    
    open func setupMediaCells() {
        mediaCollectionView.isHidden = mediaCellsData.isEmpty
        mediaCollectionView.reloadData()
        
        pageControl.isHidden = mediaCellsData.isEmpty
        pageControl.numberOfPages = mediaCellsData.count
    }
}


//MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
@objc
extension LMFeedPostMediaCell: UICollectionViewDataSource,
                               UICollectionViewDelegate,
                               UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mediaCellsData.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(with: Components.shared.imageCollectionCell, for: indexPath),
           let data = mediaCellsData[indexPath.row] as? LMFeedPostImageCollectionCell.ViewModel {
            cell.configure(with: data)
            return cell
        } else if let cell = collectionView.dequeueReusableCell(with: Components.shared.videoCollectionCell, for: indexPath),
                  let data = mediaCellsData[indexPath.row] as? LMFeedPostVideoCollectionCell.ViewModel {
            cell.configure(with: data, videoPlayer: videoPlayer)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? LMFeedPostVideoCollectionCell else { return }
        cell.pauseVideo()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
}
