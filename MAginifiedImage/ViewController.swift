//
//  ViewController.swift
//  MAginifiedImage
//
//  Created by Home on 03/08/24.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var magniImageView: UIImageView!
    
    let dragger = UIView()
    var img: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dragger.backgroundColor = .red.withAlphaComponent(0.1)
        dragger.layer.borderWidth = 1
        dragger.layer.borderColor = UIColor.red.cgColor
        dragger.frame.size = CGSize(width: 100, height: 100)
        imageView.addSubview(dragger)
        
        imageView.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(movePan(_ :)))
        dragger.addGestureRecognizer(pan)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenShot()
    }
    
    @objc func movePan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
//            magniImageView.image = nil
            return
        }
        guard sender.state == .changed || sender.state == .began else {return}
        
        dragger.center = dragger.center + sender.translation(in: imageView)
        sender.setTranslation(.zero, in: imageView)
        
        magniImageView.image = imageView.getCroppedImage(image: img, point: dragger.frame.origin, size: CGSize(width: 100, height: 100))
    }
    
    let picker = UIImagePickerController()
    @IBAction func selectImage() {
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        picker.allowsEditing = false
        self.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        setScreenShot()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setScreenShot() {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 100, y: 100), size: self.imageView.frame.size))
        imageView.image = self.imageView.image
        imageView.contentMode = self.imageView.contentMode
        imageView.backgroundColor = .blue
        
        let view = UIView(frame: CGRect(origin: .zero, size: imageView.frame.size + 200))
        view.backgroundColor = .black
        view.addSubview(imageView)
        img = view.asImage()
    }
}

extension UIImageView {
    func getCroppedImage(image: UIImage,point pointLocation: CGPoint, size pointSize: CGSize) -> UIImage? {
        // scale = pixelViseSize / (PointViseSize + blackRegion)
        let scale = image.size / (self.frame.size + 200)
        
        // adding black regin `top` `leading` margin
        let pointLocation2 = pointLocation+100
        
        // Convert the point to the image's coordinate space
        let pixelLocation = pointLocation2 * scale.toCGPoint()
        let pixelSize = pointSize * scale
        
        // Define the rect for cropping
        let cropRect = CGRect(origin: pixelLocation, size: pixelSize)
        
        return image.cgImage?.cropping(to: cropRect)?.toImage()
    }
}

extension CGImage {
    func toImage() -> UIImage {
        UIImage(cgImage: self)
    }
}

extension UIView {
    func asImage() -> UIImage {
        UIGraphicsBeginImageContext(frame.size)
        layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return UIImage(cgImage: image!.cgImage!)
    }
}


extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x+rhs.x, y: lhs.y+rhs.y)
    }
    static func +(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x+rhs, y: lhs.y+rhs)
    }
    
    static func *(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x*rhs.x, y: lhs.y*rhs.y)
    }
}
extension CGSize {
    static func +(lhs: CGSize, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width+rhs, height: lhs.height+rhs)
    }
    static func /(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width/rhs.width, height: lhs.height/rhs.height)
    }
    
    static func *(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width*rhs.width, height: lhs.height*rhs.height)
    }
    
    func toCGPoint() -> CGPoint {
        CGPoint(x: width, y: height)
    }
}
