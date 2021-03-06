//
//  SizedScrollView.swift
//  LetSwift
//
//  Created by Marcin Chojnacki on 19.06.2017.
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

class SizedScrollView: UIScrollView {
    
    override var frame: CGRect {
        didSet {
            notifySizeChangeIfNecessary()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            notifySizeChangeIfNecessary()
        }
    }
    
    private var lastSize: CGSize = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        lastSize = frame.size
        
        if lastSize != .zero {
            sizeHasChanged(to: lastSize)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func sizeHasChanged(to size: CGSize) {
    }
    
    private func notifySizeChangeIfNecessary() {
        if lastSize != bounds.size {
            lastSize = bounds.size
            sizeHasChanged(to: lastSize)
        }
    }
}
