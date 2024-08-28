//
//  LMFeedProfileImageView.swift
//  LikeMindsFeedUI
//
//  Created by Anurag Tyagi on 28/08/24.
//

import Foundation
import Kingfisher

open class LMFeedProfileImageView: LMView{
    open private(set) lazy var imageView: LMImageView = {
        let imageView = LMImageView().translatesAutoresizingMaskIntoConstraints()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    open private(set) lazy var initialsView: LMLabel = {
        let nameInitialLabel = LMLabel().translatesAutoresizingMaskIntoConstraints()
        nameInitialLabel.textColor = .white
        nameInitialLabel.textAlignment = NSTextAlignment.center
        nameInitialLabel.backgroundColor = LMFeedAppearance.shared.colors.appTintColor
        nameInitialLabel.clipsToBounds = true
        return nameInitialLabel
    }()
    
    open override func setupViews() {
        super.setupViews()
        addSubview(imageView)
        addSubview(initialsView)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        pinSubView(subView: imageView)
        pinSubView(subView: initialsView)
    }
    
    open func configure(with profileImageUrl: String?, userName: String?){
        if profileImageUrl == nil && userName == nil {
            return
        }
        
        if let url = URL(string: profileImageUrl ?? "") {
     
            imageView.kf.setImage(with: url, options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]){ [weak self] result in
                guard let self else {
                    return
                }
                switch result {
                case .success(_):
                    initialsView.isHidden = true
                    imageView.isHidden = false
                    
                case .failure(let error):
                    print(error) // The error happens
                    imageView.isHidden = true
                    initialsView.isHidden = false
                }
            }
        }else if let name = userName, !name.isEmpty {
            
            var letter: String = ""
            
            if let firstCharacter = name.first?.uppercased().first {
                letter.append(firstCharacter)
            }
            
            if name.count > 1,
               let lastCharacter = name.last?.uppercased().first {
                letter.append(lastCharacter)
            }
            
            imageView.isHidden = true
            initialsView.isHidden = false
            initialsView.text = letter
        }
        
        layoutIfNeeded()
    }
}
