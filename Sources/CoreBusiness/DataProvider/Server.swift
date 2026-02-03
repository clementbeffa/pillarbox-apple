//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A server environment.
public enum Server {
    /// Production.
    case production

    /// Stage.
    case stage

    /// Test.
    case test

    /// Custom.
    case custom(baseURL: String, headers: [String: String] = [:])

#if os(iOS)
    private static let vector = "appplay"
#else
    private static let vector = "tvplay"
#endif

    var baseUrl: URL {
        switch self {
        case .production:
            URL(string: "https://il.srgssr.ch")!
        case .stage:
            URL(string: "https://il-stage.srgssr.ch")!
        case .test:
            URL(string: "https://il-test.srgssr.ch")!
        case .custom(let baseURL, _):
            URL(string: baseURL)!
        }
    }

    func mediaCompositionRequest(forUrn urn: String) -> URLRequest {
        let url = baseUrl.appending(path: "integrationlayer/2.1/mediaComposition/byUrn/\(urn)")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .init(url: url)
        }
        components.queryItems = [
            URLQueryItem(name: "onlyChapters", value: "true"),
            URLQueryItem(name: "vector", value: Self.vector)
        ]
        var request = URLRequest.init(url: components.url ?? url)
        if case .custom(_, let headers) = self, headers.isEmpty == false {
            headers.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }

    func resizedImageUrl(_ url: URL, width: ImageWidth) -> URL {
        guard var components = URLComponents(
            url: baseUrl.appending(path: "images/"),
            resolvingAgainstBaseURL: false
        ) else {
            return url
        }
        components.queryItems = [
            URLQueryItem(name: "imageUrl", value: url.absoluteString),
            URLQueryItem(name: "format", value: "jpg"),
            URLQueryItem(name: "width", value: String(width.rawValue))
        ]
        if let scaledUrl = components.url {
            return scaledUrl
        }
        else {
            return url
        }
    }
}
