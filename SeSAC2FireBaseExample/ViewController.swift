//
//  ViewController.swift
//  SeSAC2FireBaseExample
//
//  Created by 박관규 on 2022/10/05.
//

import UIKit
import FirebaseAnalytics

class ViewController: UIViewController {

    @IBOutlet weak var crashClicked: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Analytics.logEvent("kidult", parameters: [
//          "name": "어른이",
//          "full_text": "안녕하세요",
//        ])
//
//        Analytics.setDefaultEventParameters([
//          "level_name": "Caverns01",
//          "level_difficulty": 4
//        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController ViewWillAppear")
    }
    
    @IBAction func crashClicked(_ sender: UIButton) {
    }
    
    
    @IBAction func btn_profile(_ sender: UIButton) {
        present(ProfileViewController(), animated: true)
    }
    
    @IBAction func btn_setting(_ sender: UIButton) {
        navigationController?.pushViewController(SettingViewController(), animated: true)
        
    }
    
}

class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ProfileViewController ViewWillAppear")
    }
}

class SettingViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .red
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SettingViewController ViewWillAppear")
    }
}

extension UIViewController {
    
    var topViewController: UIViewController? {
        return self.topViewController(currentViewController: self)
    }
    
    //최상위 뷰컨트롤러를 판단해주는 메서드
    func topViewController(currentViewController: UIViewController) -> UIViewController {
        
        if let tabBarController = currentViewController as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
            
            return self.topViewController(currentViewController: selectedViewController)
            
        } else if let navigationController = currentViewController as? UINavigationController, let visibleViewController = navigationController.visibleViewController {
            
            return self.topViewController(currentViewController: visibleViewController)
            
        } else if let presentedViewController = currentViewController.presentedViewController {
            
            return self.topViewController(currentViewController: presentedViewController)
            
        } else { return currentViewController }
        
    }
    
}

// 하나 더 만든 이유 : 기능이 다르기 때문에 생성
extension UIViewController {
    
    class func swizzleMethod() {
        
        let origin = #selector(viewWillAppear)
        let change = #selector(changeViewWillAppear)
        
        guard let originMethod = class_getInstanceMethod(UIViewController.self, origin), let changeMethod = class_getInstanceMethod(UIViewController.self, change) else {
            print("함수를 찾을 수 없거나 오류 발생")
            return
        }
        
        method_exchangeImplementations(originMethod, changeMethod)
        
    }
    
    @objc func changeViewWillAppear() {
        print("Change ViewWillAppear SUCCEED")
    }
    
}
