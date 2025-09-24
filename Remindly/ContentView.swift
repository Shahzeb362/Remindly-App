//
//  ContentView.swift
//  Remindly
//
//  Created by Shahzeb Khan on 01.09.25.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: ReminderViewModel
    @State private var selectedImage: UIImage?
    @State private var showImageViewer = false
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Custom Header
                    headerView
                    
                    // Search Bar
                    searchBarView
                    
                    // Stats Cards
                    statsCardsView
                    
                    // My Reminders Section Header
                    myRemindersHeaderView
                    
                    // Reminders Content
                    if filteredReminders.isEmpty {
                        emptyStateView
                    } else {
                        remindersListView
                    }
                    
                    // Bottom padding for safe scrolling
                    Spacer(minLength: 20)
                }
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showImageViewer) {
            if let selectedImage = selectedImage {
                ImageViewerSheet(image: selectedImage, isPresented: $showImageViewer)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredReminders: [Reminder] {
        if searchText.isEmpty {
            return viewModel.reminders.filter { !isCompleted($0) }
        } else {
            return viewModel.reminders.filter { reminder in
                !isCompleted(reminder) && reminder.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var todayReminders: [Reminder] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return viewModel.reminders.filter { reminder in
            guard let reminderDate = reminder.date.toDate() else { return false }
            let reminderDay = Calendar.current.startOfDay(for: reminderDate)
            return reminderDay >= today && reminderDay < tomorrow && !isCompleted(reminder)
        }
    }
    
    private var completedReminders: [Reminder] {
        return viewModel.reminders.filter { isCompleted($0) }
    }
    
    private var scheduledReminders: [Reminder] {
        return viewModel.reminders.filter { reminder in
            reminder.recurrence != nil && !isCompleted(reminder)
        }
    }
    
    private func isCompleted(_ reminder: Reminder) -> Bool {
        return viewModel.completedReminderIds.contains(reminder.id.uuidString)
    }
    
    // MARK: - Helper Functions
    private func deleteReminders(at offsets: IndexSet) {
        let remindersToDelete = offsets.map { filteredReminders[$0] }
        for reminder in remindersToDelete {
            if let index = viewModel.reminders.firstIndex(where: { $0.id == reminder.id }) {
                viewModel.deleteReminder(at: IndexSet(integer: index))
            }
        }
    }
    
    private func completeReminder(_ reminder: Reminder) {
        viewModel.toggleReminderCompletion(reminder)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("Reminders")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            NavigationLink(destination: ReminderDetailView(viewModel: viewModel)) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Search Bar View
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16))
            
            TextField("Search", text: $searchText)
                .font(.system(size: 16))
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Stats Cards View
    private var statsCardsView: some View {
        HStack(spacing: 12) {
            // Today Card
            NavigationLink(destination: ReminderCategoryView(title: "Today", reminders: todayReminders, viewModel: viewModel)) {
                StatCard(
                    title: "Today",
                    count: todayReminders.count,
                    icon: "calendar.badge.clock",
                    color: .blue
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Scheduled Card
            NavigationLink(destination: ReminderCategoryView(title: "Scheduled", reminders: scheduledReminders, viewModel: viewModel)) {
                StatCard(
                    title: "Scheduled",
                    count: scheduledReminders.count,
                    icon: "calendar",
                    color: .red
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Completed Card
            NavigationLink(destination: ReminderCategoryView(title: "Completed", reminders: completedReminders, viewModel: viewModel)) {
                StatCard(
                    title: "Completed",
                    count: completedReminders.count,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - My Reminders Header
    private var myRemindersHeaderView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("My Reminders")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack {
                Text("\(filteredReminders.count) reminders")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.badge")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Reminders Yet")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.primary)
            
            Text("Tap the + button to create your first reminder")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(minHeight: 200)
    }
    
    // MARK: - Reminders List View
    private var remindersListView: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(filteredReminders.enumerated()), id: \.element.id) { index, reminder in
                SwipeableReminderRow(
                    reminder: reminder,
                    onEdit: {
                        // Navigation handled by the row itself
                    },
                    onDelete: {
                        if let reminderIndex = viewModel.reminders.firstIndex(where: { $0.id == reminder.id }) {
                            viewModel.deleteReminder(at: IndexSet(integer: reminderIndex))
                        }
                    },
                    onComplete: {
                        completeReminder(reminder)
                    },
                    viewModel: viewModel
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 100) // Extra bottom padding to ensure last item is fully visible
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
                Text("\(count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
    }
}

// MARK: - Swipeable Reminder Row
struct SwipeableReminderRow: View {
    let reminder: Reminder
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onComplete: () -> Void
    let viewModel: ReminderViewModel
    
    @State private var offset: CGFloat = 0
    @State private var showDeleteAlert = false
    
    // Constants for swipe behavior
    private let actionButtonWidth: CGFloat = 80
    private let maxLeftReveal: CGFloat = 160 // Width for both Edit and Delete buttons
    private let maxRightReveal: CGFloat = 160  // Width for Complete button
    private let completionThreshold: CGFloat = 120 // Point where completion action triggers
    private let actionThreshold: CGFloat = 100 // Point where left actions show
    
    // Category colors mapping
    private let categoryColors: [String: Color] = [
        "General": .blue,
        "Work": .purple,
        "Personal": .green,
        "Health": .red,
        "Shopping": .orange,
        "Finance": .yellow
    ]
    
    private var categoryColor: Color {
        categoryColors[reminder.category] ?? .blue
    }
    
    // Helper to check if this reminder is completed
    private var isReminderCompleted: Bool {
        viewModel.completedReminderIds.contains(reminder.id.uuidString)
    }
    
    var body: some View {
        ZStack {
            // Background actions container
            HStack(spacing: 0) {
                // Complete action (left side, revealed by right swipe)
                if offset > 0 {
                    Button(action: onComplete) {
                        VStack {
                            Image(systemName: isReminderCompleted ? "arrow.counterclockwise" : "checkmark")
                                .font(.system(size: 18, weight: .medium))
                            Text(isReminderCompleted ? "Uncomplete" : "Complete")
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .foregroundColor(.white)
                        .frame(width: min(maxRightReveal, offset))
                        .frame(maxHeight: .infinity)
                        .background(isReminderCompleted ? Color.orange : Color.green)
                    }
                    .clipped()
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Edit and Delete actions (right side, revealed by left swipe)
                if offset < 0 {
                    HStack(spacing: 0) {
                        NavigationLink(destination: ReminderDetailView(reminder: reminder, viewModel: viewModel)) {
                            VStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Edit")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(width: actionButtonWidth)
                            .frame(maxHeight: .infinity)
                            .background(Color.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            VStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Delete")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(width: actionButtonWidth)
                            .frame(maxHeight: .infinity)
                            .background(Color.red)
                        }
                    }
                    .frame(width: min(maxLeftReveal, abs(offset)))
                    .clipped()
                    .cornerRadius(12)
                }
            }
            
            // Main content
            HStack(spacing: 0) {
                // Category color line
                Rectangle()
                    .fill(categoryColor)
                    .frame(width: 4)
                
                HStack(spacing: 16) {
                    // Main content
                    VStack(alignment: .leading, spacing: 6) {
                        // Title and date row
                        HStack {
                            Text(reminder.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(formatDate(reminder.date))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        // Note (if exists)
                        if let note = reminder.note, !note.isEmpty {
                            Text(note)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        
                        // Category and image indicator row
                        HStack {
                            // Category badge
                            HStack(spacing: 6) {
                                Text(reminder.category)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(categoryColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(categoryColor.opacity(0.15))
                                    .cornerRadius(8)
                            }
                            
                            // Image indicator (if image exists)
                            if reminder.imageData != nil {
                                HStack(spacing: 4) {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    Text("Photo")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Chevron
                    NavigationLink(destination: ReminderViewDetailScreen(reminder: reminder, viewModel: viewModel)) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            .offset(x: offset) // direct offset, no detachment
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        let translation = value.translation.width
                        let velocity = value.velocity.width
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if translation > completionThreshold || velocity > 500 {
                                // Complete the reminder
                                offset = 0
                                onComplete()
                            } else if translation > actionThreshold {
                                offset = maxRightReveal // Stop at Complete button width
                            } else if translation < -actionThreshold || velocity < -500 {
                                offset = -maxLeftReveal // Stop at Edit/Delete width
                            } else {
                                offset = 0 // Reset
                            }
                        }
                    }
            )
            .onTapGesture {
                if offset != 0 {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = 0
                    }
                }
            }
        }
        .alert("Delete Reminder", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    offset = 0
                }
            }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this reminder?")
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, h:mm a"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}


// MARK: - Reminder Category View
struct ReminderCategoryView: View {
    let title: String
    let reminders: [Reminder]
    let viewModel: ReminderViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if reminders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("No \(title) Reminders")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("Create a new reminder to see it here")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(reminders, id: \.id) { reminder in
                            SwipeableReminderRow(
                                reminder: reminder,
                                onEdit: {},
                                onDelete: {
                                    if let index = viewModel.reminders.firstIndex(where: { $0.id == reminder.id }) {
                                        viewModel.deleteReminder(at: IndexSet(integer: index))
                                    }
                                },
                                onComplete: {
                                    viewModel.toggleReminderCompletion(reminder)
                                },
                                viewModel: viewModel
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
                .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - View-Only Reminder Detail Screen
struct ReminderViewDetailScreen: View {
    let reminder: Reminder
    let viewModel: ReminderViewModel
    @State private var selectedImage: UIImage?
    @State private var showImageViewer = false
    @State private var showDeleteAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    // Category colors mapping
    private let categoryColors: [String: Color] = [
        "General": .blue,
        "Work": .purple,
        "Personal": .green,
        "Health": .red,
        "Shopping": .orange,
        "Finance": .yellow
    ]
    
    private var categoryColor: Color {
        categoryColors[reminder.category] ?? .blue
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title and Note Card
                VStack(alignment: .leading, spacing: 0) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(reminder.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    // Separator Line
                    if let note = reminder.note, !note.isEmpty {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                        
                        // Note Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(note)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 20)
                
                // Date, Time and Category Card
                VStack(alignment: .leading, spacing: 0) {
                    // Date and Time Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                            
                            Text("Date & Time")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(formatDate(reminder.date))
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    // Separator Line
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                    
                    // Category Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "tag.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                            
                            Text("Category")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(categoryColor)
                                .frame(width: 10, height: 10)
                            
                            Text(reminder.category)
                                .font(.system(size: 16))
                                .foregroundColor(categoryColor)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 20)
                
                // Image Section (if exists)
                if let imageData = reminder.imageData,
                   let image = UIImage(data: imageData) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                            
                            Text("Photo")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Button(action: {
                            selectedImage = image
                            showImageViewer = true
                        }) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: 200)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 120) // Extra space for buttons
            }
            .padding(.top, 20)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .navigationTitle("Reminder Details")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            // Edit and Delete Buttons at Bottom
            VStack {
                Spacer()
                
                VStack {
                    HStack(spacing: 12) {
                        // Edit Button
                        NavigationLink(destination: ReminderDetailView(reminder: reminder, viewModel: viewModel)) {
                            HStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Edit")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Delete Button
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Delete")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34) // Safe area padding
                }
                .background(
                    // Gradient overlay for better button visibility
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(UIColor.systemBackground).opacity(0),
                            Color(UIColor.systemBackground).opacity(0.8),
                            Color(UIColor.systemBackground)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 140)
                )
            }
        )
        .sheet(isPresented: $showImageViewer) {
            if let selectedImage = selectedImage {
                ImageViewerSheet(image: selectedImage, isPresented: $showImageViewer)
            }
        }
        .alert("Delete Reminder", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteReminder()
            }
        } message: {
            Text("Are you sure you want to delete this reminder? This action cannot be undone.")
        }
    }
    
    private func deleteReminder() {
        if let index = viewModel.reminders.firstIndex(where: { $0.id == reminder.id }) {
            viewModel.deleteReminder(at: IndexSet(integer: index))
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEEE, MMMM d, yyyy 'at' h:mm a"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Image Viewer Sheet
struct ImageViewerSheet: View {
    let image: UIImage
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    if scale < 1.0 {
                                        withAnimation(.spring()) {
                                            scale = 1.0
                                            lastScale = 1.0
                                            offset = .zero
                                            lastOffset = .zero
                                        }
                                    } else if scale > 3.0 {
                                        withAnimation(.spring()) {
                                            scale = 3.0
                                            lastScale = 3.0
                                        }
                                    }
                                },
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1.0 {
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            if scale == 1.0 {
                                scale = 2.0
                                lastScale = 2.0
                            } else {
                                scale = 1.0
                                lastScale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                    }
            }
            .navigationTitle("Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ReminderViewModel())
    }
}
