//
//  ScreenManager.swift
//  MoviesApp
//
//  Created by Vlad Tuichev on 2/5/20.
//  Copyright © 2020 Vlad Tuichev. All rights reserved.
//

import UIKit

struct MemoryAddress<T>: CustomStringConvertible {
    let intValue: Int
    
    var description: String {
        let length = 2 + 2 * MemoryLayout<UnsafeRawPointer>.size
        return String(format: "%0\(length)p", intValue)
    }
    
    /// for structures
    init(of structPointer: UnsafePointer<T>) {
        intValue = Int(bitPattern: structPointer)
    }
}

extension MemoryAddress where T: AnyObject {
    /// for classes
    init(of classInstance: T) {
        intValue = unsafeBitCast(classInstance, to: Int.self)
    }
}

protocol BaseClassesProtocol {
    func clearData()///always call in deinit
    func restoreData()
    func saveData()
}

protocol BasePresenterProtocol: BaseClassesProtocol {
    init(view: BaseViewController)
}

typealias BaseViewController = UIViewController & BaseClassesProtocol
typealias BasePresenter = NSObject & BasePresenterProtocol

final class ScreenManager {
    
    enum TransitionType {
        case push
        case present
        case pop
        case dissmis
    }
    
    static var isLogEnabled: Bool = true
    
    static private var controllers: [String: BaseViewController] = [:]
    static private var presenters: [String: BasePresenter] = [:]
    
    static private var controllerKeys: [String] = []
    static private var presenterKeys: [String] = []
    
    static func showNewViewController<T: BaseViewController>(clearByStep: Int = 2, currentVC: T, newVC: T, type: ScreenFactory.TransitionType) {
        let lastIndex = controllerKeys.count - 1
        let clearOnIndex = lastIndex - clearByStep
        
        if let key = controllerKeys[safe: clearOnIndex] {
            controllers[key]?.saveData()
            controllers[key]?.clearData()
        }
        
        switch type {
        case .push: currentVC.navigationController?.pushViewController(newVC, animated: true)
        case .present: currentVC.present(newVC, animated: true, completion: nil)
        default: break
        }
    }
    
    static func closeViewController<T: BaseViewController>(currentVC: T, type: ScreenFactory.TransitionType, withPresenter: Bool = false) {
        let lastIndex = controllerKeys.count - 1
        let restoreOnIndex = lastIndex - 1
        
        if withPresenter {
            let key = presenterKeys.last ?? ""
            presenterKeys.removeLast()
            
            let previousKey = presenterKeys.last ?? ""
            
            presenters[key]?.clearData()
            presenters[key] = nil
            
            presenters[previousKey]?.restoreData()
        }
        
        if let key = controllerKeys[safe: lastIndex] {
            controllers[key]?.clearData()
            controllers[key] = nil
        }
        
        if let key = controllerKeys[safe: restoreOnIndex] {
            controllers[key]?.restoreData()
        }
        
        switch type {
        case .pop: currentVC.navigationController?.popViewController(animated: true)
        case .dissmis: currentVC.dismiss(animated: true, completion: nil)
        default: break
        }
    }
    
    static func createViewController<T: BaseViewController>(controller: T, storyboard: UIStoryboard.Storyboard? = nil) -> T {
        let classInstanceAddress = MemoryAddress(of: controller)
        let key = classInstanceAddress.description
        
        isLogEnabled ? print("Creating new \(T.self)") : ()
        
        guard let storyboardName = storyboard else {
            let vc = T.loadFromNib()
            controllers[key] = vc
            controllerKeys.append(key)
            return vc
        }
        
        let vc = T.instance(storyboardName)
        controllers[key] = vc
        controllerKeys.append(key)
        return vc
    }
    
    static func createPresenter<T: BasePresenter>(presenter: T, view: BaseViewController, clearByStep: Int = 2) -> T {
        let classInstanceAddress = MemoryAddress(of: presenter)
        let key = classInstanceAddress.description
        
        isLogEnabled ? print("Creating new \(T.self)") : ()
        
        let presenter = T.init(view: view)
        presenters[key] = presenter
        presenterKeys.append(key)
        
        let lastIndex = presenterKeys.count - 1
        let clearOnIndex = lastIndex - clearByStep
        
        if let clearKey = presenterKeys[safe: clearOnIndex] {
            presenters[clearKey]?.saveData()
            presenters[clearKey]?.clearData()
        }
        
        return presenter
    }
}
