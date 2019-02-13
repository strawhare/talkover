import UIKit
import Reachability

class ViewController: UIViewController {
    let reachability = Reachability()!
    let imageView = UIImageView()
    let button = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        imageView.image = UIImage(named: "picture1")
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        view.addSubview(imageView)
        
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        button.center = CGPoint(x: view.center.x, y: view.frame.height - 200)
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        button.setTitle("talk over tea", for: .normal)
        button.titleLabel?.font = UIFont(name: "IowanOldStyle-Italic", size: 30)
        button.contentHorizontalAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        view.addSubview(button)
        
        //startHost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            imageView.image = UIImage(named: "picture1")
            button.isHidden = false
        case .cellular:
            print("Reachable via Cellular")
            imageView.image = UIImage(named: "picture1")
            button.isHidden = false
        case .none:
            print("Network not reachable")
            imageView.image = UIImage(named: "picture2")
            button.isHidden = true
        }
    }
    
    @objc func sendMessage() {
        let urlscheme = "line://msg/text"
        let message = "お喋りしよう。\n\n美味しいお茶があるから。"
        let appurl = "\n\nhttps://www.apple.com/jp/iphone-x/"
        // line:/msg/text/(メッセージ)
        let urlstring = urlscheme + "/" + message + appurl
        
        // URLエンコード
        guard let  encodedURL = urlstring.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
            return
        }
        
        // URL作成
        guard let url = URL(string: encodedURL) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (succes) in
                    //  LINEアプリ表示成功
                })
            }else{
                UIApplication.shared.openURL(url)
            }
        }else {
            // LINEアプリが無い場合
            let alertController = UIAlertController(title: "エラー",
                                                    message: "LINEがインストールされていません",
                                                    preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
            present(alertController,animated: true,completion: nil)
        }
    }
    
    deinit {
        stopNotifier()
    }
}
