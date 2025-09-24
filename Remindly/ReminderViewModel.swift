//
//  ReminderViewModel.swift
//  Remindly
//
//  Created by Shahzeb Khan on 01.09.25.
//

//
//  ReminderViewModel.swift
//  Remindly
//
//  Created by Shahzeb Khan on 01.09.25.
//

import Foundation
import UserNotifications

class ReminderViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var completedReminderIds: Set<String> = []

    init() {
        loadReminders()
        loadCompletedReminders()
    }

    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        saveReminders()
        scheduleNotification(for: reminder)
    }

    func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            saveReminders()
            scheduleNotification(for: reminder)
        }
    }

    func deleteReminder(at offsets: IndexSet) {
        for index in offsets {
            let reminder = reminders[index]
            cancelNotification(for: reminder)
            completedReminderIds.remove(reminder.id.uuidString)
        }
        reminders.remove(atOffsets: offsets)
        saveReminders()
        saveCompletedReminders()
    }
    
    func toggleReminderCompletion(_ reminder: Reminder) {
        let reminderIdString = reminder.id.uuidString
        
        if completedReminderIds.contains(reminderIdString) {
            // Mark as incomplete
            completedReminderIds.remove(reminderIdString)
            // Reschedule notification if the reminder date is in the future
            if let reminderDate = reminder.date.toDate(), reminderDate > Date() {
                scheduleNotification(for: reminder)
            }
        } else {
            // Mark as complete
            completedReminderIds.insert(reminderIdString)
            // Cancel notification for completed reminder
            cancelNotification(for: reminder)
        }
        
        saveCompletedReminders()
    }
    
    func isReminderCompleted(_ reminder: Reminder) -> Bool {
        return completedReminderIds.contains(reminder.id.uuidString)
    }

    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: "Reminders")
        }
    }

    private func loadReminders() {
        if let savedReminders = UserDefaults.standard.data(forKey: "Reminders"),
           let decodedReminders = try? JSONDecoder().decode([Reminder].self, from: savedReminders) {
            reminders = decodedReminders
        }
    }
    
    private func saveCompletedReminders() {
        let completedArray = Array(completedReminderIds)
        if let encoded = try? JSONEncoder().encode(completedArray) {
            UserDefaults.standard.set(encoded, forKey: "CompletedReminders")
        }
    }
    
    private func loadCompletedReminders() {
        if let savedCompleted = UserDefaults.standard.data(forKey: "CompletedReminders"),
           let decodedCompleted = try? JSONDecoder().decode([String].self, from: savedCompleted) {
            completedReminderIds = Set(decodedCompleted)
        }
    }

    private func scheduleNotification(for reminder: Reminder) {
        // Cancel any existing notification for this reminder
        cancelNotification(for: reminder)
        
        // Don't schedule notification for completed reminders
        if completedReminderIds.contains(reminder.id.uuidString) {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.note ?? "Reminder for \(reminder.title)"
        content.sound = .default

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let triggerDate = dateFormatter.date(from: reminder.date) else { return }
        
        // Don't schedule notifications for past dates
        guard triggerDate > Date() else { return }

        var trigger: UNCalendarNotificationTrigger?

        if let recurrence = reminder.recurrence {
            switch recurrence {
            case "Daily":
                trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: triggerDate), repeats: true)
            case "Weekdays":
                // Schedule for Monday through Friday
                let weekdayComponents = Calendar.current.dateComponents([.hour, .minute, .weekday], from: triggerDate)
                if let weekday = weekdayComponents.weekday, weekday >= 2 && weekday <= 6 {
                    trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute, .weekday], from: triggerDate), repeats: true)
                }
            case "Weekends":
                // Schedule for Saturday and Sunday
                let weekdayComponents = Calendar.current.dateComponents([.hour, .minute, .weekday], from: triggerDate)
                if let weekday = weekdayComponents.weekday, weekday == 1 || weekday == 7 {
                    trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute, .weekday], from: triggerDate), repeats: true)
                }
            case "Weekly":
                trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.weekday, .hour, .minute], from: triggerDate), repeats: true)
            case "Monthly":
                trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .hour, .minute], from: triggerDate), repeats: true)
            default:
                trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
            }
        } else {
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
        }

        guard let trigger = trigger else { return }

        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    private func cancelNotification(for reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }
}
