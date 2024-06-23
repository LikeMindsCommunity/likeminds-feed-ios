//
//  LMFeedPollAddOptionViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 19/06/24.
//

import LikeMindsFeed
import LikeMindsFeedUI

public protocol LMFeedPollAddOptionViewModelProtocol: LMBaseViewControllerProtocol {
    func setSubmitButton(isEnabled: Bool)
    func showButtonLoader()
    func onAddOptionResponse(postID: String, success: Bool, errorMessage: String?)
}

public final class LMFeedPollAddOptionViewModel {
    let postID: String
    let pollID: String
    let pollOptions: [String]
    weak var delegate: LMFeedPollAddOptionViewModelProtocol?
    
    init(postID: String, pollID: String, pollOptions: [String], delegate: LMFeedPollAddOptionViewModelProtocol? = nil) {
        self.postID = postID
        self.pollID = pollID
        self.pollOptions = pollOptions
        self.delegate = delegate
    }
    
    public static func createModule(for postID: String, pollID: String, options: [String], delegate: LMFeedAddOptionProtocol?) throws -> LMFeedPollAddOptionScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewcontroller = LMFeedPollAddOptionScreen()
        
        let viewmodel = Self.init(postID: postID, pollID: pollID, pollOptions: options, delegate: viewcontroller)
        viewcontroller.viewmodel = viewmodel
        viewcontroller.delegate = delegate
        
        return viewcontroller
    }
    
    public func checkValidOption(with value: String?) {
        delegate?.setSubmitButton(isEnabled: checkValidString(value: value))
    }
    
    private func checkValidString(value: String?) -> Bool {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return false
        }
        
        return !pollOptions.contains(value)
    }
    
    public func onSubmitClick(with value: String?) {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              checkValidString(value: value) else { return }
        
        let request = AddPollOptionRequest
            .builder()
            .pollID(pollID)
            .pollText(value)
            .build()
        
        LMFeedClient.shared.addPollOption(request) { [weak self] response in
            guard let self else { return }
            
            delegate?.onAddOptionResponse(postID: self.postID, success: response.success, errorMessage: response.errorMessage)
        }
    }
}
