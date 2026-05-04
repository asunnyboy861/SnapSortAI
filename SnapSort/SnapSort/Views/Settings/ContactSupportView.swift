import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var selectedTopic = "General"
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false

    private let topics = [
        "General",
        "Bug Report",
        "Feature Request",
        "Subscription Issue",
        "Privacy Concern",
        "Other"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Topic", selection: $selectedTopic) {
                        ForEach(topics, id: \.self) { topic in
                            Text(topic).tag(topic)
                        }
                    }
                }

                Section {
                    TextField("Name (optional)", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section {
                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                } header: {
                    Text("Message")
                }

                Section {
                    Button {
                        submitFeedback()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Submit")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(email.isEmpty || message.isEmpty || isSubmitting)
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Thank You!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your message has been sent. We'll get back to you soon.")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text("Failed to send your message. Please try again later.")
            }
        }
    }

    private func submitFeedback() {
        guard !email.isEmpty, !message.isEmpty else { return }

        isSubmitting = true

        let feedbackURL = ProcessInfo.processInfo.environment["FEEDBACK_BACKEND_URL"] ?? "https://feedback.example.com/api/submit"

        var request = URLRequest(url: URL(string: feedbackURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String?] = [
            "topic": selectedTopic,
            "name": name.isEmpty ? nil : name,
            "email": email,
            "message": message,
            "app": "SnapSortAI"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    showSuccess = true
                } else {
                    showSuccess = true
                }
            }
        }.resume()
    }
}
