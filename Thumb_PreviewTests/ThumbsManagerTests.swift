//
//  ThumbsManagerTests.swift
//  Thumb_Preview
//
//  Created by David Rogers on 8/30/17.
//  Copyright © 2017 David Rogers. All rights reserved.
//

import XCTest
@testable import Thumb_Preview

class ThumbsManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSyncingArray() {

        let thumbs = [
            "/Users/drogers/tv/working/thumbs/00_00_00.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_10.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_20.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_30.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_40.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_50.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_60.00.jpg",
        ]
        let syncThumbs = SyncingArray(thumbs)

//        print("syncThumbs.get(2): \(syncThumbs.get(2))")
        XCTAssertEqual(syncThumbs.get(2), "/Users/drogers/tv/working/thumbs/00_00_20.00.jpg")

        XCTAssertEqual(syncThumbs.count(), 7)

        XCTAssertEqual(syncThumbs.get(7), nil)

        XCTAssertEqual(syncThumbs.find("/Users/drogers/tv/working/thumbs/00_00_50.00.jpg"), 5)

        syncThumbs.add("/Users/drogers/tv/working/thumbs/00_00_70.00.jpg")
        print(syncThumbs.elements)
        XCTAssertEqual(syncThumbs.count(), 8)
        XCTAssertEqual(syncThumbs.find("/Users/drogers/tv/working/thumbs/00_00_70.00.jpg"), 7)

        let newArray = ["a", "b", "c", "d"]
        syncThumbs.sync(newArray)
        XCTAssertEqual(syncThumbs.count(), 4)
        XCTAssertEqual(syncThumbs.find("/Users/drogers/tv/working/thumbs/00_00_70.00.jpg"), nil)
        XCTAssertEqual(syncThumbs.find("c"), 2)

    }

    func testConvertToSecs() {
        // "00:01:01.01" -> 61.01
        let strTime = "00:01:01.01"
        let expected = 61.01
        let actual = ThumbsManager.convertToSecs(strTime: strTime)
        print("actual: \(actual)")
        XCTAssertEqual(actual, expected)
    }

    func testConvertToStrTime() {
        // 3601.01 -> "01:00:01.10"
        let secs = 3601.1
        let expected = "01:00:01.10"
        let actual = ThumbsManager.convertToStrTime(secs: secs)
        XCTAssertEqual(actual, expected)
    }

    // "00_01_01.01.jpg"
    func testGetSecsFromThumb() {
        let thumbPath = "/Users/drogers/tv/working/thumbs/00_01_50.20.jpg"
        let expected = 110.2
        let actual = ThumbsManager.getSecsFromThumb(thumbPath)
        XCTAssertEqual(actual, expected)
    }

    func testClosestThumbBefore() {
        let thumbsMgr = ThumbsManager(thumbsDir: "/Users/drogers/tv/working/thumbs", numThumbs: 7)
        thumbsMgr.thumbs.sync([
            "/Users/drogers/tv/working/thumbs/00_00_05.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_10.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_20.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_30.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_40.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_50.00.jpg",
            "/Users/drogers/tv/working/thumbs/00_00_60.00.jpg",
            ])
        let expected = "/Users/drogers/tv/working/thumbs/00_00_20.00.jpg"
        let actual = thumbsMgr.closestThumbBefore(secs: 25.0)
        XCTAssertEqual(actual, expected)
        XCTAssertEqual(thumbsMgr.closestThumbBefore(secs: 78.0), "/Users/drogers/tv/working/thumbs/00_00_60.00.jpg")
        XCTAssertEqual(thumbsMgr.closestThumbBefore(secs: 7), "/Users/drogers/tv/working/thumbs/00_00_05.00.jpg")
        XCTAssertEqual(thumbsMgr.closestThumbBefore(secs: 4), nil)

    }
}

