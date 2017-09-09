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
    // change from bar bounds to seek range in general window
    var seekBounds: NSRect?

    // mpv pid - not using as can't get pid easily from mpv
//    var pid: pid_t?
    // use video filename instead
    // basename of file
    var vidName: String?

    // video play time - seconds
    var vidLength = 0.0

    init(vidName: String, vidLength: Double) {
        winBounds = getMpvWinBounds(vidName: vidName)
        if winBounds != nil {
            if let flipped = flip_y_coord(winBounds!) {
//                barBounds = getMpvBarBounds(flippedWinBounds: flipped)
                seekBounds = getMpvSeekArea(flippedWinBounds: flipped)
            }
        }
        self.vidName = vidName
        self.vidLength = vidLength
//        print("MPV: vidName: \(String(describing: vidName)), ",
//            "winBounds: \(String(describing: winBounds)), barBounds: ",
//            "\(String(describing: barBounds)), vidLength: \(vidLength)")
        print("MPV: vidName: \(String(describing: vidName)), ",
            "winBounds: \(String(describing: winBounds)), seekBounds: ",
            "\(String(describing: seekBounds)), vidLength: \(vidLength)")
    }

    func getSecondsFor(x: CGFloat) -> Double? {
        guard let normX = normalizedX(mouseX: x) else { return nil }
        return normX * vidLength
    }

//    func normalizedX(mouseX: CGFloat) -> Double? {
//        guard barBounds != nil else { return nil }
//        guard mouseX > barBounds!.minX && mouseX < barBounds!.maxX else { return nil }
//        return Double((mouseX - barBounds!.minX) / barBounds!.width)
//    }

    func normalizedX(mouseX: CGFloat) -> Double? {
        guard seekBounds != nil else { return nil }
        guard mouseX > seekBounds!.minX && mouseX < seekBounds!.maxX else { return nil }
        return Double((mouseX - seekBounds!.minX) / seekBounds!.width)
    }

//    func inBarBounds(point: NSPoint) -> Bool {
//        if let bb = barBounds {
//            if bb.contains(point) {
//                return true
//            }
//        }
//        return false
//    }

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



//    // brittle way to get the bounds of the correct mpv window given the
//    // mpv pid
//    // bounds are screen coordinates, but the y needs to be flipped
//    private func getMpvWinBounds(pid: pid_t) -> NSRect? {
//        let winList = getWinsInfo(pid)
//        for winDict in winList {
//            //            print("mpv win:\n\(winDict)\n")
//            if let winName = winDict["kCGWindowName"] {
////                print("win with name:")
////                print("\(winDict)\n***************")
//
//                // ** note - this only occurs with the correct window, and only when it is
//                // on the same desktop (space) as the thumb-preview proc
//                //  "kCGWindowIsOnscreen": 1,
//                // so could look for that if that becomes more relevant
//
//                //                print("winDict[kCGWindowName] = \(winName)")
//                if let winBounds = winDict["kCGWindowBounds"] {
//                    if let wb = winBounds as? [AnyHashable: Any] {
//                        //                        print("its a dict")
//
//                        //                        print("winBounds: \(wb)")
//                        if let h = wb["Height"] as? Int,
//                            let w = wb["Width"] as? Int,
//                            let x = wb["X"] as? Int,
//                            let y = wb["Y"] as? Int {
//                            //                                print("x=\(x), y=\(y), width=\(w), height=\(w)")
//                            if w > 2 && h > 2 {
//                                //                                    print("this is the real window")
//                                return NSRect(x: CGFloat(x), y: CGFloat(y),
//                                              width: CGFloat(w), height: CGFloat(h))
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        return nil
//    }

    // ******* mpv osc bottombar layout ***********
    // not working - seems like scaling is unstable

    // y is flipped from CGWindowBounds
    // returns rect that works with NSEvent mouse location on screen
    // x,y = bottom left
    private func getMpvBarBounds_orig(flippedWinBounds: NSRect) -> NSRect {
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

    // ******************************
    // rather than trying to work with bar
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


    // ********* mpv osc slimbox layout *********
    // y is flipped from CGWindowBounds
    // returns rect that works with NSEvent mouse location on screen
    // x,y = bottom left - ratios are x from left to right, y from bottom to top
//    private func getMpvBarBounds(flippedWinBounds: NSRect) -> NSRect {
//        print("flippedWinBounds: \(flippedWinBounds)")
//        let left = flippedWinBounds.minX
//        let width = flippedWinBounds.width
//        let height = flippedWinBounds.height
//        let bottom = flippedWinBounds.minY - height
//        print("bottom: \(bottom), height: \(height)")
//
//        // change from left, right, bottom, top to
//        // left, width, bottom, height
//
//        let leftRatio = CGFloat(0.268)
//        let widthRatio = CGFloat(0.496)
//
//        let bottomRatio = CGFloat(0.135)
//        let heightRatio = CGFloat(0.028)
//
//        let boxX = left + leftRatio*width
//        let boxW = widthRatio*width
//        let boxY = bottom + bottomRatio*height
//        let boxH = heightRatio*height
//
//        return NSRect(x: boxX, y: boxY, width: boxW, height: boxH)
//    }


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

