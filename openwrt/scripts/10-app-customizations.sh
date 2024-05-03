# xfrpc zh_hans
mkdir feeds/luci/applications/luci-app-xfrpc/po/zh_Hans
curl -sO https://raw.githubusercontent.com/pmkol/openwrt_build_script/x86_64/openwrt/zhcn/xfrpc.po
chmod 0664 xfrpc.po
mv xfrpc.po feeds/luci/applications/luci-app-xfrpc/po/zh_Hans/xfrpc.po

# use geoip
sed -i 's/geoip-only-cn-private.dat/geoip.dat/g' package/new/helloworld/v2ray-geodata/Makefile

# disable docker option iptables
sed -i "s/iptables '1'/iptables '0'/g" feeds/packages/utils/dockerd/files/etc/config/dockerd

# remove ssr_plus
rm -rf package/new/helloworld/luci-app-ssr-plus
rm -rf package/new/helloworld/patch-luci-app-ssr-plus.patch

# distfeeds.conf settings
sed -i 's#raw.cooluc.com/sbwml/kmod-x86_64/main#gh-proxy.com/https://raw.githubusercontent.com/sbwml/kmod-x86_64/main#g' package/new/default-settings/default/zzz-default-settings
