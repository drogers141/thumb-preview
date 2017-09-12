//
//  WindowController.swift
//  Thumb_Preview
//
//  Created by David Rogers on 8/27/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        let (x, y) = (CGFloat(100), CGFloat(100))
        if let delegate = NSApp.delegate as? AppDelegate {
            let size = delegate.thumbSize
            let contentFrame = NSRect(x: x, y: y, width: size.width, height: size.height)
            let winFrame = window!.frameRect(forContentRect: contentFrame)
            window!.setFrame(winFrame, display: true)
        }

    }


    func moveWin(to: NSPoint) {
        window!.setFrameOrigin(to)
    }


    override var acceptsFirstResponder: Bool {
        return true
    }


    // handles escape key - cancelOperation is in an NSWindow
    // that would get it first - if not implemented gets caught by this
    // note no override
    func cancel(_ id: Any?) {
        //        print("cancelOperation")
        if let window = window {
            window.close()
        }
    }

}

