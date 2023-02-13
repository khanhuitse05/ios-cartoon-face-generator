import UIKit
import SwiftSpinner

final class ViewController: UIViewController {

    // MARK: - Properties

    private lazy var cartoonGanModel: CartoonGanModel = {
        let model = CartoonGanModel()
        model.delegate = self
        return model
    }()

    private lazy var openAIModel: OpenAIModel = {
        let model = OpenAIModel()
        model.delegate = self
        return model
    }()

    private lazy var styleTransfererModel: StyleTransfererModel = {
        let model = StyleTransfererModel()
        model.delegate = self
        return model
    }()

    private lazy var imagePickerController: ImagePickerController = {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()

    private var enabled: Bool = false {
        didSet {
            galleryButton.isEnabled = enabled
            cameraButton.isEnabled = enabled
        }
    }

    enum ServiceType: String {
        case openai = "Open AI"
        case cartoonGan = "Cartoon Gan"
        case styleTransferer = "Style Transferer"
    }

    var serviceType: ServiceType = .openai

    // MARK: - Views

    private lazy var spinner = UIActivityIndicatorView(style: .large)
    private lazy var mainView = MainView()
    private var cameraButton: UIButton { mainView.cameraButton }
    private var galleryButton: UIButton { mainView.galleryButton }
    private var styleButton: UIButton { mainView.styleButton }

    // MARK: - View Lifecycle

    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpinner()

        cameraButton.addTarget(
            self,
            action: #selector(cameraButtonTapped),
            for: .touchUpInside
        )
        galleryButton.addTarget(
            self,
            action: #selector(galleryButtonTapped),
            for: .touchUpInside
        )
        styleButton.addTarget(
            self,
            action: #selector(styleButtonTapped),
            for: .touchUpInside
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SwiftSpinner.show("Initializing model...")
        cartoonGanModel.start()
        openAIModel.start()
        styleTransfererModel.start()
        enabled = false
        updateStyle()
    }

    // MARK: - Private Methods

    @objc private func cameraButtonTapped() {
        imagePickerController.cameraAccessRequest()
    }

    @objc private func galleryButtonTapped() {
        imagePickerController.photoGalleryAccessRequest()
    }

    @objc private func styleButtonTapped() {
        switch serviceType {
        case .openai:
            serviceType = .cartoonGan
        case .cartoonGan:
            serviceType = .styleTransferer
        case .styleTransferer:
            serviceType = .openai
        }
        updateStyle()
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerController.present(parent: self, sourceType: sourceType)
    }

    private func showErrorDialog(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }

    private func setupSpinner() {
        SwiftSpinner.useContainerView(view)
        SwiftSpinner.setTitleFont(Font.paragraph)
    }

    private func updateStyle() {
        styleButton.setTitle(serviceType.rawValue, for: .normal)
    }
}

// MARK: - ImagePickerControllerDelegate
extension ViewController: ImagePickerControllerDelegate {
    func imagePicker(_ imagePicker: ImagePickerController, canUseCamera allowed: Bool) {
        guard allowed else {
            print("Camera access request failed!")
            showErrorDialog(message: "We don't have access to your camera")
            return
        }

        presentImagePicker(sourceType: .camera)
    }

    func imagePicker(_ imagePicker: ImagePickerController, canUseGallery allowed: Bool) {
        guard allowed else {
            print("Gallery access request failed!")
            showErrorDialog(message: "We don't have access to your gallery")
            return
        }

        presentImagePicker(sourceType: .photoLibrary)
    }

    func imagePicker(_ imagePicker: ImagePickerController, didSelect image: UIImage) {
        imagePicker.dismiss {
            SwiftSpinner.show("Processing your image...")
            if(self.serviceType == .styleTransferer) {
                self.styleTransfererModel.process(image)
            } else if(self.serviceType == .openai) {
                self.openAIModel.process(image)
            } else {
                self.cartoonGanModel.process(image)
            }
        }
    }

    func imagePicker(_ imagePicker: ImagePickerController, didCancel cancel: Bool) {
        if cancel { imagePicker.dismiss() }
    }

    func imagePicker(_ imagePicker: ImagePickerController, didFail failed: Bool) {
        if failed {
            imagePicker.dismiss()
            showErrorDialog(message: "We're having some issues to load your image!")
        }
    }
}

// MARK: - CartoonGanModelDelegate
extension ViewController: ModelDelegate {
    func model(_ model: Any, didFinishProcessing image: UIImage) {
        DispatchQueue.main.async {
            SwiftSpinner.hide()

            let cartoonViewController = CartoonViewController(image)
            self.present(cartoonViewController, animated: true)
        }
    }

    func model(_ model: Any, didFailedProcessing error: ModelError) {
        DispatchQueue.main.async {
            SwiftSpinner.hide()
            self.showErrorDialog(message: error.localizedDescription)
        }
    }

    func model(_ model: Any, didFinishAllocation error: ModelError?) {
        DispatchQueue.main.async {
            SwiftSpinner.hide()
            guard let error = error else {
                self.enabled = true
                return
            }
            self.showErrorDialog(message: error.localizedDescription)
        }
    }
}
