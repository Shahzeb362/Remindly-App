//
//  ReminderDetailView.swift
//  Remindly
//
//  Created by Shahzeb Khan on 01.09.25.
//

//
//  ReminderDetailView.swift
//  Remindly
//
//  Created by Shahzeb Khan on 01.09.25.
//

//
//  ReminderDetailView.swift
//  Remindly
//
//  Created by Shahzeb Khan on 01.09.25.
//

//
//  ReminderDetailView.swift
//  Remindly
//
//  Created by Shahzeb Khan on 01.09.25.
//

import SwiftUI
import PhotosUI
import UIKit

struct ReminderDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ReminderViewModel
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var imageData: Data?
    @State private var category: String = "General"
    @State private var recurrence: String? = nil
    @State private var isEditing = false
    @State private var reminderToEdit: Reminder?
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var showImagePicker = false
    @State private var selectedImageItem: PhotosPickerItem? = nil

    // Category configuration
    private let categories = [
        CategoryItem(name: "General", color: .blue, lightColor: Color.blue.opacity(0.1)),
        CategoryItem(name: "Work", color: .purple, lightColor: Color.purple.opacity(0.1)),
        CategoryItem(name: "Personal", color: .green, lightColor: Color.green.opacity(0.1)),
        CategoryItem(name: "Health", color: .red, lightColor: Color.red.opacity(0.1)),
        CategoryItem(name: "Shopping", color: .orange, lightColor: Color.orange.opacity(0.1)),
        CategoryItem(name: "Finance", color: .yellow, lightColor: Color.yellow.opacity(0.1))
    ]

    private let repeatOptions = ["None", "Daily", "Weekdays", "Weekends", "Weekly", "Monthly"]

    private var currentCategory: CategoryItem {
        categories.first { $0.name == category } ?? categories[0]
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }

    init(reminder: Reminder? = nil, viewModel: ReminderViewModel) {
        self.viewModel = viewModel
        if let reminder = reminder {
            _title = State(initialValue: reminder.title)
            _note = State(initialValue: reminder.note ?? "")
            _selectedDate = State(initialValue: reminder.date.toDate() ?? Date())
            _selectedTime = State(initialValue: reminder.date.toDate() ?? Date())
            _imageData = State(initialValue: reminder.imageData)
            _category = State(initialValue: reminder.category)
            _recurrence = State(initialValue: reminder.recurrence)
            _isEditing = State(initialValue: true)
            _reminderToEdit = State(initialValue: reminder)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(spacing: 16) {
                        // REMINDER DETAILS Title outside card
                        HStack {
                            Text("REMINDER DETAILS")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Reminder Details Card
                        reminderDetailsCard
                        
                        // Date, Time, Category & Repeat Card
                        schedulingCard
                    }
                }
                
                // Add Reminder Button
                addReminderButton
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header (Reduced height)
    private var headerView: some View {
        HStack {
            Spacer()
            
            Text(isEditing ? "Edit Reminder" : "New Reminder")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12) // Reduced from 16
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Reminder Details Card (Reduced height)
    private var reminderDetailsCard: some View {
        VStack(spacing: 12) { // Reduced from 16
            // Title Field
            VStack(alignment: .leading, spacing: 6) { // Reduced from 8
                Text("Title")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                TextField("Enter reminder title", text: $title)
                    .font(.system(size: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8) // Reduced from 12
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
            }
            
            // Separator Line
            Divider()
            
            // Note Field
            VStack(alignment: .leading, spacing: 6) { // Reduced from 8
                Text("Note")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                TextField("Add a note (optional)", text: $note, axis: .vertical)
                    .font(.system(size: 16))
                    .lineLimit(2...4) // Reduced from 3...6
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10) // Reduced from 12
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
            }
        }
        .padding(16) // Reduced from 20
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    // MARK: - Scheduling Card (Reduced spacing)
    private var schedulingCard: some View {
        VStack(spacing: 0) {
            // Date Section
            VStack(alignment: .leading, spacing: 8) { // Reduced from 12
                Text("Date")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showDatePicker.toggle()
                    }
                    if showTimePicker {
                        showTimePicker = false
                    }
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        Text(showDatePicker ? "Select Date" : formattedDate)
                            .font(.system(size: 16))
                            .foregroundColor(showDatePicker ? .gray : .primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(showDatePicker ? 180 : 0))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10) // Reduced from 12
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Inline Date Picker
                if showDatePicker {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle()) // Changed from GraphicalDatePickerStyle
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.bottom, 16) // Reduced from 20
            
            // Separator Line
            Divider()
                .padding(.bottom, 16) // Reduced from 20
            
            // Time Section
            VStack(alignment: .leading, spacing: 8) { // Reduced from 12
                Text("Time")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showTimePicker.toggle()
                    }
                    if showDatePicker {
                        showDatePicker = false
                    }
                }) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        Text(formattedTime)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(showTimePicker ? 180 : 0))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10) // Reduced from 12
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Inline Time Picker
                if showTimePicker {
                    HStack {
                        Spacer()
                        DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                        Spacer()
                    }
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.bottom, 16) // Reduced from 20
            
            // Separator Line
            Divider()
                .padding(.bottom, 16) // Reduced from 20
            
            // Category Section
            VStack(alignment: .leading, spacing: 8) { // Reduced from 12
                Text("Category")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) { // Reduced spacing
                    ForEach(categories, id: \.name) { cat in
                        Button(action: {
                            category = cat.name
                        }) {
                            HStack(spacing: 4) { // Reduced from 6
                                Circle()
                                    .fill(cat.color)
                                    .frame(width: 8, height: 8) // Reduced from 12
                                
                                Text(cat.name)
                                    .font(.system(size: 11, weight: .medium)) // Reduced from 13
                                    .foregroundColor(category == cat.name ? cat.color : .primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .padding(.horizontal, 8) // Reduced from 10
                            .padding(.vertical, 6) // Reduced from 8
                            .frame(maxWidth: .infinity, minHeight: 34) // Increased height from 28
                            .background(category == cat.name ? cat.lightColor : Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(14) // Made more rounded
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(category == cat.name ? cat.color : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.bottom, 16) // Reduced from 20
            
            // Separator Line
            Divider()
                .padding(.bottom, 16) // Reduced from 20
            
            // Repeat Section
            VStack(alignment: .leading, spacing: 8) { // Reduced from 12
                Text("Repeat")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) { // Reduced spacing
                    ForEach(repeatOptions, id: \.self) { option in
                        Button(action: {
                            recurrence = option == "None" ? nil : option
                        }) {
                            Text(option)
                                .font(.system(size: 11, weight: .medium)) // Reduced from 13
                                .foregroundColor(isSelectedRepeat(option) ? .white : .primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .padding(.horizontal, 8) // Reduced from 10
                                .padding(.vertical, 6) // Reduced from 8
                                .frame(maxWidth: .infinity, minHeight: 34) // Increased height from 28
                                .background(isSelectedRepeat(option) ? Color.blue : Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(14) // Made more rounded
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(isSelectedRepeat(option) ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.bottom, 16) // Reduced from 20
            
            // Separator Line
            Divider()
                .padding(.bottom, 16) // Reduced from 20
            
            // Select Image Section
            VStack(alignment: .leading, spacing: 8) { // Reduced from 12
                PhotosPicker(selection: $selectedImageItem, matching: .images) {
                    HStack {
                        Image(systemName: "photo")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                        
                        Text("Select Image")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        if imageData != nil {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(PlainButtonStyle())
                .onChange(of: selectedImageItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            imageData = data
                        }
                    }
                }
                
                // Show selected image preview
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }
            }
        }
        .padding(16) // Reduced from 20
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    // MARK: - Add Reminder Button
    private var addReminderButton: some View {
        VStack {
            Button(action: saveReminder) {
                Text(isEditing ? "Update Reminder" : "Add Reminder")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14) // Reduced from 16
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 20)
            .padding(.bottom, 20) // Reduced from 34
        }
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Helper Methods
    private func isSelectedRepeat(_ option: String) -> Bool {
        return (option == "None" && recurrence == nil) || (recurrence == option)
    }

    private func saveReminder() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // Combine date and time
        let finalDate = Calendar.current.date(bySettingHour: Calendar.current.dateComponents([.hour, .minute], from: selectedTime).hour ?? 0,
                                              minute: Calendar.current.dateComponents([.hour, .minute], from: selectedTime).minute ?? 0,
                                              second: 0,
                                              of: selectedDate) ?? Date()

        let dateString = dateFormatter.string(from: finalDate)

        if isEditing, let reminderToEdit = reminderToEdit {
            let updatedReminder = Reminder(
                id: reminderToEdit.id,
                title: title,
                date: dateString,
                imageData: imageData,
                category: category,
                recurrence: recurrence,
                note: note
            )
            viewModel.updateReminder(updatedReminder)
        } else {
            let newReminder = Reminder(
                title: title,
                date: dateString,
                imageData: imageData,
                category: category,
                recurrence: recurrence,
                note: note
            )
            viewModel.addReminder(newReminder)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Supporting Types
struct CategoryItem {
    let name: String
    let color: Color
    let lightColor: Color
}

// MARK: - Preview
struct ReminderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderDetailView(viewModel: ReminderViewModel())
    }
}
