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
    "Usage: <thumb-preview> [opt] vid-name thumbs-dir vid-length",
    "    vid-name - basename of video file path",
    "    thumbs-dir - directory where thumbnails are written",
    "    vid-length - float - duration of video in seconds",
    "    Options:",
    "        --thumb-size=THUMB_SIZE - THUMB_SIZE := wxh",
    "            e.g. 160x100, default is 120x80"
    ].joined(separator: "\n")

    // track mouse movement on screen
    var globalMonitor: GlobalEventMonitor?
    var localMonitor: LocalEventMonitor?

    var mpvVidName: String?
    var mpv: MPV?
    var vidLength: Double?

    var thumbsMgr: ThumbsManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        guard let (thumbWH, vidName, thumbsDir, vidLength) = handleCommandLineArgs() else {
            print(usage)
            NSApp.terminate(nil)
            return
        }
//        NSApp.activate(ignoringOtherApps: true)
        print("vid name: \(vidName), thumbs dir: \(thumbsDir), duration: \(vidLength)")
        if let (tWidth, tHeight) = thumbWH {
            print("thumbSize: (\(tWidth), \(tHeight))")
            thumbSize = NSRect(x: 0, y: 0, width: CGFloat(tWidth), height: CGFloat(tHeight))
        }
        self.mpvVidName = vidName
        self.vidLength = vidLength
//        vidLengthSecs = ThumbsManager.convertToSecs(strTime: vidLengthStr)
//        mpvPid = pid_t(pid)
        // fail if we don't have mpv
        mpv = MPV(vidName: vidName, vidLength: vidLength)

        thumbsMgr = ThumbsManager(thumbsDir: thumbsDir)
        NSLog("appdelegate - \(#function) - thumbs: \(Int((thumbsMgr?.thumbs.count())!))")

        initEventMonitors()
        handleEventMonitor(monitor: globalMonitor!, action: "start")

//        // get notified of all processes terminating - note this doesn't effectively work
//        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(handleProcessTerminated),
//                                                            name: NSNotification.Name.NSWorkspaceDidTerminateApplication,
//                                                            object: nil)
//        // but this works fine
//        NSWorkspace.shared().notificationCenter.addObserver(self, selector: #selector(activated),
//                                                            name: NSNotification.Name.NSWorkspaceDidActivateApplication,
//                                                            object: nil)
    }

//    // handle did activate notification
//    func activated(notification: NSNotification) {
//        if let info = notification.userInfo,
//            let app = info[NSWorkspaceApplicationKey] as? NSRunningApplication {
//            print("app activated: \(app)")
//        }
//    }
//
//    // terminate once our mpv process terminates
//    func handleProcessTerminated(notification: NSNotification) {
//        if let info = notification.userInfo,
//            let app = info[NSWorkspaceApplicationKey] as? NSRunningApplication {
//            let msg = "app terminated: \(app)"
//            print(msg)
//            if app.processIdentifier == mpv?.pid {
//                print("mpv terminated, bye ..")
//                NSApp.terminate(nil)
//            }
//        } else {
//            print("\(#function) - couldn't get notification info")
//        }
//    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        print(#function)
        if let mpv = mpv {
            mpv.resetWinBounds()
        }
//        guard let vc = NSApp.mainWindow?.contentViewController as? ViewController else {
//            print("** couldn't get viewcontroller")
//            return
//        }
        print("event monitor: stop global, start local")
        handleEventMonitor(monitor: localMonitor!, action: "start")
        handleEventMonitor(monitor: globalMonitor!, action: "stop")
    }

    func applicationDidResignActive(_ notification: Notification) {
        print(#function)
        print("event monitor: stop local, start global")
        handleEventMonitor(monitor: localMonitor!, action: "stop")
        handleEventMonitor(monitor: globalMonitor!, action: "start")
        if let vc = NSApp.mainWindow?.contentViewController as? ViewController {
            print("got vc removing thumbnailview")
            vc.removeThumbnailView()
        }
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
//        let strTime = ThumbsManager.convertToStrTime(secs: secs)
//        print("mouseX: \(mouseX), seconds: \(secs) - strTime: \(strTime)\n\(thumb)")
        return thumb
    }

    // let wc = win.windowController as? WindowController
    func handleMouse(pos: NSPoint) {
        guard let mpv = mpv else { print("no mpv .."); return }
        if mpv.inSeekBounds(point: pos) {
//            print("mouse in seek bounds")
            if let wc = NSApp.mainWindow?.windowController as? WindowController,
                let vc = NSApp.mainWindow?.contentViewController as? ViewController,
                let thumb = getThumbFor(mouseX: pos.x) {
//                print("thumb: \(thumb)")
                wc.moveWin(to: NSPoint(x: pos.x, y: pos.y+5))
                vc.updateThumb(thumb)
            }
        }
    }


    // Usage: <thumb-preview> mpv-pid thumbs-dir
    func handleCommandLineArgs() -> ((Int, Int)?, String, String, Double)? {
//        print("CommandLine.argc \(CommandLine.argc)")
//        print("CommandLine.arguments \(CommandLine.arguments)")
        guard [4, 5].contains(CommandLine.argc)  else {return nil}

        var thumbSize: (Int, Int)?
        var args = CommandLine.arguments
        args.remove(at: 0)
        if args.count == 4 {
            let opt = args.remove(at: 0)
            if opt.hasPrefix("--") && opt.contains("=") && opt.contains("x") {
                let thumbSizeStr = opt.components(separatedBy: "=")[1]
                let vals = thumbSizeStr.components(separatedBy: "x").map { Int($0) }
                thumbSize = (vals[0]!, vals[1]!) as (Int, Int)
            } else {
                return nil
            }
        }
        guard !args[0].hasPrefix("-") else {return nil}

        let vidName = args[0]
        let thumbsDir = args[1]
        let vidLength = Double(args[2])!
        return (thumbSize, vidName, thumbsDir, vidLength)
    }


    func initEventMonitors() {
        globalMonitor = GlobalEventMonitor(mask: [.mouseMoved]) {
            (event) -> Void in
//            let (absX, absY) = (event?.absoluteX, event?.absoluteY)
//            let (deltaX, deltaY) = (event?.deltaX, event?.deltaY)
//            print("event: \(String(describing: event))")
            if let mpv = self.mpv {
                if mpv.mpvIsActiveApp() {
//                    print("mpv active app")
                    if mpv.inSeekBounds(point: NSEvent.mouseLocation()) {
                        print("****** global in seek bounds *****")
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
            }
//            print("global \(String(describing: event?.type)) - abs pos: (\(String(describing: absX)), \(String(describing: absY))), delta: (\(String(describing: deltaX)), \(String(describing: deltaY)))\n")
        }
        localMonitor = LocalEventMonitor(mask: [.mouseMoved]) {
            (event) -> NSEvent in
            if let mpv = self.mpv {
                if mpv.inSeekBounds(point: NSEvent.mouseLocation()) {
//                    print("****** local in seek bounds *****")
                    self.handleMouse(pos: NSEvent.mouseLocation())
                } else {
                    print("local mouse out of seek area - hiding")
//                    NSApp.deactivate()
                    NSApp.hide(nil)
                }
            }
            return event
        }
    }

    // action := "start" | "stop"
    // idempotent
    private func handleEventMonitor(monitor: EventMonitor, action: String) {

        if action == "start" {
            if !monitor.isMonitoring {
                monitor.start()
            }
        } else if action == "stop" {
            if monitor.isMonitoring {
                monitor.stop()
            }
        }
    }

}

