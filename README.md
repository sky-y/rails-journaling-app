# ジャーナリングアプリ（仮）

ジャーナリング（書く瞑想）を手助けする小さいRailsアプリ

## 環境構築

[Ruby on Rails 6のDocker環境構築](https://zenn.dev/yuma_ito_bd/scraps/1adb89dfe0661c) を参考に行った。

- Dockerfile, docker-compose.ymlを用意する
- entrypoint.shを用意する
- Gemfile, Gemfile.lockを生成する

は上記のまま進める。

```
$ docker-compose build
```

で一旦ビルドし、`rails`コマンドを利用できるようにする。

### Railsプロジェクトを作成する

- カレントディレクトリにプロジェクトを生成する
- データベース: MySQL
- WebpackerでReactを使えるようにする
- 余計な機能はスキップする

上記の条件で`rails new`コマンドを実行する。

```
docker-compose run web bundle exec rails new . --webpack=react --skip-turbolinks --skip-action-mailer --skip-action-mailbox --skip-active-storage --skip-test -d mysql
```

もう一度ビルドを実行する。（`bundle install`が必要というエラーが出たら、再びビルドする）

```
$ docker-compose build
```

### `webpacker:install`

下記のようにエラーが出る場合がある。

    /usr/local/bundle/gems/webpacker-5.4.3/lib/webpacker/configuration.rb:103:in `rescue in load': Webpacker configuration file not found /app/config/webpacker.yml. Please run rails webpacker:install Error: No such file or directory @ rb_sysopen - /app/config/webpacker.yml (RuntimeError)

その場合は`webpacker:install`を実行する。

```
$ docker-compose run web bundle exec rails webpacker:install
```

## DBの設定

config/database.yml を編集する。

```diff:config/database.yml
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: root
-  password: 
+  password: password
-  host: localhost
+  host: db
```

## DBのセットアップ

```
$ docker-compose exec web bundle exec rails db:create
$ docker-compose exec web bundle exec rails db:migrate
```

## サーバ起動

```
$ docker-compose up -d  # 起動
$ docker-compose stop   # 停止
```

ログを見るとき：

```
$ docker-compose logs -f web
```

## Bootstrapを有効にする

Webpackerで入れる場合。

[Rails 6にjQueryとBootstrapを入れる](https://qiita.com/kazutosato/items/d47b7705ee545de4cb1a)

```
$ docker-compose exec web yarn add bootstrap @popperjs/core
```

※`popper.js` ではNG。

- [webpackerを使用してBootstrapを導入する際に出たエラーの解決方法。 - Qiita](https://qiita.com/zamazama/items/2aa18bc87f53ae443d6c)

config/webpack/environment.js:

```js
const { environment } = require('@rails/webpacker')

// ここから
// BootstapのJS(popper.js)を使えるように
const webpack = require('webpack')
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    Popper: 'popper.js'
  })
)
// ここまで

module.exports = environment
```

app/javascriptディレクトリの下にstylesheetsディレクトリを作り、application.scssを次のように記述する。

app/javascript/stylesheets/application.scss:

```scss
@import '~bootstrap/scss/bootstrap';
```

application.jsに次の2行を加える。

app/javascript/packs/application.js:

```js
import 'bootstrap';
import '../stylesheets/application';
```

レイアウトにstylesheet_pack_tagを加える。
（注：デフォルトでOK？）

app/views/layouts/application.html.erb:

```erb
<%= stylesheet_link_tag 'application', media: 'all' %>
<%= javascript_pack_tag 'application' %>
```

