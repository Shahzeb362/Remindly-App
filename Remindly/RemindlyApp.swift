//
//  RemindlyApp.swift
//  Remindly
//
//  Created by Shahzeb Khan on 01.09.25.
//

import SwiftUI
import UserNotifications

@main
struct RemindlyApp: App {
    @StateObject private var reminderViewModel = ReminderViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(reminderViewModel)
        }
    }
}
