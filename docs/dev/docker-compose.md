MissionForestの開発について
=====
- :exclamation: Note: `このドキュメントは，教育用に作成したものであり，このアプリケーションの開発の仕方を強制するものではありません．`

## ソースコードを入手する
```bash
git clone https://github.com/srmtlab/MissionForest.git
```

## 開発環境について
### 導入
MissionForestは仮想環境上で開発を行います．仮想環境を用いることで以下の様な利点があると考えられます．
- 誰でも同じ環境を構築でき，アプリケーションの配布や構築が容易になります．
- ローカルの環境（仮想環境ではない）で開発を行うと，プロジェクト以外のファイルプログラムが誤って削除する等の，ローカルの環境が破壊される可能性がある．

MissionForestでは，仮想環境としてDockerを用います．Dockerについては，以下の記事を読むと良いかもしれません
- [Docker入門（第一回）～Dockerとは何か、何が良いのか～](https://knowledge.sakura.ad.jp/13265/)
- [Dockerイメージの理解とコンテナのライフサイクル](https://www.slideshare.net/zembutsu/docker-images-containers-and-lifecycle)
- [入門 Docker](https://y-ohgi.com/introduction-docker/)

### VSCodeを用いた開発環境の構築
MissionForestでは，開発にVSCode(Visual Studio Code)を用います．VSCodeの [Remote - Containers](https://code.visualstudio.com/docs/remote/containers) という拡張機能があるので，それを用いて開発を行います．  
以下の手順で開発環境が立ち上がります．

![VSCode起動手順](./setup_dev_env.jpg)

### 初期設定
``Terminal`` -> ``New Terminal``の順にクリックを行い，ターミナルを起動し，以下を入力する．
```bash
bundle exec rails db:migrate
```

### アプリケーションの起動
``Terminal`` -> ``New Terminal``の順にクリックを行い，ターミナルを起動し，以下を入力する．
```bash
bundle exec rails server
```
http://localhost:3000/ にブラウザからアクセスするとWEBアプリケーションが起動していることが確認できます．

### VSCodeでの開発環境の終了の仕方
1. 左下の ``Dev Container: KidsRESAS development`` をクリック
2. ``Close Remote Connection`` をクリック
開発環境が終了します．

## Ruby on Rails について
MissionForestは，Ruby on Railsと呼ばれるウェブアプリケーションフレームワークを用いて開発を行います．

## 参照
- [いつも忘れる「Railsのgenerateコマンド」の備忘録](https://maeharin.hatenablog.com/entry/20130212/rails_generate)
