//
//  SystemPrompt.swift
//  AudioFetchGPT
//
//  Created by Viktor Kushnerov on 28.10.24.
//
import SwiftUI

struct SystemPromptPicker: View {
    @Binding var showSystemPromptPicker: Bool
    @ObservedObject var conversationWebViewModel: ConversationWebViewModel

    @AppStorage("systemPrompts") private var systemPromptsData: String = "[]"
    @State private var systemPrompts: [SystemPromptModel] = []
    
    @State private var newPromptValue: String = ""
    @State private var editingPrompt: SystemPromptModel? = nil
    @State private var editedPromptValue: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter a new prompt", text: $newPromptValue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                    
                    Button(action: addPrompt) {
                        Text("Add")
                    }
                    .padding(.trailing)
                }
                .padding(.vertical)
                
                List {
                    Text("None")
                        .font(.headline)
                        .padding(.vertical, 5)
                        .onTapGesture {
                            conversationWebViewModel.systemPrompt = ""
                            showSystemPromptPicker = false
                        }
                    
                    ForEach(systemPrompts) { prompt in
                        Text(prompt.value)
                            .font(.headline)
                            .padding(.vertical, 5)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deletePrompt(prompt)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    startEditing(prompt)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .onTapGesture {
                                conversationWebViewModel.systemPrompt = "\(prompt.value)\n\n\n"
                                showSystemPromptPicker = false
                            }
                    }
                    .onMove(perform: movePrompt)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("System Prompts")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .onAppear(perform: loadPrompts)
            .onChange(of: systemPrompts) { _, _ in
                savePrompts()
            }
            .sheet(item: $editingPrompt) { prompt in
                VStack {
                    TextEditor(text: $editedPromptValue)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding()
                    
                    HStack {
                        Button("Cancel") {
                            editingPrompt = nil
                            editedPromptValue = ""
                        }
                        .padding()
                        
                        Spacer()
                        
                        Button("Save Changes") {
                            updatePrompt(prompt)
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Functions for managing prompts
    
    // Load prompts from AppStorage
    private func loadPrompts() {
        if let data = systemPromptsData.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([SystemPromptModel].self, from: data)
        {
            systemPrompts = decoded
        }
    }
    
    // Save prompts to AppStorage
    private func savePrompts() {
        if let encoded = try? JSONEncoder().encode(systemPrompts),
           let jsonString = String(data: encoded, encoding: .utf8)
        {
            systemPromptsData = jsonString
        }
    }
    
    // Add a new prompt
    private func addPrompt() {
        let trimmedValue = newPromptValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return }
        
        let newPrompt = SystemPromptModel(value: trimmedValue)
        systemPrompts.append(newPrompt)
        newPromptValue = ""
    }
    
    // Delete a prompt
    private func deletePrompt(_ prompt: SystemPromptModel) {
        if let index = systemPrompts.firstIndex(of: prompt) {
            systemPrompts.remove(at: index)
        }
    }
    
    // Start editing a prompt
    private func startEditing(_ prompt: SystemPromptModel) {
        editingPrompt = prompt
        editedPromptValue = prompt.value
    }
    
    // Update a prompt after editing
    private func updatePrompt(_ prompt: SystemPromptModel) {
        guard let index = systemPrompts.firstIndex(of: prompt) else { return }
        let trimmedValue = editedPromptValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return }
        
        systemPrompts[index].value = trimmedValue
        editingPrompt = nil
        editedPromptValue = ""
    }
    
    // Move prompts in the list
    private func movePrompt(from source: IndexSet, to destination: Int) {
        systemPrompts.move(fromOffsets: source, toOffset: destination)
    }
}
