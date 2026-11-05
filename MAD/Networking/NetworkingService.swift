//
//  NetworkingService.swift
//  MAD
//
//  Created by Fabian Gerö on 15.10.26.
//


import Foundation

final class NetworkingService {
    private let session = URLSession(configuration: .default)
    private let apiKey = "AIzaSyDeLs8S6Hpy642JUPC3Pft-xVx8Ocs-uXY"

    func login(
        email: String,
        password: String,
        completionHandler: @escaping @MainActor (User?, NetworkingError?) -> Void
    ) {
        guard let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(apiKey)") else {
            DispatchQueue.main.async {
                completionHandler(nil, .unexpected("The login URL is invalid."))
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            let description = error.localizedDescription
            DispatchQueue.main.async {
                completionHandler(nil, .serializationFailed(description))
            }
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
            let (user, networkingError) = NetworkingService.handleLoginResponse(data: data, response: response, error: error)

            DispatchQueue.main.async {
                completionHandler(user, networkingError)
            }
        }

        task.resume()
    }

    func fetchCountries(
        for user: User,
        completionHandler: @escaping @MainActor ([Country]?, NetworkingError?) -> Void
    ) {
        guard let url = URL(string: "https://firestore.googleapis.com/v1/projects/mad-fe/databases/(default)/documents/countries?pageSize=1000&orderBy=name") else {
            DispatchQueue.main.async {
                completionHandler(nil, .unexpected("The countries URL is invalid."))
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(user.idToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { data, response, error in
            let (countries, networkingError) = NetworkingService.handleCountriesResponse(data: data, response: response, error: error)

            DispatchQueue.main.async {
                completionHandler(countries, networkingError)
            }
        }

        task.resume()
    }

    nonisolated private static func handleLoginResponse(data: Data?, response: URLResponse?, error: Error?) -> (User?, NetworkingError?) {
        if let error = error as NSError? {
            return (nil, transportError(from: error))
        }

        guard let httpResponse = response as? HTTPURLResponse, let data else {
            return (nil, .invalidResponseFormat)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            return (nil, loginError(from: data, statusCode: httpResponse.statusCode))
        }

        guard let user = try? JSONDecoder().decode(User.self, from: data) else {
            return (nil, .invalidResponseFormat)
        }

        return (user, nil)
    }

    nonisolated private static func handleCountriesResponse(data: Data?, response: URLResponse?, error: Error?) -> ([Country]?, NetworkingError?) {
        if let error = error as NSError? {
            return (nil, transportError(from: error))
        }

        guard let httpResponse = response as? HTTPURLResponse, let data else {
            return (nil, .invalidResponseFormat)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            return (nil, countriesError(from: data, statusCode: httpResponse.statusCode))
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)

        guard let documentsContainer = try? decoder.decode(DocumentsContainer.self, from: data) else {
            return (nil, .invalidResponseFormat)
        }

        return (documentsContainer.documents, nil)
    }

    nonisolated private static func transportError(from error: NSError) -> NetworkingError {
        let offlineCodes = [
            NSURLErrorNotConnectedToInternet,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorDataNotAllowed
        ]

        if error.domain == NSURLErrorDomain, offlineCodes.contains(error.code) {
            return .offline(error.localizedDescription)
        }

        return .unexpected(error.localizedDescription)
    }

    nonisolated private static func countriesError(from data: Data, statusCode: Int) -> NetworkingError {
        guard let responseError = try? JSONDecoder().decode(FirestoreResponseError.self, from: data) else {
            return .serverError(statusCode: statusCode, message: nil)
        }

        switch responseError.error.status {
        case "UNAUTHENTICATED":
            return .unauthenticated
        case "PERMISSION_DENIED":
            return .permissionDenied
        default:
            return .serverError(statusCode: statusCode, message: responseError.error.message)
        }
    }

    nonisolated private static func loginError(from data: Data, statusCode: Int) -> NetworkingError {
        guard let responseError = try? JSONDecoder().decode(ResponseError.self, from: data) else {
            return .serverError(statusCode: statusCode, message: nil)
        }

        let message = responseError.error.message
        let errorCode = message.components(separatedBy: " : ").first ?? message

        switch errorCode {
        case "INVALID_EMAIL":
            return .invalidEmail
        case "EMAIL_NOT_FOUND":
            return .emailNotFound
        case "INVALID_PASSWORD":
            return .wrongPassword
        case "INVALID_LOGIN_CREDENTIALS":
            return .invalidCredentials
        default:
            return .serverError(statusCode: statusCode, message: message)
        }
    }
}
