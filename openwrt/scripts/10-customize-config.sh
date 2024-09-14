# remove ssrplus
rm -rf package/new/helloworld/luci-app-ssr-plus
rm -rf package/new/helloworld/patch-luci-app-ssr-plus.patch

# add mihomo
git clone https://$github/pmkol/openwrt-mihomo package/new/openwrt-mihomo
if curl -s "https://$mirror/openwrt/23-config-common" | grep -q "^CONFIG_PACKAGE_luci-app-mihomo=y"; then
    mkdir -p files/etc/mihomo/run/ui
    curl -Lso files/etc/mihomo/run/geoip.metadb https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.metadb
    curl -Lso files/etc/mihomo/run/ASN.mmdb https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb
    curl -Lso metacubexd-gh-pages.tar.gz https://$github/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.tar.gz
    tar zxf metacubexd-gh-pages.tar.gz
    rm metacubexd-gh-pages.tar.gz
    mv metacubexd-gh-pages files/etc/mihomo/run/ui/metacubexd
fi

# openclash
git clone -b dev https://github.com/vernesong/OpenClash package/feeds/luci/openclash --depth=1
mv package/feeds/luci/openclash/luci-app-openclash package/feeds/luci/luci-app-openclash
rm -rf package/feeds/luci/openclash
sed -i 's/("OpenClash"), 50/("OpenClash"), 20/' package/feeds/luci/luci-app-openclash/luasrc/controller/openclash.lua

# change geodata
rm -rf package/new/helloworld/v2ray-geodata
git clone https://$github/sbwml/v2ray-geodata package/new/helloworld/v2ray-geodata
sed -i 's#Loyalsoldier/geoip/releases/latest/download/geoip-only-cn-private.dat#MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat#g; s#Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat#MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat#g' package/new/helloworld/v2ray-geodata/Makefile
sed -i '/geoip_api/s#Loyalsoldier/v2ray-rules-dat#pmkol/geodata-lite#' package/new/helloworld/luci-app-passwall/root/usr/share/passwall/rule_update.lua
sed -i '/geosite_api/s#Loyalsoldier/v2ray-rules-dat#MetaCubeX/meta-rules-dat#' package/new/helloworld/luci-app-passwall/root/usr/share/passwall/rule_update.lua

# add natflow by default
sed -i 's|\[\ \$(grep\ -c\ shortcut_fe\ /etc/config/firewall)\ -eq\ '\''0'\''\ \]\ \&\&\ uci\ set\ firewall.@defaults\[0\].flow_offloading='\''1'\''|\[\ \$(grep\ -c\ shortcut_fe\ /etc/config/firewall)\ -eq\ '\''0'\''\ \]\ \&\&\ \[\ \$(grep\ -c\ natflow_delay_pkts\ /etc/config/firewall)\ -eq\ '\''0'\''\ \]\ \&\&\ uci\ set\ firewall.@defaults\[0\].flow_offloading='\''1'\''|g' package/new/default-settings/default/zzz-default-settings

# configure default-settings
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' package/new/luci-theme-argon/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' package/new/luci-theme-argon/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' feeds/luci/themes/luci-theme-bootstrap/ucode/template/themes/bootstrap/footer.ut
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' feeds/luci/themes/luci-theme-material/ucode/template/themes/material/footer.ut
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' feeds/luci/themes/luci-theme-openwrt-2020/ucode/template/themes/openwrt2020/footer.ut
sed -i 's/mirrors.pku.edu.cn/mirrors.aliyun.com/g' package/new/default-settings/default/zzz-default-settings
sed -i '/# opkg mirror/a case $(uname -m) in\n    x86_64)\n        echo -e '\''src/gz immortalwrt_luci https://mirrors.vsean.net/openwrt/releases/packages-23.05/x86_64/luci\nsrc/gz immortalwrt_packages https://mirrors.vsean.net/openwrt/releases/packages-23.05/x86_64/packages'\'' >> /etc/opkg/distfeeds.conf\n        ;;\n    aarch64)\n        echo -e '\''src/gz immortalwrt_luci https://mirrors.vsean.net/openwrt/releases/packages-23.05/aarch64_generic/luci\nsrc/gz immortalwrt_packages https://mirrors.vsean.net/openwrt/releases/packages-23.05/aarch64_generic/packages'\'' >> /etc/opkg/distfeeds.conf\n        ;;\n    *)\n        echo "Warning: This system architecture is not supported."\n        ;;\nesac' package/new/default-settings/default/zzz-default-settings
sed -i '/# opkg mirror/a echo -e '\''untrusted comment: Public usign key for 23.05 release builds\\nRWRoKXAGS4epF5gGGh7tVQxiJIuZWQ0geStqgCkwRyviQCWXpufBggaP'\'' > /etc/opkg/keys/682970064b87a917' package/new/default-settings/default/zzz-default-settings

# comment out the following line to restore the full description
sed -i '/# timezone/i sed -i "s/\\(DISTRIB_DESCRIPTION=\\).*/\\1'\''OpenWrt $(sed -n "s/DISTRIB_DESCRIPTION='\''OpenWrt \\([^ ]*\\) .*/\\1/p" /etc/openwrt_release)'\'',/" /etc/openwrt_release\nsource /etc/openwrt_release \&\& sed -i -e "s/distversion\\s=\\s\\".*\\"/distversion = \\"$DISTRIB_ID $DISTRIB_RELEASE ($DISTRIB_REVISION)\\"/g" -e '\''s/distname    = .*$/distname    = ""/g'\'' /usr/lib/lua/luci/version.lua\nsed -i "s/luciname    = \\".*\\"/luciname    = \\"LuCI openwrt-23.05\\"/g" /usr/lib/lua/luci/version.lua\nsed -i "s/luciversion = \\".*\\"/luciversion = \\"v'$(date +%Y%m%d)'\\"/g" /usr/lib/lua/luci/version.lua\necho "export const revision = '\''v'$(date +%Y%m%d)'\'\'', branch = '\''LuCI openwrt-23.05'\'';" > /usr/share/ucode/luci/version.uc\n/etc/init.d/rpcd restart\n' package/new/default-settings/default/zzz-default-settings
