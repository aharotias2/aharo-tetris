AhoRis
====================================================================================================
“アホリス”といいつつ、取り立ててアホでもない、でもやっぱりすこしアホな気がするテトリス。
とさせるテトリス。

GTK+3を使用したLinux用のデスクトップアプリケーションですが最近はWindowsでもGTKのアプリを起動できるら
しい(動作未確認)です。

![画像](docs/images/screenshot-1.png)

テトリスの歴史
----------------------------------------------------------------------------------------------------
> 元々はソビエト連邦（現・ロシア）の科学者アレクセイ・パジトノフ（Алексей
> Леонидович Пажитнов、ラテン文字転写Alexey Leonidovich Pajitnov）など3人が教育用
> ソフトウェアとして開発した作品である。1984年6月6日に初めてプレイ可能な版が開発された[1]後、様々な
> ゲーム制作会社にライセンス供給され、各種のプラットフォーム上で乱立する状態になった。

-- Wikipedia より

Wikipediaに記載されていない点を補足すると、テトリスは非常に中毒性の高いゲームであるが、
これは実は冷戦時代のソ連がアメリカの国力を落とす目的でそのようにしたという説が巷では定説となっている。

その説が本当だとすれば、このプログラミングの難しさもなるほど納得であるが、実際には中毒性が知られるよ
うになってから色々陰謀に使われるようになったとかならないとか。

ライセンス
----------------------------------------------------------------------------------------------------
昔、任天堂とセガが独占販売権を巡って皿で皿を洗う抗争を繰り広げたということで、
ライセンス関係は色々地雷らしいですね。

とは言え、ネット上には模造品が山ほど転がっているし、商用利用していないので大丈夫に違いありません。

ビルド方法
----------------------------------------------------------------------------------------------------
普通にmesonビルドシステムを利用してビルドします。

    $ meson --prefix=/usr/local build
	$ cd build
	$ ninja
	$ sudo ninja install

そのうちAppImageも作ります。

----------------------------------------------------------------------------------------------------

Copyright (C) 2021 田中喬之
