# Google Gemini Web — 风格总指南（STYLE-GUIDE）

> 用途：还原 gemini.google.com 的 Material 3 /「空气感」AI 界面。  
> 平台：Web。  
> 截图：`apps/gemini-web/<screen>/`。

---

## 一、产品整体 DNA

### 一句话定位
**极简 Material You：窄侧栏 + 超大留白主画布 + 柔和径向色晕 + 全圆角胶囊输入**；比 ChatGPT 更「空灵/消费电子」，工程工具感最低。

### 设计原则
1. **负空间即品牌**：主区大量白；分隔少用线，多用间距。
2. **有机形状**：胶囊输入、大圆角按钮、软悬停底。
3. **光晕点缀**：空态可有浅蓝径向渐变光斑，忌硬色块。
4. **Google 体系**：Google Sans 气质；设置多为菜单弹出再进子页，而非 ChatGPT 式巨型设置模态。
5. **工具锚在作曲器**：+ / 模式选择贴输入条，而不是重侧栏工具墙。

### 色板 Token
| Token | 约值 | 用途 |
|-------|------|------|
| `--bg` | `#FFFFFF` | 全局白 |
| `--surface-soft` | `#F0F4F9` / `#EAF0FB` | 侧栏 hover、芯片底 |
| `--halo` | `radial-gradient` 浅蓝 `#E8F0FE`→透明 | 空态氛围 |
| `--text` | `#1F1F1F` | 主文字 |
| `--muted` | `#5F6368` | 次要（Google 灰） |
| `--accent` | Google Blue `#1A73E8` | Sign in、主按钮 |
| `--gemini-spark` | 多色星标 | Logo 点缀 |
| `--radius-pill` | `9999px` | 输入与主按钮 |

### 字体
- Google Sans / Product Sans 感；英雄句 medium、字距略松。
- 侧栏 14px；法律/页脚 12px muted。
- 线程内 Markdown 清晰，代码块圆角。

### 组件通则
- New chat / Images 等侧栏线性图标。
- Composer：全高圆角条；左 +；右模式（Flash 等）+ 麦。
- Tools 菜单从 + 弹出：上传与工具列表。
- Mode picker：贴作曲器的模式/模型菜单。
- Settings：先小菜单，再进 Theme / Usage / Skills 等子页或对话框。
- Gems / Images：画廊卡片，大圆角缩略图。
- Google Apps waffle：标准 Google 九宫格。

### 交互气质
- 最低工程感；hover 极淡圆角底；动效可含光晕缓动。
- 登录墙常见；已登录则侧栏历史 + 中列线程。

### 可还原总配方
1. 白底 + 窄侧栏（无粗分割线）。
2. 主区垂直居中英雄文案 + 胶囊输入；可加径向浅蓝光晕。
3. 线程：中列消息 + 底胶囊作曲器。
4. 设置走「菜单 → 子页」，不要做成 Codex 全页设置中心。

### 反例
- ChatGPT 式灰侧栏+蓝圆 Send 语言混用过度。
- 重图标轨 + 项目树（Codex）。
- 硬边卡片后台表单风。

---

## 二、分页面说明

## main — 主页/新对话（含未登录）
- 侧栏 + 居中问候 + 胶囊作曲器；未登录有 Sign in；可有建议芯片。
- **必须像**：大留白、光晕、胶囊输入。

## chat-thread — 对话线程
- 中列消息（用户右/模型左或居中栏）；Markdown；底作曲器。

## mode-picker / tools-menu
- 锚在作曲器的下拉：模型/模式；上传与工具。

## images / library / gems / notebooks / students
- 画廊或落地内容页；大卡片、软圆角；保留 Gemini 壳。

## search-chats — 搜索对话
- 侧栏+搜索页：查询框+结果列表（比 ChatGPT 命令面板更「整页」）。

## scheduled-actions / settings-* / skills
- 从设置菜单进入的子页/对话框：Theme、Usage limits、Personal Intelligence、Public links、Skills 等。
- **必须像**：Material 列表+开关；返回层级清晰。

## settings-menu / about
- 小弹出菜单。

## google-apps — 应用启动器
- 标准 Google waffle 浮层。

## discovery-card — 功能发现
- 居中引导/同意对话框，盖在应用上。

## sign-in — 登录
- Google 账号选择器/登录页（Google Identity 气质）。
