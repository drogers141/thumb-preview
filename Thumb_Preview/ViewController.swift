//
//  ViewController.swift
//  Thumb_Preview
//
//  Created by David Rogers on 8/16/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        addThumbnailView()

        DispatchQueue.main.async {
            self.view.window?.makeFirstResponder(self)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func addThumbnailView() {
        let path = "/Users/drogers/Desktop/images/not-a-bug.jpg"
        let rect = NSRect(x: 20, y: 30, width: 100, height: 100)
        let imgview = NSImageView(frame: rect)
        let img = NSImage(byReferencingFile: path)
        imgview.image = img

        self.view.addSubview(imgview)

    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func keyDown(with event: NSEvent) {
        let arrowKeys: Set = [123, 124, 125, 126]
        let charKeys: Set = ["d", "D"]

        if arrowKeys.contains(Int(event.keyCode)) {
            switch Int(event.keyCode) {
            case 123:
                print("left arrow")

            case 124:
                print("right arrow")

            case 125:
                print("down arrow")

            case 126:
                print("up arrow")

            default:
                break
            }
        } else if charKeys.contains(event.characters!) {
            switch event.characters! {
            case "d":
                print("got d")

            case "D":
                print("got D")

            default:
                break
            }
        } else {
            super.keyDown(with: event)
        }
    }

    override func mouseDown(with event: NSEvent) {
        print("event: \(event)")
//        DispatchQueue.main.async {
//            self.mainImage.window?.makeFirstResponder(self)
//        }
    }

}

