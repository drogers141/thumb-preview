//
//  ViewController.swift
//  Thumb_Preview
//
//  Created by David Rogers on 8/16/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var globalMonitor: GlobalEventMonitor?
    var isMonitoringGlobalEvents = false

    var localMonitor: LocalEventMonitor?
    var isMonitoringLocalEvents = false

    var thumbs: [String]?
    var thumbSize: NSRect?
    var imageView: NSImageView?

    var mouseLoc: NSPoint?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let delegate = NSApp.delegate as? AppDelegate else { print("** couldn't get delegate **"); return }
        thumbs = delegate.thumbs
        thumbSize = delegate.thumbSize

        let path = thumbs![0]

        addThumbnailView(path, frame: thumbSize!)

        globalMonitor = GlobalEventMonitor(mask: [.mouseMoved, .leftMouseDown, .leftMouseUp]) {
            (event) -> Void in
            print("global event: \(String(describing: event))")
            if event?.type == NSEventType.leftMouseDown {
                print("** global leftMouseDown **")
            } else if event?.type == NSEventType.leftMouseUp {
                print("** global leftMouseUp **")
            }
            let (absX, absY) = (event?.absoluteX, event?.absoluteY)
            let (deltaX, deltaY) = (event?.deltaX, event?.deltaY)
            print("global \(String(describing: event?.type)) - abs pos: (\(String(describing: absX)), \(String(describing: absY))), delta: (\(String(describing: deltaX)), \(String(describing: deltaY)))\n")
        }

        localMonitor = LocalEventMonitor(mask: [.mouseMoved, .leftMouseDown, .leftMouseUp]) {
            (event) -> NSEvent in
            print("local event: \(String(describing: event))")
            if event.type == NSEventType.leftMouseDown {
                print("** local leftMouseDown **")
            } else if event.type == NSEventType.leftMouseUp {
                print("** local leftMouseUp **")
            }
            let (absX, absY) = (event.absoluteX, event.absoluteY)
            let (deltaX, deltaY) = (event.deltaX, event.deltaY)
            print("local \(event.type) - abs pos: (\(absX), \(absY)), delta: (\(deltaX), \(deltaY))\n   ")
            self.mouseLoc = NSPoint(x: CGFloat(absX), y: CGFloat(absY))
            print("mouseLoc: \(self.mouseLoc!)")

            return event
        }

        DispatchQueue.main.async {
            self.view.window?.makeFirstResponder(self)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

//    func

    // imgfile is path to image
    func addThumbnailView(_ imgfile: String, frame: NSRect) {
//        let path = "/Users/drogers/Desktop/images/not-a-bug.jpg"
//        let rect = NSRect(x: 20, y: 30, width: 100, height: 100)
//        let imgview = NSImageView(frame: rect)
        let img = NSImage(byReferencingFile: imgfile)
        imageView = NSImageView(frame: frame)
        imageView!.image = img

        self.view.addSubview(imageView!)

    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func keyDown(with event: NSEvent) {
        let arrowKeys: Set = [123, 124, 125, 126]
        let charKeys: Set = ["e", "E", "w", "m", "p"]

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
                if !isMonitoringGlobalEvents {
                    print("starting to monitor mouse")
                    isMonitoringGlobalEvents = true
                    globalMonitor?.start()

                } else {
                    print("stopping the monitor")
                    isMonitoringGlobalEvents = false
                    globalMonitor?.stop()
                }

            case "E":
                print("got E")
                if !isMonitoringLocalEvents {
                    print("starting to monitor mouse - local")
                    isMonitoringLocalEvents = true
                    localMonitor?.start()

                } else {
                    print("stopping the local monitor")
                    isMonitoringLocalEvents = false
                    localMonitor?.stop()
                }
            case "w":
                if let win = view.window {
                    print("win: \(win.frame)")
                }
            case "m":
//                print("got m")
                if let wc = view.window?.windowController as? WindowController {
                    print("got wc")
                    let loc = NSEvent.mouseLocation()
                    print("mouse loc: \(loc)")
                    view.window!.setFrameOrigin(loc)
//                    if let loc = mouseLoc {
//                        print("loc: \(loc)")
////                        wc.moveWinTo(x: loc.x, y: loc.y)
////                        view.window!.setFrameOrigin(loc)
//                    }
                }
            case "p":
                // print mouse location
                let loc = NSEvent.mouseLocation()
                print("mouse loc: \(loc)")
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

