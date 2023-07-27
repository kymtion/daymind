

import Foundation
import UIKit

func drawText(_ text: String, inImage image: UIImage) -> UIImage? {
    let font = UIFont.boldSystemFont(ofSize: 140)
    let textAttributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: UIColor.white
    ]
    UIGraphicsBeginImageContext(image.size)
    image.draw(in: CGRect(origin: .zero, size: image.size))
    
    let attributedText = NSAttributedString(string: text, attributes: textAttributes)
    let textWidth = attributedText.size().width
    let textRect = CGRect(x: (image.size.width - textWidth) / 2.0, y: 50, width: textWidth, height: font.lineHeight)
    text.draw(in: textRect, withAttributes: textAttributes)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}


class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var parent: ImagePicker
    
    init(_ parent: ImagePicker) {
        self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let dateString = formatter.string(from: Date())
            let newImage = drawText(dateString, inImage: image)
            parent.image = newImage
        }
        parent.didFinishPicking(parent.image)
        picker.dismiss(animated: true)
    }
}

