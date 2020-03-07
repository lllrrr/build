include $(TOPDIR)/rules.mk

LUCI_TITLE:=Docker Manager interface for LuCI
LUCI_DEPENDS:=+luci-lib-docker +e2fsprogs +fdisk +ttyd +docker-ce
PKG_NAME:=luci-app-dockerman
PKG_VERSION:=v0.4.0
PKG_RELEASE:=leanmod
PKG_MAINTAINER:=lisaac <https://github.com/lisaac/luci-app-dockerman>
PKG_LICENSE:=AGPL-3.0

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
uci set uhttpd.main.script_timeout="600"
uci commit uhttpd
/etc/init.d/uhttpd restart
rm -rf /tmp/luci-*
endef

# call BuildPackage - OpenWrt buildroot signature
