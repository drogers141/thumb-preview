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

