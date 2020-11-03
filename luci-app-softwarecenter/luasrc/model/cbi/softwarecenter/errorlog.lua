m=Map("softwarecenter",translate(""),translate("Nginx operation information"))
m:section(SimpleSection).template = "softwarecenter/error_log"

m:section(SimpleSection).template = "softwarecenter/access_log"
return m