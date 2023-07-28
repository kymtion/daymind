

import Foundation
import UIKit

func drawText(_ text: String, inImage image: UIImage) -> (newImage: UIImage?, captureTime: Date) {
    let font = UIFont.boldSystemFont(ofSize: 140)
    let textAttributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: UIColor.white
    ]
    
    UIGraphicsBeginImageContext(image.size)
    image.draw(in: CGRect(origin: .zero, size: image.size))
    
    let captureTime = Date() // 촬영 시간을 직접 생성합니다.
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    let dateString = formatter.string(from: captureTime)
    
    let attributedText = NSAttributedString(string: dateString, attributes: textAttributes)
    let textWidth = attributedText.size().width
    let textRect = CGRect(x: (image.size.width - textWidth) / 2.0, y: 50, width: textWidth, height: font.lineHeight)
    attributedText.draw(in: textRect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return (newImage, captureTime) // 촬영 시간과 이미지를 함께 반환합니다.
}



class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var parent: ImagePicker
    
    init(_ parent: ImagePicker) {
        self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            let (newImage, captureTime) = drawText("", inImage: image) // 촬영 시간을 가져옵니다.
            parent.image = newImage
            parent.didFinishPicking(newImage, captureTime)
        }
        
        picker.dismiss(animated: true)
    }
}
