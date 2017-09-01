//
//  ThumbsManager.swift
//  Thumb_Preview
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
}



// array of String
class SyncingArray {

    var elements: [String]
    let queue = DispatchQueue(label: "SynchingArrayQueue")

    init() {
        elements = [String]()
    }
    init(_ otherArray: [String]) {
        elements = [String]()
        elements.append(contentsOf: otherArray)
    }

    func add(_ elem: String) {
        queue.async(flags: .barrier) {
            self.elements.append(elem)
        }
    }

    // sync to other array - replacing our contents
    func sync(_ otherArray: [String]) {
        queue.async(flags: .barrier) {
            self.elements.removeAll()
            self.elements.append(contentsOf: otherArray)
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


//******** Leaving generic implementation for now - need to understand more about
// swift closures and whether or not to use a predicate to get around equals in the find()
// method

//class SynchingArray<T: Equatable> {
//
//    var elements: [T]
//    let queue = DispatchQueue(label: "SynchingArrayQueue")
//
//    init() {
//        elements = [T]()
//    }
//    init(_ otherArray: [T]) {
//        elements = [T]()
//        elements.append(contentsOf: otherArray)
//    }
//
//    func add(_ elem: T) {
//        queue.async(flags: .barrier) {
//            self.elements.append(elem)
//        }
//    }
//
//    // sync to other array - replacing our contents
//    func sync(_ otherArray: [T]) {
//        queue.async(flags: .barrier) {
//            self.elements.removeAll()
//            self.elements.append(contentsOf: otherArray)
//        }
//    }
//
//    func get(_ index: Int) -> T? {
//        var val: T?
//        queue.sync {
//            if elements.count > index {
//                val = elements[index]
//            } else {
//                val = nil
//            }
//        }
//        return val
//    }
//
//    func find<T: Equatable>(_ value: T) -> Int? {
//        var index: Int?
//        queue.sync {
//            for (i, e) in self.elements.enumerated() {
//                if e == value {
//                    index = i
//                    break
//                }
//            }
//            index = nil
//        }
//        return index
//    }
//}

