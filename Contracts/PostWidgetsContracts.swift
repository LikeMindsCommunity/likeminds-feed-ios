//
//  PostWidgetsContracts.swift
//  LikeMindsFeedUI
//
//  Created by Devansh Mohata on 20/07/24.
//


// MARK: LMPostWidgetTableViewCellProtocol
public protocol LMPostWidgetTableViewCellProtocol: AnyObject {
    func didTapPost(postID: String)
    func didTapURL(url: URL)
    func didTapRoute(route: String)
    func didTapSeeMoreButton(for postID: String)
}

public extension LMPostWidgetTableViewCellProtocol {
    func didTapPost(postID: String) { }
    func didTapSeeMoreButton(for postID: String) { }
}


// MARK: LMFeedMediaProtocol
public protocol LMFeedMediaProtocol { }


// MARK: LMFeedLinkProtocol
public protocol LMFeedLinkProtocol: LMPostWidgetTableViewCellProtocol {
    func didTapLinkPreview(with url: String)
}


// MARK: LMFeedPostDocumentCellProtocol
public protocol LMFeedPostDocumentCellProtocol: LMPostWidgetTableViewCellProtocol {
    func didTapShowMoreDocuments(for indexPath: IndexPath)
    func didTapDocument(with url: URL)
}


// MARK: LMFeedPostPollCellProtocol
public protocol LMFeedPostPollCellProtocol: LMPostWidgetTableViewCellProtocol {
    func didTapVoteCountButton(for postID: String, pollID: String, optionID: String?)
    func didTapToVote(for postID: String, pollID: String, optionID: String)
    func didTapSubmitVote(for postID: String, pollID: String)
    func editVoteTapped(for postID: String, pollID: String)
    func didTapAddOption(for postID: String, pollID: String)
}
