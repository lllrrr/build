f = SimpleForm("softwarecenter",translate(""),translate("Installation information of deployment and software configuration of entware and Onmp"))
f.reset = false
f.submit = false
f:append(Template("softwarecenter/log"))
return f

