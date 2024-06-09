//
//  LMFeedCreatePollViewModel.swift
//  LikeMindsFeedCore
//
//  Created by Devansh Mohata on 08/06/24.
//

import LikeMindsFeedUI

public protocol LMFeedCreatePollViewModelProtocol: LMBaseViewControllerProtocol {
    func configure(pollHeaderData: LMFeedCreatePollHeader.ContentModel, pollOptionsData: [LMFeedCreatePollOptionWidget.ContentModel], metaOptions: LMFeedCreatePollMetaView.ContentModel, expiryDate: Date?)
    func updateExpiryDate(with newDate: Date)
    func updatePollOptions(with newData: [LMFeedCreatePollOptionWidget.ContentModel])
    func showMetaOptionsPickerView(with components: [[String]], selectedOptionRow: Int, selectedOptionCountRow: Int)
}

final public class LMFeedCreatePollViewModel {
    var delegate: LMFeedCreatePollViewModelProtocol?
    var prefilledData: LMFeedCreatePollDataModel?
    let defaultPollAnswerCount: Int
    var currentOptionCount: Int
    var optionSelectionState: LMFeedCreatePollDataModel.OptionState
    var pollExpiryDate: Date?
    var pollOptions: [String?]
    
    init(delegate: LMFeedCreatePollViewModelProtocol?, prefilledData: LMFeedCreatePollDataModel?) {
        self.delegate = delegate
        self.prefilledData = prefilledData
        self.defaultPollAnswerCount = 2
        self.optionSelectionState = prefilledData?.selectState ?? .exactly
        self.currentOptionCount = prefilledData?.selectStateCount ?? 1
        self.pollOptions = prefilledData?.pollOptions ?? Array(repeating: nil, count: defaultPollAnswerCount)
    }
    
    public static func createModule(with data: LMFeedCreatePollDataModel? = nil) throws -> LMFeedCreatePollScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewcontroller = LMFeedCreatePollScreen()
        let viewModel = LMFeedCreatePollViewModel(delegate: viewcontroller, prefilledData: data)
        
        viewcontroller.viewmodel = viewModel
        
        return viewcontroller
    }
    
    public func loadInitialData() {
        let userDetails = LocalPreferences.userObj
        
        let pollHeaderData = LMFeedCreatePollHeader.ContentModel(
            profileImage: userDetails?.imageUrl,
            username: userDetails?.name ?? "User",
            pollQuestion: prefilledData?.pollQuestion
        )
        
        let pollOptions: [LMFeedCreatePollOptionWidget.ContentModel] = pollOptions.enumerated().map { id, option in
            return .init(option: option)
        }
        
        
        var metaOptionsModel: [LMFeedCreatePollMetaOptionWidget.ContentModel] = []
        
        LMFeedCreatePollDataModel.MetaOptions.allCases.forEach { option in
            let desc = option.description
            switch option {
            case .isAnonymousPoll:
                metaOptionsModel.append(.init(id: option.rawValue, title: desc, isSelected: prefilledData?.isAnonymous ?? false))
            case .isInstantPoll:
                metaOptionsModel.append(.init(id: option.rawValue, title: desc, isSelected: prefilledData?.isInstantPoll ?? false))
            case .allowAddOptions:
                metaOptionsModel.append(.init(id: option.rawValue, title: desc, isSelected: prefilledData?.allowAddOptions ?? false))
            }
        }
        
        let metaOptionsData: LMFeedCreatePollMetaView.ContentModel = .init(
            metaOptions: metaOptionsModel,
            optionState: optionSelectionState.description,
            optionCount: currentOptionCount
        )
        
        
        delegate?.configure(
            pollHeaderData: pollHeaderData,
            pollOptionsData: pollOptions,
            metaOptions: metaOptionsData,
            expiryDate: prefilledData?.expiryTime
        )
    }
    
    public func updatePollExpiryDate(with newDate: Date) {
        let current = Date()
        var newDate = newDate
        
        if newDate < current {
            newDate = current.addingTimeInterval(60 * 5)
        }
        
        pollExpiryDate = newDate
        delegate?.updateExpiryDate(with: newDate)
    }
    
    public func removePollOption(at index: Int) {
        guard pollOptions.count > 2,
              pollOptions.indices.contains(index) else { return }
        pollOptions.remove(at: index)
        
        delegate?.updatePollOptions(with: pollOptions.map({ .init(option: $0) }))
    }
    
    public func insertPollOption() {
        guard pollOptions.count < 10 else {
            delegate?.showError(with: "You can add at max 10 options", isPopVC: false)
            return
        }
        pollOptions.append(nil)
        
        delegate?.updatePollOptions(with: pollOptions.map({ .init(option: $0) }))
    }
    
    public func showMetaOptionsPicker() {
        let optionTypeRow: [String] = LMFeedCreatePollDataModel.OptionState.allCases.map({ $0.description })
        
        var optionCountRow: [String] = []
        
        let count = pollOptions.count
        
        for i in 1...count {
            optionCountRow.append("\(i) option\(i == 1 ? "" : "s")")
        }
        
        delegate?.showMetaOptionsPickerView(
            with: [optionTypeRow, optionCountRow],
            selectedOptionRow: optionSelectionState.rawValue,
            selectedOptionCountRow: currentOptionCount - 1 // Doing this because array starts from 0
        )
    }
}
