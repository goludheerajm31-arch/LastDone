import SwiftUI

/// The main home screen displaying the list of tracked activities.
struct ActivityListView: View {
    @EnvironmentObject private var store: ActivityStore

    private enum SheetDestination: Identifiable {
        case create
        case edit(Activity)

        var id: String {
            switch self {
            case .create: return "create"
            case .edit(let activity): return "edit-\(activity.id)"
            }
        }
    }

    @State private var activeSheet: SheetDestination?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.activities) { activity in
                    NavigationLink(value: activity.id) {
                        ActivityRowView(activity: activity)
                            .equatable()
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            withAnimation(.snappy(duration: 0.15)) {
                                store.markDoneToday(id: activity.id)
                            }
                        } label: {
                            Label("Done Today", systemImage: "checkmark")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation(.snappy(duration: 0.15)) {
                                store.delete(id: activity.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .contextMenu {
                        Button {
                            withAnimation(.snappy(duration: 0.15)) {
                                store.markDoneToday(id: activity.id)
                            }
                        } label: {
                            Label("Done Today", systemImage: "checkmark")
                        }

                        Button {
                            activeSheet = .edit(activity)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            withAnimation(.snappy(duration: 0.15)) {
                                store.delete(id: activity.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete { indexSet in
                    withAnimation(.snappy(duration: 0.15)) {
                        store.delete(at: indexSet)
                    }
                }
            }
            .navigationTitle("LastDone")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        activeSheet = .create
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: UUID.self) { activityId in
                ActivityDetailView(activityId: activityId)
            }
            .sheet(item: $activeSheet) { destination in
                switch destination {
                case .create:
                    ActivityEditSheet(mode: .create)
                case .edit(let activity):
                    ActivityEditSheet(mode: .edit(activity))
                }
            }
        }
    }
}

struct ActivityListView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityListView()
            .environmentObject(ActivityStore.preview)
    }
}
