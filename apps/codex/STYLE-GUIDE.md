# Codex（ChatGPT 桌面）— 风格总指南（STYLE-GUIDE）

> 用途：还原 OpenAI Codex / ChatGPT 桌面壳的视觉与交互。与 Grok Bot 同属第一梯队，但信息架构更「产品功能面完整」。  
> 平台：Windows 桌面 · 浅色。  
> 截图：`apps/codex/<screen>/`。

---

## 一、产品整体 DNA

### 一句话定位
**最左图标轨 + 会话/项目侧栏 + 大主画布（空态英雄文案或线程）+ 浮层式作曲器**；设置是**全页左右分栏**，不是小模态。

### 设计原则
1. **双层导航**：图标轨（Home/图像/定时/资料库/插件/更多）决定「产品面」；第二栏管会话与项目。
2. **空态即品牌**：主画布大留白 + 居中问候（如「我们要构建什么？」）+ 底部浮起作曲器。
3. **功能面可展开**：图像、代码审查、资料库、插件、个人资料、动态均为独立内容页，但仍共享壳。
4. **设置中心化**：全页设置，左侧超长分组列表 + 右侧表单，Windows Fluent 感（浅底、软阴影、8px 圆角）。
5. **模式切换**：ChatGPT 模式 vs Codex 模式共用壳，侧栏结构略变。

### 色板 Token
| Token | 约值 | 用途 |
|-------|------|------|
| `--bg-app` | `#F7F7F8` / `#F9FAFB` | 主画布浅灰 |
| `--bg-rail` / `--bg-sidebar` | `#FFFFFF` | 图标轨与侧栏 |
| `--border` | `#E5E5E5` | 栏分割 |
| `--text-primary` | `#0D0D0D` | 标题 |
| `--text-muted` | `#6B6B6B` | 次要 |
| `--accent` | `#3B82F6` / OpenAI 蓝 | 发送钮、升级、焦点 |
| `--accent-soft` | `#EFF6FF` | 选中行 |
| `--composer-bg` | `#FFFFFF` | 浮起输入卡片 |
| `--shadow-composer` | `0 4px 16px rgba(0,0,0,.06)` | 作曲器抬升 |

### 字体
- 现代无衬线；空态英雄文案约 24–28px medium。
- 侧栏最近项 13–14px；设置分组小标题 12px muted uppercase/semibold。
- 线程内 Agent 步骤、代码块：等宽 + 浅底，偏工程可读。

### 组件通则
- **图标轨**：细线图标，宽约 48–56px；底头像。
- **New Chat**：侧栏顶幽灵按钮。
- **作曲器**：居中 max-width ~720–800px；上层可选项目条；中输入；底工具图标 + 模型芯片 + 圆蓝发送。
- **Popover**：更多菜单、模式切换、个人资料——白底圆角轻阴影。
- **设置行**：左标题+说明，右 Toggle/下拉/「更改」按钮。
- **Profile 页**：头像、Token 统计卡、图表、插件列表——卡片网格。

### 交互气质
- 侧栏密度高；主空态极疏。
- Hover 浅灰圆角；选中蓝软底或描边。
- 比 Grok Bot 更「产品完备」，但仍克制，非彩虹仪表盘。

### 可还原总配方
1. `icon-rail | sidebar | main` 三列壳。
2. 空态居中标题 + 浮起作曲器。
3. 内容页（图像/插件等）替换 main，保留双轨导航。
4. 设置做成全页 master-detail，勿缩成 Grok 那种小模态。

### 反例
- 去掉图标轨只留会话列表（会变成 Grok Bot）。
- 设置用居中小对话框（不像 Codex）。
- 主区做成 IDE 三栏编辑器（过工程）。

---

## 二、分页面说明

## main — Codex 主空态
- 图标轨 + 侧栏（项目/最近）+ 居中「我们要构建什么？」+ 底浮作曲器；可有系统通知条。
- **必须像**：三列壳、英雄空态、浮起输入。

## chatgpt-mode-main — ChatGPT 模式主页
- 同壳；侧栏偏 Pin/Projects/Recents；主区更接近 ChatGPT Web 空态作曲器。
- **差异**：模式切换后信息架构略偏「聊天」而非「构建」。

## chat-thread — 会话线程
- 主区变为消息流；可含 Agent 工具步骤时间线；底作曲器贴底。
- **必须像**：步骤块可读、气泡/纯文本层级清楚。

## images / library / plugins / scheduled-tasks / code-review — 内容页族
- 共用双轨导航；main 换成各功能列表/网格/空态说明。
- **必须像**：页标题清晰、内容区大留白列表；功能可简化为占位列表。

## activity — 动态
- 活动流面板；时间线/卡片列表。

## search — 搜索
- 命令面板式 overlay，盖在壳上。

## mode-switcher — 模式切换
- 侧栏头下拉：ChatGPT / Codex。

## more-menu — 更多菜单
- 图标轨溢出 popover（项目/地图/代码审查等）。

## profile / profile-menu — 个人资料
- **profile**：全页统计、图表、热门插件。
- **profile-menu**：左下头像上浮菜单。

## settings-* — 全页设置族（账户/外观/通用/Git/钩子/密码/用量…）
- **共性**：左部分组（Personal / Integration / Coding 等）超长导航 + 右表单；顶可有设置内搜索。
- **行样式**：标题 + 灰色说明 | Toggle/下拉/路径+更改。
- **password**：凭证相关 UI 也按同样行列；外发注意打码。
- **必须像**：全页、分组侧栏、Fluent 软圆角卡片。
- **可省略**：真实路径、密钥、账单数字。

### 设置分区完整清单（布局同壳，仅右栏字段不同）
- `settings-account`
- `settings-ads`
- `settings-app-snapshots`
- `settings-appearance`
- `settings-archived-chats`
- `settings-browser`
- `settings-cloud-computer`
- `settings-cloud-preferences`
- `settings-code-review`
- `settings-computer-use`
- `settings-config`
- `settings-connections`
- `settings-data-controls`
- `settings-environments`
- `settings-general`
- `settings-git`
- `settings-hooks`
- `settings-import`
- `settings-mini-pet`
- `settings-notifications`
- `settings-parental-controls`
- `settings-password`
- `settings-personalization`
- `settings-plugins`
- `settings-shortcuts`
- `settings-trusted-contacts`
- `settings-usage-billing`
- `settings-voice`
- `settings-worktrees`

实现时一套 SettingsShell + 换表单即可。
