//
//  OpenAIService.swift
//  CartoonGan
//
//  Created by Ping9 on 10/02/2023.
//

import Foundation
import OpenAIKit
import UIKit
import AsyncHTTPClient

class OpenAIModel {

    weak var delegate: ModelDelegate?
    var httpClient: HTTPClient
    var configuration: Configuration
    var openAIClient: OpenAIKit.Client

    private let queue = DispatchQueue(label: "com.go.openai.serial")

    init() {
        let apiKey: String =
            ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!


        let organization: String =
            ProcessInfo.processInfo.environment["OPENAI_ORGANIZATION"]!

        self.httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        self.configuration = Configuration(apiKey: apiKey, organization: organization)

        self.openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
    }
    func start() {

    }

    func process(_ image: UIImage) {
        queue.async {

            guard let data = image.pngData() else {
                print("Failed to retrieve cgImage")
                self.delegate?.model(self, didFailedProcessing: .preprocess)
                return
            }
            Task {
                await self.postprocess(data: data) { image in
                    if let image = image {
                        self.delegate?.model(self, didFinishProcessing: image)
                    } else {
                        self.delegate?.model(self, didFailedProcessing: .postprocess)
                    }
                }
            }

        }
    }

    private func postprocess(
        data: Data, completion: @escaping ((UIImage?) -> Void)) async {
        do {
            let image: ImageResponse = try await openAIClient.images.createVariation(
                image: data,
                n: 1,
                size: .twoFiftySix
            )
            if let image = image.data.first?.url {
                if let url = URL(string: image) {
                    downloadImage(from: url, completion: completion)
                    return
                }
            }
        } catch {

        }
        completion(nil)

    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    func downloadImage(from url: URL, completion: @escaping ((UIImage?) -> Void)) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }
    }
}
