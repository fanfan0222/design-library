# Perplexity — 风格总指南（STYLE-GUIDE）

> 用途：还原 perplexity.ai 检索/回答产品壳。  
> 平台：Web · 物理 4K 全屏。  
> 截图：`apps/perplexity-web/<screen>/`。

---

## 一、产品整体 DNA

### 一句话定位
**居中搜索英雄 + 回答页引文卡片**；Spaces/Projects 做集合；设置偏账户面板。比纯聊天产品更「搜索引擎 × AI」。

### 设计原则
1. 首页大输入「Ask anything」中轴。
2. 结果页：回答正文 + 来源芯片/侧引文。
3. Spaces/Projects 为集合导航。
4. 深浅均可，默认偏深或中性对比（以实截为准）。

### 色板 Token（约值）
| Token | 约值 | 用途 |
|-------|------|------|
| `--bg` | 深炭或浅灰 | 主底 |
| `--composer` | 大圆角输入 | 搜索 |
| `--accent` | 青绿/品牌青 | 焦点、主按钮 |
| `--source-chip` | 小圆角标签 | 引文 |

### 字体
- 无衬线；英雄问句较大；回答正文舒适行高。

### 组件通则
- 顶栏：Logo、模式、库/发现、账户。
- Spaces 网格/列表；Settings 账户表单。

### 可还原总配方
1. 首页 = 中轴巨大搜索。
2. Spaces = 集合卡片。
3. Settings = 账户分区。

### 反例
- 做成纯 ChatGPT 气泡串而丢掉引文/来源层。

---

## 二、分页面说明

## home
- 首页/搜索（含 onboarding 重定向时的过渡态）。若 URL 含 onboarding，属于半登录，下次登录后重采。

## spaces
- Spaces/Projects 集合页。

## settings-account
- 账户设置（hash 或 `/settings/...`）。

## account-menu
- 账户弹出菜单。

## discover / library（若有）
- 发现流 / 资料库。

### 采集备注
- 本轮 bridge 未稳定出现 Google 按钮；部分屏可能为访客/引导态，**建议登录后复采 home**。
