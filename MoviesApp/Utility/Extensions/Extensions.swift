//
//  Extensions.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/4/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import Foundation
import AVKit

enum TagsGlobalViews: Int {
    case inBlockScreen = 24102017
    case inBlockCustomView = 22022018
    case blockScreen = 26102017
    case offInternet = 20102017
    case onInternet = 19102017
    case informView = 18102017
    case loadingIndicator = 26102018
}

extension UIStoryboard {
    
    enum Storyboard: String {
        case splash = "LaunchScreen"
        case main = "Main"
    }
    
    convenience init(storyboard: Storyboard) {
        self.init(name: storyboard.rawValue, bundle: nil)
    }
    
    func instantiateViewController<T: UIViewController>(_ type: T.Type) -> T {
        let id = NSStringFromClass(T.self).components(separatedBy: ".").last!
        return self.instantiateViewController(withIdentifier: id) as! T
    }
}

extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
    
}

extension UIViewController {
    
    class func instance(_ storyboard: UIStoryboard.Storyboard = .main) -> Self {
        let storyboard = UIStoryboard(storyboard: storyboard)
        let viewController = storyboard.instantiateViewController(self)
        return viewController
    }
    
    class var identifier: String {
        return String(describing: self)
    }
    
    func showErrAlert(msg: String, title: String = StringValue.Base.kErrorAlertTitle) {
        self.showAlert(title: title, msg: msg)
    }
    
    func showAlert(title: String, msg: String, customActions: [UIAlertAction] = []) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
            
            if customActions.isEmpty {
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            } else {
                for action in customActions {
                    alert.addAction(action)
                }
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    class func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }
        
        return instantiateFromNib()
    }
}

extension UIView {
    
    func addGradient(colors: [Any]? = nil, locations: [NSNumber]? = nil, startPoint: CGPoint? = nil, endPoint: CGPoint? = nil) {
        let layer0 = CAGradientLayer()

        layer0.colors = colors ??  [
        UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 0.05).cgColor,
        UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 0.2).cgColor,
        UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 0.3).cgColor,
        UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1).cgColor
        ]

        layer0.locations = locations ?? [0, 0.2, 0.5, 0.9]
        layer0.startPoint = startPoint ?? CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = endPoint ?? CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        layer0.bounds = self.bounds.insetBy(dx: -0.5*self.bounds.size.width, dy: -0.5*self.bounds.size.height)
        layer0.position = self.center

        self.layer.addSublayer(layer0)
    }
    
    func addShadow(to edges: [UIRectEdge], radius: CGFloat, color: UIColor? = nil) {
        
        let shadowColor = color ?? UIColor.init(displayP3Red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.2)
        
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        self.layer.shadowRadius = radius
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        for edge in edges {
            switch edge {
            case UIRectEdge.top:
                let offset: CGFloat = self.layer.shadowOffset.height > 0 ? 0 : -1
                self.layer.shadowOffset.height = offset
                
            case UIRectEdge.bottom:
                let offset: CGFloat = self.layer.shadowOffset.height < 0 ? 0 : 1
                self.layer.shadowOffset.height = offset
                
            case UIRectEdge.left:
                let offset: CGFloat = self.layer.shadowOffset.width > 0 ? 0 : -1
                self.layer.shadowOffset.width = offset
                
            case UIRectEdge.right:
                let offset: CGFloat = self.layer.shadowOffset.width < 0 ? 0 : 1
                self.layer.shadowOffset.width = offset
                
            default: break
            }
        }
    }
    
    // Simple shadow
    func viewShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.16
        layer.shadowRadius = 10
        layer.masksToBounds = false
    }
    
    class func fromNib<T: UIView>() -> T {
        return UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! T
    }
    
    class var identifier: String {
        return String(describing: self)
    }
    
    func constrainToEdges(_ subview: UIView, top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let topContraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: top)
        
        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: bottom)
        
        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: leading)
        
        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: trailing)
        
        addConstraints([
            topContraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint])
    }
    
    func viewCorner(_ radius: CGFloat? = nil) {
        layer.cornerRadius = radius ?? self.frame.height / 2
        layer.masksToBounds = true
    }
    
    func viewCornerForSide(_ roundingCorners: UIRectCorner,_ radius: CGFloat) {
        
        if #available(iOS 11.0, *) {
            clipsToBounds = false
            layer.cornerRadius = radius
            layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            let rectShape = CAShapeLayer()
            rectShape.bounds = frame
            rectShape.position = center
            rectShape.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: 0, height: 0)).cgPath
            layer.mask = rectShape
        }
    }
    
    func viewBorder(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    func inBlockCustomViewStart(flag: Bool) {
        
        DispatchQueue.main.async {
            
            let tag = TagsGlobalViews.inBlockCustomView.rawValue
            
            for v in self.subviews {
                if v.tag == tag {
                    v.removeFromSuperview()
                    break
                }
            }
            
            if !flag {
                return
            }
            
            let heightContainer: CGFloat = 80.0
            
            let container = UIView.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            container.tag = tag
            
            container.layer.cornerRadius = 10
            container.clipsToBounds = true
            container.backgroundColor = UIColor.clear
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: container.frame.width / 2, y: container.frame.height / 2, width: heightContainer / 2, height: heightContainer / 2))
            
            loadingIndicator.center = container.center
            
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .whiteLarge
            loadingIndicator.color = ColorScheme.Others.kBaseLoader
            
            let transform: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            loadingIndicator.transform = transform
            loadingIndicator.startAnimating()
            
            container.addSubview(loadingIndicator)
            
            self.addSubview(container)
        }
    }
}

extension NSRegularExpression {
    
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
    
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

extension NSObject {
   
    func safeRemoveObserver(_ observer: NSObject, keyPath: String, context: inout Int) {
        let result = checkIfAlreadyAdded(keyPath: keyPath, context: &context)
        
        if result {
            removeObserver(observer, forKeyPath: keyPath, context: &context)
        }
    }
    
    fileprivate func address(_ o: UnsafeRawPointer) -> Int {
        return Int(bitPattern: o)
    }

    fileprivate func checkIfAlreadyAdded(keyPath: String, context: inout Int) -> Bool {
        
        guard self.observationInfo != nil else { return false }
        
        let info = Unmanaged<AnyObject>
               .fromOpaque(self.observationInfo!)
               .takeUnretainedValue()
         
        let contextStr = NSString(format: "%p", address(&context))
        
        let infoStr = info.description ?? ""
        
        let regex = NSRegularExpression("\(keyPath).*[a-z].*\(contextStr)")
        let result = regex.matches(infoStr)
        
        return result
    }
}

extension UITableView {
    
    func reloadTableRows(isAnimate: Bool, path: [IndexPath]) {
        
        if isAnimate {
            self.reloadRows(at: path, with: .fade)
        } else {
            self.reloadRows(at: path, with: .none)
        }
    }
    
    func reloadTable(isAnimate: Bool) {
        
        if isAnimate {
            UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                self.reloadData()
            }, completion: nil)
        } else {
            self.reloadData()
        }
    }
    
    func hasRowAtIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    func createCell<T: UITableViewCell>(_ cell: T.Type, _ indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: cell.identifier, for: indexPath) as! T
    }
    
    func registerCell<T: UITableViewCell>(_ cell: T.Type) {
        self.register(UINib(nibName: T.identifier, bundle: nil), forCellReuseIdentifier: T.identifier)
    }
    
}

extension UICollectionView {
    
    func createCell<T: UICollectionViewCell>(_ cell: T.Type, _ indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as! T
    }
    
    func registerCell<T: UICollectionViewCell>(_ cell: T.Type) {
        self.register(UINib(nibName: cell.identifier, bundle: nil), forCellWithReuseIdentifier: cell.identifier)
    }
}

extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
}

extension UIColor {
    
    class func hex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        let cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.count == 6 {
            
            var rgbValue: UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)
            
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        } else if cString.count == 8 {
            
            var rgbValue: UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)
            
            return UIColor(
                red: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x000000FF) / 255.0,
                alpha: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            )
        } else {
            return UIColor.black
        }
    }
}

extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension NSNotification.Name {
    static let notificationReachable = NSNotification.Name("kNotificationReachable")
}

extension UILabel {

    func setupAttributed(_ text: String?) {
        let attributedString = NSMutableAttributedString(string: text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSMakeRange(0, attributedString.length))
        attributedText = attributedString
    }
}
