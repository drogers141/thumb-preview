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

    let usage = [
    "Usage: <thumb-preview> mpv-pid thumbs-dir thumbs-count vid-length",
    "    thumbs-count - expected number of thumbs total",
    "    vid-length - string time format from ffmpeg - e.g. 00:30:00.00"
    ].joined(separator: "\n")

    var mpvPid: pid_t?
    var mpv: MPV?
    var vidLengthSecs = 0.0

    var thumbsMgr: ThumbsManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        guard let (pid, thumbsDir, thumbsCount, vidLengthStr) = handleCommandLineArgs() else {
            print(usage)
            NSApp.terminate(nil)
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        print("pid: \(pid), thumbs dir: \(thumbsDir), thumbs count: \(thumbsCount), vidLengthStr: \(vidLengthStr)")
        vidLengthSecs = ThumbsManager.convertToSecs(strTime: vidLengthStr)
        mpvPid = pid_t(pid)
        // fail if we don't have mpv
        mpv = MPV(pid: mpvPid!, vidLength: vidLengthSecs)

        thumbsMgr = ThumbsManager(thumbsDir: thumbsDir, numThumbs: thumbsCount)

//        guard let winRect = getMpvWinBounds(pid: pid) else {
//            print("couldn't get mpv win bounds")
//            return
//        }
//        print("pid: \(pid), thumbs dir: \(thumbsDir)")
//        if let flipped = flip_y_coord(winRect)  {
////                print("mpv window bounds: x=\(x), y=\(y), width=\(w), height=\(h)")
//
//            print("mpv window bounds: \(winRect)")
//            print("mpv flipped window bounds: \(flipped)")
//            mpvBarBounds = getMpvBarBounds(flippedWinBounds: flipped)
//            print("mpv bar bounds: \(mpvBarBounds)")
//        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        print(#function)
        print("creating new mpv object")
        guard let pid = mpvPid else { print("no mpv pid .."); return }
        mpv = MPV(pid: pid, vidLength: self.vidLengthSecs)
    }

    func applicationDidResignActive(_ notification: Notification) {
        print(#function)
    }

    func getThumbFor(mouseX: CGFloat) -> String? {
        guard let secs = mpv?.getSecondsFor(x: mouseX) else {
            print("couldn't get seconds for mouse x")
            return nil
        }
        guard let mgr = thumbsMgr else { print("no thumb mgr"); return nil }
        guard let thumb = mgr.closestThumbBefore(secs: secs) else {
            print("no closest thumb"); return nil
        }
        print("mouseX: \(mouseX), seconds: \(secs)\n\(thumb)")
        return thumb
    }

    // let wc = win.windowController as? WindowController
    func handleMouse(pos: NSPoint) {
        guard let mpv = mpv else { print("no mpv .."); return }
        if mpv.inBarBounds(point: pos) {
            print("mouse in bar bounds")
            if let wc = NSApp.mainWindow?.windowController as? WindowController,
                let vc = NSApp.mainWindow?.contentViewController as? ViewController,
                let thumb = getThumbFor(mouseX: pos.x) {
                print("thumb: \(thumb)")
                wc.moveWin(to: NSPoint(x: pos.x, y: pos.y+15))
                vc.updateThumb(thumb)
            }
        }
    }


    // Usage: <thumb-preview> mpv-pid thumbs-dir
    func handleCommandLineArgs() -> (pid_t, String, Int, String)? {
        print("CommandLine.argc \(CommandLine.argc)")
        print("CommandLine.arguments \(CommandLine.arguments)")
        guard CommandLine.argc == 5  else {return nil}

        let firstArg = CommandLine.arguments[1]
        print("firstArg: \(firstArg)")
        guard !firstArg.hasPrefix("-") else {return nil}

        let pid = pid_t(firstArg)!
        let thumbsDir = String(CommandLine.arguments[2])!
        let thumbsCount = Int(CommandLine.arguments[3])!
        let vidLengthStr = String(CommandLine.arguments[4])!
        return (pid, thumbsDir, thumbsCount, vidLengthStr)
    }



}

