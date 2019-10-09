//
//  MenuCardTests.swift
//  GryphEatsTests
//
//  Created by Domenic Bianchi on 2019-10-08.
//  Copyright © 2019 The Subway Squad. All rights reserved.
//

import SnapshotTesting
import SwiftUI
import XCTest

@testable import GryphEats

class MenuCardTests: XCTestCase {
    
    let record = false
    
    func testMenuCard() {
        assertSnapshot(
            matching: UIHostingController(rootView: MenuCard(itemName: "Hamburger", imageName: "hamburger", onTap: {})),
            as: .image,
            record: record)
    }
}
