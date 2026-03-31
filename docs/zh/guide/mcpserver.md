# MCP服务器

## 支持工具列表

#### Viper平台工具

- `get_host_info`: 获取主机的详细信息（进程列表、网络连接等）
- `get_session_info`: 获取 session 的详细配置信息
- `list_handler`: 获取平台所有的 handler 配置信息
- `list_session`: 返回平台当前 session 列表及简要信息
- `list_host`: 返回平台当前 host 列表及简要信息
- `list_route`: 返回平台当前路由配置信息
- `query_route_by_ipaddress`: 查询连接特定 IP 时使用的路由配置
- `query_port_forward_config`: 返回平台当前的端口转发配置
- `session_meterpreter_command_run`: 在 session 上执行 meterpreter 命令
- `session_shell_command_run`: 在 session 上执行 os 命令
- `read_loot_file`: 读取 loot 目录文件内容
- `msf_module_execute`: 执行 msf 模块
- `msf_module_search`: 搜索 msf 模块
- `msf_module_info`: 查看 msf 模块信息
- `msf_module_target_compatible_payloads`: 查看 msf 模块适配的 payload 类型

## 启动MCP服务器

- Viper处于正常运行状态
- 进入Docker容器命令行

```shell
cd /root/VIPER
docker exec -it viper-c bash
```

- 启动MCP服务器

```shell
python3.12 /root/viper/Worker/mcpserver.py
```

命令会输出mcp服务器url

```shell
mcp server url: http://your_server_ip:8000/XXXXXXXXXXXXX/sse
```

## 配置MCP服务器

### Cursor

- <project_root>/.cursor/mcp.json中配置mcp服务器url

```json
{
  "mcpServers": {
    "viper_mcp": {
      "url": "http://your_server_ip:8000/XXXXXXXXXXXXX/sse"
    }
  }
}
```

- 配置完成后效果

![img.png](webp/mcpserver/img.png)

### Cherry Studio

![img_1.png](webp/mcpserver/img_1.png)

## 使用MCP服务器

### Cursor

![img_2.png](webp/mcpserver/img_2.png)
![img_3.png](webp/mcpserver/img_3.png)

## MCP服务器后台运行

可以使用如下命令后台运行mcp服务器

```shell
nohup python3.12 /root/viper/Worker/mcpserver.py &
```

生成的url可以通过做Viper UI中的通知查看
![img.png](webp/mcpserver/img4.png)