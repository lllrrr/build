include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-qbittorrent
PKG_VERSION:=1.0.5
PKG_RELEASE:=20210316

define Package/$(PKG_NAME)/conffiles
/etc/config/qbittorrent
endef

LUCI_TITLE:=LuCI support for qBittorrent
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+qBittorrent +axel

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
