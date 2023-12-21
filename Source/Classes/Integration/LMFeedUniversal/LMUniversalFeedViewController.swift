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
    
    open private(set) lazy var headerView: LMFeedPostHeaderView = {
        let vc = LMFeedPostHeaderView()
        vc.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    open private(set) lazy var footerView: LMFeedPostFooterView = {
        let vc = LMFeedPostFooterView()
        vc.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    open private(set) lazy var searchBar: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        return search
    }()
    
    
    // MARK: Data Variables
    public var data: [LMFeedPostTableCellProtocol] = []
    
    
    // MARK: viewDidLoad
    open override func viewDidLoad() {
        super.viewDidLoad()
        dataGenerator()
        tableViewScrolled(tableView: tableView)
    }
    
    
    // MARK: setupViews
    open override func setupViews() {
        super.setupViews()
        view.addSubview(tableView)
    }
    
    // MARK: setupLayouts
    open override func setupLayouts() {
        super.setupLayouts()
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(didTapNavigationMenuButton))
        navigationController?.navigationBar.backgroundColor = Appearance.shared.colors.navigationBackgroundColor
        navigationItem.setTitle(with: "CommunityHood")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: nil, action: nil)
        
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
