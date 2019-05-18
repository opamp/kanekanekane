# kanekanekane



## 概要

Webで動作する家計簿的な何か。

## Installation

- 動かす前にsql/init-postgres.sqlを使ってDBを初期化
- その後はCommon Lisp + caveman2で作っているので、そんな感じで。

## 使い方

Webサーバー上で動かしてWebブラウザでアクセス。

### ユーザー登録方法

#### signup機能を利用する場合

src/config.lispのsignup-enableにtを設定するとsignupページが利用できるようになる。

    (defparameter *signup-enable* t)

signupページからユーザー登録を行うことで新規ユーザーを登録できる。
ただし今のところsignupページは簡単に作っただけなので所謂CAPTCHAのような機能はない。

#### Common LispのREPLから登録する方法

kanekanekane.user-control:user-add関数にユーザー名とパスワードを渡すことでユーザー登録できる。
成功した場合はユーザー情報が返り、すでにユーザーが存在する場合はnilが返る。

quicklispなどでkanekanekane.asdをロードする。

    (ql:quickload :kanekanekane)

その後、user-add関数を呼び出す。

    (kanekanekane.user-control:user-add "username" "password")

## Copyright

念の為LICENSE.txtに設定した。
