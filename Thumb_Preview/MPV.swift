//
//  MPV.swift
//
//  Encapsulates state of the MPV player
//  Note - This is a short-lived object
//      Resizing of the window invalidates
//      If Thumb_Preview exists and becomes unhidden, a new MPV should be created
//
//  Created by David Rogers on 9/3/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa



class MPV {

    // rect around mpv window
    var winBounds: NSRect?
    // rect around mpv seek bar
    var barBounds: NSRect?
    // mpv pid - not using as can't get pid easily from mpv
    var pid: pid_t?
    // use video filename instead
    // basename of file
    var vidName: String?

    // video play time - seconds
    var vidLength = 0.0

    init(pid: pid_t, vidLength: Double) {
        winBounds = getMpvWinBounds(pid: pid)
        if winBounds != nil {
            if let flipped = flip_y_coord(winBounds!) {
                barBounds = getMpvBarBounds(flippedWinBounds: flipped)
            }
        }
        self.pid = pid
        self.vidLength = vidLength
        print("MPV: winBounds: \(String(describing: winBounds)), barBounds: ",
            "\(String(describing: barBounds)), vidLength: \(vidLength)")
    }

    func getSecondsFor(x: CGFloat) -> Double? {
        guard let normX = normalizedX(mouseX: x) else { return nil }
        return normX * vidLength
    }

    func normalizedX(mouseX: CGFloat) -> Double? {
        guard barBounds != nil else { return nil }
        guard mouseX > barBounds!.minX && mouseX < barBounds!.maxX else { return nil }
        return Double((mouseX - barBounds!.minX) / barBounds!.width)
    }

    func inBarBounds(point: NSPoint) -> Bool {
        if let bb = barBounds {
            if bb.contains(point) {
                return true
            }
        }
        return false
    }


    // brittle way to get the bounds of the correct mpv window given the
    // mpv pid
    // bounds are screen coordinates, but the y needs to be flipped
    private func getMpvWinBounds(pid: pid_t) -> NSRect? {
        let winList = getWinsInfo(pid)
        for winDict in winList {
            //            print("mpv win:\n\(winDict)\n")
            if let winName = winDict["kCGWindowName"] {
//                print("win with name:")
//                print("\(winDict)\n***************")

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
    private func getMpvBarBounds(flippedWinBounds: NSRect) -> NSRect {
        print("flippedWinBounds: \(flippedWinBounds)")
        let left = flippedWinBounds.minX
        let width = flippedWinBounds.width
        let height = flippedWinBounds.height
        let bottom = flippedWinBounds.minY - height
        print("bottom: \(bottom), height: \(height)")

        let leftRatio = CGFloat(0.1952)
//        let leftRatio = CGFloat(0.183)

        let rightRatio = CGFloat(0.6639)
//        let rightRatio = CGFloat(0.684)

        //        let topRatio = CGFloat(0.036)
        let topRatio = CGFloat(0.040)

        let boxX = left + leftRatio*width
        let boxW = (rightRatio - leftRatio) * width
        let boxH = topRatio*height
        let boxY = bottom

        return NSRect(x: boxX, y: boxY, width: boxW, height: boxH)
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



}

