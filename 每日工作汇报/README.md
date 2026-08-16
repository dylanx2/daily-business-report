# 每日经营汇报生成工具

一个无需登录、无需服务器的纯前端日报生成工具。直接用浏览器打开 `index.html` 即可使用。

## 功能

- 录入经营数据并实时生成日报预览
- 一键复制纯文本到微信群
- 导出 `每日汇报.txt`
- 使用浏览器 localStorage 自动保存最近一次填写的数据
- “新一天”会清空全部已填写数据，开始录入新的日报

## 使用

1. 双击打开 `index.html`，或将文件拖入 Chrome、Safari、Edge。
2. 填写左侧数据，右侧会同步显示日报。
3. 点击“复制到微信”后，直接粘贴到微信群发送。

---

## Mac 网页开发环境检测

`check-dev-env.sh` 是一个只读的 macOS Bash 检测脚本，适用于 React、Next.js、TypeScript、Tailwind CSS、Node.js、本地数据库及 Docker 部署前的环境检查。它不会安装软件，也不会修改任何系统配置。

### 运行脚本

在终端进入本目录后执行：

```bash
bash check-dev-env.sh
```

也可以授予可执行权限后直接运行：

```bash
chmod +x check-dev-env.sh
./check-dev-env.sh
```

### 查看检测结果

脚本会按“系统、开发工具、编程环境、编辑器、容器环境、网络”分组输出报告：

- `✓`：已安装、可用或版本符合建议。
- `✗`：缺失。
- `⚠`：版本偏低、资源不足或服务未运行。

报告最后会汇总正常、缺失和需要关注的项目，并给出与当前结果对应的建议。

### 常见问题

**提示 Xcode Command Line Tools 未安装**

执行 `xcode-select --install`，按系统提示完成安装后重新运行脚本。

**Docker 已安装但未运行**

打开 Docker Desktop，等待状态栏图标显示 Docker 已就绪，再重新运行脚本。

**GitHub 或 npm registry 不可访问**

先确认网络、VPN、代理或公司防火墙设置；可分别在浏览器打开 `https://github.com` 和 `https://registry.npmjs.org/-/ping` 验证。npm registry 也可通过 `npm config get registry` 查看当前配置。

**找不到 VS Code，但应用已经安装**

脚本会识别默认 Applications 目录中的 VS Code。若希望终端支持 `code .`，在 VS Code 的命令面板中执行 “Shell Command: Install 'code' command in PATH”。
