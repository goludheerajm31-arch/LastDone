import SwiftUI

/// Minimal detail view displaying the activity name, large relative time, exact completion date,
/// and the primary "Done Today" action.
struct ActivityDetailView: View {
    let activityId: UUID

    @EnvironmentObject private var store: ActivityStore
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingEditSheet = false
    @State private var feedbackTrigger = 0

    private var activity: Activity? {
        store.activities.first(where: { $0.id == activityId })
    }

    var body: some View {
        Group {
            if let activity {
                VStack(spacing: 32) {
                    Spacer()

                    // Core Information
                    VStack(spacing: 12) {
                        Text(activity.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)

                        Text(RelativeDateFormatter.relativeString(for: activity.lastCompletedAt))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(.primary)

                        Text("Last completed: \(RelativeDateFormatter.exactDateString(for: activity.lastCompletedAt))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Primary Action
                    Button {
                        withAnimation(.snappy(duration: 0.15)) {
                            store.markDoneToday(id: activity.id)
                            feedbackTrigger += 1
                        }
                    } label: {
                        Text("Done Today")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .sensoryFeedback(.success, trigger: feedbackTrigger)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") {
                            isShowingEditSheet = true
                        }
                    }
                }
                .sheet(isPresented: $isShowingEditSheet) {
                    ActivityEditSheet(mode: .edit(activity))
                }
            } else {
                // Activity was deleted, automatically dismiss
                Color.clear
                    .onAppear {
                        dismiss()
                    }
            }
        }
    }
}

struct ActivityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let store = ActivityStore.preview
            ActivityDetailView(activityId: store.activities[0].id)
                .environmentObject(store)
        }
    }
}
