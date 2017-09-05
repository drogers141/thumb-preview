//
//  ThumbsManager.swift
//  Thumb_Preview
//
//  Frames from a video are saved to one directory and named according to their time
//  within video.  Thumbs are made available in an optimized manner, so this class has
//  the thumbs available for display at the time, adding as they become available.
//
//  Given a time in seconds, this class will return the path to the best thumb available.
//
//  ************ move this documentation to the appropriate class/file docs **********
//  For display when the mouse enters the seek bar of mpv this app is started or unhidden
//  if it was already active
//  The location of the mouse x coord in the bar is mapped to a bucket - discrete handling of
//  a continuous data source.  For the range of x values the thumbnail shown will be the thumb
//  corresponding to the time at the beginning of the bucket.
//
//  Created by David Rogers on 8/30/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import Cocoa

class ThumbsManager {

    // thumbs we have available for display
    var thumbs = SyncingArray()
    // thumbs directory we may need to keep observing as more thumbs are written to it
    var thumbsDir = ""
    // number of thumbs expected - we can stop observing once thumbs.count = this
    var numThumbs = 0

    let thumbFileExts = [".jpg"]

    init(thumbsDir: String, numThumbs: Int) {
        self.thumbsDir = thumbsDir
        self.numThumbs = numThumbs
        updateThumbs()
        print("thumbs mgr: thumbs: \(thumbs.count())")
    }

    // implement with timer - keep updating until thumbs.count() == numThumbs
    func keepUpdatingThumbs() {

    }

    func updateThumbs() {
        var thumbsInDir = [String]()
        let fileManager = FileManager.default
        do {
            let allFiles = try fileManager.contentsOfDirectory(atPath: thumbsDir)
            for f in allFiles
            {
                //                print("checking \(f)")
                for suffix in thumbFileExts {
                    if f.lowercased().hasSuffix(suffix) {
                        let url = URL.init(fileURLWithPath: thumbsDir + "/" + f)
                        let abspath = url.path
                        assert(fileManager.fileExists(atPath: abspath))
                        thumbsInDir.append(abspath)
                        break
                    }
                }

            }
        } catch {
            print("error getting dir contents")
        }
        if thumbsInDir.count != thumbs.count() {
            print("syncing thumbs - thumbs.count(): \(thumbs.count()),",
                " in dir: \(thumbsInDir.count)")
            thumbs.sync(thumbsInDir)
        }
    }

    // nil if no thumbs or time is before any thumb's time
    // return the thumb that should be displayed given the time in seconds
    func closestThumbBefore(secs: Double) -> String? {
        guard thumbs.count() > 0 else { print("no thumbs"); return nil }
        guard ThumbsManager.getSecsFromThumb(thumbs.get(0)!) <= secs else {
            print("secs: \(secs) < first thumb secs"); return nil }
        // don't care that first iteration this stays the same
        var current = thumbs.get(0)!
        for i in 0...thumbs.count()-1 {
//            print("current: \(current)")
            if ThumbsManager.getSecsFromThumb(thumbs.get(i)!) > secs {
                break
            }
            current = thumbs.get(i)!
        }
        return current
    }

    // thumbPath - full path of thumb
    // expect thumb to have format: hh_mm_ss.ss.jpg
    // e.g.: "/Users/drogers/tv/working/thumbs/00_01_01.01.jpg"
    static func getSecsFromThumb(_ thumbPath: String) -> Double {
        let nsPath = thumbPath as NSString
        let filename = nsPath.lastPathComponent
        var parts = filename.components(separatedBy: ".")
        parts.removeLast()
        let basename = parts.joined(separator: ".")
        let strTime = basename.replacingOccurrences(of: "_", with: ":")
        return ThumbsManager.convertToSecs(strTime: strTime)
    }

    // "00:01:01.01" -> 61.01
    static func convertToSecs(strTime: String) -> Double {
        let parts = strTime.components(separatedBy: ":").map { Double($0) }
//        print("parts: \(parts)")
        return parts[0]! * 3600 + parts[1]! * 60 + parts[2]!
    }
    // 3601.01 -> "01:00:01.010"
    // not sure we'll need this one
    static func convertToStrTime(secs: Double) -> String {
        let frac = secs - floor(secs)
        let intSecs = Int(secs)
        let hours = intSecs / 3600
        var remaining = intSecs % 3600
        let minutes = remaining / 60
        remaining %= 60
        let secsPart = Double(remaining) + frac
        return String(format: "%02d:%02d:%05.2f", hours, minutes, secsPart)
    }
}


// array of String
// sorted
// locks access during write
// allows multiple concurrent readers
class SyncingArray {

    var elements: [String]
    let queue = DispatchQueue(label: "SynchingArrayQueue")

    init() {
        elements = [String]()
    }
    init(_ otherArray: [String]) {
        elements = [String]()
        elements.append(contentsOf: otherArray)
        elements.sort()
    }

    func add(_ elem: String) {
        queue.async(flags: .barrier) {
            self.elements.append(elem)
            self.elements.sort()
        }
    }

    // sync to other array - replacing our contents
    func sync(_ otherArray: [String]) {
        queue.async(flags: .barrier) {
            self.elements.removeAll()
            self.elements.append(contentsOf: otherArray)
            self.elements.sort()
        }
    }

    func get(_ index: Int) -> String? {
        var val: String?
        queue.sync {
            if elements.count > index {
                val = elements[index]
            } else {
                val = nil
            }
        }
        return val
    }

    func find(_ value: String) -> Int? {
        var index: Int?
        index = nil
        queue.sync {
            for (i, e) in self.elements.enumerated() {
                if e == value {
                    index = i
                    break
                }
            }
        }
        return index
    }

    func count() -> Int {
        var count = 0
        queue.sync {
            count = self.elements.count
        }
        return count
    }
}

