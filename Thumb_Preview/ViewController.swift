//
//  ViewController.swift
//  Thumb_Preview
//
//  Created by David Rogers on 8/16/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var thumbs: [String]?
    // do we need to keep?
    var thumbSize: NSRect?
    var imageView: NSImageView?

    var mouseLoc: NSPoint?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let delegate = NSApp.delegate as? AppDelegate else { print("** couldn't get delegate **"); return }
        thumbSize = delegate.thumbSize
        addThumbnailView(thumbSize!)

        DispatchQueue.main.async {
            self.view.window?.makeFirstResponder(self)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func addThumbnailView(_ frame: NSRect) {
        imageView = NSImageView(frame: frame)
        self.view.addSubview(imageView!)
    }

    // thumb - path to thumb
    func updateThumb(_ thumb: String) {
        let img = NSImage(byReferencingFile: thumb)
        imageView!.image = img
    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func keyDown(with event: NSEvent) {
        let arrowKeys: Set = [123, 124, 125, 126]
        let charKeys: Set = ["e", "E", "w", "m", "p", "b"]

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
            case "e":
                print("got e")

            case "E":
                print("got E")

            case "w":
                if let win = view.window {
                    print("win: \(win.frame)")
                }

            case "m":
//                print("got m")
                guard let delegate = NSApp.delegate as? AppDelegate else { print("** couldn't get delegate **"); return }
                let loc = NSEvent.mouseLocation()
                delegate.handleMouse(pos: loc)

            case "p":
                // print mouse location
                let loc = NSEvent.mouseLocation()
                print("mouse loc: \(loc)")
                // print frontmost application
                let ws = NSWorkspace.shared()
                if let active = ws.frontmostApplication {
                    print(active)
                }
            case "b":
                print("got b")

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

