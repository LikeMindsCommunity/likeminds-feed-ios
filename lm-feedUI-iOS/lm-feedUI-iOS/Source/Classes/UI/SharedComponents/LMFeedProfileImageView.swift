//
//  LMFeedProfileImageView.swift
//  LikeMindsFeedUI
//
//  Created by Anurag Tyagi on 28/08/24.
//

import Foundation

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
        
        
        if let profileImageUrl, !profileImageUrl.isEmpty {
            imageView.isHidden = false
            initialsView.isHidden = true
            imageView.loadImage(url: profileImageUrl, to: CGSize(width: 100, height: 100), scale: CGFloat(1.0))
        }

        else if let name = userName, !name.isEmpty {
            
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
