//
//  MediaDisplayView.swift
//  FilterShop
//
//  Created by Xue Yu on 9/17/17.
//  Copyright © 2017 XueYu. All rights reserved.
//

import Cocoa

/// MediaDisplayView will be used to show the image
/// It accepts drag and drop image
/// The filters effects is used on layer until we wants to export it
class MediaDisplayView: NSView {
    
    /// The imageUrl, shown in NSImageView, we'll use it to create NSImage and CIImage
    var imageUrl: URL? {
        didSet {
            guard let imageUrl = imageUrl else { return }
            nsimage = NSImage.init(contentsOf: imageUrl)
            ciimage = CIImage.init(contentsOf: imageUrl)
            needsDisplay = true
        }
    }
    
    /// ImageView to display Image
    var imageView = NSImageView()
    
    /// NSImage of the ImageView
    var nsimage: NSImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    /// For display effciency, we'll apply the filters on layers, but for export/save we need to use ciimage
    var ciimage: CIImage?
    
    /// receive drag and drop, display accordingly
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    /// Options of the drag and drop eare, only receive images
    let options = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes: NSImage.imageTypes]
    
    /// Set up ImageView and layer for filter
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.addSubview(imageView)
        imageView.frame = self.bounds
        
        self.layerUsesCoreImageFilters = true
        self.wantsLayer = true

        
        NSColor.gray.setFill()
        dirtyRect.fill()
    }
    
    /// Register drag and drop, also unregister for imageView, since imageView support drag and drop naturally
    override func awakeFromNib() {
        registerForDraggedTypes([.fileURL, .URL])
        imageView.unregisterDraggedTypes()
    }
    
    
    
    /// Return drag and drop should be allowed for this
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        let pasteBoard = draggingInfo.draggingPasteboard
        
        if pasteBoard.canReadObject(forClasses: [ NSURL.self ], options: options) {
            canAccept = true
        }
        
        return canAccept
    }
    
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isReceivingDrag = false
        
        let pasteBoard = sender.draggingPasteboard
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: options) as? [URL],
            let fileUrl = urls.first {
            imageUrl = fileUrl
            return true
        }
        return false
    }
    
    /// apply filters to layers
    func apply(filters: [CIFilter]) {
        self.layer?.filters = filters
    }
    
    
    /**
     Export CGImage for 
    */
    func export(filters: [CIFilter]) -> CGImage? {
 
        guard var inputImage = ciimage else { return nil }
        
        for filter in filters {
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            inputImage = filter.outputImage!
        }
        
        let cxt = CIContext()
        return cxt.createCGImage(inputImage, from: inputImage.extent)
    }
    
    
    
    
    
}

