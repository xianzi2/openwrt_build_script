#!/bin/bash

# 自定义脚本

# fallback udp_offload to kernel 6.6.43
if [ "$version" = "rc2" ]; then
    curl -s https://raw.githubusercontent.com/pmkol/openwrt-lite/patch/linux/hack-6.6/099-udp_offload-backto-43.patch > target/linux/generic/hack-6.6/099-udp_offload-backto-43.patch
    curl -s https://raw.githubusercontent.com/pmkol/openwrt-lite/patch/linux/backport-6.6/099-udp-Compute-L4-checksum-as-usual-when-not-segmenting-the-skb.patch > target/linux/generic/backport-6.6/999-udp-Compute-L4-checksum-as-usual-when-not-segmenting-the-skb.patch
    rm -rf target/linux/generic/‎backport-6.6/611-03-v6.11-udp-Fall-back-to-software-USO-if-IPv6-extension-head.patch
fi

# fallback uboot-rockchip version
if [ "$platform" = "rk3568" ]; then
    rm -rf package/boot/uboot-rockchip
    git clone https://$github/pmkol/package_boot_uboot-rockchip package/boot/uboot-rockchip -b v2024.04 --depth 1
fi

# add mihomo
rm -rf package/new/helloworld/luci-app-mihomo
rm -rf package/new/helloworld/mihomo
git clone https://$github/pmkol/openwrt-mihomo package/new/openwrt-mihomo --depth 1
if [ "$MINIMAL_BUILD" = "y" ]; then
    if curl -s "https://$mirror/openwrt/23-config-minimal-common" | grep -q "^CONFIG_PACKAGE_luci-app-mihomo=y"; then
        mkdir -p files/etc/mihomo/run/ui
        curl -Lso files/etc/mihomo/run/GeoSite.dat https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat
        curl -Lso files/etc/mihomo/run/GeoIP.dat https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat
        curl -Lso files/etc/mihomo/run/geoip.metadb https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.metadb
        curl -Lso files/etc/mihomo/run/ASN.mmdb https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb
        curl -Lso metacubexd-1.151.0.tar.gz https://$github/MetaCubeX/metacubexd/archive/refs/tags/v1.151.0.tar.gz
        tar zxf metacubexd-1.151.0.tar.gz
        rm metacubexd-1.151.0.tar.gz
        mv metacubexd-1.151.0 files/etc/mihomo/run/ui/metacubexd
    fi
else
    if curl -s "https://$mirror/openwrt/23-config-common" | grep -q "^CONFIG_PACKAGE_luci-app-mihomo=y"; then
        mkdir -p files/etc/mihomo/run/ui
        curl -Lso files/etc/mihomo/run/geoip.metadb https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.metadb
        curl -Lso files/etc/mihomo/run/ASN.mmdb https://$github/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb
        curl -Lso metacubexd-1.151.0.tar.gz https://$github/MetaCubeX/metacubexd/archive/refs/tags/v1.151.0.tar.gz
        tar zxf metacubexd-1.151.0.tar.gz
        rm metacubexd-1.151.0.tar.gz
        mv metacubexd-1.151.0 files/etc/mihomo/run/ui/metacubexd
    fi
fi

# add ddns-go
git clone https://$github/sirpdboy/luci-app-ddns-go package/new/ddns-go --depth 1
sed -i '3 a\\t\t"order": 50,' package/new/ddns-go/luci-app-ddns-go/root/usr/share/rpcd/acl.d/luci-app-ddns-go.json

# add eqosplus
git clone https://$github/pmkol/openwrt-eqosplus package/new/openwrt-eqosplus --depth 1

# add qosmate
git clone https://$github/hudra0/qosmate package/new/qosmate --depth 1
sed -i "s/option enabled '1'/option enabled '0'/g" package/new/qosmate/etc/config/qosmate
git clone https://$github/pmkol/luci-app-qosmate package/new/luci-app-qosmate --depth 1

# add luci-app-tailscale
git clone https://$github/asvow/luci-app-tailscale package/new/luci-app-tailscale --depth 1
rm -rf feeds/packages/net/tailscale
cp -a ../master/packages/net/tailscale feeds/packages/net/tailscale
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile

# add luci-app-upnp
rm -rf feeds/luci/applications/luci-app-upnp
git clone https://$github/pmkol/luci-app-upnp feeds/luci/applications/luci-app-upnp --depth 1

# bump haproxy version
rm -rf feeds/packages/net/haproxy
cp -a ../master/packages/net/haproxy feeds/packages/net/haproxy
sed -i '/ADDON+=USE_QUIC_OPENSSL_COMPAT=1/d' feeds/packages/net/haproxy/Makefile

# change geodata
rm -rf package/new/helloworld/v2ray-geodata
git clone https://$github/sbwml/v2ray-geodata package/new/helloworld/v2ray-geodata --depth 1
sed -i 's#Loyalsoldier/geoip/releases/latest/download/geoip-only-cn-private.dat#MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat#g; s#Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat#MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat#g' package/new/helloworld/v2ray-geodata/Makefile
sed -i '/geoip_api/s#Loyalsoldier/v2ray-rules-dat#pmkol/geodata-lite#' package/new/helloworld/luci-app-passwall/root/usr/share/passwall/rule_update.lua
sed -i '/geosite_api/s#Loyalsoldier/v2ray-rules-dat#MetaCubeX/meta-rules-dat#' package/new/helloworld/luci-app-passwall/root/usr/share/passwall/rule_update.lua

# default settings
if [ "$MINIMAL_BUILD" = "y" ]; then
    rm -rf package/new/default-settings
    git clone https://$github/pmkol/default-settings package/new/default-settings -b lite --depth 1
fi
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' package/new/luci-theme-argon/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' package/new/luci-theme-argon/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' feeds/luci/themes/luci-theme-bootstrap/ucode/template/themes/bootstrap/footer.ut
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' feeds/luci/themes/luci-theme-material/ucode/template/themes/material/footer.ut
sed -i 's/openwrt\/luci/pmkol\/openwrt-plus/g' feeds/luci/themes/luci-theme-openwrt-2020/ucode/template/themes/openwrt2020/footer.ut
sed -i 's/mirrors.pku.edu.cn/mirrors.aliyun.com/g' package/new/default-settings/default/zzz-default-settings
if [ "$MINIMAL_BUILD" != "y" ]; then
    sed -i '/# opkg mirror/a case $(uname -m) in\n    x86_64)\n        echo -e '\''src/gz immortalwrt_luci https://mirrors.vsean.net/openwrt/releases/packages-23.05/x86_64/luci\nsrc/gz immortalwrt_packages https://mirrors.vsean.net/openwrt/releases/packages-23.05/x86_64/packages'\'' >> /etc/opkg/distfeeds.conf\n        ;;\n    aarch64)\n        echo -e '\''src/gz immortalwrt_luci https://mirrors.vsean.net/openwrt/releases/packages-23.05/aarch64_generic/luci\nsrc/gz immortalwrt_packages https://mirrors.vsean.net/openwrt/releases/packages-23.05/aarch64_generic/packages'\'' >> /etc/opkg/distfeeds.conf\n        ;;\n    *)\n        echo "Warning: This system architecture is not supported."\n        ;;\nesac' package/new/default-settings/default/zzz-default-settings
    sed -i '/# opkg mirror/a echo -e '\''untrusted comment: Public usign key for 23.05 release builds\\nRWRoKXAGS4epF5gGGh7tVQxiJIuZWQ0geStqgCkwRyviQCWXpufBggaP'\'' > /etc/opkg/keys/682970064b87a917' package/new/default-settings/default/zzz-default-settings
fi

# comment out the following line to restore the full description
sed -i '/# timezone/i sed -i "s/\\(DISTRIB_DESCRIPTION=\\).*/\\1'\''OpenWrt $(sed -n "s/DISTRIB_DESCRIPTION='\''OpenWrt \\([^ ]*\\) .*/\\1/p" /etc/openwrt_release)'\'',/" /etc/openwrt_release\nsource /etc/openwrt_release \&\& sed -i -e "s/distversion\\s=\\s\\".*\\"/distversion = \\"$DISTRIB_ID $DISTRIB_RELEASE ($DISTRIB_REVISION)\\"/g" -e '\''s/distname    = .*$/distname    = ""/g'\'' /usr/lib/lua/luci/version.lua\nsed -i "s/luciname    = \\".*\\"/luciname    = \\"LuCI openwrt-23.05\\"/g" /usr/lib/lua/luci/version.lua\nsed -i "s/luciversion = \\".*\\"/luciversion = \\"v'$(date +%Y%m%d)'\\"/g" /usr/lib/lua/luci/version.lua\necho "export const revision = '\''v'$(date +%Y%m%d)'\'\'', branch = '\''LuCI openwrt-23.05'\'';" > /usr/share/ucode/luci/version.uc\n/etc/init.d/rpcd restart\n' package/new/default-settings/default/zzz-default-settings
