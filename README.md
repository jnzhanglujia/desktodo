# DeskTodo — Desktop Todo Widget

> A semi-transparent, always-on-top todo list that stays on your Windows desktop.

---

## 🇬🇧 English

### Features

- **Always on desktop** — semi-transparent dark window, stays on top of everything
- **Add tasks** — type and press Enter or click ＋
- **Complete tasks** — checkbox automatically strikes through and dims text
- **Delete tasks** — click 🗑 to remove
- **Pin toggle** — click 📌 to switch always-on-top on/off
- **Drag to move** — drag the title bar to reposition
- **Auto-save** — tasks and window position saved to `todo-data.json`
- **Import from clipboard** — copy tasks from Microsoft To Do, Excel, anywhere → 📥 → "从剪贴板粘贴导入"
- **Import from JSON** — 📥 → "从 JSON 文件导入"

### Requirements

- Windows 10 / 11
- PowerShell 5.1+ (built-in)

### Quick Start

```powershell
# Double-click 启动待办.bat
# Or run from terminal:
powershell -ExecutionPolicy Bypass -File TodoWidget.ps1
```

### How to Import from Microsoft To Do

1. Open https://to-do.live.com/tasks/ in your browser
2. Press **F12** → Console tab
3. Paste this and press Enter:
   ```js
   copy([...document.querySelectorAll('[data-task-id]')].map(e=>e.querySelector('[contenteditable]')?.innerText||'').filter(Boolean).join('\n'))
   ```
4. Click **📥** → "从剪贴板粘贴导入"

---

## 🇨🇳 中文

### 功能

- **常驻桌面** — 半透明暗色窗口，始终置顶显示
- **添加任务** — 输入后按 Enter 或点击 ＋
- **标记完成** — 勾选复选框，自动加删除线变灰
- **删除任务** — 点击 🗑 图标删除
- **置顶切换** — 点击 📌 切换置顶/取消
- **拖拽移动** — 拖拽标题栏任意移动位置
- **自动保存** — 任务和窗口位置自动保存到 `todo-data.json`
- **剪贴板导入** — 从 Microsoft To Do、Excel 等处复制 → 📥 → "从剪贴板粘贴导入"
- **JSON 导入** — 支持批量导入标准 JSON 格式 → 📥 → "从 JSON 文件导入"

### 运行环境

- Windows 10 / 11
- PowerShell 5.1+（系统自带）

### 快速启动

```powershell
# 双击 启动待办.bat
# 或在终端运行：
powershell -ExecutionPolicy Bypass -File TodoWidget.ps1
```

### 从 Microsoft To Do 导入任务

1. 浏览器打开 https://to-do.live.com/tasks/ 并登录
2. 按 **F12** → Console（控制台）标签
3. 粘贴以下代码并回车：
   ```js
   copy([...document.querySelectorAll('[data-task-id]')].map(e=>e.querySelector('[contenteditable]')?.innerText||'').filter(Boolean).join('\n'))
   ```
4. 点击 **📥** → "从剪贴板粘贴导入"

### 项目结构

```
desktodo/
├── TodoWidget.ps1       # 主程序（PowerShell WPF）
├── 启动待办.bat          # 启动脚本（双击运行）
├── .gitignore            # Git 忽略配置
├── README.md             # 本文件
├── todo-data.json        # 用户数据（自动生成，不同步）
└── todo-token.dat        # OAuth Token（自动生成，不同步）
```

### 技术栈

- **PowerShell 5.1** — 核心语言
- **WPF / XAML** — 桌面 UI 框架
- **Microsoft Graph API** — 设备码授权流程（可选同步）
- **Windows DPAPI** — Token 加密存储

### 许可

MIT
