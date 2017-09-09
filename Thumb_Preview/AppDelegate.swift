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

    var thumbSize = NSRect(x: 0, y: 0, width: 120, height: 80)

    let usage = [
    "Usage: <thumb-preview> vid-name thumbs-dir thumbs-count vid-length",
    "    vid-name - basename of video file path",
    "    thumbs-count - expected number of thumbs total",
    "    vid-length - float - duration of video in seconds",
    "    vid-length - string time format from ffmpeg - e.g. 00:30:00.00"
    ].joined(separator: "\n")

    var mpvVidName: String?
    var mpv: MPV?
    var vidLength: Double?

    var thumbsMgr: ThumbsManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        guard let (vidName, thumbsDir, thumbsCount, vidLength) = handleCommandLineArgs() else {
            print(usage)
            NSApp.terminate(nil)
            return
        }
        NSApp.activate(ignoringOtherApps: true)
        print("vid name: \(vidName), thumbs dir: \(thumbsDir), thumbs count: \(thumbsCount), duration: \(vidLength)")
        self.mpvVidName = vidName
        self.vidLength = vidLength
//        vidLengthSecs = ThumbsManager.convertToSecs(strTime: vidLengthStr)
//        mpvPid = pid_t(pid)
        // fail if we don't have mpv
        mpv = MPV(vidName: vidName, vidLength: vidLength)

        thumbsMgr = ThumbsManager(thumbsDir: thumbsDir, numThumbs: thumbsCount)
        NSLog("appdelegate - thumbs: \(Int((thumbsMgr?.thumbs.count())!))")

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
        guard let vidName = mpvVidName else { print("no video file name .."); return }
        guard let vidLength = self.vidLength else { print("no video length .."); return }
        mpv = MPV(vidName: vidName, vidLength: vidLength)

        guard let vc = NSApp.mainWindow?.contentViewController as? ViewController else {
            print("** couldn't get viewcontroller")
            return
        }
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
        let strTime = ThumbsManager.convertToStrTime(secs: secs)
        print("mouseX: \(mouseX), seconds: \(secs) - strTime: \(strTime)\n\(thumb)")
        return thumb
    }

    // let wc = win.windowController as? WindowController
    func handleMouse(pos: NSPoint) {
        guard let mpv = mpv else { print("no mpv .."); return }
        if mpv.inSeekBounds(point: pos) {
            print("mouse in seek bounds")
            if let wc = NSApp.mainWindow?.windowController as? WindowController,
                let vc = NSApp.mainWindow?.contentViewController as? ViewController,
                let thumb = getThumbFor(mouseX: pos.x) {
                print("thumb: \(thumb)")
                wc.moveWin(to: NSPoint(x: pos.x, y: pos.y+15))
                vc.updateThumb(thumb)
            }
        }
    }

//    func handleMouse(pos: NSPoint) {
//        guard let mpv = mpv else { print("no mpv .."); return }
//        if mpv.inBarBounds(point: pos) {
//            print("mouse in bar bounds")
//            if let wc = NSApp.mainWindow?.windowController as? WindowController,
//                let vc = NSApp.mainWindow?.contentViewController as? ViewController,
//                let thumb = getThumbFor(mouseX: pos.x) {
//                print("thumb: \(thumb)")
//                wc.moveWin(to: NSPoint(x: pos.x, y: pos.y+15))
//                vc.updateThumb(thumb)
//            }
//        }
//    }



    // Usage: <thumb-preview> mpv-pid thumbs-dir
    func handleCommandLineArgs() -> (String, String, Int, Double)? {
        print("CommandLine.argc \(CommandLine.argc)")
        print("CommandLine.arguments \(CommandLine.arguments)")
        guard CommandLine.argc == 5  else {return nil}

        let firstArg = CommandLine.arguments[1]
        print("firstArg: \(firstArg)")
        guard !firstArg.hasPrefix("-") else {return nil}

        let vidName = String(firstArg)!
        let thumbsDir = String(CommandLine.arguments[2])!
        let thumbsCount = Int(CommandLine.arguments[3])!
        let vidLength = Double(CommandLine.arguments[4])!
        return (vidName, thumbsDir, thumbsCount, vidLength)
    }



}

