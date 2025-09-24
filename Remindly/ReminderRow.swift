//
//  ReminderRow.swift
//  Remindly
//
//  Created by Shahzeb Khan on 01.09.25.


import SwiftUI
import UIKit

struct ReminderRow: View {
    let reminder: Reminder

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let imageData = reminder.imageData, let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                if let note = reminder.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Text(reminder.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct ReminderRow_Previews: PreviewProvider {
    static var previews: some View {
        ReminderRow(reminder: Reminder(
            title: "Buy Groceries",
            date: "2023-10-10 12:00:00",
            category: "Personal",
            note: "Don't forget milk and eggs"
        ))
    }
}
