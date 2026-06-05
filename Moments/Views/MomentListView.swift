import SwiftUI
import SwiftData

struct MomentListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Moment.createdAt, order: .reverse) private var moments: [Moment]

    @State private var viewModel = MomentListViewModel()
    @State private var momentToDelete: Moment?
    @State private var momentToEdit: Moment?
    @State private var showDeleteConfirmation = false
    @State private var navigateToNewMoment: Moment?

    var body: some View {
        NavigationStack {
            Group {
                if moments.isEmpty {
                    emptyState
                } else {
                    momentGrid
                }
            }
            .navigationTitle("Momento")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateSheet) {
                MomentFormView(mode: .create) { newMoment in
                    navigateToNewMoment = newMoment
                }
            }
            .sheet(item: $momentToEdit) { moment in
                MomentFormView(mode: .edit(moment))
            }
            .confirmationDialog("Delete Moment", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let moment = momentToDelete {
                        viewModel.deleteMoment(moment, context: context)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove the moment and all its photo references. Original photos in Apple Photos are not affected.")
            }
            .navigationDestination(item: $navigateToNewMoment) { moment in
                MomentDetailView(moment: moment)
            }
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "photo.on.rectangle.angled",
                title: "No Moments Yet",
                message: "Create your first moment to start collecting photos.",
                actionTitle: "Create a Moment"
            ) {
                viewModel.showingCreateSheet = true
            }
            Spacer()
        }
    }

    private var momentGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                spacing: 16
            ) {
                ForEach(moments) { moment in
                    NavigationLink(destination: MomentDetailView(moment: moment)) {
                        MomentCardView(moment: moment)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            momentToEdit = moment
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            momentToDelete = moment
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
    }
}
