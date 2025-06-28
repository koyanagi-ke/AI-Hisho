import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    let sharedKey = "sharedText"
    let suiteName = "group.com.hellohack.miralife"
    let hostURLScheme = "ShareMedia-com.hellohack.miralife"

    override func isContentValid() -> Bool { true }

    override func didSelectPost() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { data, _ in
                        if let text = data as? String {
                            let ud = UserDefaults(suiteName: self.suiteName)
                            ud?.set(text, forKey: self.sharedKey)
                            ud?.synchronize()

                            self.redirectToHostApp()
                        } else {
                            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                        }
                    }
                    return
                }
            }
        }

        // fallback
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
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

        // シェアExtensionを閉じる
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! { [] }
}
