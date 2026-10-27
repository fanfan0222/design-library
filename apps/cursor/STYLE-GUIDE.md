# Cursor（桌面）— 风格总指南（STYLE-GUIDE）

> 用途：还原本机 Cursor 桌面（含 Agents 窗口）。  
> 平台：Windows desktop · 物理 4K。  
> 截图：`apps/cursor/<screen>/`。

---

## 一、产品整体 DNA

### 一句话定位
**VS Code 骨架 + AI 侧栏/Agents**；深色为主，编辑器信息密度高。

### 设计原则
1. 活性栏 + 侧栏 + 编辑器 + 可选 Agent/Chat 面板。
2. 与 Cursor Web 同品牌，但桌面是真正 IDE 密度。
3. Agents 窗口可独立（本库 `agents-main`）。

### 色板 Token（约值）
| Token | 约值 | 用途 |
|-------|------|------|
| `--bg-editor` | 深灰 | 编辑区 |
| `--bg-sidebar` | 略深/略浅 | 侧栏 |
| `--accent` | Cursor 绿/蓝 | 焦点 |
| `--chat-panel` | 对话列 | Agent |

### 字体
- 编辑器等宽；UI 无衬线。

### 可还原总配方
1. IDE 多栏，不是居中聊天英雄。
2. Agent 面板贴侧或独立窗。

### 反例
- 套成纯 Web 营销页。

---

## 二、分页面说明

## agents-main
- 已开「Cursor Agents」窗口最大化全屏。**主参考。**

## main（若目录存在但缺 meta）
- 历史占位；优先用 agents-main / 补采 IDE 主窗。
