//
//  LMUniversalFeedViewController.swift
//  LMFramework
//
//  Created by Devansh Mohata on 28/11/23.
//

import UIKit

public protocol LMFeedPostTableCellProtocol { }

open class LMUniversalFeedViewController: LMViewController {
    // MARK: UI Elements
    open private(set) lazy var tableView: LMTableView = {
        let table = LMTableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    open private(set) lazy var searchBar: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        return search
    }()
    
    open private(set) lazy var contentStack: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.backgroundColor = Appearance.shared.colors.clear
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 4
        return stack
    }()
    
    open private(set) lazy var topicContainerView: LMView = {
        let view = LMView().translatesAutoresizingMaskIntoConstraints()
        view.backgroundColor = Appearance.shared.colors.white
        return view
    }()
    
    open private(set) lazy var topicStackView: LMStackView = {
        let stack = LMStackView().translatesAutoresizingMaskIntoConstraints()
        stack.backgroundColor = Appearance.shared.colors.clear
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    open private(set) lazy var allTopicsButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setTitle(Constants.shared.strings.allTopics, for: .normal)
        button.setImage(Constants.shared.images.downArrow, for: .normal)
        button.setFont(Appearance.shared.fonts.buttonFont2)
        button.setTitleColor(Appearance.shared.colors.gray102, for: .normal)
        button.tintColor = Appearance.shared.colors.gray102
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()
    
    open private(set) lazy var topicCollection: LMCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = .init(width: 100, height: 30)
        
        let collection = LMCollectionView(frame: .zero, collectionViewLayout: layout).translatesAutoresizingMaskIntoConstraints()
        collection.dataSource = self
        collection.delegate = self
        collection.registerCell(type: Components.shared.topicFeedEditCollectionCell)
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        return collection
    }()
    
    open private(set) lazy var clearButton: LMButton = {
        let button = LMButton().translatesAutoresizingMaskIntoConstraints()
        button.setFont(Appearance.shared.fonts.buttonFont2)
        button.setTitleColor(Appearance.shared.colors.gray102, for: .normal)
        button.setTitle("Clear", for: .normal)
        button.setImage(nil, for: .normal)
        button.tintColor = Appearance.shared.colors.gray102
        return button
    }()
    
    
    // MARK: Data Variables
    public var data: [LMFeedPostTableCellProtocol] = []
    public var selectedTopics: [LMFeedTopicCollectionCellDataModel] = []
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        dataGenerator()
        selectedTopics = [.init(topic: "Topic #1", topicID: "123"), .init(topic: "Topic #2", topicID: "234"), .init(topic: "Topic #3", topicID: "345"), .init(topic: "Topic #4", topicID: "456")]
        allTopicsButton.isHidden = true
        tableViewScrolled(tableView: tableView)
    }
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        view.addSubview(contentStack)
        
        contentStack.addArrangedSubview(topicContainerView)
        contentStack.addArrangedSubview(tableView)
        
        topicContainerView.addSubview(topicStackView)
        topicStackView.addArrangedSubview(allTopicsButton)
        topicStackView.addArrangedSubview(topicCollection)
        topicStackView.addArrangedSubview(clearButton)
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            topicContainerView.heightAnchor.constraint(equalToConstant: 50),
            topicStackView.leadingAnchor.constraint(equalTo: topicContainerView.leadingAnchor, constant: 16),
            topicStackView.trailingAnchor.constraint(lessThanOrEqualTo: topicContainerView.trailingAnchor, constant: -16),
            topicStackView.topAnchor.constraint(equalTo: topicContainerView.topAnchor),
            topicStackView.bottomAnchor.constraint(equalTo: topicContainerView.bottomAnchor),
            
            topicCollection.topAnchor.constraint(equalTo: topicStackView.topAnchor),
            topicCollection.bottomAnchor.constraint(equalTo: topicStackView.bottomAnchor),
            topicCollection.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        allTopicsButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        clearButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    // MARK: setupActions
    open override func setupActions() {
        super.setupActions()
        
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(Components.shared.postCell)
        tableView.register(Components.shared.documentCell)
        tableView.register(Components.shared.linkCell)
    }
    
    @objc
    open func didTapNavigationMenuButton() {
        print(#function)
    }
    
    // MARK: setupAppearance
    open override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = Appearance.shared.colors.backgroundColor
    }
    
    // MARK: setupNavigationBar
    open override func setupNavigationBar() {
        super.setupNavigationBar()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.shared.images.menuIcon, style: .plain, target: self, action: #selector(didTapNavigationMenuButton))
        navigationController?.navigationBar.backgroundColor = Appearance.shared.colors.navigationBackgroundColor
        navigationItem.setTitle(with: Constants.shared.strings.communityHood)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Constants.shared.images.personIcon, style: .plain, target: nil, action: nil)
        
        navigationItem.searchController = searchBar
    }
    
    open func tableViewScrolled(tableView: LMTableView) {
        for case let cell as LMFeedPostMediaCell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell) {
                let cellRect = tableView.rectForRow(at: indexPath)
                let convertedRect = tableView.convert(cellRect, to: tableView.superview)
                cell.tableViewScrolled(isPlay: tableView.bounds.contains(convertedRect))
            }
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
@objc
extension LMUniversalFeedViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(Components.shared.postCell),
           let cellData = data[indexPath.row] as? LMFeedPostMediaCell.ViewModel {
            cell.configure(with: cellData, delegate: self)
            return cell
        } else if let cell = tableView.dequeueReusableCell(Components.shared.documentCell),
                  let cellData = data[indexPath.row] as? LMFeedPostDocumentCell.ViewModel {
            cell.configure(for: indexPath, with: cellData, delegate: self)
            return cell
        } else if let cell = tableView.dequeueReusableCell(Components.shared.linkCell),
                  let cellData = data[indexPath.row] as? LMFeedPostLinkCell.ViewModel {
            cell.configure(with: cellData, delegate: self)
            return cell
        }
        
        return UITableViewCell()
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? LMTableView else { return }
        tableViewScrolled(tableView: tableView)
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellRect = tableView.rectForRow(at: indexPath)
        if tableView.bounds.contains(cellRect) {
            print(indexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Components.shared.postDetailScreen.init()
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: UICollectionView
@objc
extension LMUniversalFeedViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedTopics.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(with: Components.shared.topicFeedEditCollectionCell, for: indexPath),
           let data = selectedTopics[safe: indexPath.row] {
            cell.configure(with: data, delegate: self)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = selectedTopics[indexPath.row].topic.sizeOfString(with: Appearance.shared.fonts.textFont1)
        return .init(width: size.width + 40, height: 30)
    }
}

// MARK: LMFeedPostDocumentCellProtocol
@objc
extension LMUniversalFeedViewController: LMFeedPostDocumentCellProtocol {
    open func didTapShowMoreDocuments(for indexPath: IndexPath) {
        guard var datum = data[indexPath.row] as? LMFeedPostDocumentCell.ViewModel else { return }
        datum.isShowAllDocuments.toggle()
        data[indexPath.row] = datum
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}


// MARK: LMChatLinkProtocol
@objc
extension LMUniversalFeedViewController: LMChatLinkProtocol {
    open func didTapLinkPreview(with url: String) {
        print(#function, url)
    }
}

// MARK: LMFeedTableCellToViewControllerProtocol
@objc
extension LMUniversalFeedViewController: LMFeedTableCellToViewControllerProtocol {
    open func didTapProfilePicture(for uuid: String) { print(#function) }
    
    open func didTapMenuButton(for postID: String) { print(#function) }
    
    open func didTapLikeButton(for postID: String) { print(#function) }
    
    open func didTapLikeTextButton(for postID: String) { print(#function) }
    
    open func didTapCommentButton(for postID: String) { print(#function) }
    
    open func didTapShareButton(for postID: String) { print(#function) }
    
    open func didTapSaveButton(for postID: String) { print(#function) }
}


// MARK: LMFeedTopicViewCellProtocol
@objc
extension LMUniversalFeedViewController: LMFeedTopicViewCellProtocol {
    open func didTapCrossButton(for topicId: String) {
        print(#function)
    }
    
    open func didTapEditButton() {
        print(#function)
    }
}


// MARK: Sample Data
extension LMUniversalFeedViewController {
    func dataGenerator() {
        docGenerator()
        linkGenerator()
        mediaGenerator()
    }
    
    func docGenerator() {
        func doccer(id: Int) -> LMFeedPostDocumentCellView.ViewModel {
            .init(
                documentID: id,
                title: "This is PDF \(id)",
                size: Double(id * id) * 10,
                pageCount: id,
                docType: "PDF"
            )
        }
        
        for i in 0..<5 {
            var docs: [LMFeedPostDocumentCellView.ViewModel] = []
            
            for j in 0...i {
                docs.append(doccer(id: j))
            }
            
            let datum = LMFeedPostDocumentCell.ViewModel.init(
                headerData: headerData(), 
                topics: .init(topics: generateTopics(), isEditFlow: Bool.random(), isSepratorShown: Bool.random()),
                postText: "<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments",
                documents: docs,
                footerData: .init(isSaved: Bool.random(), isLiked: Bool.random()))
            
            data.append(datum)
        }
    }
    
    func linkGenerator() {
        func linker() -> LMFeedPostLinkCellView.ViewModel {
            .init(
                linkPreview: "https://picsum.photos/200",
                title: "This is Gooogle",
                description: "Google.com is the best Search Engine",
                url: "www.google.com"
            )
        }
        
        (0...5).forEach { _ in
            let linkum = LMFeedPostLinkCell.ViewModel.init(
                headerData: headerData(),
                postText: "<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments", 
                topics: .init(topics: generateTopics(), isEditFlow: false, isSepratorShown: true),
                mediaData: linker(),
                footerData: .init(isSaved: Bool.random(), isLiked: Bool.random())
            )
            data.append(linkum)
        }
    }
    
    func generateTopics() -> [LMFeedTopicCollectionCellDataModel] {
        var data = [LMFeedTopicCollectionCellDataModel]()
        
        (0...20).forEach { i in
            data.append(.init(topic: "\(i*i)", topicID: "\(i+i)"))
        }
        
        return data
    }
    
    func mediaGenerator() {
        func imageMedium() -> LMFeedPostImageCollectionCell.ViewModel {
            .init(image: "pdfIcon")
        }
        
        func videMedium() -> LMFeedPostVideoCollectionCell.ViewModel {
            .init(videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
        }
        
        for _ in 0..<5 {
            let medium = LMFeedPostMediaCell.ViewModel.init(
                headerData: headerData(),
                postText: "<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments<<Thor|route://user_profile/thor123>> <<DB|route://user_profile/fgsdfgs>> fdsgkdskfbj <<DB|route://user_profile/fgsdfgs>> <<Feed Api key bot|route://user_profile/1d7fcd74-21ed-4e54-b5b4-792e2d2a1e2f>> This is a Post containing Documents www.google.com as #Attachments", 
                topics: .init(topics: generateTopics(), isEditFlow: Bool.random(), isSepratorShown: Bool.random()),
                mediaData: [imageMedium(), videMedium(), imageMedium()],
                footerData: .init(isSaved: Bool.random(), isLiked: Bool.random())
            )
            
            data.append(medium)
        }
    }
    
    func headerData() -> LMFeedPostHeaderView.ViewModel {
        .init(
            profileImage: "https://picsum.photos/200/300",
            authorName: "Devansh Mohata",
            authorTag: Bool.random() ? "Owner" : nil,
            subtitle: "3 Hours Ago",
            isPinned: Bool.random(),
            showMenu: Bool.random()
        )
    }
}
