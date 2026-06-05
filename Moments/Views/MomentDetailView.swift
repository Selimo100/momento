import SwiftUI
import SwiftData
import PhotosUI
import Photos

struct MomentDetailView: View {
    let moment: Moment

    @Environment(\.modelContext) private var context
    @AppStorage("albumPrefix") private var albumPrefix = "Momento –"

    @State private var viewModel = MomentDetailViewModel()
    @State private var showEditSheet = false
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                coverSection
                    .padding(.bottom, 20)

                infoSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                photoSection
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Edit Moment", systemImage: "pencil")
                    }
                    Button {
                        prepareExport()
                    } label: {
                        Label("Export to Photos", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            MomentFormView(mode: .edit(moment))
        }
        .photosPicker(
            isPresented: $viewModel.showingPhotoPicker,
            selection: $viewModel.photoPickerItems,
            maxSelectionCount: 100,
            matching: .images
        )
        .onChange(of: viewModel.photoPickerItems) { _, items in
            guard !items.isEmpty else { return }
            Task {
                await viewModel.loadPickerItems(items, into: moment, context: context)
                viewModel.photoPickerItems = []
            }
        }
        .sheet(isPresented: $viewModel.showingExportSheet) {
            ExportSheetView(
                moment: moment,
                albumName: $viewModel.exportAlbumName,
                isExporting: viewModel.isExporting,
                onExport: { scope in
                    Task { await viewModel.export(moment: moment, scope: scope) }
                },
                onCancel: { viewModel.showingExportSheet = false }
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showingPhotoDetail) {
            if let photo = viewModel.selectedPhoto {
                PhotoDetailView(
                    photo: photo,
                    moment: moment,
                    onFavoriteToggle: {
                        viewModel.toggleFavorite(photo, in: moment, context: context)
                    },
                    onSetCover: {
                        viewModel.setCover(photo, in: moment, context: context)
                    },
                    onRemove: {
                        viewModel.removePhoto(photo, from: moment, context: context)
                        viewModel.showingPhotoDetail = false
                    }
                )
            }
        }
        .alert("Export Result", isPresented: $viewModel.showExportResult) {
            Button("OK") {}
        } message: {
            Text(viewModel.exportResultMessage ?? "")
        }
        .alert("Photo Access", isPresented: $showPermissionAlert) {
            Button("Open Settings") { PermissionHelpers.openAppSettings() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(permissionMessage)
        }
    }

    // MARK: Cover

    private var coverSection: some View {
        ZStack(alignment: .bottom) {
            if let cover = moment.coverPhoto {
                AssetThumbnailView(
                    localIdentifier: cover.localIdentifier,
                    targetSize: CGSize(width: 800, height: 500)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipped()
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemGray5), Color(.systemGray4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 280)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 44, weight: .light))
                                .foregroundStyle(.tertiary)
                            Text("No Cover Photo")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.45)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 280)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(moment.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Text(moment.date.momentFormatted)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
    }

    // MARK: Info

    @ViewBuilder
    private var infoSection: some View {
        if !moment.momentDescription.isEmpty {
            HStack {
                Text(moment.momentDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.top, 4)
        }
    }

    // MARK: Photos

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photos")
                    .font(.headline)
                Spacer()
                if moment.favoriteCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.pink)
                        Text("\(moment.favoriteCount)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                Button {
                    checkPermissionsAndAddPhotos()
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .padding(8)
                        .background(Color(.tertiarySystemGroupedBackground), in: Circle())
                }
            }
            .padding(.horizontal, 20)

            if moment.photos.isEmpty {
                emptyPhotosState
                    .padding(.top, 20)
            } else {
                PhotoGridView(
                    photos: moment.photos,
                    coverPhotoId: moment.coverPhotoId
                ) { photo in
                    viewModel.selectedPhoto = photo
                    viewModel.showingPhotoDetail = true
                }
                .padding(.bottom, 32)
            }
        }
    }

    private var emptyPhotosState: some View {
        VStack(spacing: 16) {
            EmptyStateView(
                icon: "photo.badge.plus",
                title: "No Photos Yet",
                message: "Add photos from your library to this moment.",
                actionTitle: "Add Photos"
            ) {
                checkPermissionsAndAddPhotos()
            }
        }
        .padding(.vertical, 32)
    }

    // MARK: Actions

    private func checkPermissionsAndAddPhotos() {
        let status = PhotoLibraryService.shared.authorizationStatus
        switch status {
        case .denied, .restricted:
            permissionMessage = PermissionHelpers.photoLibraryAccessDescription
            showPermissionAlert = true
        case .notDetermined:
            Task {
                let granted = await PhotoLibraryService.shared.requestAuthorization()
                if granted == .authorized || granted == .limited {
                    viewModel.showingPhotoPicker = true
                } else {
                    permissionMessage = PermissionHelpers.photoLibraryAccessDescription
                    showPermissionAlert = true
                }
            }
        default:
            viewModel.showingPhotoPicker = true
        }
    }

    private func prepareExport() {
        guard !moment.photos.isEmpty else {
            viewModel.exportResultMessage = "This moment has no photos to export."
            viewModel.showExportResult = true
            return
        }
        viewModel.exportAlbumName = viewModel.defaultAlbumName(for: moment, prefix: albumPrefix)
        viewModel.showingExportSheet = true
    }
}
