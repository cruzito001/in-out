//
//  LoginView.swift
//  in-out
//
//  Created by Alan Joel Cruz Ortega on 29/08/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
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
            
            VStack(spacing: 40) {
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
                }
                .padding(.horizontal, 36)
                
                Spacer()
                Spacer()
            }
        }
    }
    
    private func loginAction() {
        
    }
}

#Preview {
    LoginView()
}
