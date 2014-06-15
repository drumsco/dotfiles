#bash, zsh共通設定の読み込み
if [ -f ~/.zashrc ]; then
    . ~/.zashrc
fi


# 重複パスの除去
# http://d.hatena.ne.jp/yascentur/20111111/1321015289
#LD_LIBRARY_PATH=${HOME}/lib:$LD_LIBRARY_PATH
#INCLUDE=${HOME}/include:$INCLUDE

[ -z "$ld_library_path" ] && typeset -T LD_LIBRARY_PATH ld_library_path
[ -z "$include" ] && typeset -T INCLUDE include
typeset -U path cdpath fpath manpath ld_library_path include
fpath=(~/.zsh/completions/ $fpath)

# 基本設定 {{{
# ファイルがある場合のリダイレクト(>)の防止したい場合は>!を使う
setopt noclobber

# 対話シェルでコメントを使えるようにする
setopt interactive_comments
# zmv
# http://ref.layer8.sh/ja/entry/show/id/2694
# http://d.hatena.ne.jp/mollifier/20101227/p1
autoload -Uz zmv
alias zmv='zmv -W'
# add-zsh-hook precmd functionするための設定
# http://d.hatena.ne.jp/kiririmode/20120327/p1
autoload -Uz add-zsh-hook
# }}}
# alias {{{
# ============================================================================
alias hgr='history 1 | grep -C 3'
# }}}
# グローバルエイリアス {{{
alias -g A='| awk'
alias -g L='| less -R'
alias -g H='| head'
alias -g T='| tail -f'
alias -g R='| tail -r'
alias -g V='| vim -R -'
alias -g G='| grep'
alias -g E='| egrep'
alias -g GI='| egrep -i'
alias -g X='-print0 | xargs -0'
alias -g C="2>&1 | sed -e 's/.*ERR.*/[31m&[0m/' -e 's/.*WARN.*/[33m&[0m/'"
alias -g TGZ='| gzip -dc | tar xf -'
# }}}
# プロンプト {{{
# ==============================================================================
# 最後に改行のない出力をプロンプトで上書きするのを防ぐ
# unsetopt promptcr
# バージョン4.3.0からはデフォルトでセットされるprompt_spというオプションで
# 最後に改行がない場合は%か#を最後に加えて改行されるようになった。

# 現在のホストによってプロンプトの色を変える。
# 256色の内、カラーで背景黒の時見やすい色はこの216色かな
colArr=({1..6} {9..14} {22..59} {61..186} {190..229})

# hostnameをmd5でハッシュに変更し、1-217の数値を生成する
# hostnameが長いとエラーが出るので最初の8文字を使う
if which md5 1>/dev/null 2>&1; then
    md5=md5
else
    md5=md5sum
fi
host_num=$((0x`hostname | $md5 | cut -c1-8` % 216 + 1)) # zshの配列のインデックスは1から
user_num=$((0x`whoami   | $md5 | cut -c1-8` % 216 + 1))

host_color="%{"$'\e'"[38;5;$colArr[$host_num]m%}"
user_color="%{"$'\e'"[38;5;$colArr[$user_num]m%}"

reset_color=$'\e'"[0m"
fg_yellow=$'\e'"[33m"
fg_red=$'\e'"[31m"
bg_red=$'\e'"[41m"

PROMPT="${user_color}%n%{${reset_color}%}@${host_color}%M%{${reset_color}%} %F{blue}%U%D{%Y-%m-%d %H:%M:%S}%u%f
%0(?|%{$fg_yellow%}|%18(?|%{$fg_yellow%}|%{$bg_red%}))%~%(!|#|$)%{${reset_color}%} "

PROMPT2="%_> "

# コマンド実行時に右プロンプトをけす
# setopt transient_rprompt

# command correct edition before each completion attempt
setopt correct
SPROMPT="%{$fg_yellow%}%r is correct? [n,y,a,e]:%{${reset_color}%} "

# 参考にしたサイト
# ■zshで究極のオペレーションを：第3回　zsh使いこなしポイント即効編｜gihyo.jp … 技術評論社
#  - http://gihyo.jp/dev/serial/01/zsh-book/0003
#  - C-zでサスペンドしたとき(18)以外のエラー終了時の設定を参考にした
#  - エスケープシーケンスの記述、プロンプトで使える特殊文字の表がある
# ■【コラム】漢のzsh (2) 取りあえず、プロンプトを整えておく。カッコつけたいからね | エンタープライズ | マイナビニュース
#  - http://news.mynavi.jp/column/zsh/002/index.html
#  - SPROMPTの設定
# ■zshでログイン先によってプロンプトに表示されるホスト名の色を自動で変える - absolute-area
#  - http://absolute-area.com/post/6664864690/zsh
# ■The 256 color mode of xterm
#  - http://frexx.de/xterm-256-notes/
# ■可愛いzshの作り方 - プログラムモグモグ
#  - http://d.hatena.ne.jp/itchyny/20110629/1309355617
#  - 顔文字を参考にした
# }}}
# 補完 {{{
autoload -U compinit && compinit
# bash用の補完を使うためには以下の設定をする
# https://github.com/dsanson/pandoc-completion
# autoload bashcompinit
# bashcompinit
# source "/path/to/hoge-completion.bash"

# compacked complete list display
setopt list_packed

zstyle ':completion:*' list-colors 'di=;34;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
# 今いるディレクトリを補完候補から外す
# http://qiita.com/items/7916037b1384d253b457
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*' use-cache true
# 補完対象が2つ以上の時、選択できるようにする
zstyle ':completion:*:default' menu select=2

# Incremental completion on zsh
# http://mimosa-pudica.net/zsh-incremental.html
if [ -f ~/.zsh/plugin/incr-0.2.zsh ]; then
    . ~/.zsh/plugin/incr-0.2.zsh
fi

## 補完関数を作るための設定 {{{
# http://www.ayu.ics.keio.ac.jp/~mukai/translate/write_zsh_functions.html
zstyle ':completion:*' verbose yes
#zstyle ':completion:*' format '%BCompleting %d%b'
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# site-functionsのリロード
rsf() {
  local f
  f=(~/local/share/zsh/site-functions/*(.))
  unfunction $f:t 2> /dev/null
  autoload -U $f:t
}
## }}}
# }}}
# keybind {{{
bindkey -e # emacs like
# bindkey -v # vi like
bindkey "^/" undo
bindkey "^[/" redo
bindkey "^[v" quoted-insert
# DELで一文字削除
bindkey "^[[3~" delete-char
# HOMEで行頭へ
bindkey "^[[1~" beginning-of-line
# Endで行末へ
bindkey "^[[4~" end-of-line

# 前方一致ヒストリ履歴検索
bindkey "^N" history-beginning-search-forward
bindkey "^P" history-beginning-search-backward

# カーソル位置が行末になったほうがいい人の設定
# 漢のzsh (4) コマンド履歴の検索～EmacsとVi、どっちも設定できるぜzsh <http://news.mynavi.jp/column/zsh/004/>
# autoload history-search-end
# zle -N history-beginning-search-backward-end history-search-end
# zle -N history-beginning-search-forward-end history-search-end
# history-beginning-search-backward-end
# history-beginning-search-forward-end

# 2行以上あるとき、^p,^nで上下にしたいときは以下の設定。
# ただし、ヒストリ検索のときカーソルが行末になる
# autoload -U up-line-or-beginning-search down-line-or-beginning-search 
# zle -N up-line-or-beginning-search
# zle -N down-line-or-beginning-search
# bindkey "^P" up-line-or-beginning-search
# bindkey "^N" down-line-or-beginning-search
# Zsh - コード片置き場 <https://sites.google.com/site/codehen/environment/zsh>

# グロブ(*)が使えるインクリメンタルサーチ
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward
## C-sでのヒストリ検索が潰されてしまうため、出力停止・開始用にC-s/C-qを使わない。
setopt no_flow_control

# 単語境界とみなさない記号の設定
# /を入れないことでを単語境界とみなし、Ctrl+Wで1ディレクトリだけ削除できるようにする
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# menuselectのキーバインド
zmodload -i zsh/complist
bindkey -M menuselect \
    '^p' up-line-or-history '^n' down-line-or-history \
    '^b' backward-char '^f' forward-char \
    '^o' accept-and-infer-next-history
bindkey -M menuselect "\e[Z" reverse-menu-complete # Shift-Tabで補完メニューを逆に選ぶ
# bindkey -M menuselect '^i' menu-expand-or-complete # 一回のCtrl+I or Tabで補完メニューの最初の候補を選ぶ
# }}}
# ディレクトリ関連 {{{
# ==============================================================================
# auto change directory
setopt auto_cd
# シンボリックリンクのディレクトリにcdしたら実際のディレクトリに移る
# setopt chase_links

# directory stack {{{
# ------------------------------------------------------------------------------
# auto directory pushd that you can get dirs list by cd -(+)[tab]
# -:古いのが上、+:新しいのが上
setopt auto_pushd
# cd -[tab]とcd +[tab]の役割を逆にする
setopt pushd_minus
# pushdで同じディレクトリを重複してpushしない
setopt pushd_ignore_dups
# 保存するディレクトリスタックの数
DIRSTACKSIZE=10

## ディレクトリスタックをファイルに保存することで端末間で共有したり、ログアウトしても残るようにする {{{
# http://sanrinsha.lolipop.jp/blog/2012/02/%E3%83%87%E3%82%A3%E3%83%AC%E3%82%AF%E3%83%88%E3%83%AA%E3%82%B9%E3%82%BF%E3%83%83%E3%82%AF%E3%82%92%E7%AB%AF%E6%9C%AB%E9%96%93%E3%81%A7%E5%85%B1%E6%9C%89%E3%81%97%E3%81%9F%E3%82%8A%E3%80%81%E4%BF%9D.html
test ! -d ~/.zsh && mkdir ~/.zsh
test ! -f ~/.zsh/.dirstack && touch ~/.zsh/.dirstack
# プロンプトが表示される前にディレクトリスタックを更新する
function share_dirs_precmd {
    if which tac 1>/dev/null 2>&1;then
        taccmd=`which tac`
    else
        taccmd='tail -r'
    fi

    pwd >> ~/.zsh/.dirstack
    # ファイルの書き込まれたディレクトリを移動することでディレクトリスタックを更新
    while read line
    do
        # ディレクトリが削除されていることもあるので調べる
        [ -d $line ] && cd $line
    done < ~/.zsh/.dirstack
    # 削除されたディレクトリが取り除かれた新しいdirsを時間の昇順で書き込む
    dirs -v | awk '{print $2}' | sed "s|~|${HOME}|" | eval ${taccmd} >! ~/.zsh/.dirstack
}
# ファイルサーバーに接続している環境だと遅くなるので設定しない
if [[ `uname` != Darwin ]]; then
    # autoload -Uz add-zsh-hookが必要
    add-zsh-hook precmd  share_dirs_precmd
fi
# }}} }}}
# cdr
# ----------------------------------------------------------------------------
# zshでcdの履歴管理に標準添付のcdrを使う - @znz blog <http://blog.n-z.jp/blog/2013-11-12-zsh-cdr.html>
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    mkdir -p ${ZDOTDIR}/.cache
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    # zstyle ':completion:*:*:cdr:*:*' menu selection
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 500
    zstyle ':chpwd:*' recent-dirs-file "${ZDOTDIR}/.cache/chpwd-recent-dirs"
    # zstyle ':chpwd:*' recent-dirs-pushd true
fi
# }}}
# 履歴 {{{
# =============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
## ヒストリファイルにコマンドラインだけではなく実行時刻と実行時間も保存する。
setopt extended_history
## 同じコマンドラインを連続で実行した場合はヒストリに登録しない。
setopt hist_ignore_dups
## スペースで始まるコマンドラインはヒストリに追加しない。
setopt hist_ignore_space
## すぐにヒストリファイルに追記する。
#setopt inc_append_history
# share_historyをしていれば必要ない
# http://www.ayu.ics.keio.ac.jp/~mukai/translate/zshoptions.html#SHARE_HISTORY
## zshプロセス間でヒストリを共有する。
setopt share_history
# }}}
# set terminal title including current directory {{{
#==============================================================================
case "${TERM}" in
kterm*|xterm)
    terminal_title_precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    add-zsh-hook precmd terminal_title_precmd
    ;;
esac
# }}}
# tmux & screen {{{
# ============================================================================
if [ $TERM = screen ];then
    # ウィンドウ名をディレクトリ名@ホスト名(コマンド実行時はコマンド名@ホスト名)にする
    tmux_preexec() {
        mycmd=(${(s: :)${1}})
        echo -ne "\ek${1%% *}@${HOST%%.*}\e\\"
    }

    tmux_precmd() {
        echo -ne "\ek$(basename $(pwd))@${HOST%%.*}\e\\"
    }
    add-zsh-hook preexec tmux_preexec
    add-zsh-hook precmd tmux_precmd
    # tmuxでset-window-option -g automatic-rename offが聞かない場合の設定
    # http://qiita.com/items/c166700393481cb15e0c
    DISABLE_AUTO_TITLE=true
fi
# }}}
## 改行でls {{{
## http://d.hatena.ne.jp/kei_q/20110406/1302091565
#alls() {
#  if [[ -z "$BUFFER" ]]; then
#      echo ''
#      ls
#  fi
#  zle accept-line
#}
#zle -N alls
#bindkey "\C-m" alls
#bindkey "\C-j" alls
##}}}
if [ -f ~/.zsh/plugin/z.sh ]; then
    _Z_CMD=j
    source ~/.zsh/plugin/z.sh
fi

if [ -f ~/.zshrc.local ]; then
    . ~/.zshrc.local
fi

if [[ `uname` = CYGWIN* ]]; then
    test -f $ZDOTDIR/.zshrc.cygwin && . $ZDOTDIR/.zshrc.cygwin
else
    test -f $ZDOTDIR/.zshrc.vcs && . $ZDOTDIR/.zshrc.vcs
fi
