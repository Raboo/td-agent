#!/bin/bash
version=`cat VERSION`
password=`cat PASSWORD`
dst=td-agent-$version

rm -fR fluentd
git clone git://github.com/fluent/fluentd.git
rm -fR $dst*
rm -fR $dst*
rm -fR *.dsc
cp -r fluentd $dst
cp -r debian $dst
cp td-agent.conf $dst
cp Makefile.am $dst
tar czf $dst.tar.gz $dst

pushd $dst
yes | dh_make -e k@treasure-data.com --single -f ../$dst.tar.gz
./autogen.sh
./make_dist.sh
dpkg-buildpackage -rfakeroot -us -uc -S
popd

DISTS='lucid'
ARCHITECTURES='i386 amd64'

for dist in $DISTS; do
  for arc in $ARCHITECTURES; do
    echo $password | sudo -S ls
    echo td-agent_$version-1.dsc
    pbuilder-dist $dist $arc build td-agent_$version-1.dsc &
  done
done

wait

for dist in $DISTS; do
  for arc in $ARCHITECTURES; do
    echo $password | sudo -S ls
    mkdir -p $version/$dist
    cp ~/pbuilder/$dist-${arc}_result/td-agent_$version-1_$arc.deb $version/$dist
  done
done

wait
