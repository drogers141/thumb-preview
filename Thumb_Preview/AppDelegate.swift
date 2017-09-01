//
//  AppDelegate.swift
//  Thumb_Preview
//
//  Created by David Rogers on 8/16/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let thumbs = [
        "/Users/drogers/tv/working/thumbs/00_00_00.00.jpg",
        "/Users/drogers/tv/working/thumbs/00_00_10.00.jpg",
        "/Users/drogers/tv/working/thumbs/00_00_20.00.jpg",
        "/Users/drogers/tv/working/thumbs/00_00_30.00.jpg"
    ]
    var thumbSize = NSRect(x: 0, y: 0, width: 120, height: 80)

    let usage = "Usage: <thumb-preview> mpv-pid thumbs-dir"

    var mpvBarBounds: NSRect?

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        NSApp.activate(ignoringOtherApps: true)

        guard let (pid, thumbsDir) = handleCommandLineArgs() else { print(usage); return }
        guard let winRect = getMpvWinBounds(pid: pid) else {
            print("couldn't get mpv win bounds")
            return
        }
        print("pid: \(pid), thumbs dir: \(thumbsDir)")
        if let flipped = flip_y_coord(winRect)  {
//                print("mpv window bounds: x=\(x), y=\(y), width=\(w), height=\(h)")

            print("mpv window bounds: \(winRect)")
            print("mpv flipped window bounds: \(flipped)")
            mpvBarBounds = getMpvBarBounds(flippedWinBounds: flipped)
            print("mpv bar bounds: \(mpvBarBounds)")
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        print(#function)
    }
    func applicationDidResignActive(_ notification: Notification) {
        print(#function)
    }


    // Usage: <thumb-preview> mpv-pid thumbs-dir
    func handleCommandLineArgs() -> (pid_t, String)? {
        guard CommandLine.argc == 3  else {return nil}

        let firstArg = CommandLine.arguments[1]
        print("firstArg: \(firstArg)")
        guard !firstArg.hasPrefix("-") else {return nil}

        let pid = pid_t(firstArg)!
        let thumbsDir = String(CommandLine.arguments[2])!

        return (pid, thumbsDir)
    }


    func flip_y_coord(_ winBounds: NSRect) -> NSRect? {
        guard let screen = NSScreen.main() else { return nil }
        print("#function: screen: \(screen.frame), visible: \(screen.visibleFrame)")
        let screenH = screen.frame.height
//        let (x, y, w, h) = winTuple
//        print("screenH: \(screenH), y: \(y)")
//        return (x, screenH-y, w, h)
        return NSRect(x: winBounds.minX, y: screenH - winBounds.minY,
                      width: winBounds.width, height: winBounds.height)
    }

    // brittle way to get the bounds of the correct mpv window given the
    // mpv pid
    // bounds are screen coordinates, but the y needs to be flipped
    func getMpvWinBounds(pid: pid_t) -> NSRect? {
        let winList = getWinsInfo(pid)
        for winDict in winList {
//            print("mpv win:\n\(winDict)\n")
            if let winName = winDict["kCGWindowName"] {
                print("win with name:")
                print("\(winDict)\n***************")

                // ** note - this only occurs with the correct window, and only when it is
                // on the same desktop (space) as the thumb-preview proc
                //  "kCGWindowIsOnscreen": 1,
                // so could look for that if that becomes more relevant

//                print("winDict[kCGWindowName] = \(winName)")
                if let winBounds = winDict["kCGWindowBounds"] {
                    if let wb = winBounds as? [AnyHashable: Any] {
//                        print("its a dict")

//                        print("winBounds: \(wb)")
                        if let h = wb["Height"] as? Int,
                            let w = wb["Width"] as? Int,
                            let x = wb["X"] as? Int,
                            let y = wb["Y"] as? Int {
//                                print("x=\(x), y=\(y), width=\(w), height=\(w)")
                                if w > 2 && h > 2 {
//                                    print("this is the real window")
                                    return NSRect(x: CGFloat(x), y: CGFloat(y),
                                                  width: CGFloat(w), height: CGFloat(h))
                                }
                        }
                    }
                }
            }
        }
        return nil
    }

    // y is flipped from CGWindowBounds
    // returns rect that works with NSEvent mouse location on screen
    // x,y = bottom left
    func getMpvBarBounds(flippedWinBounds: NSRect) -> NSRect {
        print("flippedWinBounds: \(flippedWinBounds)")
        let left = flippedWinBounds.minX
        let width = flippedWinBounds.width
        let height = flippedWinBounds.height
        let bottom = flippedWinBounds.minY - height
        print("bottom: \(bottom), height: \(height)")
        let leftRatio = CGFloat(0.195)
        let rightRatio = CGFloat(0.667)
        let topRatio = CGFloat(0.036)
        let boxX = left + leftRatio*width
        let boxW = (rightRatio - leftRatio) * width
        let boxH = topRatio*height
        let boxY = bottom

        return NSRect(x: boxX, y: boxY, width: boxW, height: boxH)
    }

}

