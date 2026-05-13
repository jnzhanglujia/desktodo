# DeskTodo — Desktop Todo Widget

> A semi-transparent, always-on-top todo list that stays on your Windows desktop.

---

## Features

- **Always on desktop** — semi-transparent dark window, stays on top of everything
- **Add tasks** — type and press Enter or click ＋
- **Complete tasks** — checkbox automatically strikes through and dims text
- **Delete tasks** — click 🗑 to remove
- **Pin toggle** — click 📌 to switch always-on-top on/off
- **Drag to move** — drag the title bar to reposition
- **Auto-save** — tasks and window position saved to `todo-data.json`
- **Import from clipboard** — copy tasks from Microsoft To Do, Excel, anywhere else, then click 📥 → "Import from clipboard"
- **Import from JSON** — 📥 → "Import from JSON file"

## Requirements

- Windows 10 / 11
- PowerShell 5.1+ (built-in)

## Quick Start

```powershell
# Double-click 启动待办.bat
# Or run from terminal:
powershell -ExecutionPolicy Bypass -File TodoWidget.ps1
```

## How to Import from Microsoft To Do

1. Open https://to-do.live.com/tasks/ in your browser and sign in
2. Press **F12** → Console tab
3. Paste the code below and press Enter:
   ```js
   copy([...document.querySelectorAll('[data-task-id]')].map(e=>e.querySelector('[contenteditable]')?.innerText||'').filter(Boolean).join('\n'))
   ```
4. Click **📥** → "Import from clipboard"

## Project Structure

```
desktodo/
├── TodoWidget.ps1       # Main program (PowerShell WPF)
├── 启动待办.bat          # Launcher (double-click to run)
├── .gitignore            # Git ignore rules
├── README.md             # This file
├── todo-data.json        # User data (auto-generated, excluded from Git)
└── todo-token.dat        # OAuth token (auto-generated, excluded from Git)
```

## Tech Stack

- **PowerShell 5.1** — runtime language
- **WPF / XAML** — desktop UI framework
- **Microsoft Graph API** — device code OAuth flow (optional sync)
- **Windows DPAPI** — encrypted token storage

## License

MIT

---

## 🇨🇳 中文

# DeskTodo — 桌面待办工具

> 半透明暗色无边框窗口，始终停留在 Windows 桌面上的待办清单。

---

## 功能

- **常驻桌面** — 半透明暗色窗口，始终置顶显示
- **添加任务** — 输入后按 Enter 或点击 ＋
- **标记完成** — 勾选复选框，自动加删除线并变灰
- **删除任务** — 点击 🗑 图标删除
- **置顶切换** — 点击 📌 切换置顶或取消置顶
- **拖拽移动** — 拖拽标题栏任意移动位置
- **自动保存** — 任务和窗口位置自动保存到 `todo-data.json`
- **剪贴板导入** — 从 Microsoft To Do、Excel 等处复制任务后，点击 📥 → "从剪贴板粘贴导入"
- **JSON 导入** — 点击 📥 → "从 JSON 文件导入"，支持批量导入标准格式

## 运行环境

- Windows 10 / 11
- PowerShell 5.1+（系统自带）

## 快速启动

```powershell
# 双击 启动待办.bat
# 或在终端运行：
powershell -ExecutionPolicy Bypass -File TodoWidget.ps1
```

## 从 Microsoft To Do 导入任务

1. 浏览器打开 https://to-do.live.com/tasks/ 并登录
2. 按 **F12** → 控制台标签
3. 粘贴以下代码并回车：
   ```js
   copy([...document.querySelectorAll('[data-task-id]')].map(e=>e.querySelector('[contenteditable]')?.innerText||'').filter(Boolean).join('\n'))
   ```
4. 点击 **📥** → "从剪贴板粘贴导入"

## 项目结构

```
desktodo/
├── TodoWidget.ps1       # 主程序（PowerShell 脚本）
├── 启动待办.bat          # 启动脚本（双击运行）
├── .gitignore            # Git 忽略配置
├── README.md             # 本文件
├── todo-data.json        # 用户数据（自动生成，不同步到 Git）
└── todo-token.dat        # 身份凭证（自动生成，不同步到 Git）
```

## 技术栈

- **PowerShell 5.1** — 运行语言
- **WPF / XAML** — 桌面界面框架
- **微软 Graph 接口** — 设备码授权流程（可选同步）
- **Windows 数据保护接口** — 凭证加密存储

## 许可

MIT
