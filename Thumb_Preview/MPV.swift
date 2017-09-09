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
    // area in window that maps to seeking in mpv when clicked
    // (left-click will seek to the percentage of the video corresponding
    // to the percentage of the window width of mouse-x)
    // this could be mapped to a smaller range perhaps with visual clues
    var seekBounds: NSRect?

    // basename of video file path
    var vidName: String?

    // video play time - seconds
    var vidLength = 0.0

    init(vidName: String, vidLength: Double) {
        winBounds = getMpvWinBounds(vidName: vidName)
        if winBounds != nil {
            if let flipped = flip_y_coord(winBounds!) {
                seekBounds = getMpvSeekArea(flippedWinBounds: flipped)
            }
        }
        self.vidName = vidName
        self.vidLength = vidLength
        print("MPV: vidName: \(String(describing: vidName)), ",
            "winBounds: \(String(describing: winBounds)), seekBounds: ",
            "\(String(describing: seekBounds)), vidLength: \(vidLength)")
    }

    func getSecondsFor(x: CGFloat) -> Double? {
        guard let normX = normalizedX(mouseX: x) else { return nil }
        return normX * vidLength
    }


    func normalizedX(mouseX: CGFloat) -> Double? {
        guard seekBounds != nil else { return nil }
        guard mouseX > seekBounds!.minX && mouseX < seekBounds!.maxX else { return nil }
        return Double((mouseX - seekBounds!.minX) / seekBounds!.width)
    }


    func inSeekBounds(point: NSPoint) -> Bool {
        if let bb = seekBounds {
            if bb.contains(point) {
                return true
            }
        }
        return false
    }

    // use the video filename to get the mpv window
    // if there are multiple mpv instances running with videos having the same name
    // or where one name is a substring of another, the first found is chosen
    //
    // bounds are screen coordinates, but the y needs to be flipped
    private func getMpvWinBounds(vidName: String) -> NSRect? {
        let winList = getMpvWinsInfo(vidName)
        guard winList.count > 0 else { return nil }
        for winDict in winList {
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
        return nil
    }


    // seek area is part of window with x mapped to seek
    // implemented in lua
    // work with bottom .25 of window - configurable as seekHeightFraction
    // scale across the whole window
    // perhaps flipping imageview location to left when on extreme right

    // y is flipped from CGWindowBounds
    // returns rect that works with NSEvent mouse location on screen
    // x,y = bottom left - ratios are x from left to right, y from bottom to top
    private func getMpvSeekArea(flippedWinBounds: NSRect) -> NSRect {
        print("flippedWinBounds: \(flippedWinBounds)")
        let seekHeightFraction = CGFloat(0.25)
        let left = flippedWinBounds.minX
        let width = flippedWinBounds.width
        let height = flippedWinBounds.height * seekHeightFraction
        let bottom = flippedWinBounds.minY - flippedWinBounds.height
        print("bottom: \(bottom), height: \(height)")

        return NSRect(x: left, y: bottom, width: width, height: height)
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

