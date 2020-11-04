m=Map("softwarecenter",translate("安装日志"),translate("安装Entware，ONMP和软件配置运行日志"))
s=m:section(TypedSection,"softwarecenter")
s.anonymous=true
m:section(SimpleSection).template = "softwarecenter/log"
return m

