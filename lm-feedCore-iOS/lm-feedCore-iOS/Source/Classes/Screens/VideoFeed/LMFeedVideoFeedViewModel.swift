import Foundation
import Photos
import LikeMindsFeedUI

public protocol LMFeedVideoFeedViewModelDelegate: AnyObject {
    func navigateToCreateShortVideo(with video: (PHAsset, URL, Data))
}

public class LMFeedVideoFeedViewModel {
    // MARK: Data Variables
    private var selectedVideo: (PHAsset, URL, Data)?
    public weak var delegate: LMFeedVideoFeedViewModelDelegate?
    public var postIds: [String] = []
    
    // MARK: Initialization
    init(delegate: LMFeedVideoFeedViewModelDelegate?) {
        self.delegate = delegate
    }
    
    public static func createModule(postIds: [String] = []) throws -> LMFeedVideoFeedScreen{
        guard LMFeedCore.isInitialized else { throw LMFeedError.feedNotInitialized }
        
        let viewController = Components.shared.feedVideoFeedScreen.init()
        let viewModel = LMFeedVideoFeedViewModel(delegate: viewController)
        viewModel.postIds = postIds
        viewController.viewModel = viewModel
        
        return viewController
    }
    
    // MARK: Public Methods
    func handleSelectedVideo(_ assets: [PHAsset]) {
        guard let videoAsset = assets.first else { return }
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        videoAsset.asyncURL { [weak self] url in
            defer { dispatchGroup.leave() }
            
            guard let self = self,
                  let url = url else { return }
            
            let fm = FileManager.default
            let destination = fm.temporaryDirectory.appendingPathComponent("\(Int(Date().timeIntervalSince1970))_\(url.lastPathComponent)")
            
            do {
                try fm.copyItem(at: url, to: destination)
                let data = try Data(contentsOf: url)
                self.selectedVideo = (videoAsset, destination, data)
                
                DispatchQueue.main.async {
                    self.delegate?.navigateToCreateShortVideo(with: (videoAsset, destination, data))
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
} 
