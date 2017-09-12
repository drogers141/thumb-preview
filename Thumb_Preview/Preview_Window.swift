//
//  Preview_Window.swift
//  Thumb_Preview
//
//  Created by David Rogers on 8/16/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa

class Preview_Window: NSWindow {

    override init(contentRect: NSRect, styleMask style: NSWindowStyleMask,
                  backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)

        // Set the opaque value off,remove shadows and fill the window with clear (transparent)
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = NSColor.clear

        // Change the title bar appereance
//        self.title = "Thumbs"
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
    }
}

