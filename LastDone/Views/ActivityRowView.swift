import SwiftUI

/// Renders a single activity row showing the activity name and its relative completion time.
struct ActivityRowView: View, Equatable {
    let activity: Activity

    static func == (lhs: ActivityRowView, rhs: ActivityRowView) -> Bool {
        lhs.activity == rhs.activity
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(activity.name)
                .font(.body)
                .foregroundStyle(.primary)

            Text(RelativeDateFormatter.relativeString(for: activity.lastCompletedAt))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ActivityRowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRowView(
            activity: Activity(
                name: "Haircut",
                lastCompletedAt: Calendar.current.date(byAdding: .day, value: -18, to: Date()) ?? Date()
            )
        )
        .padding()
    }
}
