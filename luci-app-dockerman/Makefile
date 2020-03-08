include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-dockerman
PKG_VERSION:=v0.4.2
PKG_RELEASE:=beta
PKG_MAINTAINER:=lisaac <https://github.com/lisaac/luci-app-dockerman>
PKG_LICENSE:=AGPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=Docker Manager interface for LuCI
	PKGARCH:=all
	 DEPENDS:=+luci-lib-docker +e2fsprogs +fdisk +ttyd +docker-ce
endef

define Package/$(PKG_NAME)/description
	Docker Manager interface for LuCI
endef
define Build/Compile
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	uci set uhttpd.main.script_timeout="600" >/dev/null 2>&1
	uci commit uhttpd >/dev/null 2>&1
	uci delete ucitrack.@dockerd[-1] >/dev/null 2>&1
	uci add ucitrack dockerd >/dev/null 2>&1
	uci set ucitrack.@dockerd[-1].init=dockerd >/dev/null 2>&1
	uci commit ucitrack >/dev/null 2>&1
	rm -fr /tmp/luci-indexcache /tmp/luci-modulecache >/dev/null 2>&1
	chmod +x /etc/init.d/dockerd >/dev/null 2>&1
	/etc/init.d/uhttpd restart >/dev/null 2>&1
fi
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/* $(1)/etc/init.d/
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/dockerman $(1)/etc/config/dockerman
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/dockerman.po $(1)/usr/lib/lua/luci/i18n/dockerman.zh-cn.lmo
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
