# 荊街データ小屋　解析プログラム
百合鏡データ小屋は[百合鏡](http://csyuki.sakura.ne.jp/cgi-bin/prism/)を解析して得られるデータを扱った情報サイトです。  
このプログラムは四城半データ小屋で実際に使用している解析・DB登録プログラムです。  
データ小屋の表示部分については[別リポジトリ](https://github.com/white-mns/ibara_rails)を参照ください。

# サイト
実際に動いているサイトです。  
[百合鏡データ小屋](https://data.teiki.org/yk/)

# 動作環境
以下の環境での動作を確認しています  
  
OS:CentOS release 6.5 (Final)  
DB:MySQL 8.0.13
Perl:5.10.1  

## 必要なもの

bashが使えるLinux環境。（Windowsでやる場合、execute.shの処理を手動で行ってください）  
perlが使える環境  
デフォルトで入ってないモジュールを使ってるので、

    cpan DateTime

みたいにCPAN等を使ってDateTimeやHTML::TreeBuilderといった足りないモジュールをインストールしてください。

## 使い方
git cloneで作成されたディレクトリの直下に`data/orig`、`data/utf`を作成します。  

第1回更新なら

    ./execute.sh 1 0

とします。本家から圧縮結果をダウンロードして解析を行います。  
再更新があった場合、

    ./execute.sh 1 1

とすることで再更新前の圧縮結果を保存しつつ、再更新後の結果をダウンロードすることができます。  
なお、再更新前の圧縮結果を残したまま

    ./execute.sh 1 0

と実行すると、ダウンロード済の圧縮ファイルを利用して再解析します。

    ./execute.sh 1

と更新回だけ指定すると、ダウンロード済で最も新しい（≒確定した）圧縮結果を利用して再解析します。

（ただし、データ小屋では仕様上、再更新前、再更新後のデータを同時に登録しないようにしています）  
上手く動けばoutput内に中間ファイルcsvが生成され、指定したDBにデータが登録されます。  
`ConstData.pm`及び`ConstData_Upload.pm`を書き換えることで、処理を実行する項目を制限できます。  
    
    ./_execute_all.sh 1 5

とすると、第1回更新結果から第5回更新結果までの確定結果を再解析します。

## DB設定
`source/DbSetting.pm`にサーバーの設定を記述します。  
DBのテーブルは[Railsアプリ側](https://github.com/white-mns/yurikagami_rails)で`rake db:migrate`して作成しています。

## 中間ファイル
DBにアップロードしない場合、固有名詞を数字で置き換えている箇所があるため、csvファイルを読むのは難しいと思います。

    $$common_datas{ProperName}->GetOrAddId($$data[2])

のような`GetorAddId`、`GetId`関数で変換していますので、似たような箇所を全て

    $$data[2]

のように中身だけに書き換えることで元の文字列がcsvファイルに書き出され読みやすくなります。

## 絵文字
　データに絵文字を含むデータを扱う場合、mysqlであればmy.cnfに

    [libmysqlclient]
    default-character-set = utf8mb4

という二行を追加する必要があります。追加しない場合、絵文字を含むデータは正しくアップロードされません。（エラーは起きないので、絵文字を含まない文字列は正しい表示でアップロードされます）

## ライセンス
本ソフトウェアはMIT Licenceを採用しています。 ライセンスの詳細については`LICENSE`ファイルを参照してください。
