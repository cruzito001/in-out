//
//  AuthenticationManager.swift
//  in-out
//
//  Created by Alan Cruz on 24/01/25.
//

import Foundation
import LocalAuthentication

class AuthenticationManager: ObservableObject {
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    enum AuthenticationError: Error, LocalizedError {
        case biometryNotAvailable
        case biometryNotEnrolled
        case biometryLockout
        case authenticationFailed
        case userCancel
        case userFallback
        case systemCancel
        case passcodeNotSet
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .biometryNotAvailable:
                return "La autenticación biométrica no está disponible en este dispositivo."
            case .biometryNotEnrolled:
                return "No hay datos biométricos registrados. Por favor, configura Face ID o Touch ID en Configuración."
            case .biometryLockout:
                return "La autenticación biométrica está bloqueada. Usa tu código de acceso para desbloquear."
            case .authenticationFailed:
                return "La autenticación falló. Por favor, inténtalo de nuevo."
            case .userCancel:
                return "Autenticación cancelada por el usuario."
            case .userFallback:
                return "El usuario eligió usar el código de acceso."
            case .systemCancel:
                return "Autenticación cancelada por el sistema."
            case .passcodeNotSet:
                return "No hay código de acceso configurado en el dispositivo."
            case .unknown:
                return "Ocurrió un error desconocido durante la autenticación."
            }
        }
    }
    
    private let context = LAContext()
    
    // MARK: - Public Methods
    
    /// Verifica si la autenticación biométrica está disponible
    func isBiometricAuthenticationAvailable() -> Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Obtiene el tipo de biometría disponible
    func getBiometricType() -> BiometricType {
        guard isBiometricAuthenticationAvailable() else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    /// Autentica al usuario usando biometría
    func authenticateWithBiometrics() async -> Result<Bool, AuthenticationError> {
        guard isBiometricAuthenticationAvailable() else {
            return .failure(.biometryNotAvailable)
        }
        
        let reason = "Verifica tu identidad para acceder a la aplicación"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return .success(success)
        } catch let error as LAError {
            return .failure(mapLAError(error))
        } catch {
            return .failure(.unknown)
        }
    }
    
    /// Autentica al usuario usando biometría o código de acceso
    func authenticateWithBiometricsOrPasscode() async -> Result<Bool, AuthenticationError> {
        let reason = "Verifica tu identidad para acceder a la aplicación"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            return .success(success)
        } catch let error as LAError {
            return .failure(mapLAError(error))
        } catch {
            return .failure(.unknown)
        }
    }
    
    // MARK: - Private Methods
    
    private func mapLAError(_ error: LAError) -> AuthenticationError {
        switch error.code {
        case .biometryNotAvailable:
            return .biometryNotAvailable
        case .biometryNotEnrolled:
            return .biometryNotEnrolled
        case .biometryLockout:
            return .biometryLockout
        case .authenticationFailed:
            return .authenticationFailed
        case .userCancel:
            return .userCancel
        case .userFallback:
            return .userFallback
        case .systemCancel:
            return .systemCancel
        case .passcodeNotSet:
            return .passcodeNotSet
        default:
            return .unknown
        }
    }
}