import UIKit
import MLKitTextRecognition
import MLKitVision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let textRecognizer = TextRecognizer.textRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func openGallery(_ sender: Any) {
        openImagePicker()
    }

    func openImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        // Retrieve the selected image
        if let image = info[.originalImage] as? UIImage {
            performTextRecognition(image: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)

        // Handle cancellation
    }

    func performTextRecognition(image: UIImage) {
        // Create a VisionImage and set its orientation
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation

        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result else {
                // Error handling
                return
            }

            // Access recognized text
            let fullText = result.text
            print("Full Text: \(fullText)")

            var mrzPart: String = ""
            var isMRZPartStarted = false

            // Scan for the specific MRZ part containing "<<"
            for block in result.blocks {
                for line in block.lines {
                    let lineText = line.text

                    // Check if the line contains "<<"
                    if lineText.contains("<<") {
                        isMRZPartStarted = true
                    }

                    // Continue appending subsequent lines until a line is empty or doesn't contain "<<"
                    if isMRZPartStarted {
                        if lineText.isEmpty || !lineText.contains("<<") {
                            isMRZPartStarted = false
                            break
                        } else {
                            mrzPart += lineText + "\n"
                        }
                    }
                }
            }

            // Process the extracted MRZ part
            print("Extracted MRZ Part:\n\(mrzPart.replacingOccurrences(of: " ", with: ""))")
        }
    }




    
}

