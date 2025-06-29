import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  var sharedTextChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "app.channel.shared.data", binaryMessenger: controller.binaryMessenger)
    self.sharedTextChannel = channel

    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      let defaults = UserDefaults(suiteName: "group.com.hellohack.miralife")

      if call.method == "getSharedText" {
        let jsonString = defaults?.string(forKey: "sharedTextList") ?? "[]"
        result(jsonString)
      } else if call.method == "clearSharedText" {
        defaults?.removeObject(forKey: "sharedTextList")
        defaults?.synchronize()
        result(nil)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // カスタムURLスキームからの呼び出しに対応
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    if url.scheme == "ShareMedia-com.hellohack.miralife",
       url.host == "share",
       let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
       let queryItems = components.queryItems,
       let keyItem = queryItems.first(where: { $0.name == "key" }) {

      let sharedKey = keyItem.value ?? ""
      let suiteName = "group.com.hellohack.miralife"
      if let text = UserDefaults(suiteName: suiteName)?.string(forKey: sharedKey) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.sharedTextChannel?.invokeMethod("onShared", arguments: text)
        }
      }
      return true
    }

    return false
  }
}
