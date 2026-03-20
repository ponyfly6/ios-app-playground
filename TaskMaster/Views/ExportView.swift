import SwiftUI
import SwiftData

struct ExportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    @Query(sort: \TaskCategory.name) private var categories: [TaskCategory]

    @State private var selectedFormat: ExportFormat = .json
    @State private var isExporting = false
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    @State private var errorMessage: String?
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            Form {
                formatSection
                infoSection
                exportButton
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fileExporter(
                isPresented: $showingShareSheet,
                document: exportedFileURL.map { FileDocument(fileURL: $0) },
                contentType: .data,
                defaultFilename: ExportManager.shared.generateFilename(for: selectedFormat)
            ) { result in
                switch result {
                case .success(let url):
                    print("File exported to: \(url)")
                case .failure(let error):
                    errorMessage = "Failed to export file: \(error.localizedDescription)"
                    showingError = true
                }
            }
            .alert("Export Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }

    // MARK: - Sections

    private var formatSection: some View {
        Section("Export Format") {
            Picker("Format", selection: $selectedFormat) {
                ForEach(ExportFormat.allCases) { format in
                    Label(format.rawValue, systemImage: formatIcon(for: format))
                        .tag(format)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var infoSection: some View {
        Section("Data Summary") {
            infoRow(title: "Tasks", value: "\(tasks.count)")
            infoRow(title: "Categories", value: "\(categories.count)")
            infoRow(title: "Subtasks", value: "\(totalSubTasks)")
            infoRow(title: "Completed Tasks", value: "\(completedTasksCount)")
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private var exportButton: some View {
        Section {
            Button {
                exportData()
            } label: {
                HStack {
                    Spacer()
                    if isExporting {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Label("Export", systemImage: "square.and.arrow.up")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
            }
            .disabled(isExporting || tasks.isEmpty)
        } header: {
            if tasks.isEmpty {
                Text("No data to export")
            }
        } footer: {
            Text("Your data will be exported as a file that you can save or share.")
        }
    }

    // MARK: - Helpers

    private func formatIcon(for format: ExportFormat) -> String {
        switch format {
        case .json: return "doc.text"
        case .csv: return "tablecells"
        }
    }

    private var totalSubTasks: Int {
        tasks.reduce(0) { $0 + $1.subTasks.count }
    }

    private var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }

    // MARK: - Actions

    private func exportData() {
        isExporting = true

        Task {
            do {
                let data: Data
                switch selectedFormat {
                case .json:
                    data = try ExportManager.shared.exportToJSON(tasks: tasks, categories: categories)
                case .csv:
                    data = try ExportManager.shared.exportToCSV(tasks: tasks, categories: categories)
                }

                let filename = ExportManager.shared.generateFilename(for: selectedFormat)
                let tempDir = FileManager.default.temporaryDirectory
                let fileURL = tempDir.appendingPathComponent(filename)

                try data.write(to: fileURL)

                await MainActor.run {
                    exportedFileURL = fileURL
                    isExporting = false
                    showingShareSheet = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isExporting = false
                    showingError = true
                }
            }
        }
    }
}

// MARK: - File Document

struct FileDocument: FileDocument {
    var fileURL: URL

    static var readableContentTypes: [UTType] { [.data] }

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    init(configuration: ReadConfiguration) throws {
        guard let fileURL = configuration.file else {
            throw CocoaError(.fileNoSuchFile)
        }
        self.fileURL = fileURL
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: fileURL)
    }

    func read(configuration: ReadConfiguration) throws {
        // Not needed for export-only use
    }
}

#Preview {
    ExportView()
        .modelContainer(for: [TaskItem.self, TaskCategory.self, SubTask.self], inMemory: true)
}
