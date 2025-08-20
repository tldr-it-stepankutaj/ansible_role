#!/usr/local/bin/bash
pid=`ps awwx | grep /[e]tc/openvpn/is202-test/is202-test.conf|grep -v grep |awk '{print $1}'`
if [ ! -z "$pid" ]; then
  kill $pid
fi
exit 0

