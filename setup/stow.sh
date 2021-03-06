#!/usr/bin/env bash
set -eux
# stowについて
# http://rcmdnk.github.io/blog/2013/08/11/computer-linux-windows-cygwin/
# http://blog.glidenote.com/blog/2012/08/10/stow/

# 予めディレクトリを作成しておかないと、stowコマンド打った時、
# ディレクトリのシンボリックリンクができてしまう
mkdir -p $HOME/local/{\
stow,\
Library/Perl/5.16,\
bin,\
include,\
share/{doc,info,man}\
}

if type mktemp 1>/dev/null 2>&1; then
    tmpdir=`mktemp -d /tmp/XXXXXX`
else
    mkdir -p ~/tmp/$$
    tmpdir="$HOME/tmp/$$"
fi

cd $tmpdir
if which curl;then
    curl='curl -L'
elif which wget;then
    curl='wget -O -'
else
    echo 'curlまたはwgetをインストールしてください'
    exit 1
fi

$curl http://ftp.gnu.org/gnu/stow/stow-latest.tar.gz | gzip -dc | tar xf -
pkg_ver=$(ls)
cd $pkg_ver
./configure --prefix=$HOME/local/stow/$pkg_ver
# GNU makeじゃないとしくじる
make
make install
cd ~/local/stow

# http://gateman-on.blogspot.jp/2013/02/stow.html
# 以下のオプションを付けないと、dirファイルが他パッケージとかぶってエラーが出る
./$pkg_ver/bin/stow $pkg_ver --ignore=share/info/dir
