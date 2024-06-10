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
    func showMetaOptionsPickerView(with data: LMFeedGeneralPicker.ContentModel)
    func updateMetaOption(with option: String, count: Int)
    func presentDatePicker(with selectedDate: Date, minimumDate: Date)
    func updatePoll(with data: LMFeedCreatePollDataModel)
}

final public class LMFeedCreatePollViewModel {
    var delegate: LMFeedCreatePollViewModelProtocol?
    
    /// minimum poll options to be shown
    let defaultPollAnswerCount: Int
    
    /// poll question
    var pollQuestion: String?
    
    /// number of options in selection
    var currentOptionCount: Int
    
    /// poll option state - `exactly` || `at_max` || `at_least`
    var optionSelectionState: LMFeedCreatePollDataModel.OptionState
    
    /// poll expiry date
    var pollExpiryDate: Date?
    
    /// poll options
    var pollOptions: [String?]
    
    /// is anonymous poll: default is `false`
    var isAnonymousPoll: Bool
    
    /// is instant poll: default is `true`
    var isInstantPoll: Bool
    
    /// allow user to add options: default is `false`
    var allowAddOptions: Bool
    
    init(delegate: LMFeedCreatePollViewModelProtocol?, prefilledData: LMFeedCreatePollDataModel?) {
        self.delegate = delegate
        self.pollQuestion = prefilledData?.pollQuestion
        self.defaultPollAnswerCount = 2
        self.optionSelectionState = prefilledData?.selectState ?? .exactly
        self.currentOptionCount = prefilledData?.selectStateCount ?? 1
        self.pollOptions = prefilledData?.pollOptions ?? Array(repeating: nil, count: defaultPollAnswerCount)
        self.isAnonymousPoll = prefilledData?.isAnonymous ?? false
        self.isInstantPoll = prefilledData?.isInstantPoll ?? true
        self.allowAddOptions = prefilledData?.allowAddOptions ?? false
        self.pollExpiryDate = prefilledData?.expiryTime
    }
    
    public static func createModule(with pollDelegate: LMFeedCreatePollProtocol, data: LMFeedCreatePollDataModel? = nil) throws -> LMFeedCreatePollScreen {
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewcontroller = LMFeedCreatePollScreen()
        let viewModel = LMFeedCreatePollViewModel(delegate: viewcontroller, prefilledData: data)
        
        viewcontroller.viewmodel = viewModel
        viewcontroller.pollDelegate = pollDelegate
        
        return viewcontroller
    }
    
    public func loadInitialData() {
        let userDetails = LocalPreferences.userObj
        
        let pollHeaderData = LMFeedCreatePollHeader.ContentModel(
            profileImage: userDetails?.imageUrl,
            username: userDetails?.name ?? "User",
            pollQuestion: pollQuestion
        )
        
        let pollOptions: [LMFeedCreatePollOptionWidget.ContentModel] = pollOptions.enumerated().map { id, option in
            return .init(id: id, option: option)
        }
        
        
        var metaOptionsModel: [LMFeedCreatePollMetaOptionWidget.ContentModel] = []
        
        LMFeedCreatePollDataModel.MetaOptions.allCases.forEach { option in
            let desc = option.description
            switch option {
            case .isAnonymousPoll:
                metaOptionsModel.append(.init(id: option.rawValue, title: desc, isSelected: isAnonymousPoll))
            case .isInstantPoll:
                metaOptionsModel.append(.init(id: option.rawValue, title: desc, isSelected: !isInstantPoll))
            case .allowAddOptions:
                metaOptionsModel.append(.init(id: option.rawValue, title: desc, isSelected: allowAddOptions))
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
            expiryDate: pollExpiryDate
        )
    }
    
    public func updatePollExpiryDate(with newDate: Date) {
        pollExpiryDate = newDate
        delegate?.updateExpiryDate(with: newDate)
    }
    
    public func removePollOption(at index: Int) {
        guard pollOptions.count > 2,
              pollOptions.indices.contains(index) else { return }
        pollOptions.remove(at: index)
        
        
        if currentOptionCount > pollOptions.count {
            currentOptionCount = 1
            delegate?.updateMetaOption(with: optionSelectionState.description, count: currentOptionCount)
        }
        
        delegate?.updatePollOptions(with: pollOptions.enumerated().map({ .init(id: $0, option: $1) }))
    }
    
    public func insertPollOption() {
        guard pollOptions.count < 10 else {
            delegate?.showError(with: "You can add at max 10 options", isPopVC: false)
            return
        }
        pollOptions.append(nil)
        
        delegate?.updatePollOptions(with: pollOptions.enumerated().map({ .init(id: $0, option: $1) }))
    }
    
    public func updatePollOption(for id: Int, option: String?) {
        guard pollOptions.indices.contains(id) else { return }
        pollOptions[id] = option
    }
    
    public func showMetaOptionsPicker() {
        let optionTypeRow: [String] = LMFeedCreatePollDataModel.OptionState.allCases.map({ $0.description })
        
        var optionCountRow: [String] = []
        
        let count = pollOptions.count
        
        for i in 1...count {
            optionCountRow.append("\(i) option\(i == 1 ? "" : "s")")
        }
        
        let data = LMFeedGeneralPicker.ContentModel(components: [optionTypeRow, optionCountRow],
                                                    selectedIndex: [optionSelectionState.rawValue, currentOptionCount - 1])
        
        delegate?.showMetaOptionsPickerView(with: data)
    }
    
    public func updateMetaOptionPicker(with selectedIndex: [Int]) {
        guard let newOptionType = LMFeedCreatePollDataModel.OptionState(rawValue: selectedIndex[0]) else { return }
        optionSelectionState = newOptionType
        currentOptionCount = selectedIndex[1] + 1
        
        delegate?.updateMetaOption(with: optionSelectionState.description, count: currentOptionCount)
    }
    
    public func openDatePicker() {
        delegate?.presentDatePicker(with: pollExpiryDate ?? Date(), minimumDate: Date().addingTimeInterval(60 * 5))
    }
    
    public func metaValueChanged(for id: Int) {
        guard let option = LMFeedCreatePollDataModel.MetaOptions(rawValue: id) else { return }
        
        switch option {
        case .isAnonymousPoll:
            isAnonymousPoll.toggle()
        case .isInstantPoll:
            isInstantPoll.toggle()
        case .allowAddOptions:
            allowAddOptions.toggle()
        }
    }
    
    public func validatePoll(with question: String?, options: [String?]) {
        guard let question,
              !question.isEmpty else {
            delegate?.showError(with: "Question cannot be empty", isPopVC: false)
            return
        }
        
        let filteredOptions = options.compactMap { option in
            let trimmedText = option?.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedText?.isEmpty != false ? nil : trimmedText
        }
        
        guard filteredOptions.count > 1 else {
            delegate?.showError(with: "Need atleast 2 poll options", isPopVC: false)
            return
        }
        
        guard filteredOptions.count == Set(filteredOptions).count else {
            delegate?.showError(with: "Options should be unique", isPopVC: false)
            return
        }
        
        guard let pollExpiryDate else {
            delegate?.showError(with: "Expiry date cannot be empty", isPopVC: false)
            return
        }
        
        
        let pollDetails: LMFeedCreatePollDataModel = .init(
            pollQuestion: question,
            expiryTime: pollExpiryDate,
            pollOptions: filteredOptions,
            isInstantPoll: isInstantPoll,
            selectState: optionSelectionState,
            selectStateCount: currentOptionCount,
            isAnonymous: isAnonymousPoll,
            allowAddOptions: allowAddOptions
        )
        
        
        delegate?.updatePoll(with: pollDetails)
    }
}
