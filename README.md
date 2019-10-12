# Java Practice Helper
大阪工業大学のJava演習用お助けプラグインです。Javaがゴリゴリ書けるようになるツールではありません
Junitによるデバッグ作業を行うまでに至るプロセスが大変めんどくさいので自動化しました。NeoVimの使い手がいらっしゃいましたらご自由にお使い下さい。コンパイルから必要なファイルのコピーまで教員から要求された操作のすべてを自動化しております。また、import java.io.*; や class workYY 、public static void ... などプログラムの冒頭部分も地味に面倒なので、演習用のディレクトリにおいて新規ファイルは自動で入力されるように実装しました。

## How to install
本プラグインは dein.vim でのインストールを推奨しています。それ以外は自己責任でお願いします。

```viml:init.vim
call dein#add('kushimoto/jph')
```

## How to use
まずは init.vim に以下の変数宣言を追加して下さい。

```viml

" 下半分をターミナルウィンドウにする場合
let g:window_setting = 1

" 既に下半分をターミナルウィンドウにする設定を施している場合
let g:window_setting = 0
```
コマンド
```viml
:Jph
```
コマンドを実行すると一連の操作が行われます。下ウィンドウのターミナルでコンパイルされた際にエラーが出ていなければ成功です。デバッグによって出力されたファイルも確認しておくと確実です。

