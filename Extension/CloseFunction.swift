//
//  CloseFunction.swift
//  Bromides
//
//  Created by シン・ジャスティン on 2025/08/24.
//

import UserNotifications

func close() {
    NotificationCenter.default.post(name: NSNotification.Name("close"), object: nil)
}
