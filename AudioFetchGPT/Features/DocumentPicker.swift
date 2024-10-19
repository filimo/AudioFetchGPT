//
//  DocumentPicker.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 19.10.24.
//
import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var textFiles: [String] // Массив для хранения содержимого файлов
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Теперь мы выбираем именно файлы, а не папки
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.plainText], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Фильтруем файлы с расширением .txt и читаем их содержимое
            parent.textFiles = []
            for url in urls.filter({ $0.pathExtension == "txt" }) {
                do {
                    let content = try String(contentsOf: url, encoding: .utf8)
                    parent.textFiles.append(content) // Добавляем содержимое файла в массив
                } catch {
                    print("Ошибка чтения файла: \(error.localizedDescription)")
                }
            }
        }
    }
}
