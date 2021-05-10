include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-rebootschedule
PKG_VERSION:=1.0
PKG_RELEASE:=20210510

define Package/$(PKG_NAME)/conffiles
/etc/config/rebootschedule
endef

LUCI_TITLE:=LuCI support for rebootschedule
LUCI_PKGARCH:=all
LUCI_DEPENDS:=

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
