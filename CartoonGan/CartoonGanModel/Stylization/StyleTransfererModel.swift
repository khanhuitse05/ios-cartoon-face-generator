//
//  StyleTransfererModel.swift
//  StyleTransferer
//
//  Created by Ping9 on 11/02/2023.
//

import Foundation
import UIKit
import os

// MARK: - StyleTransfererModel
final class StyleTransfererModel {

    // MARK: - Properties

    weak var delegate: ModelDelegate?

    /// Style transferer instance reponsible for running the TF model. Uses a Float16-based model and
    /// runs inference on the GPU.
    private var transferer: StyleTransferer?

    /// Style-representative image applied to the input image to create a pastiche.
    private var styleImage: UIImage?

    func start() {
        self.styleImage = UIImage(named: "style11")
        StyleTransferer.newCPUStyleTransferer { result in
            switch result {
            case .success(let transferer):
                self.transferer = transferer
            case .error(let wrappedError):
                print("Failed to initialize: \(wrappedError)")
            }
        }
    }
    func process(_ image: UIImage) {

        // Make sure that the style transferer is initialized.
        guard let styleTransferer = transferer else {
            delegate?.model(self, didFailedProcessing: .allocation)
            return
        }

        guard let styleImage = styleImage else {
            delegate?.model(self, didFailedProcessing: .preprocess)
            return
        }

        // 🍉 Run style transfer.
        print("Start post-processing 🍉")
        styleTransferer.runStyleTransfer(
            style: styleImage,
            image: image,
            completion: { result in
                // Show the result on screen
                switch result {
                case let .success(styleTransferResult):
                    print("Finished processing image!")
                    self.delegate?.model(self, didFinishProcessing: styleTransferResult.resultImage)
                case .error(_):
                    print("Could not retrieve output image")
                    self.delegate?.model(self, didFailedProcessing: .postprocess)
                }
            })
    }
}
