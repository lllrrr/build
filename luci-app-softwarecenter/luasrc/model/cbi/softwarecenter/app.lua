local appname = "passwall"
m=Map("softwarecenter",translate("应用安装"),translate("安装Entware的应用软件"))

s = m:section(TypedSection, "global_app")
s.anonymous = true

return m 