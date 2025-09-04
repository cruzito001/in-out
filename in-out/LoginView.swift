//
//  LoginView.swift
//  in-out
//
//  Created by Alan Joel Cruz Ortega on 29/08/25.
//

import SwiftUI

struct LoginView: View {
    @Binding var showingRegister: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isAuthenticating = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @StateObject private var authManager = AuthenticationManager()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGroupedBackground),
                    Color(.secondarySystemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Image("logoApp")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                Text("Iniciar Sesión")
                    .font(.system(.largeTitle, design: .rounded, weight:
                            .bold))
                    .foregroundStyle(.primary)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                VStack(spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email")
                            .font(.system(.subheadline, design: .default, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        TextField("Ingresa tu email", text: $email)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .default))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Contraseña")
                            .font(.system(.subheadline, design: .default, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        SecureField("Ingresa tu contraseña", text: $password)
                            .textFieldStyle(.plain)
                            .font(.system(.body, design: .default))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .textContentType(.password)
                    }
                    
                    Button(action: loginAction) {
                        Text("Iniciar Sesión")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    }
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
                    
                    // "¿Olvidaste tu contraseña?
                    VStack {
                        Button(action: forgotPasswordAction) {
                            Text("¿Olvidaste tu contraseña?")
                                .font(.system(.footnote, design: .default, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, -15)
                    }
                    
                    // Nuevo Usuario
                    HStack(spacing: 4) {
                        Text("¿No tienes cuenta?")
                            .font(.system(.footnote, design: .default, weight: .regular))
                            .foregroundStyle(.secondary)
                        
                        Button(action: signUpAction) {
                            Text("Registrarse")
                                .font(.system(.footnote, design: .default, weight: .semibold))
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    // Línea coqueta separador
                    HStack {
                        Rectangle()
                            .fill(.quaternary)
                            .frame(height: 1)
                        
                        Text("o")
                            .font(.system(.caption, design: .default, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(.quaternary)
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Botón FaceID
                    Button(action: faceIDAction) {
                        HStack(spacing: 12) {
                            if isAuthenticating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.primary)
                            } else {
                                Image(systemName: getBiometricIcon())
                                    .font(.system(.title2, design: .default, weight: .medium))
                                    .foregroundStyle(.primary)
                            }
                            
                            Text(isAuthenticating ? "Autenticando..." : getBiometricButtonText())
                                .font(.system(.headline, design: .rounded, weight: .medium))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                    }
                    .background(
                        .thinMaterial,
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .disabled(isAuthenticating || !authManager.isBiometricAuthenticationAvailable())
                }
                .padding(.horizontal, 36)
                
                Spacer()
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loginAction() {
        
    }
    
    private func forgotPasswordAction() {
        // Aquí se implementará la lógica para recuperar contraseña
    }
    
    private func signUpAction() {
        showingRegister = true
    }
    
    private func faceIDAction() {
        guard authManager.isBiometricAuthenticationAvailable() else {
            showAlert(title: "Biometría no disponible", message: "La autenticación biométrica no está disponible en este dispositivo.")
            return
        }
        
        isAuthenticating = true
        
        Task {
            let result = await authManager.authenticateWithBiometrics()
            
            await MainActor.run {
                isAuthenticating = false
                
                switch result {
                case .success(let success):
                    if success {
                        // Autenticación exitosa
                        showAlert(title: "¡Éxito!", message: "Autenticación biométrica exitosa. Bienvenido a la aplicación.")
                        // Aquí puedes navegar a la siguiente pantalla o realizar la acción de login
                    }
                case .failure(let error):
                    showAlert(title: "Error de autenticación", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func getBiometricIcon() -> String {
        switch authManager.getBiometricType() {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock.fill"
        }
    }
    
    private func getBiometricButtonText() -> String {
        switch authManager.getBiometricType() {
        case .faceID:
            return "Iniciar con Face ID"
        case .touchID:
            return "Iniciar con Touch ID"
        case .none:
            return "Biometría no disponible"
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
}

#Preview {
    LoginView(showingRegister: .constant(false))
}
