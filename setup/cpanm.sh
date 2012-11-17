#!/usr/bin/env bash
set -ex

test -d ~/bin || mkdir ~/bin
cd ~/bin
curl -LO http://xrl.us/cpanm
chmod +x cpanm
export PERL5LIB="${HOME}/perl5/lib/perl5:$PERL5LIB"
cpanm --local-lib=~/perl5 local::lib
test -d ~/.profile.d || mkdir ~/.profile.d
echo 'export PERL5LIB="${HOME}/perl5/lib/perl5:$PERL5LIB"' > ~/.profile.d/cpanm.sh
echo 'eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)'    >> ~/.profile.d/cpanm.sh