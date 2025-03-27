//
//  String.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/03/27.
//

import SwiftUI

extension Color {
  init(from text: String) {
      var hash = 0
      let colorConstant = 131
      let maxSafeValue = Int.max / colorConstant
      for char in text.unicodeScalars {
          if hash > maxSafeValue {
              hash /= colorConstant
          }
          hash = Int(char.value) + ((hash << 5) - hash)
      }
      let finalHash = abs(hash) % (256*256*256)
      let color = UIColor(
        red: max(CGFloat(0.2), CGFloat((finalHash & 0xFF0000) >> 16) / 255.0),
        green: max(CGFloat(0.2), CGFloat((finalHash & 0xFF00) >> 8) / 255.0),
        blue: max(CGFloat(0.2), CGFloat((finalHash & 0xFF)) / 255.0),
        alpha: 1.0
      )
      self.init(uiColor: color)
  }
}
