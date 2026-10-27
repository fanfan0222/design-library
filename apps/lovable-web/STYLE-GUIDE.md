# Lovable — 风格总指南（STYLE-GUIDE）

> 用途：还原 lovable.dev 应用/网站生成产品。  
> 平台：Web · 物理 4K。  
> 截图：`apps/lovable-web/<screen>/`。

---

## 一、产品整体 DNA

### 一句话定位
**现代 SaaS 营销英雄 + 登录后项目画布/对话生成**；onboarding 含 Light/Dark 风格选择步进条。

### 设计原则
1. 营销页：大标题、产品截图、强 CTA。
2. 登录后：项目网格 / 对话 + 预览。
3. 引导流：分步（style → …）底部 step indicator。

### 色板 Token（约值）
| Token | 约值 | 用途 |
|-------|------|------|
| `--bg` | 白/近白或深色 | 主底 |
| `--accent` | 品牌色（粉紫/电光系，以实截为准） | CTA |
| `--card` | 大圆角阴影卡 | 项目 |

### 字体
- 现代无衬线；营销标题很大。

### 组件通则
- Cookie banner；Getting started wizard；Dashboard 项目卡。

### 可还原总配方
1. 营销英雄 ≠ 工作台：入库时分开 screen。
2. Wizard 保留步进点。

### 反例
- 与 v0 黑白极简混淆；Lovable 更「消费级彩色 SaaS」。

---

## 二、分页面说明

## home
- 官网/登录后首页（以 meta.url 区分）。

## login / getting-started / dashboard（若有）
- 登录墙；引导；项目面板。

### 采集备注
- Google 登录后曾进入 `/getting-started`；dashboard 若仍跳登录需再采。
