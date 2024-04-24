//
//  AppDelegate.swift
//  PBL_abe
//
//  Created by Abe on R 3/09/29.
//

import UIKit
import UserNotifications
import SideMenu
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    struct Content: Codable {
        var userId: String
    }
    var contents = [Content]()

    var window: UIWindow?
    var userId: String?

    let navigationColor = UIColor.ThemeColor

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // ナビゲーションの色
        UINavigationBar.appearance().backgroundColor = navigationColor
        UINavigationBar.appearance().tintColor = .white

        //　フォント設定
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "KFhimaji", size: 22)!, NSAttributedString.Key.foregroundColor: UIColor.white]

        // UIBarButtonItem
        let attributes = [NSAttributedString.Key.font:  UIFont(name: "KFhimaji", size: 18)!]
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .highlighted)

        UNUserNotificationCenter.current().delegate = self
        // MARK: 02. request to user
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }

            // MARK: - 03. register to APNs
            DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
        }
        setInfo()
        setSideMenu()

        return true
    }

    private func setInfo() {
        UserDefaults.standard.register(defaults: ["registeredDefaultNotificationValue": [["768","1024","1536","0","co2","0"], //CO2
                                                                 ["15","30","-1","3","temperature","0"], // 気温
                                                                 ["40","60","-1","3","humidity","0"], // 湿度
                                                                 ["1000","1020","-1","3","pressure","0"], // 気圧
                                                                 ["100","-1","-1","4","voc","0"]]]) // VOC
                                                                // alert1, alert2, alert3, type, whatAlert, flag nullは-1
        
        UserDefaults.standard.register(defaults: ["userId":0])
        guard let userId = UserDefaults.standard.object(forKey: "userId") as? Int else { return }
        if userId > 0 {
            let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
            let modelName = UIDevice.modelName
            let hostName = UIDevice.current.name
            let systemVersion = UIDevice.current.systemVersion

            var request = URLRequest(url: URL(string: "http://133.17.165.154:8086/akamura4/setInfo.php")!)
            request.httpMethod = "POST"

            var postString = "userId=\(userId)&build=\(build)&modelName=\(modelName)&hostName=\(hostName)&systemVersion=\(systemVersion)"

            UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
                UserDefaults.standard.register(defaults: ["notification":0])

                switch setttings.authorizationStatus{
                case .authorized:
                    //                    let postString = postStringBase + "&notification=1"
                    //                    request.httpBody = postString.data(using: .utf8)
                    postString += "&notification=1"
                    UserDefaults.standard.set(1, forKey: "notification")
                case .notDetermined:    fallthrough
                case .denied:           fallthrough
                case .provisional:      fallthrough
                case .ephemeral:        fallthrough
                @unknown default:
                    //                    let postString = postStringBase + "&notification=0"
                    //                    request.httpBody = postString.data(using: .utf8)
                    postString += "&notification=0"
                    UserDefaults.standard.set(0, forKey: "notification")
                }
                //                print("postString: \(postString)")
                request.httpBody = postString.data(using: .utf8)
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    //                guard let _ = data, error == nil, response != nil else { return }
                })
                .resume()
            }
        }
    }

    private func setSideMenu() {
        // さきほど作ったメニュー用のMenuViewControllerをSideMenuにセットする
        let menuViewController = MenuViewController()
        let menuNavigationController = SideMenuNavigationController(rootViewController: menuViewController)

        SideMenuManager.default.rightMenuNavigationController = menuNavigationController
        SideMenuManager.default.rightMenuNavigationController?.presentationStyle = .menuSlideIn
    }

    // フォアグラウンドでの通知受信
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("フォアグラウンドで受信しました")
        completionHandler([ .badge, .sound, .banner, .list ])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        debugPrint("プッシュ通知のメッセージをクリック")
        completionHandler()
    }

    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // プッシュ通知
//        UIApplication.shared.applicationIconBadgeNumber = -1
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    // MARK: - CoreData
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Callback for Remote Notification
extension AppDelegate {
    // MARK: 04-1. succeeded to register to APNs
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 値が保持されていなければ，初期値をセット
        UserDefaults.standard.register(defaults: ["deviceToken":"0"])
        UserDefaults.standard.register(defaults: ["uuid":"0"])
        UserDefaults.standard.register(defaults: ["userId":0])

        // デバイストークンとUUIDを読込み，値がデフォルト値であれば，すぐにセット
        let deviceToken = deviceToken.map { (byte: UInt8) in String(format: "%02.2hhx", byte) }
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        if UserDefaults.standard.object(forKey: "deviceToken") as? String == "0" { UserDefaults.standard.set(deviceToken.joined(), forKey:"deviceToken") }
        if UserDefaults.standard.object(forKey: "uuid") as? String == "0" { UserDefaults.standard.set(uuid, forKey:"uuid") }

        // 保存されている値を読み込む
        guard let storedDeviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? String else { return }
        guard let storedUuid = UserDefaults.standard.object(forKey: "uuid") as? String else { return }
        guard let userId = UserDefaults.standard.object(forKey: "userId") as? Int else { return }

        // 保存されている値と比較し，違っていたら新しい値をセット
        if deviceToken.joined() != storedDeviceToken { UserDefaults.standard.set(deviceToken.joined(), forKey:"deviceToken") }
        if uuid != storedUuid { UserDefaults.standard.set(uuid, forKey:"uuid") }

        // 情報収集
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let modelName = UIDevice.modelName
        let systemVersion = UIDevice.current.systemVersion

        // POST送信の準備
        let postString = "deviceToken=\(deviceToken.joined())&storedDeviceToken=\(storedDeviceToken)&uuid=\(uuid)&storedUuid=\(storedUuid)&userId=\(userId)&build=\(build)&modelName=\(modelName)&systemVersion=\(systemVersion)"
        print(postString)
        var request = URLRequest(url: URL(string: "http://133.17.165.154:8086/akamura4/deviceToken.php")!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)

        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data, error == nil, response != nil else { return }

//            let resultData = String(data: data, encoding: .utf8)!
//            print("\(resultData)")

            do {
                self.contents = try JSONDecoder().decode([Content].self, from: data)
                if ( self.contents.count > 0 ) { self.userId = self.contents[0].userId }
                else { self.userId = "0" }
                guard let userId = self.userId else { return }
                UserDefaults.standard.set(Int(userId), forKey:"userId")
            } catch {
                print("Error: didRegisterForRemoteNotificationsWithDeviceToken")
            }
        })
        .resume()
    }

    // MARK: failed to register to APNs
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register to APNs: \(error)")
    }
}
