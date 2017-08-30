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

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        NSApp.activate(ignoringOtherApps: true)
        let pid = handleCommandLineArgs()
        print("return from handleCommandLineArgs: \(pid)")

        getWinInfo(pid: pid_t(43161))
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

    // note - .optionOnScreenOnly brings in a bunch of crap like finder and accessibility stuff
    // but does not seem to bring in windows from other desktops
    func getWinInfo(pid: pid_t) {
        if let info = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[ String : Any]] {
            for dict in info {
                print("dict: \(dict)")
            }
        }
    }

//    func getWinInfo_old(pid: pid_t) {
//        if let winDicts = CGWindowListCopyWindowInfo(CGWindowListOption.optionOnScreenOnly, kCGNullWindowID) {
//            let len = CFArrayGetCount(winDicts)
//            for index in 0...len {
//                let wd = CFArrayGetValueAtIndex(winDicts, index)
//                print("window dict:\n\(String(describing: wd))\n*******************\n")
//                var key = kCGWindowOwnerPID
//                let val = withUnsafePointer(to: &key) { upKey in
//                    return CFDictionaryGetValue(wd as! CFDictionary, upKey)
//                }
//
////                let swiftd: CFDictionary = wd as! CFDictionary
////                if let wpid = (swiftd as NSDictionary)[CFDictionaryGetValue] as? String {
////                    print("pid: \(wpid)")
////                }
////                let wpid = CFDictionaryGetValue(wd as! CFDictionary, kCGWindowOwnerPID)
////                let wnumber = CFDictionaryGetValue(wd as! CFDictionary, kCGWindowNumber)
////                let wbounds = CFDictionaryGetValue(wd as! CFDictionary, kCGWindowBounds)
////                print("pid: \(wpid), wnumber: \(wnumber), wbounds: \(wbounds)")
////                print("******************************")
//            }
////             in winDicts {
////                print("window dict:\n\(d)\n*******************\n")
////            }
//        }
//    }

    // returns pid of mpv instance to attach to
    func handleCommandLineArgs() -> String {
        if CommandLine.argc > 1 {
            let firstArg = CommandLine.arguments[1]
            print("firstArg: \(firstArg)")
            guard !firstArg.hasPrefix("-") else {return "n/a"}
            let pid = pid_t(firstArg)
            getWinInfo(pid: pid!)

            if let sharedApp = NSRunningApplication.init(processIdentifier: pid!) {
                print("got shared app: \(sharedApp)")
//                sharedApp.
            }

        }
        return "pid: "
    }
}

