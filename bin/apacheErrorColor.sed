#!/usr/bin/sed -f
# Apacheのエラーログのカラー化
# http://d.hatena.ne.jp/y-kawaz/20110713/1310532417
# を元に作った
# 使い方
# PATHを通して
# tail -f /var/log/httpd-error.log | apacheErrorColor.sed
# など
## MEMO
# [0m  reset
# [1m  bold
# [3m  italic
# [4m  underline
# [5m  blink
# [30m black
# [31m red
# [32m green
# [33m yellow
# [34m blue
# [35m magenta
# [36m cyan
# [37m white
s/^\(.*\)\(\[emerg\]\)/[31m\1\2[0m/
s/^\(.*\)\(\[alert\]\)/[31m\1\2[0m/
s/^\(.*\)\(\[crit\]\)/[31m\1\2[0m/
s/^\(.*\)\(\[error\]\)/[33m\1\2[0m/
s/^\(.*\)\(\[warn\]\)/[33m\1\2[0m/
s/^\(.*\)\(\[notice\]\)/[34m\1\2[0m/
s/^\(.*\)\(\[info\]\)/[32m\1\2[0m/
s/^\(.*\)\(\[debug\]\)/[35m\1\2[0m/
