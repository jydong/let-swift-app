//
//  ScreenDiagonalSize.swift
//  LetSwift
//
//  Created by Kinga Wilczek, Marcin Chojnacki on 13.04.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

enum DeviceScreenHeight: CGFloat {
    case inch3¨5 = 480.0
    case inch4¨0 = 568.0
    case inch4¨7 = 667.0
    case inch5¨5 = 736.0
    case inch5¨8 = 812.0
    case unknown = 0.0
    
    static let deviceHeight: DeviceScreenHeight = DeviceScreenHeight(rawValue: UIScreen.main.bounds.maxY) ?? .unknown
}

func ><T: RawRepresentable>(a: T, b: T) -> Bool where T.RawValue: Comparable {
    return a.rawValue > b.rawValue
}
