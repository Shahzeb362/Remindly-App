//
//  Reminder.swift
//  Remindly
//
//  Created by Shahzeb Khan on 01.09.25.
//
import Foundation

struct Reminder: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: String
    var imageData: Data?
    var category: String = "General"
    var recurrence: String?
    var note: String?
}

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: self)
    }
}
