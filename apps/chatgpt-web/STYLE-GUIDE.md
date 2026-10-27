# ChatGPT Web — 风格总指南（STYLE-GUIDE）

> 用途：还原 chatgpt.com 网页端浅色 UI，可与桌面 Codex 对照。  
> 平台：Web · 视口约 1920×1080 素材。  
> 截图：`apps/chatgpt-web/<screen>/`。

---

## 一、产品整体 DNA

### 一句话定位
**浅灰侧栏 + 纯白主画布 + 居中英雄空态/线程 + 胶囊作曲器**；设置多为**居中大模态 + 左分区轨道**；整体比桌面 Codex 更「空气感、Web 原生」。

### 设计原则
1. **内容中轴**：主列水平居中，巨大负空间。
2. **侧栏组织**：New Chat、搜索、GPTs/项目、Pinned、Recents；底账户。
3. **胶囊语言**：输入框接近 stadium（大圆角）；Send 为实心蓝圆。
4. **分段模式**：顶栏 Chat / Work 等 pill 切换。
5. **模态层级**：搜索、分享、新建项目、设置为浮层；登录/注册为独立营销页。

### 色板 Token
| Token | 约值 | 用途 |
|-------|------|------|
| `--bg-sidebar` | `#F9F9F9` | 侧栏 |
| `--bg-main` | `#FFFFFF` | 主区 |
| `--text` | `#0D0D0D` | 主文字 |
| `--muted` | `#8A8A8A` | 次要 |
| `--accent` | `#0A84FF`–`#2174FF` | Send、Upgrade、链接 |
| `--hover` | `#ECECEC` | 侧栏 hover/选中 |
| `--composer-shadow` | `0 4px 12px rgba(0,0,0,.08)` | 输入抬升 |
| `--radius-pill` | `9999px` | 输入/芯片 |
| `--radius-card` | `12–16px` | 模态/卡片 |

### 字体
- Inter / 系统无衬线；英雄句 ~24–28px。
- 侧栏 13–14px；分区头 muted 小字。
- 消息 Markdown：标题层级清楚，代码块圆角浅底。

### 组件通则
- New Chat 浅底圆角条；侧栏项图标+文字。
- Composer：`+` | 输入 | Think 芯片 | 麦 | 蓝圆发送。
- Model picker / 选项菜单：锚点下拉。
- Settings：大模态，左搜索+分组列表，右表单卡。
- Share / New Project：居中表单模态。

### 交互气质
- 低密度主区、中密度侧栏。
- 克制、消费级 AI；比 Gemini 略「产品功能多」，比 Codex 桌面少一层图标轨。

### 可还原总配方
1. `sidebar(~260px #F9F9F9) | main(#fff)`。
2. 空态居中标题 + 大圆角作曲器。
3. 线程模式：消息中列 + 底作曲器。
4. 设置为居中 master-detail 模态。

### 反例
- 最左再加图标轨（那是桌面 Codex）。
- Material 大光晕英雄（那是 Gemini）。
- 直角表单后台风。

---

## 二、分页面说明

## main / temporary-chat / sidebar-collapsed
- **main**：登录后新对话空态，「Ready when you are」类文案 + 居中作曲器。
- **temporary-chat**：临时对话横幅 + 同样中轴作曲器。
- **sidebar-collapsed**：侧栏收成图标轨，主区更宽。

## chat-thread — 对话线程
- 侧栏保留；中列气泡/纯文本；底作曲器；顶可有对话选项。

## chat-options-menu / model-picker / think-toggle / work-mode / composer-plus-menu
- 均为锚点浮层或作曲器芯片：选项菜单、模型列表、Think 开关、Chat/Work 分段、+ 工具菜单。
- **必须像**：轻下拉、短列表、不打断整页路由（除非进独立页）。

## search — 搜索对话
- 居中搜索模态/面板，盖在侧栏之上，命令面板感。

## explore-gpts / gpts-mine / gpt-editor / images / library / plugins / scheduled / sora / pricing / codex-web / deep-research
- 侧栏 + 内容页：画廊/列表/编辑器/营销升级页不等。
- **必须像**：保留 ChatGPT 壳；内容区大标题+卡片网格或列表。
- deep-research 可为盖在 home 上的对话框。

## explore-menu / recents-menu / recents-filter / profile-menu
- 侧栏飞出菜单或底账户菜单。

## new-project-modal / share-modal
- 居中表单模态；圆角卡片；主按钮强调色。

## login / signup / composer-home（未登录）
- 营销/认证页或未登录居中作曲器；品牌留白更大。

## settings / settings-* — 设置模态族
- 左轨分区（General、Account、Appearance、Billing、Security…）+ 右表单。
- 行：标题+说明 | 控件；搜索在左轨顶。
- **必须像**：大圆角模态、分组导航；各 slug 只换右侧字段。

## settings-code-review 等补充分区
- 与上同壳；实现时同一 SettingsShell。

### 设置分区完整清单（大模态同壳）
- `settings-account`
- `settings-appearance`
- `settings-archived`
- `settings-billing`
- `settings-cloud-computer`
- `settings-code-review`
- `settings-data-controls`
- `settings-general`
- `settings-keyboard`
- `settings-notifications`
- `settings-parental`
- `settings-passwords`
- `settings-personalization`
- `settings-pets`
- `settings-plugins`
- `settings-profile`
- `settings-search`
- `settings-security`
- `settings-storage`
- `settings-trusted-contact`
- `settings-usage`
- `settings-voice`

另：`settings` 为未登录/总入口态。库中部分分区目录可能尚无独立 meta，有截图者以实际 `apps/chatgpt-web/<screen>/` 为准。
