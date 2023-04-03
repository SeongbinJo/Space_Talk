//
//  RgbExtension.swift
//  SpaceTalk
//
//  Created by 조성빈 on 2023/04/03.
//

import SwiftUI

//rgb별 색상 지정
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a/1.0)
    }
}
