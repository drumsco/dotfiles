" {{{
scriptencoding utf-8 "vimrcの設定でマルチバイト文字を使うときに必要
set encoding=utf-8 "vimrcのエラーメッセージが文字化けしないように早めに設定

let $VIMDIR = expand('~/.vim')
let $VIMRC_DIR = $VIMDIR . '/rc'

if has('win32')
    set runtimepath&
    set runtimepath^=$HOME/.vim
    set runtimepath+=$HOME/.vim/after
    cd ~
endif

function! SourceRc(path) " {{{
    if filereadable(expand("$VIMRC_DIR/".a:path))
        execute "source $VIMRC_DIR/".a:path
    endif
endfunction " }}}
function! MyHasPatch(str) " {{{
    if has('patch-7.4.237')
        return has(a:str)
    else
        let patches =  split(matchstr(a:str, '\v(\d|\.)+'), '\.')
        return v:version >  patches[0] . 0 . patches[1] ||
            \  v:version == patches[0] . 0 . patches[1] && has('patch' . patches[2])
    endif
endfunction " }}}
" Pluginの有無をチェック {{{
" runtimepathにあるか
" http://yomi322.hateblo.jp/entry/2012/06/20/225559
function! HasPlugin(plugin)
  return !empty(globpath(&runtimepath, 'plugin/'   . a:plugin . '.vim'))
  \   || !empty(globpath(&runtimepath, 'autoload/' . a:plugin . '.vim'))
  \   || !empty(globpath(&runtimepath, 'colors/'   . a:plugin . '.vim'))
endfunction
" NeoBundleLazyを使うと最初はruntimepathに含まれないため、
" neobundle#is_installedを使う
" 直接使うとneobundleがない場合にエラーが出るので確認
function! IsInstalled(plugin)
    if HasPlugin('neobundle') && MyHasPatch('patch-7.2.051')
        return neobundle#is_installed(a:plugin)
    else
        return 0
    endif
endfunction
" }}}
" vimrc全体で使うaugroup {{{
" http://rhysd.hatenablog.com/entry/2012/12/19/001145
" autocmd!の回数を減らすことでVimの起動を早くする
" ネームスペースを別にしたい場合は別途augroupを作る
augroup MyVimrc
    autocmd!
augroup END
" }}}

call SourceRc('local_pre.vim')
" }}}
" 基本設定 {{{
" ============================================================================
set showmode "現在のモードを表示
set showcmd "コマンドを表示
set cmdheight=2 "コマンドラインの高さを2行にする
set number
set ruler
set cursorline
set t_Co=256 " 256色

set showmatch matchtime=1 "括弧の対応
set matchpairs& matchpairs+=<:>
" 7.3.769からmatchpairsにマルチバイト文字が使える
if MyHasPatch('patch-7.3.769')
    set matchpairs+=（:）,「:」
endif
runtime macros/matchit.vim "HTML tag match

" 不可視文字の表示 {{{
set list
set listchars=tab:»-,trail:_,extends:»,precedes:«,nbsp:% ",eol:↲

" 全角スペースをハイライト （Vimテクニックバイブル1-11）
syntax enable
scriptencoding utf-8
augroup MyVimrc
    autocmd VimEnter,WinEnter * match IdeographicSpace /　/
    autocmd ColorScheme * highlight IdeographicSpace term=underline ctermbg=67 guibg=#5f87af
augroup END
" }}}

set textwidth=0

set formatoptions&
" r : Insert modeで<Enter>を押したら、comment leaderを挿入する
set formatoptions+=r
" M : マルチバイト文字の連結(J)でスペースを挿入しない
set formatoptions+=M
if MyHasPatch('patch-7.3.541') && MyHasPatch('patch-7.3.550')
    " j : コメント行の連結でcomment leaderを取り除く
    set formatoptions+=j
endif
" t : textwidthを使って自動的に折り返す
set formatoptions-=t
" c : textwidthを使って、コマントを自動的に折り返しcomment leaderを挿入する
set formatoptions-=c
" o : Normal modeでoまたOを押したら、comment leaderを挿入する
set formatoptions-=o

" CTRL-AやCTRL-Xを使った時の文字の増減の設定
" 10進数と16進数を増減させる。
" 0で始まる数字列を8進数とみなさず、10進数として増減させる。
" アルファベットは増減させない
set nrformats=hex

"変更中のファイルでも、保存しないで他のファイルを表示
set hidden
set foldmethod=marker
set shellslash

" macに最初から入っているvimはセキュリティの問題からシステムのvimrcでset modelines=0している。
" http://unix.stackexchange.com/questions/19875/setting-vim-filetype-with-modeline-not-working-as-expected
" この問題は7.0.234と7.0.235のパッチで修正された
" https://bugzilla.redhat.com/show_bug.cgi?id=cve-2007-2438
if MyHasPatch('patch-7.0.234') && MyHasPatch('patch-7.0.235')
    set modelines&
else
    set modelines=0
endif

" pasteモードのトグル。autoindentをonにしてペーストすると
" インデントが入った文章が階段状になってしまう。
" pasteモードではautoindentが解除されそのままペーストできる
set pastetoggle=<F11>
" ターミナルで自動でpasteモードに変更する設定は.cvimrc参照

set mouse=a

" if has('path_extra')
"     set tags=./tags;~,~/**2/tags
" endif
set helplang=en,ja
"}}}
" 文字コード・改行コード {{{
" ==============================================================================
" 文字コード
set encoding=utf-8
set fileencoding=utf-8

" ファイルのエンコードの判定を前から順番にする
" ファイルを読み込むときに 'fileencodings' が "ucs-bom" で始まるならば、
" BOM が存在するかどうかが調べられ、その結果に従って 'bomb' が設定される。
" http://vim-jp.org/vimdoc-ja/options.html#%27fileencoding%27
" 以下はVimテクニックバイブル「2-7ファイルの文字コードを変換する」に書いてあるfileencodings。
" ただし2つあるeuc-jpの2番目を消した
" if has("win32")
    " set fileencodings=iso-2222-jp-3,iso-2022-jp,euc-jisx0213,euc-jp,utf-8,ucs-bom,eucjp-ms,cp932
" else
    " 上の設定はたまに誤判定をするので、UNIX上で開く可能性があるファイルのエンコードに限定
    " set fileencodings=ucs-boms,utf-8,euc-jp,cp932
" endif

if ! has('guess_encode')
    set fileencodings=ucs-boms,utf-8,euc-jp,cp932
endif

" エンコーディングを指定して開き直す
command! EncCp932     edit ++enc=cp932
command! EncEucjp     edit ++enc=euc-jp
command! EncIso2022jp edit ++enc=iso-2022-jp
command! EncUtf8      edit ++enc=uff-8
" alias
command! EncJis  EncIso2022jp
command! EncSjis EncCp932

" 改行
set fileformat=unix
set fileformats=unix,dos,mac
" 改行コードを指定して開き直すには
"  :e ++ff=dos
" などとする

"□や○の文字があってもカーソル位置がずれないようにする
set ambiwidth=double
"}}}
" mapping {{{
" ------------------------------------------------------------------------------
" :h map-modes
" gvimにAltのmappingをしたい場合は先にset encoding=...をしておく

" key mappingに対しては3000ミリ秒待ち、key codeに対しては10ミリ秒待つ
set timeout timeoutlen=9000 ttimeoutlen=10
if exists('+macmeta')
   " MacVimでMETAキーを使えるようにする
   set macmeta
endif
" let mapleader = "\<space>"

" prefix
" http://blog.bouzuya.net/2012/03/26/prefixedmap-vim/
" [Space]でmapするようにするとVimFilerのスペースキーでキー待ちが発生しなくなる
noremap [Space]   <Nop>
map <Space> [Space]

noremap ; :
noremap : ;

inoremap jj <ESC>
"cnoremap jj <ESC>
nnoremap Y y$

"挿入モードのキーバインドをemacs風に
inoremap <C-a> <Home>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-d> <Del>
" neocomplcacheにて設定
" inoremap <C-h> <BS>
" inoremap <C-n> <Down>
" inoremap <C-p> <Up>
" inoremap <C-e> <End>
" neosnippetにて設定
" inoremap <C-k> <C-o>D

" インデントを考慮したペースト]p,]Pとペーストしたテキストの最後に行くペーストgp,gPを合わせたようなもの
nnoremap ]gp ]p`]j
nnoremap ]gP ]P`]j

" inoremap <expr> <C-d> "\<C-g>u".(col('.') == col('$') ? '<Esc>^y$A<Space>=<Space><C-r>=<C-r>"<CR>' : '<Del>')
inoremap <Leader>= <Esc>^y$A<Space>=<Space><C-r>=<C-r>"<CR>
" }}}
" swap, backup, undo {{{
" ==============================================================================
" デフォルトの設定にある~/tmpを入れておくと、swpファイルが自分のホームディレクトリ以下に生成されてしまい、他の人が編集中か判断できなくなるので除く
set directory&
set directory-=~/tmp
" 他の人が編集する可能性がない場合はswapファイルを作成しない
if has('win32') || has('mac')
    set noswapfile
endif

" 富豪的バックアップ
" http://d.hatena.ne.jp/viver/20090723/p1
" http://synpey.net/?p=127
" savevers.vimが場合はそちらを使う
if ! HasPlugin('savevers')
    set backup
    set backupdir=$VIMDIR/.bak

    augroup backup
        autocmd!
        autocmd BufWritePre,FileWritePre,FileAppendPre * call UpdateBackupFile()
        function! UpdateBackupFile()
            let basedir = expand("$VIMDIR/.bak")
            let dir = strftime(basedir."/%Y%m/%d", localtime()).substitute(expand("%:p:h"), '\v\c^([a-z]):', '/\1/' , '')
            if !isdirectory(dir)
                call mkdir(dir, "p")
            endif

            let dir = escape(dir, ' ')
            exe "set backupdir=".dir
            let time = strftime("%H-%M", localtime())

            exe "set backupext=.".time
        endfunction
    augroup END
endif

" アンドゥの履歴をファイルに保存し、Vim を一度終了したとしてもアンドゥやリドゥを行えるようにする
" 開いた時に前回保存時と内容が違う場合はリセットされる
if has('persistent_undo')
    set undofile
    if !isdirectory($VIMDIR.'/.undo')
        call mkdir($VIMDIR.'/.undo')
    endif
    set undodir=$VIMDIR/.undo
endif

" Always Jump to the Last Known Cursor Position
autocmd MyVimrc BufReadPost *
            \ if line("`\"") > 1 && line("`\"") <= line("$") |
            \   execute "normal! g`\"" |
            \ endif

"}}}
" タブ・インデント {{{
" ==============================================================================
"ファイル内の <Tab> が対応する空白の数
set tabstop=4
"<Tab> の挿入や <BS> の使用等の編集操作をするときに、<Tab> が対応する空白の数
set softtabstop=4
"インデントの各段階に使われる空白の数
set shiftwidth=4
set expandtab
"新しい行のインデントを現在行と同じくする
set autoindent
set smartindent
"}}}
" ステータスライン {{{
" ==============================================================================

" 最下ウィンドウにいつステータス行が表示されるかを設定する。
"               0: 全く表示しない
"               1: ウィンドウの数が2以上のときのみ表示
"               2: 常に表示
set laststatus=2

"set statusline=%f%=%m%r[%{(&fenc!=''?&fenc:&enc)}][%{&ff}][%Y][%v,%l]\ %P
"set statusline=%f%=%<%m%r[%{(&fenc!=''?&fenc:&enc)}][%{&ff}][%Y][%v,%l/%L]
"}}}
" window {{{
" ==============================================================================
"nnoremap <M-h> <C-w>h
"nnoremap <M-j> <C-w>j
"nnoremap <M-k> <C-w>k
"nnoremap <M-l> <C-w>l
nnoremap <M--> <C-w>-
nnoremap <M-+> <C-w>+
nnoremap <M-,> <C-w><
nnoremap <M-.> <C-w>>
nnoremap <M-0> <C-w>=
nnoremap <C-w>; <C-w>p

set splitbelow
set splitright

"  常にカーソル行を真ん中に
"set scrolloff=999

"縦分割されたウィンドウのスクロールを同期させる
"同期させたいウィンドウ上で<F12>を押せばおｋ
"解除はもう一度<F12>を押す
"横スクロールも同期させたい場合はこちら
"http://ogawa.s18.xrea.com/fswiki/wiki.cgi?page=Vim%A4%CE%A5%E1%A5%E2
"nnoremap <F12> :set scrollbind!<CR>
"}}}
" タブ {{{
" ==============================================================================
"  いつタブページのラベルを表示するかを指定する。
"  0: 表示しない
"  1: 2個以上のタブページがあるときのみ表示
"  2: 常に表示
set showtabline=1

nnoremap [TAB] <Nop>
nmap <C-@> [TAB]
" 一番右にタブを作る
nnoremap [TAB]c :tablast <Bar> tabnew<CR>
nnoremap [TAB]q :tabc<CR>

nnoremap <C-Tab> :tabn<CR>
nnoremap <S-C-Tab> :tabp<CR>

nnoremap [TAB]n :tabn<CR>
nnoremap [TAB]p :tabp<CR>

nnoremap <C-p> gT
nnoremap <C-n> gt

nnoremap <M-n> :tabn<CR>
nnoremap <M-p> :tabp<CR>
nnoremap <M-1> :1tabn<CR>
nnoremap <M-2> :2tabn<CR>
nnoremap <M-3> :3tabn<CR>
nnoremap <M-4> :4tabn<CR>
nnoremap <M-5> :5tabn<CR>
nnoremap <M-6> :6tabn<CR>
nnoremap <M-7> :7tabn<CR>
nnoremap <M-8> :8tabn<CR>
nnoremap <M-9> :9tabn<CR>
nnoremap <M-0> :10tabn<CR>
nnoremap [TAB]1 :1tabn<CR>
nnoremap [TAB]2 :2tabn<CR>
nnoremap [TAB]3 :3tabn<CR>
nnoremap [TAB]4 :4tabn<CR>
nnoremap [TAB]5 :5tabn<CR>
nnoremap [TAB]6 :6tabn<CR>
nnoremap [TAB]7 :7tabn<CR>
nnoremap [TAB]8 :8tabn<CR>
nnoremap [TAB]9 :9tabn<CR>
nnoremap [TAB]0 :10tabn<CR>
"}}}
" コマンドラインモード {{{
" ==============================================================================
" 補完 {{{
" ------------------------------------------------------------------------------
set wildmenu "コマンド入力時にTabを押すと補完メニューを表示する

" コマンドモードの補完をシェルコマンドの補完のようにする
" http://vim-jp.org/vimdoc-ja/options.html#%27wildmode%27
" <TAB>で共通する最長の文字列まで補完して一覧表示
" 再度<Tab>を打つと候補を選択。<S-Tab>で逆
set wildmode=list:longest,full
"}}}

"前方一致をCtrl+PとCtrl+Nで
cnoremap <C-P> <UP>
cnoremap <C-N> <DOWN>
cnoremap <UP> <C-P>
cnoremap <DOWN> <C-N>

" vim-emacscommandlineで<C-F>は右に進むになっているので、
" コマンドラインウィンドウを開きたいときは<Leader><C-F>にする
cnoremap <Leader><C-F> <C-F>

set history=100 "保存する履歴の数

" 外部コマンド実行でエイリアスを使うための設定
" http://sanrinsha.lolipop.jp/blog/2013/09/vim-alias.html
" bashスクリプトをquickrunで実行した時にエイリアス展開されてしまうのでコメント
" アウト
" let $BASH_ENV=expand('~/.bashenv')
" let $ZDOTDIR=expand('~/.vim/')
" 検索・置換 {{{
" ------------------------------------------------------------------------------
set incsearch
set ignorecase "検索パターンの大文字小文字を区別しない
set smartcase  "検索パターンに大文字を含んでいたら大文字小文字を区別する
set hlsearch   "検索結果をハイライト

" ESCキー2度押しでハイライトのトグル
nnoremap <Esc><Esc> :set hlsearch!<CR>

nnoremap * *N
nnoremap # g*N
" function! s:RegistSearchWord()
"     silent normal yiw
"     let @/ = '\<'.@".'\>'
" endfunction
"
" command! -range RegistSearchWord :call s:RegistSearchWord()
" nnoremap <silent> * :RegistSearchWord<CR>

" バックスラッシュやクエスチョンを状況に合わせ自動的にエスケープ
cnoremap <expr> /  getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ?  getcmdtype() == '?' ? '\?' : '?'
cnoremap <expr> \/ getcmdtype() == '/' ? '/'  : '\/'
cnoremap <expr> \? getcmdtype() == '?' ? '?'  : '\?'

"ヴィビュアルモードで選択した範囲だけ検索
xnoremap <Leader>/ <ESC>/\%V
xnoremap <Leader>? <ESC>?\%V

nnoremap "\<Leader>ss :%s/\<C-R>//"
xnoremap "\<Leader>ss :s/\<C-R>//"
" }}}
" }}}
" コマンドラインウィンドウ {{{
" ==============================================================================
" http://vim-users.jp/2010/07/hack161/
" nnoremap <sid>(command-line-enter) q:
" xnoremap <sid>(command-line-enter) q:
" nnoremap <sid>(command-line-norange) q:<C-u>
"
" nmap :  <sid>(command-line-enter)
" xmap :  <sid>(command-line-enter)

autocmd MyVimrc CmdwinEnter * call s:init_cmdwin()
function! s:init_cmdwin()
  nnoremap <buffer> q :<C-u>quit<CR>
  nnoremap <buffer> <TAB> :<C-u>quit<CR>
  inoremap <buffer><expr><CR> pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
  inoremap <buffer><expr><C-h> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"
  inoremap <buffer><expr><BS> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"

  " Completion.
  inoremap <buffer><expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

  startinsert!
endfunction
" }}}
" ビジュアルモード {{{
" =============================================================================
" ビジュアル矩形モードでなくても、IやAで挿入できるようにする {{{
" -----------------------------------------------------------------------------
" http://labs.timedia.co.jp/2012/10/vim-more-useful-blockwise-insertion.html
vnoremap <expr> I  <SID>force_blockwise_visual('I')
vnoremap <expr> A  <SID>force_blockwise_visual('A')

function! s:force_blockwise_visual(next_key)
    if mode() ==# 'v'
        return "\<C-v>" . a:next_key
    elseif mode() ==# 'V'
        return "\<C-v>0o$" . a:next_key
    else  " mode() ==# "\<C-v>"
        return a:next_key
    endif
endfunction
" 最後に変更したテキスト（ペーストした部分など）を選択
" ----------------------------------------------------------------------------
nnoremap gm `[v`]
vnoremap gm :<C-u>normal gm<CR>
onoremap gm :<C-u>normal gm<CR>
"}}}
"}}}
" ディレクトリ・パス {{{
" ==============================================================================
"augroup CD
"    autocmd!
"    autocmd BufEnter * execute ":lcd " . expand("%:p:h")
"augroup END
" 現在編集中のファイルのディレクトリをカレントディレクトリにする
nnoremap <silent><Leader>gc :cd %:h<CR>

" full path of file
inoremap <C-r>f <C-r>=expand('%:p:r')<CR>
cnoremap <C-r>f <C-r>=expand('%:p:r')<CR>
" full path of directory
inoremap <C-r>d <C-r>=expand('%:p:h')<CR>/
cnoremap <C-r>d <C-r>=expand('%:p:h')<CR>/
" " expand file (not ext)
" inoremap <C-r>f <C-r>=expand('%:p:r')<CR>
" cnoremap <C-r>f <C-r>=expand('%:p:r')<CR>

" Vim-users.jp - Hack #17: Vimを終了することなく編集中ファイルのファイル名を変更する
" http://vim-users.jp/2009/05/hack17/
command! -nargs=1 -complete=file Rename f <args>|call delete(expand('#'))
" }}}
" カーソル {{{
" ==============================================================================
" set virtualedit=block       " 矩形選択でカーソル位置の制限を解除

"カーソルを表示行で移動する。
nnoremap j gj
xnoremap j gj
nnoremap k gk
xnoremap k gk
nnoremap <down> gj
xnoremap <down> gj
nnoremap <up> gk
xnoremap <up> gk
nnoremap 0 g0
xnoremap 0 g0
nnoremap $ g$
" これをやると<C-V>$Aできなくなる
" xnoremap $ g$
nnoremap gj j
xnoremap gj j
nnoremap gk k
xnoremap gk k
nnoremap g0 0
xnoremap g0 0
nnoremap g$ $
xnoremap g$ $

" backspaceキーの挙動を設定する
" " indent        : 行頭の空白の削除を許す
" " eol           : 改行の削除を許す
" " start         : 挿入モードの開始位置での削除を許す
set backspace=indent,eol,start

" カーソルを行頭、行末で止まらないようにする。
" http://vimwiki.net/?'whichwrap'
"set whichwrap=b,s,h,l,<,>,[,],~
"}}}
" vimdiff {{{
" ==============================================================================
set diffopt=filler
nnoremap [VIMDIFF] <Nop>
nmap <Leader>d [VIMDIFF]
nnoremap <silent> [VIMDIFF]t :diffthis<CR>
nnoremap <silent> [VIMDIFF]u :diffupdate<CR>
nnoremap <silent> [VIMDIFF]o :diffoff<CR>
nnoremap <silent> [VIMDIFF]T :windo diffthis<CR>
nnoremap <silent> [VIMDIFF]O :windo diffoff<CR>
nnoremap          [VIMDIFF]s :vertical diffsplit<space>
"}}}
" Manual {{{
" ==============================================================================
":Man <man>でマニュアルを開く
runtime ftplugin/man.vim
nmap K <Leader>K
"コマンドラインでmanを使ったとき、vimの:Manで見るようにするための設定
"http://vim.wikia.com/wiki/Using_vim_as_a_man-page_viewer_under_Unix
".zshrc .bashrc等にも記述が必要
let $PAGER=''

"}}}
" vimrcの編集 {{{
" ==============================================================================
" http://vim-users.jp/2009/09/hack74/
" .vimrcと.gvimrcの編集
nnoremap [VIMRC] <Nop>
nmap <Leader>v [VIMRC]
" nnoremap <silent> [VIMRC]e :<C-u>edit $MYVIMRC<CR>
" nnoremap <silent> [VIMRC]E :<C-u>edit $MYGVIMRC<CR>
nnoremap <silent> [VIMRC]e :<C-u>edit ~/git/tmsanrinsha/dotfiles/home/.vimrc<CR>
nnoremap <silent> [VIMRC]E :<C-u>edit ~/git/tmsanrinsha/dotfiles/home/_gvimrc<CR>

" Load .gvimrc after .vimrc edited at GVim.
nnoremap <silent> [VIMRC]r :<C-u>source $MYVIMRC \| if has('gui_running') \| source $MYGVIMRC \| endif<CR>
nnoremap <silent> [VIMRC]R :<C-u>source $MYGVIMRC<CR>

""vimrc auto update
"augroup MyAutoCmd
"  autocmd!
"  " nested: autocmdの実行中に更に別のautocmdを実行する
"  autocmd BufWritePost .vimrc nested source $MYVIMRC
"  " autocmd BufWritePost .vimrc RcbVimrc
"augroup END
"}}}
" printing {{{
set printoptions=wrap:y,number:y,header:0
set printfont=Andale\ Mono:h12:cUTF8
"}}}
" Quickfix {{{
" ==============================================================================
nnoremap [q :cprevious<CR>   " 前へ
nnoremap ]q :cnext<CR>       " 次へ
nnoremap [Q :<C-u>cfirst<CR> " 最初へ
nnoremap ]Q :<C-u>clast<CR>  " 最後へ
noremap [quickfix] <Nop>
nmap <Leader>q [quickfix]
noremap [quickfix]o :copen<CR>
noremap [quickfix]c :cclose<CR>
nmap <Leader>l [location]
noremap [location]o :lopen<CR>
noremap [location]c :lclose<CR>

" show quickfix automatically
" これをやるとneocomlcacheの補完時にquickfix winodow（中身はtags）が開くのでコメントアウト
" autocmd MyVimrc QuickfixCmdPost * if !empty(getqflist()) | cwindow | lwindow | endif
"}}}
" Ip2host {{{
" ==============================================================================
function! s:Ip2host(line1, line2)
    for linenum in range(a:line1, a:line2)
        let oldline = getline(linenum)
        let newline = substitute(oldline,
                    \   '\v((%(2%([0-4]\d|5[0-5])|1\d\d|[1-9]?\d)\.){3}%(2%([0-4]\d|5[0-5])|1\d\d|[1-9]?\d))',
                    \   '\=substitute(system("nslookup ".submatch(1)), "\\v.*%(name = |:    )([0-9a-z-.]+).*", "\\1","")',
                    \   '')
        call setline(linenum, newline)
    endfor
endfunction

command! -range=% Ip2host call s:Ip2host(<line1>, <line2>)
" }}}
" color {{{
" ============================================================================
" カーソル以下のカラースキームの情報の取得 {{{
" ----------------------------------------------------------------------------
" http://cohama.hateblo.jp/entry/2013/08/11/020849
function! s:get_syn_id(transparent)
  let synid = synID(line("."), col("."), 1)
  if a:transparent
    return synIDtrans(synid)
  else
    return synid
  endif
endfunction
function! s:get_syn_attr(synid)
  let name = synIDattr(a:synid, "name")
  let ctermfg = synIDattr(a:synid, "fg", "cterm")
  let ctermbg = synIDattr(a:synid, "bg", "cterm")
  let guifg = synIDattr(a:synid, "fg", "gui")
  let guibg = synIDattr(a:synid, "bg", "gui")
  return {
        \ "name": name,
        \ "ctermfg": ctermfg,
        \ "ctermbg": ctermbg,
        \ "guifg": guifg,
        \ "guibg": guibg}
endfunction
function! s:get_syn_info()
  let baseSyn = s:get_syn_attr(s:get_syn_id(0))
  echo "name: " . baseSyn.name .
        \ " ctermfg: " . baseSyn.ctermfg .
        \ " ctermbg: " . baseSyn.ctermbg .
        \ " guifg: " . baseSyn.guifg .
        \ " guibg: " . baseSyn.guibg
  let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
  echo "link to"
  echo "name: " . linkedSyn.name .
        \ " ctermfg: " . linkedSyn.ctermfg .
        \ " ctermbg: " . linkedSyn.ctermbg .
        \ " guifg: " . linkedSyn.guifg .
        \ " guibg: " . linkedSyn.guibg
endfunction
command! SyntaxInfo call s:get_syn_info()
" }}}
" Rgb2xterm {{{
" ----------------------------------------------------------------------------
" true color(#FF0000など)を一番近い256色の番号に変換する
" http://d.hatena.ne.jp/y_yanbe/20080611
"" the 6 value iterations in the xterm color cube
let s:valuerange = [ 0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF ]

"" 16 basic colors
let s:basic16 = [ [ 0x00, 0x00, 0x00 ], [ 0xCD, 0x00, 0x00 ], [ 0x00, 0xCD, 0x00 ], [ 0xCD, 0xCD, 0x00 ], [ 0x00, 0x00, 0xEE ], [ 0xCD, 0x00, 0xCD ], [ 0x00, 0xCD, 0xCD ], [ 0xE5, 0xE5, 0xE5 ], [ 0x7F, 0x7F, 0x7F ], [ 0xFF, 0x00, 0x00 ], [ 0x00, 0xFF, 0x00 ], [ 0xFF, 0xFF, 0x00 ], [ 0x5C, 0x5C, 0xFF ], [ 0xFF, 0x00, 0xFF ], [ 0x00, 0xFF, 0xFF ], [ 0xFF, 0xFF, 0xFF ] ]

function! s:Xterm2rgb(color)
    " 16 basic colors
    let r=0
    let g=0
    let b=0
    if a:color<16
        let r = s:basic16[a:color][0]
        let g = s:basic16[a:color][1]
        let b = s:basic16[a:color][2]
    endif

    " color cube color
    if a:color>=16 && a:color<=232
        let color=a:color-16
        let r = s:valuerange[(color/36)%6]
        let g = s:valuerange[(color/6)%6]
        let b = s:valuerange[color%6]
    endif

    " gray tone
    if a:color>=233 && a:color<=253
        let r=8+(a:color-232)*0x0a
        let g=r
        let b=r
    endif
    let rgb=[r,g,b]
    return rgb
endfunction

function! s:pow(x, n)
    let x = a:x
    for i in range(a:n-1)
        let x = x*a:x
        return x
    endfor
endfunction

let s:colortable=[]
for c in range(0, 254)
    let color = s:Xterm2rgb(c)
    call add(s:colortable, color)
endfor

" selects the nearest xterm color for a rgb value like #FF0000
function! s:Rgb2xterm(color)
    let best_match=0
    let smallest_distance = 10000000000
    let r = eval('0x'.a:color[1].a:color[2])
    let g = eval('0x'.a:color[3].a:color[4])
    let b = eval('0x'.a:color[5].a:color[6])
    for c in range(0,254)
        let d = s:pow(s:colortable[c][0]-r,2) + s:pow(s:colortable[c][1]-g,2) + s:pow(s:colortable[c][2]-b,2)
        if d<smallest_distance
            let smallest_distance = d
            let best_match = c
        endif
    endfor
    return best_match
endfunction
command! -nargs=1 Rgb2xterm echo s:Rgb2xterm(<f-args>)
"" }}}
" }}}
" ftdetect {{{
" ==============================================================================
autocmd MyVimrc BufRead sanrinsha*
            \   setlocal filetype=mkd
" autocmd MyVimrc BufRead,BufNewFile *.md setlocal filetype=markdown
" MySQLのEditorの設定
" http://lists.ccs.neu.edu/pipermail/tipz/2003q2/000030.html
autocmd MyVimrc BufRead /var/tmp/sql* setlocal filetype=sql
autocmd MyVimrc BufRead,BufNewFile *apache*/*.conf setlocal filetype=apache
" }}}
" filetype {{{
" ============================================================================
nnoremap <Leader>fh :<C-u>setlocal filetype=html<CR>
nnoremap <Leader>fj :<C-u>setlocal filetype=javascript<CR>
nnoremap <Leader>fm :<C-u>setlocal filetype=markdown<CR>
nnoremap <Leader>fp :<C-u>setlocal filetype=php<CR>
nnoremap <Leader>fs :<C-u>setlocal filetype=sql<CR>
nnoremap <Leader>fv :<C-u>setlocal filetype=vim<CR>
nnoremap <Leader>fx :<C-u>setlocal filetype=xml<CR>

" プラグインなどで変更された設定をグローバルな値に戻す
" *.txtでtextwidth=78されちゃう
" [vimrc_exampleのロードのタイミング - Google グループ](https://groups.google.com/forum/#!topic/vim_jp/Z_3NSVO57FE "vimrc_exampleのロードのタイミング - Google グループ")
autocmd MyVimrc FileType vim,text,mkd call s:override_plugin_setting()

function! s:override_plugin_setting()
    setlocal textwidth<
    setlocal formatoptions<
endfunction

" shell {{{
" ----------------------------------------------------------------------------
autocmd MyVimrc FileType sh setlocal errorformat=%f:\ line\ %l:\ %m
"}}}
" HTML {{{
" ----------------------------------------------------------------------------
" HTML Key Mappings for Typing Character Codes: {{{
" * http://www.stripey.com/vim/html.html
" * https://github.com/sigwyg/dotfiles/blob/8c70c4032ebad90a8d92b76b1c5d732f28559e40/.vimrc
"
" |--------------------------------------------------------------------
" |Keys     |Insert   |For  |Comment
" |---------|---------|-----|-------------------------------------------
" |\&       |&amp;    |&    |ampersand
" |\<       |&lt;     |<    |less-than sign
" |\>       |&gt;     |>    |greater-than sign
" |\.       |&middot; |・   |middle dot (decimal point)
" |\?       |&#8212;  |?    |em-dash
" |\2       |&#8220;  |“   |open curved double quote
" |\"       |&#8221;  |”   |close curved double quote
" |\`       |&#8216;  |‘   |open curved single quote
" |\'       |&#8217;  |’   |close curved single quote (apostrophe)
" |\`       |`        |`    |OS-dependent open single quote
" |\'       |'        |'    |OS-dependent close or vertical single quote
" |\<Space> |&nbsp;   |     |non-breaking space
" |---------------------------------------------------------------------
"
augroup MapHTMLKeys
    autocmd!
    autocmd FileType html call MapHTMLKeys()
    function! MapHTMLKeys()
        inoremap <buffer> \\ \
        inoremap <buffer> \& &amp;
        inoremap <buffer> \< &lt;
        inoremap <buffer> \> &gt;
        inoremap <buffer> \. ・
        inoremap <buffer> \- &#8212;
        inoremap <buffer> \<Space> &nbsp;
        inoremap <buffer> \` &#8216;
        inoremap <buffer> \' &#8217;
        inoremap <buffer> \2 &#8220;
        inoremap <buffer> \" &#8221;
    endfunction " MapHTMLKeys()
augroup END
"}}}
" gf(goto file)の設定 {{{
" http://sanrinsha.lolipop.jp/blog/2012/01/vim%E3%81%AEgf%E3%82%92%E6%94%B9%E8%89%AF%E3%81%97%E3%81%A6%E3%81%BF%E3%82%8B.html
autocmd MyVimrc FileType html
    \   setlocal includeexpr=substitute(v:fname,'^\\/','','')
    \|  setlocal path&
    \|  setlocal path+=./;/
" }}}
" }}}
" JavaScript {{{
" ----------------------------------------------------------------------------
autocmd MyVimrc FileType javascript setlocal syntax=jquery
" }}}
" PHP {{{
" ----------------------------------------------------------------------------
let php_sql_query = 1     " 文字列中のSQLをハイライトする
let php_htmlInStrings = 1 " 文字列中のHTMLをハイライトする
let php_noShortTags = 1   " ショートタグ (<?を無効にする→ハイライト除外にする)
let php_parent_error_close = 1  " for highlighting parent error ] or )
let php_parent_error_open = 1   " for skipping an php end tag,
"                                 if there exists an open ( or [ without a closing one
let PHP_vintage_case_default_indent = 1 " switch文でcaseをインデントする
"let php_folding = 0 " クラスと関数の折りたたみ(folding)を有効にする (重い)
" augroup php
"     autocmd!
"     au Syntax php set foldmethod=syntax
" augroup END
" " Vimテクニックバイブル1-13
" " PHPプログラムの構文チェック
" " http://d.hatena.ne.jp/i_ogi/20070321/1174495931
" autocmd FileType php setlocal makeprg=php\ -l\ % | setlocal errorformat=%m\ in\ %f\ on\ line\ %l
autocmd MyVimrc FileType php setlocal errorformat=%m\ in\ %f\ on\ line\ %l
" autocmd BufWrite *.php w | make
" "http://d.hatena.ne.jp/Cside/20110805/p1に構文チェックを非同期にやる方法が書いてある
"}}}
" Java {{{
" ----------------------------------------------------------------------------
if isdirectory(expand('~/AppData/Local/Android/android-sdk/sources/android-17'))
    autocmd MyVimrc FileType java setlocal path+=~/AppData/Local/Android/android-sdk/sources/android-17
elseif isdirectory(expand('/Program Files (x86)/Android/android-sdk/sources/android-17'))
    autocmd MyVimrc FileType java setlocal path+=/Program\ Files\ (x86)/Android/android-sdk/sources/android-17
endif
autocmd MyVimrc FileType java
            \   setlocal foldmethod=syntax
            \|  nnoremap <buffer>  [[ [m
            \|  nnoremap <buffer>  ]] ]m
"}}}
" MySQL {{{
" ----------------------------------------------------------------------------
" ]}, [{ の移動先
let g:sql_type_default = 'mysql'
let g:ftplugin_sql_statements = 'create,alter'
" }}}
" yaml {{{
" ----------------------------------------------------------------------------
autocmd MyVimrc FileType yaml
    \   setlocal foldmethod=indent softtabstop=2 shiftwidth=2
" }}}
" vim {{{
" ----------------------------------------------------------------------------
autocmd MyVimrc FileType vim
    \   nnoremap <buffer> <C-]> :<C-u>help<Space><C-r><C-w><CR>
    \|  setlocal path&
    \|  setlocal path+=$VIMDIR/bundle
let g:vim_indent_cont = &sw
" }}}
" help {{{
" ----------------------------------------------------------------------------
autocmd MyVimrc FileType help nnoremap <buffer><silent> q :q<CR>
" }}}
" Git {{{
" ----------------------------------------------------------------------------
" コミットメッセージは72文字で折り返す
" http://keijinsonyaban.blogspot.jp/2011/01/git.html
autocmd MyVimrc BufRead */.git/COMMIT_EDITMSG
    \   setlocal textwidth=72
    \|  setlocal colorcolumn=+1
    \|  startinsert
" }}}
" crontab {{{
" ----------------------------------------------------------------------------
autocmd MyVimrc FileType crontab setlocal backupcopy=yes
"}}}
" tsv {{{
" ----------------------------------------------------------------------------
autocmd MyVimrc BufRead,BufNewFile *.tsv setlocal noexpandtab
" }}}
" }}}
call SourceRc('plugin.vim')
if !has('gui_running')
    call SourceRc('cui.vim')
endif
call SourceRc('local.vim')
