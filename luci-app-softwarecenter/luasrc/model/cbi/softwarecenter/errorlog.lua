m=Map("softwarecenter",translate("Nginx日志"),translate("Nginx的运行和错误日志"))
s=m:section(TypedSection,"softwarecenter")
s.anonymous=true
m:section(SimpleSection).template = "softwarecenter/error_log"
m:section(SimpleSection).template = "softwarecenter/access_log"
return m