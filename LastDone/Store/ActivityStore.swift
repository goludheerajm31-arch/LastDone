import Foundation
import Combine
import SwiftUI

/// Manages the collection of activities, handling local persistence and updates.
final class ActivityStore: ObservableObject {
    @Published var activities: [Activity] = []

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.fileURL = directory.appendingPathComponent("activities.json")
        }
        load()
    }

    // MARK: - CRUD Operations

    /// Creates and persists a new activity.
    @discardableResult
    func add(name: String, lastCompletedAt: Date = Date()) -> Activity {
        let newActivity = Activity(name: name, lastCompletedAt: lastCompletedAt)
        activities.append(newActivity)
        save()
        return newActivity
    }

    /// Updates an existing activity.
    func update(id: UUID, name: String, lastCompletedAt: Date) {
        guard let index = activities.firstIndex(where: { $0.id == id }) else { return }
        activities[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        activities[index].lastCompletedAt = lastCompletedAt
        save()
    }

    /// Marks the activity as completed today with the current date/time.
    func markDoneToday(id: UUID) {
        guard let index = activities.firstIndex(where: { $0.id == id }) else { return }
        activities[index].lastCompletedAt = Date()
        save()
    }

    /// Deletes an activity by ID.
    func delete(id: UUID) {
        activities.removeAll { $0.id == id }
        save()
    }

    /// Deletes activities at the given index set (used in SwiftUI List .onDelete).
    func delete(at offsets: IndexSet) {
        activities.remove(atOffsets: offsets)
        save()
    }

    private let saveQueue = DispatchQueue(label: "com.lastdone.storage", qos: .utility)

    // MARK: - Local Persistence

    /// Loads activities from local disk.
    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([Activity].self, from: data)
            self.activities = decoded
        } catch {
            print("Failed to load activities: \(error.localizedDescription)")
        }
    }

    /// Saves activities to local disk asynchronously on a background thread to keep the UI at 120 FPS.
    func save() {
        let snapshot = activities
        let destination = fileURL
        saveQueue.async {
            do {
                let data = try JSONEncoder().encode(snapshot)
                try data.write(to: destination, options: [.atomic])
            } catch {
                print("Failed to save activities: \(error.localizedDescription)")
            }
        }
    }

    /// Flushes any pending background saves to disk (useful for synchronization and testing).
    func flush() {
        saveQueue.sync {}
    }
}

// MARK: - Preview Support

extension ActivityStore {
    /// In-memory store populated with sample activities for SwiftUI Previews.
    static var preview: ActivityStore {
        let store = ActivityStore(fileURL: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        let calendar = Calendar.current
        let today = Date()

        let haircutDate = calendar.date(byAdding: .day, value: -18, to: today) ?? today
        let bedsheetsDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        let cleanShoesDate = calendar.date(byAdding: .day, value: -12, to: today) ?? today
        let toothbrushDate = calendar.date(byAdding: .day, value: -71, to: today) ?? today

        store.activities = [
            Activity(name: "Haircut", lastCompletedAt: haircutDate),
            Activity(name: "Bedsheets", lastCompletedAt: bedsheetsDate),
            Activity(name: "Clean shoes", lastCompletedAt: cleanShoesDate),
            Activity(name: "Change toothbrush", lastCompletedAt: toothbrushDate)
        ]
        return store
    }
}
