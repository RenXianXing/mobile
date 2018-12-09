//
//  RoundedUIButton.swift
//  SCOOTER
//
//  Created by RoyIM on 11/28/18.
//  Copyright © 2018 JinClevery. All rights reserved.
//

import UIKit

class RoundedUIButton: UIButton {
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 5.0)

    }

}
