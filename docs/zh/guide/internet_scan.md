# 全网扫描

该功能类似于AutoSploit,当前只开放测试用途的模块

# 全网搜索/漏洞扫描

+ 执行全网搜索功能前,要配置Quake/FOFA/Hunter等互联网测绘服务APIkey

+ 点击 `新建任务`可打开新建任务界面

+ 选择模块后,可使用搜索功能查找当前互联网适配该模块的主机

+ 每个模块内置指纹规则,如SSH暴力破解模块的适配规则为"protocol="SSH",可以在 `说明`部分查看.

+ 用户输入的规则,如ip="47.240.60.0/24"会与模块已有规则组合成 ip="47.240.60.0/24" && "protocol="SSH"发送到后端,后端会调用Quake/FOFA/Hunter等API查询,并将结果返回

+ 新建任务后会自动建立等待列表,Viper自动从列表中取出任务执行

> Viper自动控制后台之多同时执行3个任务,无需担心流量过大问题
