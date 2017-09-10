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

// selects from only mpv windows
// returns windows with titles containing substring titleSubstr
// case-insensitive
// the title of the window should contain the video name (wouldn't try full path)
// returns list
func getMpvWinsInfo(_ titleSubstr: String)  -> [[ String: Any ]] {
    var retlist = [[ String: Any ]]()
    if let info = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[ String : Any]] {
        for dict in info {
//            print("***********\ndict: \(dict)")
            if dict["kCGWindowOwnerName"] as? String == "mpv" {
                if let title = dict["kCGWindowName"] as? String {
                    if title.lowercased().range(of: titleSubstr.lowercased()) != nil {
                        retlist.append(dict)
                    }
                }
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

