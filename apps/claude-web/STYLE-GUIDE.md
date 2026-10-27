# Claude Web — 风格总指南（STYLE-GUIDE）

> 用途：还原 claude.ai 网页端（登录后）浅色 UI。  
> 平台：Web · 素材为物理 4K（3840×2160）全屏截图。  
> 截图：`apps/claude-web/<screen>/`。

---

## 一、产品整体 DNA

### 一句话定位
**暖纸感侧栏 + 大留白主画布 + 圆角胶囊搜索/作曲器**；设置多为 **hash 路由面板（`#settings/...`）叠在主壳上**；气质克制、偏「安静写作台」，比 ChatGPT 更暖、比 Gemini 更少 Material 光晕。

### 设计原则
1. **侧栏组织**：Search（Ctrl+K）→ New → Projects / Artifacts / Customize → Pinned / Recents；底账户。
2. **中轴对话**：新对话空态居中欢迎 + 大输入区；线程模式消息中列、底作曲器。
3. **胶囊语言**：搜索条、侧栏行 hover 均为大圆角 pill。
4. **设置内嵌**：`/new#settings/general` 一类覆盖层/右栏，而非完全跳出产品壳。
5. **Artifacts / Projects** 作为一等公民入口，不只是聊天附属。

### 色板 Token（约值）
| Token | 约值 | 用途 |
|-------|------|------|
| `--bg-app` | `#F5F2EB`–`#FAF8F5` | 暖灰/米纸底 |
| `--bg-sidebar` | 略深或同色系 | 侧栏 |
| `--bg-main` | 近白暖调 | 主区 |
| `--text` | `#1A1A1A` | 主文字 |
| `--muted` | `#8A857C` | 次要/快捷键 |
| `--accent` | 橙褐/珊瑚系（品牌） | 主按钮、焦点环 |
| `--radius-pill` | `9999px` / 大圆角 | 搜索、行 |
| `--radius-card` | `16–24px` | 卡片/计划卡 |

### 字体
- 系统无衬线 / Anthropic 产品字体；标题中等字重。
- 侧栏 ~13–14px；快捷键标注 muted 小字。

### 组件通则
- Hide/Show sidebar 图标钮；Search 整行可点。
- New + 模板入口；Projects / Artifacts 列表/空态。
- Composer：附加工具 + 多行输入 + 发送。
- Settings：左分区（General / Profile / Account / Privacy / Billing / Features…）+ 右表单。

### 交互气质
- 低噪声、暖色、偏「书房」；onboarding 多步卡片（计划、桌面端、隐私开关、姓名、角色）。

### 可还原总配方
1. `sidebar(暖底 pill 行) | main(大留白作曲器)`。
2. 设置为 hash 面板，保持外框。
3. Projects/Artifacts 独立路由，仍带侧栏。

### 反例
- 纯冷灰 ChatGPT 壳直接套 Claude 橙标。
- Material 大光晕英雄（Gemini）。
- 最左再加 Codex 式 icon rail。

---

## 二、分页面说明

## login
- 未登录：品牌壳 +「Continue with Google」等；可有 hCaptcha。本库已保留登录墙一张。

## new-chat
- 登录后新对话：侧栏齐全 + 中轴空态/作曲器。**主参考屏。**

## sidebar-collapsed
- Hide sidebar 后主区更宽；应保留展开入口。

## search
- Ctrl+K / Search：命令面板式搜索对话。

## projects / artifacts
- 侧栏入口对应的列表/空态/画廊；保留侧栏上下文。

## settings / settings-*
- `#settings/general|profile|account|privacy|billing|features`：分区设置。**勿在入库时改开关值。**

## account-menu（若有）
- 底栏账户弹出：Settings / 登出等。

### 采集备注
- Bridge 档案经 Google OAuth 新建账户后采；`logged_in=true` 的屏优于仅 login。
