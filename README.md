# Design Library · 本机产品界面审美库

把本机已安装的主流产品（优先 **Grok Bot**、**Codex**）真实 UI 截图沉淀下来，按风格/布局召回，供自己开发抄图、也方便给别人整理素材——避免每次让 Agent 现场打开网页再截。

## 快速打开 Demo

双击或：

```powershell
Start-Process F:\project\design-library\demo\index.html
```

导航：**侧栏选应用 → 页面网格 → 点卡片看详情（大图 / 4K / 标签 / 点击轨迹）**。

独立副本（自带 AI 预览图）：`C:\Users\fanfan\design-library-preview\demo\`

## 库结构

见 `apps/<应用>/<页面>/{shot.png,shot-ai.jpg,meta.json}`。索引：`index.json`。

- `shot.png`：主屏 4K 物理像素原图
- `shot-ai.jpg`：长边 1920 的压缩预览（给 AI / Demo 用）

## 自动化

Windows 原生 **UI Automation**。完整流程见：

**[SOP-windows-uia-capture.md](./SOP-windows-uia-capture.md)**

抓完后刷新 Demo：

```powershell
powershell -File F:\project\design-library\scripts\refresh-demo.ps1
```

## 偏好

- 第一梯队：Codex、Grok Bot
- 反例（可选）：Qoder
- 隐私：学习可截敏感页；外发前打码；meta 不写口令明文

## 脚本入口

`scripts/uia-lib.ps1` · `Capture-Fullscreen.ps1` · `Invoke-UiaByName.ps1` · `refresh-demo.ps1`
