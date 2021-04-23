include $(TOPDIR)/rules.mk

PKG_NAME:=axel
PKG_VERSION:=2.17.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/axel-download-accelerator/$(PKG_NAME)/releases/download/v$(PKG_VERSION)
PKG_HASH:=c0d26eba6b94945cd98c5b69ca6df2744639d17bfd49047ef51a8a48f067de10

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=File Transfer
	DEPENDS:=+libopenssl +libpthread
	TITLE:=axel download accelerator
	URL:=https://github.com/axel-download-accelerator/axel
endef

define Package/$(PKG_NAME)/description
 Description: light command line download accelerator
 Axel tries to accelerate the downloading process by using multiple
 connections for one file, similar to DownThemAll and other famous
 programs. It can also use multiple mirrors for one download.
 Using Axel, you will get files faster from Internet. So, Axel can
 speed up a download up to 60% (approximately, according to some tests).
 Axel supports HTTP, HTTPS, FTP and FTPS protocols.
 Axel tries to be as light as possible, so it might be useful as a
 wget clone (and other console based programs) on byte-critical systems.
endef

# CONFIGURE_ARGS := \
	# --prefix=/usr \
	# --etcdir=/etc \
	# --debug=0 \
	# --i18n=0 \
	# --strip=0

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/axelrc.example $(1)/etc/axelrc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/configure $(1)/etc/configure
	echo "alternate_output = 1" >> $(1)/etc/axelrc
endef

define Package/axel/conffiles
/etc/axelrc
endef

$(eval $(call BuildPackage,$(PKG_NAME)))