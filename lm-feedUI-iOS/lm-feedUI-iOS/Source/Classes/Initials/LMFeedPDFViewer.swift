//
//  LMFeedPDFViewer.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 19/02/24.
//

import UIKit
import WebKit

@IBDesignable
open class LMFeedPDFViewer: LMViewController {
    open private(set) lazy var webViewer: WKWebView = {
        let viewer = WKWebView(frame: view.frame)
        viewer.translatesAutoresizingMaskIntoConstraints = false
        viewer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return viewer
    }()
    
    
    open override func setupViews() {
        super.setupViews()
        view.addSubview(webViewer)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        view.pinSubView(subView: webViewer)
    }
    
    open func configure(with pdf: URL) {
        setNavigationTitleAndSubtitle(with: "PDF Viewer", subtitle: nil, alignment: .center)
        webViewer.loadFileURL(pdf, allowingReadAccessTo: pdf)
    }
}
