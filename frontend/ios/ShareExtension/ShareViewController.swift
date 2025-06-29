import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    let sharedKey = "sharedTextList"
    let suiteName = "group.com.hellohack.miralife"
    let hostURLScheme = "ShareMedia-com.hellohack.miralife"

    override func didSelectPost() {
        var textList: [String] = []

        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            let group = DispatchGroup()

            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    group.enter()
                    provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { data, _ in
                        if let text = data as? String {
                            textList.append(text)
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                if !textList.isEmpty {
                    let jsonData = try? JSONSerialization.data(withJSONObject: textList)
                    let jsonString = String(data: jsonData!, encoding: .utf8)

                    let ud = UserDefaults(suiteName: self.suiteName)
                    ud?.set(jsonString, forKey: self.sharedKey)
                    ud?.synchronize()

                    self.redirectToHostApp()
                } else {
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
            }
        }
    }

    private func redirectToHostApp() {
        let url = URL(string: "\(hostURLScheme)://share?key=\(sharedKey)")!
        var responder = self as UIResponder?

        while responder != nil {
            if let application = responder as? UIApplication {
                application.perform(#selector(UIApplication.open(_:options:completionHandler:)),
                                    with: url,
                                    with: nil)
                break
            }
            responder = responder?.next
        }

        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
