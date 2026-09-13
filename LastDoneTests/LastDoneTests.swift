import XCTest
@testable import LastDone

final class LastDoneTests: XCTestCase {
    var calendar: Calendar!
    var referenceDate: Date!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current

        // Use a fixed reference date for deterministic testing
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 13
        components.hour = 12
        components.minute = 0
        components.second = 0
        referenceDate = calendar.date(from: components)!
    }

    // MARK: - RelativeDateFormatter Tests

    func testRelativeDate_Today() {
        let completionDate = referenceDate!
        let result = RelativeDateFormatter.relativeString(for: completionDate, relativeTo: referenceDate, calendar: calendar)
        XCTAssertEqual(result, "Today")
    }

    func testRelativeDate_Yesterday() {
        let completionDate = calendar.date(byAdding: .day, value: -1, to: referenceDate)!
        let result = RelativeDateFormatter.relativeString(for: completionDate, relativeTo: referenceDate, calendar: calendar)
        XCTAssertEqual(result, "Yesterday")
    }

    func testRelativeDate_ExamplesFromPrompt() {
        // Bedsheets — 6 days ago
        let bedsheets = calendar.date(byAdding: .day, value: -6, to: referenceDate)!
        XCTAssertEqual(
            RelativeDateFormatter.relativeString(for: bedsheets, relativeTo: referenceDate, calendar: calendar),
            "6 days ago"
        )

        // Clean shoes — 12 days ago
        let shoes = calendar.date(byAdding: .day, value: -12, to: referenceDate)!
        XCTAssertEqual(
            RelativeDateFormatter.relativeString(for: shoes, relativeTo: referenceDate, calendar: calendar),
            "12 days ago"
        )

        // Haircut — 18 days ago
        let haircut = calendar.date(byAdding: .day, value: -18, to: referenceDate)!
        XCTAssertEqual(
            RelativeDateFormatter.relativeString(for: haircut, relativeTo: referenceDate, calendar: calendar),
            "18 days ago"
        )

        // Change toothbrush — 71 days ago
        let toothbrush = calendar.date(byAdding: .day, value: -71, to: referenceDate)!
        XCTAssertEqual(
            RelativeDateFormatter.relativeString(for: toothbrush, relativeTo: referenceDate, calendar: calendar),
            "71 days ago"
        )
    }

    func testExactDateFormatter() {
        let exactString = RelativeDateFormatter.exactDateString(for: referenceDate)
        XCTAssertFalse(exactString.isEmpty)
        XCTAssertTrue(exactString.contains("2026"))
    }

    // MARK: - ActivityStore Tests

    func testActivityStore_AddUpdateDelete() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let store = ActivityStore(fileURL: tempURL)
        XCTAssertTrue(store.activities.isEmpty)

        // 1. Add
        let activity = store.add(name: "Haircut", lastCompletedAt: calendar.date(byAdding: .day, value: -18, to: Date())!)
        XCTAssertEqual(store.activities.count, 1)
        XCTAssertEqual(store.activities.first?.name, "Haircut")

        // 2. Mark Done Today
        store.markDoneToday(id: activity.id)
        let updatedActivity = store.activities.first!
        XCTAssertEqual(RelativeDateFormatter.relativeString(for: updatedActivity.lastCompletedAt), "Today")

        // 3. Update
        let newDate = calendar.date(byAdding: .day, value: -5, to: Date())!
        store.update(id: activity.id, name: "Haircut & Beard", lastCompletedAt: newDate)
        XCTAssertEqual(store.activities.first?.name, "Haircut & Beard")
        XCTAssertEqual(store.activities.first?.lastCompletedAt, newDate)

        // 4. Persistence Reload
        store.flush()
        let newStore = ActivityStore(fileURL: tempURL)
        XCTAssertEqual(newStore.activities.count, 1)
        XCTAssertEqual(newStore.activities.first?.name, "Haircut & Beard")

        // 5. Delete
        store.delete(id: activity.id)
        XCTAssertTrue(store.activities.isEmpty)

        store.flush()
        let reloadedStore = ActivityStore(fileURL: tempURL)
        XCTAssertTrue(reloadedStore.activities.isEmpty)
    }
}
