import UIKit
import SwiftUI
import EvernoteSDK

/**
 SwiftUIでviewControllerを表示する際に必要なコード
 */
struct EvernoteViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = EvernoteViewController
    func makeUIViewController(context: Context) -> UIViewControllerType {
        return EvernoteViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

/**
 従来のViewControllerでviewの作成
 */
class EvernoteViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view.
        // このタイミングならOK
        initENSession()
    }

    fileprivate func initENSession() {
        print(ENSession.shared.isAuthenticated)
        ENSession.shared.authenticate(with: self, preferRegistration: false, completion: { (_error: Error?) in
            print(_error)
            print("Authenticate Completion")
        })
    }
}