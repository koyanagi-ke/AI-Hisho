# prを出すまでの流れ
・mainをgit pull origin mainで最新化する
・mainブランチからfeature/xxxxブランチをgit checkout -b feature/xxxxで作成する
・色々ファイルを修正する
・git add . でaddステージに追加
・git commit -m "メッセージ"でコミット
・git push origin feature/xxxxでgithubにアップロード
・github上でプルリクエストを作成