# Firebase SDK の追加

Swift Package Manager を使用して Firebase の依存関係のインストールと管理を行います。

Xcode でアプリのプロジェクトを開いたまま、[File] > [Add Packages] に移動します。
プロンプトが表示されたら、次の Firebase iOS SDK リポジトリ URL を入力します。
https://github.com/firebase/firebase-ios-sdk
使用する SDK のバージョンを選択します。
デフォルト（最新）の SDK バージョンを使用することをおすすめしますが、必要に応じて古いバージョンも使用できます。

使用する Firebase ライブラリを選択します。
[Finish] をクリックすると、Xcode は依存関係の解決とバックグラウンドでのダウンロードを自動的に開始します。

# 初期化コードの追加

アプリの起動時に Firebase を接続するには、アプリのメイン エントリ ポイントに次の初期化コードを追加します。

## swift ui

```
import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}
```

## swift

```
import UIKit
import FirebaseCore


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
      [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
```

## objectiv-c

```
@import UIKit;
@import FirebaseCore;


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [FIRApp configure];

  return YES;
}
```

# 次のステップ

これで設定は完了です。

[このドキュメント](https://firebase.google.com/docs/guides?hl=ja&authuser=1&_gl=1*1o0yyrh*_ga*MTU1ODY1Mzg1My4xNzQ2NjMxNDc3*_ga_CW55HF8NVT*czE3NDY2MzUxNjMkbzIkZzEkdDE3NDY2MzU1MTEkajkkbDAkaDA.)をご覧になり、アプリで使用する各種の Firebase プロダクトの利用開始方法をご確認ください。

[サンプルの Firebase アプリ](https://firebase.google.com/docs/samples?hl=ja&authuser=1&_gl=1*1o0yyrh*_ga*MTU1ODY1Mzg1My4xNzQ2NjMxNDc3*_ga_CW55HF8NVT*czE3NDY2MzUxNjMkbzIkZzEkdDE3NDY2MzU1MTEkajkkbDAkaDA.)もご覧いただけます。

または、コンソールに進んで Firebase をご確認ください。
