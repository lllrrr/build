m=Map("softwarecenter",translate("网站管理"),translate("在能正常运行 Nginx/MySQL/PHP 后先添加网站名称后再选择要部署的网站<br>可以自动部署PHP探针，phpMyAdmin，可道云，h5ai，Typecho等等"))
m:section(SimpleSection).template = "softwarecenter/website_status"
s = m:section(TypedSection,"website")
s.anonymous = true
s.addremove = true
s.sortable = false
s.template = "cbi/tblsection"
s.rmempty = false
p = s:option(Flag,"website_enabled",translate("Enabled"),translate("确保ONMP已运行"))
p = s:option(Flag,"autodeploy_enable",translate("自动部署"))
p = s:option(ListValue,"website_select",translate("网站列表"),translate("选择部署的网站,系统会自动获取311-330的空闲端口"))
p:value("0","tz（雅黑PHP探针）")
p:value("1","phpMyAdmin（数据库管理工具）")
p:value("2","WordPress（使用最广泛的CMS）")
p:value("3","Owncloud（经典的私有云）")
p:value("4","Nextcloud（Owncloud团队的新作，美观强大的个人云盘）")
p:value("5","h5ai（优秀的文件目录）")
p:value("6","Lychee（一个很好看，易于使用的Web相册）")
p:value("7","Kodexplorer（可道云aka芒果云在线文档管理器）")
p:value("8","Typecho (流畅的轻量级开源博客程序)")
p:value("9","Z-Blog (体积小，速度快的PHP博客程序)")
p:value("10","DzzOffice (开源办公平台)")
p = s:option(Flag,"redis_enabled",translate("启用Redis"),translate("只有Owncloud和Nextcloud才可以使用。<br>需要先在web界面配置完成后，才能使用开启Redis"))
p:depends("website_select","3")
p:depends("website_select","4")
-- p = s:option(Flag,"customdeploy_enabled",translate("启用自定义部署"))
-- p:depends("autodeploy_enable",0)
-- p = s:option(Value,"website_dir",translate("网站目录"),translate("需输入/opt/wwwroot/下自建目录名"))
-- p:depends("customdeploy_enabled",1)
-- p = s:option(Value,"port",translate("访问端口设定"),translate("如设定的端口已在用，系统自动找查100-120中可用的端口"))
-- p:value("",translate("自动获取"))
-- p:depends("website_enabled",1)
return m