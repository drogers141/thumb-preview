//
//  AppsWinInfo.swift
//
//  Get window and app info from other applications
//  Start collecting this functionality here for exploratory purposes.
//
//  Created by David Rogers on 8/30/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa

// return dictionary of info for windows matching pid
// returns empty array if none found
// note - .optionOnScreenOnly brings in a bunch of crap like finder and accessibility stuff
// but does not seem to bring in windows from other desktops
func getWinsInfo(_ pid: pid_t) -> [[ String: Any ]] {
    var retlist = [[ String: Any ]]()
    if let info = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[ String : Any]] {
        for dict in info {
//            print("dict: \(dict)")
            if dict["kCGWindowOwnerPID"] as? pid_t == pid {
                retlist.append(dict)
            }
        }
    }
    return retlist
}


func printAllWinsInfo() {
    if let info = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[ String : Any]] {
        for dict in info {
            print("dict: \(dict)")
        }
    }
}

//  Example of using NSRunningApplication
//
//        if let sharedApp = NSRunningApplication.init(processIdentifier: pid!) {
//            print("got shared app: \(sharedApp)")
////                sharedApp.
//        }
