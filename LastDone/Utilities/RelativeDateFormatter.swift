import Foundation

/// Provides clean, native formatting for relative and absolute completion dates.
enum RelativeDateFormatter {
    /// Formats the time elapsed since the given completion date.
    ///
    /// Examples:
    /// - 0 days: "Today"
    /// - 1 day: "Yesterday"
    /// - 18 days: "18 days ago"
    /// - 71 days: "71 days ago"
    private static let defaultCalendar = Calendar.autoupdatingCurrent

    static func relativeString(for date: Date, relativeTo now: Date = Date(), calendar: Calendar = defaultCalendar) -> String {
        let startOfCompletion = calendar.startOfDay(for: date)
        let startOfNow = calendar.startOfDay(for: now)
        let days = calendar.dateComponents([.day], from: startOfCompletion, to: startOfNow).day ?? 0

        if days <= 0 {
            return "Today"
        } else if days == 1 {
            return "Yesterday"
        } else {
            return "\(days) days ago"
        }
    }

    /// Formats the completion date for display in the detail view.
    /// Example: "September 13, 2026"
    static func exactDateString(for date: Date) -> String {
        date.formatted(date: .long, time: .omitted)
    }
}
