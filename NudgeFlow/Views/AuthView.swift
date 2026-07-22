import SwiftUI
import UIKit

struct AuthView: View {
    @Bindable var auth: AuthModel
    @Bindable var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var mode: AuthMode = .signUp
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                NFTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        configWarning
                        authFields
                        actionButton
                        modeSwitch
                    }
                    .padding(22)
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(NFTheme.accent)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            displayName = model.displayName
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppMark(size: 58)
            Text(mode.title)
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(NFTheme.text)
            Text("Sync fasting, consumption logs, water intake, and future insights across devices and the admin portal.")
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundStyle(NFTheme.secondaryText)
        }
    }

    @ViewBuilder
    private var configWarning: some View {
        if !auth.isConfigured {
            Text("Supabase is not configured yet. Add your project URL and anon key in SupabaseConfig.swift before signing in.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(NFTheme.accentTwo)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(NFTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var authFields: some View {
        VStack(spacing: 12) {
            if mode == .signUp {
                AccountTextField(title: "Name", text: $displayName, contentType: .name)
            }
            AccountTextField(title: "Email", text: $email, contentType: .emailAddress)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            AccountTextField(title: "Password", text: $password, contentType: .password, secure: true)

            if let error = auth.errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(NFTheme.destructive)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var actionButton: some View {
        Button {
            Task {
                if mode == .signUp {
                    await auth.signUp(email: email, password: password, displayName: displayName, appModel: model)
                } else {
                    await auth.signIn(email: email, password: password, appModel: model)
                }
                if auth.isSignedIn {
                    dismiss()
                }
            }
        } label: {
            HStack {
                if auth.isWorking {
                    ProgressView()
                        .tint(.white)
                }
                Text(auth.isWorking ? "Working..." : mode.buttonTitle)
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(NFTheme.gradient)
            .clipShape(Capsule())
        }
        .disabled(auth.isWorking || !auth.isConfigured || email.isEmpty || password.count < 6)
        .opacity(auth.isWorking || !auth.isConfigured || email.isEmpty || password.count < 6 ? 0.55 : 1)
        .buttonStyle(.plain)
    }

    private var modeSwitch: some View {
        Button {
            auth.errorMessage = nil
            mode = mode == .signUp ? .signIn : .signUp
        } label: {
            Text(mode.switchTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(NFTheme.accent)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private enum AuthMode {
    case signUp
    case signIn

    var title: String { self == .signUp ? "Create your account" : "Welcome back" }
    var buttonTitle: String { self == .signUp ? "Create Account" : "Sign In" }
    var switchTitle: String { self == .signUp ? "I already have an account" : "Create a new account" }
}

private struct AccountTextField: View {
    let title: String
    @Binding var text: String
    var contentType: UITextContentType?
    var secure = false

    var body: some View {
        Group {
            if secure {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
            }
        }
        .textContentType(contentType)
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(NFTheme.text)
        .padding(16)
        .background(NFTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
