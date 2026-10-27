# SOP：Windows 本机应用 UI 截图入库（UIA + 4K）

适用：台式机 `fanfan` 上的 Electron / WebView2 桌面应用（Grok Bot、Codex/ChatGPT Desktop 等）。目标是把**当前真实界面**沉淀到 `F:\project\design-library`，供审美参考与 Agent 抄图，而不是每次现场开页截图。

对应 Mac 侧：Accessibility API / AppleScript System Events。  
Windows 侧：**UI Automation（UIA）是系统自带组件**，无需第三方插件。

---

## 0. 目录与资产约定

```
F:\project\design-library\
  apps\<slug>\<screen>\
    shot.png          # 4K 物理像素原图（主屏 3840×2160 @150%）
    shot-ai.jpg       # AI/预览用：长边 1920，JPEG q≈82
    meta.json         # 风格标签、布局、导航、点击轨迹、隐私备注
  index.json          # 全库索引（由 build_demo.py 重建）
  demo\
    index.html        # 浏览 Demo（file:// 可用）
    screens-data.js   # 嵌入式数据（避免 file:// CORS）
  scripts\
    uia-lib.ps1       # DPI / 找控件 / 点击 / 截图核心库
    Capture-Fullscreen.ps1
    Invoke-UiaByName.ps1
    dump.ps1          # 枚举某进程窗口控件名
    build_demo.py     # 扫 meta → index.json + screens-data.js
    refresh-demo.ps1  # 重建索引并同步独立预览副本
    cap-*.ps1         # 各次抓取脚本（可复跑）
  SOP-windows-uia-capture.md
  README.md
```

独立预览副本（自带全部 `shot-ai.jpg`）：`C:\Users\fanfan\design-library-preview\demo\`

---

## 1. DPI 感知的 4K 全屏截图

问题：4K 屏 + Windows 缩放 150% 时，未声明 DPI 的进程只会截到逻辑分辨率 2560×1440。

正确流程（`uia-lib.ps1` / `Capture-Fullscreen.ps1`）：

1. **进程启动后立刻**调用 `SetProcessDpiAwarenessContext(-4)`（PerMonitorV2）。
2. 目标窗口 `ShowWindow(SW_MAXIMIZE)` + `SetForegroundWindow`（需要时可先 Alt 一下抢前台）。
3. **鼠标移开**任务栏预览区（例如移到屏幕中部），再等约 0.5–1s。
4. `System.Drawing.Graphics.CopyFromScreen` 用 `Screen.PrimaryScreen.Bounds`（物理像素）。
5. 落盘 `shot.png`；再缩放到长边 1920 写 `shot-ai.jpg`（JPEG Quality 82）。

验证：`shot.png` 应为 `3840x2160`（或当前主屏物理分辨率）。

---

## 2. UIA 点击模式

加载程序集：`UIAutomationClient`、`UIAutomationTypes`。

常用模式（按优先级）：

| Pattern | 用途 |
|---------|------|
| `InvokePattern.Invoke` | 按钮、菜单项 |
| `ExpandCollapsePattern.Expand` | 可展开按钮（如「打开账户菜单」） |
| `SelectionItemPattern.Select` | 列表项、部分 Tab |
| `TogglePattern.Toggle` | 开关（**入库时尽量不要 Toggle**） |
| 中心点 `mouse_event` | Pattern 失败时的 fallback |

查找：

1. `AutomationElement.FromHandle(MainWindowHandle)` 得到窗口根。
2. `FindAll(TreeScope.Descendants)`，按 `Current.Name` + `ControlType` 过滤。
3. 弹层 / 菜单 / 独立设置窗可能挂在 **RootElement** 下，需 `Find-Root-All`。
4. 同一名字多个控件时，用 `BoundingRectangle`（例如左侧 icon rail 的 `X < 100`）消歧。
5. 长列表项：`ScrollItemPattern.ScrollIntoView` 后再点。

回退：`Escape` 关菜单；有「关闭」按钮则 Invoke；尽量**不改任何设置值、不发送消息、不切换难恢复的状态**。

枚举控件：

```powershell
powershell -File F:\project\design-library\scripts\dump.ps1 -proc "Grok Bot" -types "Button,TabItem,MenuItem"
powershell -File F:\project\design-library\scripts\dump.ps1 -proc "ChatGPT" -types "Button,MenuItem,ListItem"
```

注意：Codex 桌面端进程名是 **`ChatGPT`**，窗口标题也是 ChatGPT；CLI `codex.exe` 是另一回事。

---

## 3. 全应用爬取 Runbook（枚举 → 点击 → 截图 → 回滚）

### 3.1 准备

1. 确认目标应用已登录且主窗口可前置。
2. `. F:\project\design-library\scripts\uia-lib.ps1`
3. `Focus-App '<ProcessName>'`（Grok Bot → `Grok Bot`；Codex → `ChatGPT`）。

### 3.2 枚举可达页面

1. `dump.ps1` 列出侧栏按钮、Tab、菜单项。
2. 画一版页面清单（主界面 / 抽屉 Tab / 设置左栏各分区 / 弹层）。
3. 标注风险：会改设置、会发消息、会切模式、会暴露密钥。

### 3.3 逐页捕获

对每个 screen：

1. 从已知稳定入口走点击轨迹（记入 `meta.clicks`）。
2. 等 UI 稳定（1.5–3s）。
3. `Save-Shot <slug> <screen> @{ app; tags; layout; nav; clicks; notes; privacy }`  
   → 写出 `shot.png` + `shot-ai.jpg` + `meta.json`。
4. **回滚**：Esc / 关对话框 / 点回原 Tab / 切回原模式。
5. 敏感页（密码、账单）也要截（学习 UI），但 **meta 禁止粘贴密钥/口令明文**；`privacy` 字段写清红线。

### 3.4 模式切换（可选）

若产品有 ChatGPT / Codex 模式开关：**可以**一键切到对照模式截一张主界面，然后**立刻切回**并确认模式按钮文案恢复。无法确认切回则停手，留给用户。

### 3.5 收尾

```powershell
powershell -File F:\project\design-library\scripts\refresh-demo.ps1
```

会：

1. 跑 `build_demo.py` 重建 `index.json` + `demo/screens-data.js`
2. 同步独立副本到 `C:\Users\fanfan\design-library-preview\demo\`（含全部 `shot-ai.jpg`）

---

## 4. Demo 信息架构

**不要**把每一个 screen 直接堆在侧栏（颗粒度过细）。

正确导航：

1. **侧栏**：只列应用（Grok Bot、Codex…）+ 页面数量徽章  
2. **内容区**：当前应用的 **页面网格**（缩略图 + 中文名 + tier/标签 + 布局摘要）  
3. **点卡片 → 详情**：大图（AI 预览）、打开 4K 原图、meta、UIA 点击轨迹；**← 返回网格**；支持浏览器后退 / Esc；详情内 j/k 或左右键翻页  

`demo/index.html` 通过嵌入的 `screens-data.js` 在 `file://` 下工作。  
可选 `config.js`：`IMG_BASE` / `FULL_BASE`（独立预览副本用本地 AI 图 + 指向 F: 的 4K 原图）。

打开方式：双击 `F:\project\design-library\demo\index.html`，或：

```powershell
Start-Process F:\project\design-library\demo\index.html
```

---

## 5. 隐私策略

| 阶段 | 策略 |
|------|------|
| 入库学习 | **可以**截含账号、聊天标题、密码页布局的界面 |
| meta / 日志 | **不要**记录口令、API key、完整密钥材料 |
| 对外分享 | **必须**打码或裁切；demo 卡片上的 privacy 警告要保留 |

---

## 6. 脚本速查

| 脚本 | 作用 |
|------|------|
| `scripts/uia-lib.ps1` | DPI、Focus、Find、Click、Save-Shot |
| `scripts/Capture-Fullscreen.ps1` | 独立全屏截图工具 |
| `scripts/Invoke-UiaByName.ps1` | 按名触发一次 UIA 点击 |
| `scripts/dump.ps1` | 枚举控件 |
| `scripts/build_demo.py` | meta → index + screens-data.js |
| `scripts/refresh-demo.ps1` | 重建并同步 preview demo |
| `scripts/cap-*.ps1` | 历史抓取脚本（可参考轨迹） |

---

## 7. 已验证路径（摘要）

- **Grok Bot**：查看对话详情 → Tab 详情/资料库/电脑；搜索；新建聊天；打开账户菜单 → 设置 → 左栏 通用/电脑/用量与账单/更新。  
- **Codex（ChatGPT 进程）**：左侧 icon rail（首页/图像/定时任务/资料库/插件/更多/代码审查）；模式切换；搜索；活动；个人资料菜单 → 设置 Ctrl+, → 各设置分区（含密码页 UI）；ChatGPT 模式主界面（截完切回 Codex）。

---

*最后更新：随 design-library 全量爬取 + Demo IA 改为「应用 → 网格 → 详情」一并修订。*


## Web capture via OpenCLI (preferred for websites)

Do **not** drive Chrome with Windows UIA. On the agent box:

1. `opencli doctor` (extension connected)
2. Box Chrome may need CDP `Security.setIgnoreCertificateErrors` if proxy causes `NET::ERR_CERT_AUTHORITY_INVALID`
3. `opencli browser <session> open <url>` or CDP createTarget + `opencli browser <session> bind`
4. `opencli chatgpt status` / `opencli gemini status` for login — if not logged in, capture login + public shell only (do not invent credentials)
5. `state` → click numeric ref → `screenshot` → `shot-ai.jpg` (long edge 1920, JPEG ~82) → meta with `tool: opencli`, `platform: web`, `logged_in`
6. Sync to fanfan `F:\project\design-library\apps\` and run `scripts\refresh-demo.ps1`

Sessions used: `cg-lib` (ChatGPT), `gm-lib` (Gemini).
