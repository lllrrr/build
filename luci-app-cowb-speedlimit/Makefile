include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-cowb-speedlimit
PKG_VERSION:=v4.0.4
PKG_RELEASE:=20210515

PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=

LUCI_TITLE:=A Luci module that uses wrtbwmon to track bandwidth usage
LUCI_DEPENDS:=+tc +kmod-ifb +kmod-sched +kmod-sched-core
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature