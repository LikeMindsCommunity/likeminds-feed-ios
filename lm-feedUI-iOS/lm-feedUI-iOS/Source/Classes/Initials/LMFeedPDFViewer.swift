//
//  LMFeedPDFViewer.swift
//  lm-feedUI-iOS
//
//  Created by Devansh Mohata on 19/02/24.
//

import PDFKit
import UIKit

@IBDesignable
open class LMFeedPDFViewer: LMViewController {
    open private(set) lazy var pdfViewer: PDFView = {
        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.autoScales = true
        pdfView.delegate = self
        return pdfView
    }()
    
    
    open override func setupViews() {
        super.setupViews()
        view.addSubview(pdfViewer)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        view.pinSubView(subView: pdfViewer)
    }
    
    open func configure(with pdf: PDFDocument) {
        pdfViewer.document = pdf
    }
}

extension LMFeedPDFViewer: PDFViewDelegate {
    public func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        openURL(with: url)
    }
}
