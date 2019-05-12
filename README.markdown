# kanekanekane



## 概要

Webで動作する家計簿的な何か。

## Installation

Common Lisp + caveman2で作っているので、そんな感じで。

## 使い方

Webサーバー上で動かしてWebブラウザでアクセス。

### 注意

version 0.0.1はとりあえず一人で使う分には問題ないくらいな感じにできた程度なのでユーザー登録ページが実装されていない。
なので、ユーザーを登録するには直接DBにinsertするか、kanekanekane.user-control:user-addをREPLから呼び出す。

    (kanekanekane.user-control:user-add "username" "password")

## Copyright

念の為LICENSE.txtに設定した。
