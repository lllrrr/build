f = SimpleForm("softwarecenter")
f.reset = false
f.submit = false
f:append(Template("softwarecenter/error_log"))
return f