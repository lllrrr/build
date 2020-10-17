f = SimpleForm("softwarecenter")
f.reset = false
f.submit = false
f:append(Template("softwarecenter/log"))
return f