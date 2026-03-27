import SwiftUI

struct ScriptEditorView: View {
    @Environment(ScriptStorage.self) private var storage
    @State private var editText: String = ""
    @State private var editTitle: String = "Untitled"
    @State private var showFileImporter = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Script title", text: $editTitle)
                    .textFieldStyle(.plain)
                    .font(.title2.bold())
                    .padding(.horizontal)

                Spacer()

                Button("Open File...") {
                    showFileImporter = true
                }

                Button("Save") {
                    let script = Script(title: editTitle, body: editText)
                    storage.currentScript = script
                    storage.save(script: script)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .padding(.vertical, 12)

            Divider()

            TextEditor(text: $editText)
                .font(.system(.body, design: .monospaced))
                .padding(8)
        }
        .frame(minWidth: 400, minHeight: 400)
        .onAppear {
            if let script = storage.currentScript {
                editText = script.body
                editTitle = script.title
            }
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.plainText, .text],
            allowsMultipleSelection: false
        ) { result in
            guard case .success(let urls) = result,
                  let url = urls.first else { return }

            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            if let content = try? String(contentsOf: url, encoding: .utf8) {
                editText = content
                editTitle = url.deletingPathExtension().lastPathComponent
            }
        }
    }
}
