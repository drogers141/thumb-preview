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
}

