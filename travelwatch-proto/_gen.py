#!/usr/bin/env python3
"""Generate TravelWatch three-variant clickable HTML prototypes."""
from pathlib import Path
OUT = Path("/workspace/travelwatch-proto")

# Shared body markup — skin via CSS variables / class on body
BODY = r'''
<nav class="preview-nav" aria-label="设计稿切页">
  <span class="pn-brand">TravelWatch · {label}</span>
  <a href="#landing">首页</a>
  <a href="#list">监控列表</a>
  <a href="#new">新建</a>
  <a href="#mail">到货邮件</a>
  <a href="#admin">运营台</a>
</nav>

<!-- LANDING：同页含 hero / 登录态 / 已发送态 -->
<main id="landing" class="screen shell">
  <header class="topbar">
    <a class="brand" href="#landing" data-nav="#landing">TravelWatch</a>
    <nav>
      <a href="#landing" data-nav="#landing" data-landing-state="login" class="js-landing-login">登录</a>
    </nav>
  </header>
  <div class="page">
    <!-- hero（默认） -->
    <section class="hero landing-panel" data-landing="hero">
      <div>
        <p class="eyebrow">票务监控 · 邮件通知</p>
        <h1>热门票务有货时通知你</h1>
        <p class="sub">选好地点和日期，系统替你查官方库存。有票发邮件，购买仍在官网完成。</p>
        <form class="mail-row" data-landing-submit="sent">
          <input type="email" name="email" placeholder="邮箱" autocomplete="email" required />
          <button class="btn" type="submit">开始监控</button>
        </form>
        <p class="hint">Magic Link 登录 · 不代下单 · 不聊天壳</p>
      </div>
      <div class="panel">
        <table>
          <thead><tr><th>地点</th><th>日期</th><th>状态</th></tr></thead>
          <tbody>
            <tr><td>梵蒂冈博物馆</td><td>2026-12-24</td><td><span class="pill ok">有票</span></td></tr>
            <tr><td>特罗姆瑟 → 斯沃尔韦尔</td><td>2027-02-26</td><td><span class="pill watch">监控中</span></td></tr>
            <tr><td>特罗姆瑟 → 哈斯塔德</td><td>2027-02-11</td><td><span class="pill off">暂无班次</span></td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- 登录态（同页） -->
    <section class="landing-panel page-center-inner" data-landing="login" hidden>
      <div class="form-shell">
        <h1>登录</h1>
        <p class="sub">输入邮箱，我们发送登录链接。无需密码。</p>
        <form class="form" data-landing-submit="sent">
          <label><span>邮箱</span>
            <input type="email" name="email" value="you@example.com" autocomplete="email" required />
          </label>
          <button class="btn btn-block" type="submit">发送登录邮件</button>
        </form>
        <p class="hint" style="margin-top:16px"><a class="link" href="#landing" data-nav="#landing" data-landing-state="hero">返回首页</a></p>
      </div>
    </section>

    <!-- 已发送态（同页） -->
    <section class="landing-panel page-center-inner" data-landing="sent" hidden>
      <div class="form-shell">
        <h1>请查收邮件</h1>
        <p class="sub">登录链接已发送到 <strong class="js-sent-email">you@example.com</strong>。如未收到，请检查垃圾箱。</p>
        <p class="hint">演示：点下方直接进入监控列表</p>
        <a class="btn" href="#list" data-nav="#list">打开监控列表</a>
        <p style="margin-top:16px"><a class="link" href="#landing" data-nav="#landing" data-landing-state="login">使用其他邮箱</a></p>
      </div>
    </section>
  </div>
</main>

<!-- LIST：同页可切有数据 / 空列表 -->
<main id="list" class="screen shell" hidden>
  <header class="topbar">
    <a class="brand" href="#landing" data-nav="#landing">TravelWatch</a>
    <nav>
      <span class="muted">you@example.com</span>
      <a href="#admin" data-nav="#admin" class="link-quiet">运营台</a>
    </nav>
  </header>
  <div class="page">
    <div class="toolbar">
      <div>
        <h1>监控</h1>
        <p class="sub js-list-sub">有票后会发邮件，并附官方购票链接。</p>
      </div>
      <div class="toolbar-right">
        <div class="proto-toggle" role="group" aria-label="列表状态（设计用）">
          <button type="button" class="proto-chip active" data-list-state="filled">有数据</button>
          <button type="button" class="proto-chip" data-list-state="empty">空列表</button>
        </div>
        <a class="btn" href="#new" data-nav="#new">新建监控</a>
      </div>
    </div>
    {list_extra}
    <div class="panel js-list-filled">
      <table>
        <thead>
          <tr><th>地点</th><th>日期</th><th>人数</th><th>状态</th><th></th></tr>
        </thead>
        <tbody>
          <tr>
            <td>梵蒂冈博物馆</td><td>2026-12-24</td><td>2</td>
            <td><span class="pill ok">有票</span></td>
            <td><div class="row-actions">
              <a class="btn secondary" href="https://tickets.museivaticani.va/" target="_blank" rel="noreferrer">打开官网</a>
              <button class="btn secondary" type="button">暂停</button>
              <button class="btn danger" type="button">删除</button>
            </div></td>
          </tr>
          <tr>
            <td>特罗姆瑟 → 斯沃尔韦尔</td><td>2027-02-26</td><td>1</td>
            <td><span class="pill watch">监控中</span></td>
            <td><div class="row-actions">
              <a class="btn secondary" href="https://www.hurtigruten.com/en/port-to-port" target="_blank" rel="noreferrer">打开官网</a>
              <button class="btn secondary" type="button">暂停</button>
              <button class="btn danger" type="button">删除</button>
            </div></td>
          </tr>
          <tr>
            <td>特罗姆瑟 → 哈斯塔德</td><td>2027-02-11</td><td>1</td>
            <td><span class="pill off">暂无班次</span></td>
            <td><div class="row-actions">
              <a class="btn secondary" href="https://www.hurtigruten.com/en/port-to-port" target="_blank" rel="noreferrer">打开官网</a>
              <button class="btn secondary" type="button">暂停</button>
              <button class="btn danger" type="button">删除</button>
            </div></td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="panel empty js-list-empty" hidden>
      <p>还没有监控任务。选一个景点和日期后，有票会发到你的邮箱。</p>
      <p style="margin-top:16px"><a class="btn" href="#new" data-nav="#new">新建监控</a></p>
    </div>
  </div>
</main>

<!-- NEW -->
<main id="new" class="screen shell" hidden>
  <header class="topbar">
    <a class="brand" href="#landing" data-nav="#landing">TravelWatch</a>
    <nav><a href="#list" data-nav="#list">返回列表</a></nav>
  </header>
  <div class="page page-center">
    <div class="form-shell">
      <h1>新建监控</h1>
      <p class="sub">系统按你填写的条件查询官方库存。</p>
      <form class="form" data-nav="#list">
        <div class="pick">
          <label>
            <input type="radio" name="site" value="vatican" checked />
            <strong>梵蒂冈博物馆</strong>
            <em>按日期查询入场票 · provider: vatican</em>
          </label>
          <label>
            <input type="radio" name="site" value="hurtigruten" />
            <strong>Hurtigruten 港到港</strong>
            <em>特罗姆瑟出发舱位 · provider: hurtigruten</em>
          </label>
        </div>
        <label id="route-fields" hidden>
          <span>到达港</span>
          <select name="toPort">
            <option value="SVJ">斯沃尔韦尔 (SVJ)</option>
            <option value="HRD">哈斯塔德 (HRD)</option>
          </select>
        </label>
        <label>
          <span>日期</span>
          <input type="date" name="date" value="2026-12-24" required />
        </label>
        <label>
          <span>人数</span>
          <input type="number" name="pax" min="1" max="6" value="2" required />
        </label>
        <div class="cols">
          <label>
            <span>时段开始（可选）</span>
            <input type="text" name="from" placeholder="11:30" />
          </label>
          <label>
            <span>时段结束</span>
            <input type="text" name="to" placeholder="12:30" />
          </label>
        </div>
        <label class="check">
          <input type="checkbox" name="enabled" checked />
          <span>启用监控（enabled）</span>
        </label>
        <button class="btn" type="submit">保存并开始监控</button>
      </form>
    </div>
  </div>
</main>

<!-- MAIL -->
<main id="mail" class="screen shell" hidden>
  <header class="topbar">
    <a class="brand" href="#landing" data-nav="#landing">TravelWatch</a>
  </header>
  <div class="page page-center">
    <article class="form-shell form-shell-mail mail">
      <p class="hint">TravelWatch 发至 you@example.com</p>
      <h1>梵蒂冈博物馆有票</h1>
      <p class="sub">日期 2026-12-24，2 人。请到官网完成购买。</p>
      <div class="mail-summary">
        <div><span>地点</span><strong>梵蒂冈博物馆</strong></div>
        <div><span>日期</span><strong>2026-12-24</strong></div>
        <div><span>人数</span><strong>2</strong></div>
        <div><span>状态</span><strong>有票</strong></div>
      </div>
      <p><a class="btn" href="https://tickets.museivaticani.va/" target="_blank" rel="noreferrer">打开梵蒂冈官网</a></p>
      <p class="hint">TravelWatch 不代下单。同一条有票通知不会重复发送，除非库存消失后再次出现。</p>
    </article>
  </div>
</main>

<!-- ADMIN -->
<main id="admin" class="screen shell admin-shell" hidden>
  <header class="topbar">
    <a class="brand" href="#landing" data-nav="#landing">TravelWatch</a>
    <nav><span class="muted">运营 · you@example.com</span></nav>
  </header>
  <div class="admin-layout">
    <aside class="admin-side">
      <button type="button" class="side-item active" data-panel="monitors">监控</button>
      <button type="button" class="side-item" data-panel="clients">客户</button>
      <button type="button" class="side-item" data-panel="rules">通知规则</button>
      <button type="button" class="side-item" data-panel="settings">设置</button>
    </aside>
    <div class="admin-main">
      <section class="admin-panel" data-panel="monitors">
        <div class="toolbar">
          <div>
            <h1>全部监控</h1>
            <p class="sub">跨客户任务总览 · provider / 港口 / 日期 / 人数 / enabled</p>
          </div>
          <a class="btn" href="#new" data-nav="#new">代客新建</a>
        </div>
        <div class="panel">
          <table>
            <thead><tr><th>客户</th><th>地点</th><th>日期</th><th>人数</th><th>enabled</th><th>状态</th></tr></thead>
            <tbody>
              <tr><td>Durant</td><td>梵蒂冈博物馆</td><td>2026-12-24</td><td>2</td><td>是</td><td><span class="pill ok">有票</span></td></tr>
              <tr><td>小红书·阿梨</td><td>特罗姆瑟 → 斯沃尔韦尔</td><td>2027-02-26</td><td>1</td><td>是</td><td><span class="pill watch">监控中</span></td></tr>
              <tr><td>Durant</td><td>特罗姆瑟 → 哈斯塔德</td><td>2027-02-11</td><td>1</td><td>否</td><td><span class="pill off">暂无班次</span></td></tr>
            </tbody>
          </table>
        </div>
      </section>
      <section class="admin-panel" data-panel="clients" hidden>
        <div class="toolbar">
          <div>
            <h1>客户</h1>
            <p class="sub">邮箱 · Cc 主人 · 欢迎信 · 备注</p>
          </div>
          <button class="btn" type="button">添加客户</button>
        </div>
        <div class="panel">
          <table>
            <thead><tr><th>客户</th><th>登录邮箱</th><th>Cc 主人</th><th>欢迎信</th><th>备注</th></tr></thead>
            <tbody>
              <tr><td>Durant</td><td>durant@example.com</td><td>owner@travelwatch.app</td><td><span class="pill ok">已发</span></td><td>挪威线重点</td></tr>
              <tr><td>小红书·阿梨</td><td>ali@xiaohongshu.test</td><td>owner@travelwatch.app</td><td><span class="pill watch">待发</span></td><td>小红书获客</td></tr>
            </tbody>
          </table>
        </div>
      </section>
      <section class="admin-panel" data-panel="rules" hidden>
        <div class="toolbar">
          <div>
            <h1>通知规则</h1>
            <p class="sub">有票邮件 · 去重 · Cc</p>
          </div>
        </div>
        <div class="panel pad">
          <form class="form form-wide" onsubmit="return false">
            <label class="check"><input type="checkbox" checked /><span>有票时发邮件给客户</span></label>
            <label class="check"><input type="checkbox" checked /><span>同时 Cc 主人邮箱</span></label>
            <label class="check"><input type="checkbox" checked /><span>同一库存周期不重复通知</span></label>
            <label><span>默认 Cc</span><input type="email" value="owner@travelwatch.app" /></label>
            <button class="btn" type="button">保存规则</button>
          </form>
        </div>
      </section>
      <section class="admin-panel" data-panel="settings" hidden>
        <div class="toolbar">
          <div>
            <h1>设置</h1>
            <p class="sub">品牌 · Magic Link · 运营备注字段</p>
          </div>
        </div>
        <div class="panel pad">
          <form class="form form-wide" onsubmit="return false">
            <label><span>产品名</span><input type="text" value="TravelWatch" /></label>
            <label><span>Magic Link 发件显示名</span><input type="text" value="TravelWatch" /></label>
            <label><span>备注标签示例</span><input type="text" value="Durant / 小红书" /></label>
            <button class="btn" type="button">保存设置</button>
          </form>
        </div>
      </section>
    </div>
  </div>
</main>
'''

JS = r'''
<script>
(function () {
  const KNOWN = new Set(["landing", "list", "new", "mail", "admin"]);
  const screens = [...document.querySelectorAll("main.screen")];
  const navLinks = [...document.querySelectorAll(".preview-nav a")];

  function setLandingState(state) {
    const next = state || "hero";
    document.querySelectorAll("[data-landing]").forEach((el) => {
      el.hidden = el.getAttribute("data-landing") !== next;
    });
  }

  function setListState(state) {
    const empty = state === "empty";
    const filled = document.querySelector(".js-list-filled");
    const emptyEl = document.querySelector(".js-list-empty");
    const sub = document.querySelector(".js-list-sub");
    if (filled) filled.hidden = empty;
    if (emptyEl) emptyEl.hidden = !empty;
    if (sub) sub.textContent = empty
      ? "还没有监控任务。"
      : "有票后会发邮件，并附官方购票链接。";
    document.querySelectorAll("[data-list-state]").forEach((btn) => {
      btn.classList.toggle("active", btn.getAttribute("data-list-state") === (empty ? "empty" : "filled"));
    });
  }

  function show(raw) {
    let hash = String(raw || "").replace(/^#/, "") || "landing";
    // 旧锚点兼容：login/sent → landing 同页态；empty → list 空态
    if (hash === "login") { hash = "landing"; setLandingState("login"); }
    else if (hash === "sent") { hash = "landing"; setLandingState("sent"); }
    else if (hash === "empty") { hash = "list"; setListState("empty"); }
    else if (!KNOWN.has(hash)) { hash = "landing"; setLandingState("hero"); }
    else if (hash === "landing") { /* keep current landing panel unless forced */ }

    screens.forEach((el) => { el.hidden = el.id !== hash; });
    navLinks.forEach((a) => {
      const href = a.getAttribute("href") || "";
      a.toggleAttribute("aria-current", href === "#" + hash);
    });
    window.scrollTo(0, 0);
  }

  function go(hash, landingState) {
    const id = String(hash || "#landing").replace(/^#/, "") || "landing";
    if (id === "landing" && landingState) setLandingState(landingState);
    else if (id === "landing" && !landingState) setLandingState("hero");
    if (location.hash === "#" + id) show("#" + id);
    else location.hash = id;
    // hashchange 会再调 show；同 hash 时上面已直接 show
    if (location.hash === "#" + id) show("#" + id);
  }

  function current() {
    const h = location.hash.slice(1) || "landing";
    if (h === "landing" && !document.querySelector('[data-landing="login"]:not([hidden]), [data-landing="sent"]:not([hidden])')) {
      // 初次进入或未知：默认 hero；若已有可见态则保留
      const visible = document.querySelector("[data-landing]:not([hidden])");
      if (!visible) setLandingState("hero");
    }
    show("#" + h);
  }

  function syncRoute() {
    const route = document.getElementById("route-fields");
    const picked = document.querySelector('input[name="site"]:checked');
    if (route) route.hidden = picked?.value !== "hurtigruten";
  }

  // 站内 a[href^="#"]：统一 JS 跳转（file:// 稳）
  document.addEventListener("click", (event) => {
    const a = event.target.closest('a[href^="#"]');
    if (!a) return;
    // 外部 / 新开窗不拦
    if (a.target === "_blank") return;
    event.preventDefault();
    const href = a.getAttribute("href") || "#landing";
    const landingState = a.getAttribute("data-landing-state");
    go(href, landingState || undefined);
  });

  // form：data-nav 跳屏；data-landing-submit 同页切态
  document.querySelectorAll("form").forEach((form) => {
    form.addEventListener("submit", (event) => {
      event.preventDefault();
      const landingSubmit = form.getAttribute("data-landing-submit");
      if (landingSubmit) {
        const emailInput = form.querySelector('input[type="email"]');
        const email = (emailInput && emailInput.value) || "you@example.com";
        document.querySelectorAll(".js-sent-email").forEach((el) => { el.textContent = email; });
        setLandingState(landingSubmit);
        go("#landing", landingSubmit);
        return;
      }
      const nav = form.getAttribute("data-nav") || form.getAttribute("action");
      if (nav && nav.startsWith("#")) go(nav);
    });
  });

  document.querySelectorAll('input[name="site"]').forEach((input) => {
    input.addEventListener("change", syncRoute);
  });

  document.querySelectorAll(".admin-side .side-item").forEach((btn) => {
    btn.addEventListener("click", () => {
      const panel = btn.dataset.panel;
      document.querySelectorAll(".admin-side .side-item").forEach((b) => b.classList.toggle("active", b === btn));
      document.querySelectorAll(".admin-panel").forEach((p) => { p.hidden = p.dataset.panel !== panel; });
    });
  });

  document.querySelectorAll(".filter-chip").forEach((chip) => {
    chip.addEventListener("click", () => {
      document.querySelectorAll(".filter-chip").forEach((c) => c.classList.toggle("active", c === chip));
    });
  });

  // 列表空态切换：button，不换 hash
  document.querySelectorAll("[data-list-state]").forEach((btn) => {
    btn.addEventListener("click", () => setListState(btn.getAttribute("data-list-state")));
  });

  window.addEventListener("hashchange", current);
  syncRoute();
  setLandingState("hero");
  setListState("filled");
  current();
})();
</script>
'''

BASE_CSS = r'''
*,*::before,*::after{box-sizing:border-box}
:root{--page-max:1080px}
html,body{margin:0;min-height:100%;font-family:var(--font);font-size:14px;line-height:1.45;background:var(--bg);color:var(--text)}
a{color:inherit}button,input,select{font:inherit}button{cursor:pointer}
.preview-nav{display:flex;flex-wrap:wrap;align-items:center;gap:4px;padding:8px 16px;background:#111827;position:sticky;top:0;z-index:50}
.preview-nav a{color:#d1d5db;text-decoration:none;padding:4px 8px;border-radius:4px;font-size:12px}
.preview-nav a[aria-current="page"]{color:#fff;background:#374151}
.pn-brand{color:#9ca3af;font-size:12px;margin-right:8px}
.shell{min-height:calc(100vh - 40px);display:flex;flex-direction:column}
.topbar{display:flex;align-items:center;justify-content:space-between;height:52px;padding:0 24px;background:var(--surface);border-bottom:1px solid var(--line);flex-shrink:0}
.brand{font-weight:600;text-decoration:none;letter-spacing:-0.02em}
.topbar nav{display:flex;gap:16px;align-items:center;color:var(--muted)}
.topbar nav a{text-decoration:none}
.topbar nav a:hover{color:var(--text)}
.muted{color:var(--muted)}.link,.link-quiet{color:var(--accent);text-decoration:none}
/* 唯一内容宽：landing / list / admin-main 共用 */
.page{width:min(var(--page-max),calc(100% - 48px));margin:0 auto;padding:24px 0 48px}
/* 短页/表单：垂直水平居中列 */
.page.page-center{flex:1;display:flex;align-items:center;justify-content:center;padding:32px 0 48px;width:min(var(--page-max),calc(100% - 48px))}
.page-center-inner{display:flex;align-items:center;justify-content:center;min-height:calc(100vh - 160px);padding:24px 0}
.form-shell{width:min(480px,100%);margin:0 auto}
.form-shell.form-shell-mail,.form-shell.mail{width:min(520px,100%)}
.form-shell:not(.mail){padding:28px;background:var(--surface);border:1px solid var(--line);border-radius:var(--radius)}
h1{margin:0 0 8px;font-size:22px;font-weight:600;letter-spacing:-0.02em}
.sub{margin:0 0 20px;color:var(--muted)}.eyebrow{margin:0 0 8px;font-size:12px;color:var(--accent);font-weight:500}
.hero{display:grid;grid-template-columns:1fr 1.15fr;gap:32px;align-items:start;padding:28px 0}
.mail-row{display:flex;gap:8px;margin-top:16px}
.mail-row input{flex:1;height:40px;padding:0 12px;border:1px solid var(--line);border-radius:var(--radius-sm);background:var(--input-bg,var(--surface));color:var(--text)}
.btn{display:inline-flex;align-items:center;justify-content:center;height:36px;padding:0 14px;border:1px solid transparent;border-radius:var(--radius-sm);background:var(--primary);color:var(--primary-fg,#fff);text-decoration:none;white-space:nowrap;font-weight:500}
.btn:hover{filter:brightness(1.06)}.btn-block{width:100%;height:40px}
.btn.secondary{background:var(--surface);color:var(--text);border-color:var(--line)}
.btn.secondary:hover{background:var(--bg)}
.btn.danger{background:var(--surface);color:var(--danger);border-color:var(--line)}
.hint{margin:8px 0 0;color:var(--muted);font-size:12px}
.panel{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);overflow:hidden}
.panel.pad{padding:20px}.toolbar{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:16px}
.toolbar-right{display:flex;align-items:center;gap:10px;flex-wrap:wrap;justify-content:flex-end}
.proto-toggle{display:inline-flex;gap:2px;padding:2px;border:1px solid var(--line);border-radius:999px;background:var(--surface)}
.proto-chip{height:26px;padding:0 10px;border:0;border-radius:999px;background:transparent;color:var(--muted);font-size:11px}
.proto-chip.active{background:var(--chip-active-bg,var(--primary));color:var(--chip-active-fg,#fff)}
table{width:100%;border-collapse:collapse;table-layout:fixed}
th,td{padding:10px 12px;text-align:left;border-bottom:1px solid var(--line);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
th{font-weight:500;color:var(--muted);background:var(--th-bg,transparent);font-size:12px}
.row-actions{display:flex;justify-content:flex-end;gap:6px;flex-wrap:wrap}
.pill{display:inline-flex;align-items:center;padding:2px 8px;border-radius:999px;font-size:12px;font-weight:500;border:1px solid transparent}
.pill.ok{color:var(--ok);background:var(--ok-bg);border-color:var(--ok-bd)}
.pill.watch{color:var(--watch);background:var(--watch-bg);border-color:var(--watch-bd)}
.pill.off{color:var(--danger);background:var(--off-bg);border-color:var(--off-bd)}
.form{display:grid;gap:14px;width:100%;max-width:none}.form-wide{max-width:none}
label span{display:block;margin-bottom:6px;color:var(--muted)}
input[type="email"],input[type="text"],input[type="date"],input[type="number"],select{
  width:100%;height:36px;padding:0 10px;border:1px solid var(--line);border-radius:var(--radius-sm);background:var(--input-bg,var(--surface));color:var(--text)}
.pick{display:grid;gap:8px}
.pick label{display:grid;grid-template-columns:auto 1fr;gap:4px 10px;padding:12px;border:1px solid var(--line);border-radius:var(--radius);background:var(--surface);cursor:pointer}
.pick label:has(input:checked){border-color:var(--primary);box-shadow:0 0 0 1px var(--primary)}
.pick input{width:auto;height:auto;margin-top:3px}
.pick strong,.pick em{grid-column:2}.pick em{font-style:normal;color:var(--muted);font-size:12px}
.cols{display:grid;grid-template-columns:1fr 1fr;gap:8px}
.check{display:flex!important;align-items:center;gap:8px}
.check span{margin:0!important;color:var(--text)!important}
.check input{width:auto;height:auto}
.empty{padding:56px 16px;text-align:center;color:var(--muted)}
.mail{padding:28px;background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);margin:0}
.mail-summary{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin:0 0 20px;padding:14px;border:1px solid var(--line);border-radius:var(--radius-sm);background:var(--th-bg,transparent)}
.mail-summary span{display:block;font-size:11px;color:var(--muted);margin-bottom:2px}
.mail-summary strong{font-weight:560}
.filters{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:12px}
.filter-chip{height:28px;padding:0 12px;border-radius:999px;border:1px solid var(--line);background:var(--surface);color:var(--muted);font-size:12px}
.filter-chip.active{background:var(--chip-active-bg,var(--primary));color:var(--chip-active-fg,#fff);border-color:transparent}
.admin-layout{display:grid;grid-template-columns:220px 1fr;min-height:calc(100vh - 92px);flex:1}
.admin-side{border-right:1px solid var(--line);background:var(--side-bg,var(--surface));padding:12px;display:flex;flex-direction:column;gap:4px}
.side-item{text-align:left;border:0;background:transparent;color:var(--muted);padding:8px 12px;border-radius:var(--radius-sm);font-weight:500}
.side-item:hover{background:var(--side-hover);color:var(--text)}
.side-item.active{background:var(--side-active);color:var(--text)}
.admin-main{padding:24px;overflow:auto;display:flex;flex-direction:column;align-items:center}
.admin-main .admin-panel{width:min(var(--page-max),100%)}
.btn:focus-visible,input:focus-visible,select:focus-visible,.topbar a:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
@media (max-width:860px){
  .hero,.cols,.mail-summary{grid-template-columns:1fr}
  .page,.page.page-center{width:calc(100% - 24px)}
  table{table-layout:auto;min-width:680px}
  .panel{overflow-x:auto}
  .admin-layout{grid-template-columns:1fr}
  .admin-side{flex-direction:row;overflow-x:auto;border-right:0;border-bottom:1px solid var(--line)}
  .side-item{white-space:nowrap}
}
'''


THEMES = {
  "A-linear.html": {
    "title": "TravelWatch · A Linear",
    "label": "A · Linear 克制列表",
    "list_extra": "",
    "css": BASE_CSS + r'''
:root{
  --font: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Inter, sans-serif;
  --bg:#0f0f12; --surface:#16161a; --text:#ececef; --muted:#8b8b96;
  --line:#2a2a32; --primary:#5e6ad2; --accent:#8b8cff; --danger:#f04438;
  --ok:#4ade80; --ok-bg:rgba(74,222,128,.12); --ok-bd:rgba(74,222,128,.25);
  --watch:#a5b4fc; --watch-bg:rgba(99,102,241,.15); --watch-bd:rgba(99,102,241,.3);
  --off-bg:rgba(240,68,56,.12); --off-bd:rgba(240,68,56,.25);
  --radius:8px; --radius-sm:6px; --th-bg:#121216;
  --side-bg:#121216; --side-hover:#1c1c22; --side-active:#22222b;
  --input-bg:#0f0f12; --chip-active-bg:#5e6ad2;
}
body{background:var(--bg)}
.topbar{background:#121216;border-bottom-color:#22222b}
.panel{box-shadow:none}
th,td{padding:8px 12px;font-size:13px}
.hero h1{font-size:32px;font-weight:560;letter-spacing:-0.04em}
.form-shell{background:#16161a}
.mail{background:#16161a}
'''
  },
  "B-github.html": {
    "title": "TravelWatch · B GitHub Issues",
    "label": "B · GitHub Issues 多客户流",
    "list_extra": '''
    <div class="filters" role="tablist" aria-label="状态过滤">
      <button type="button" class="filter-chip active">全部</button>
      <button type="button" class="filter-chip">有票</button>
      <button type="button" class="filter-chip">监控中</button>
      <button type="button" class="filter-chip">暂无班次</button>
    </div>
    ''',
    "css": BASE_CSS + r'''
:root{
  --font: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans", Helvetica, Arial, sans-serif;
  --bg:#f6f8fa; --surface:#ffffff; --text:#1f2328; --muted:#656d76;
  --line:#d0d7de; --primary:#1f883d; --accent:#0969da; --danger:#cf222e;
  --ok:#1a7f37; --ok-bg:#dafbe1; --ok-bd:#4ac26b66;
  --watch:#0969da; --watch-bg:#ddf4ff; --watch-bd:#54aeff66;
  --off-bg:#ffebe9; --off-bd:#ff818266;
  --radius:6px; --radius-sm:6px; --th-bg:#f6f8fa;
  --side-bg:#ffffff; --side-hover:#f3f4f6; --side-active:#ddf4ff;
  --chip-active-bg:#1f883d;
}
.topbar{height:56px}
.brand{font-weight:700}
.panel{border-radius:6px}
.hero h1{font-size:28px}
.filter-chip.active{background:#1f883d}
.side-item.active{color:#0969da;font-weight:600}
'''
  },
  "C-stripe-claude.html": {
    "title": "TravelWatch · C Stripe + Claude",
    "label": "C · Stripe + Claude 设置气质",
    "list_extra": "",
    "css": BASE_CSS + r'''
:root{
  --font: ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif;
  --bg:#f5f2eb; --surface:#fffcf7; --text:#1a1a1a; --muted:#8a857c;
  --line:#e6e0d4; --primary:#635bff; --accent:#635bff; --danger:#df1b41;
  --ok:#0d9488; --ok-bg:#ccfbf1; --ok-bd:#5eead466;
  --watch:#635bff; --watch-bg:#eef2ff; --watch-bd:#a5b4fc66;
  --off-bg:#ffe4e6; --off-bd:#fb718566;
  --radius:16px; --radius-sm:10px; --th-bg:#faf7f0;
  --side-bg:#f0ebe1; --side-hover:#e7e0d3; --side-active:#fff;
  --input-bg:#fffcf7; --chip-active-bg:#635bff;
}
.topbar{background:#fffcf7;border-bottom-color:#e6e0d4}
.brand{letter-spacing:-0.03em}
.btn{border-radius:999px;height:38px;padding:0 16px}
.btn.secondary,.btn.danger{border-radius:999px}
.mail-row input{border-radius:999px;height:42px;padding:0 16px}
.hero h1{font-size:34px;font-weight:560;letter-spacing:-0.035em}
.form-shell{border-radius:20px;box-shadow:0 8px 30px rgba(40,30,10,.06)}
.panel{border-radius:16px;box-shadow:0 1px 2px rgba(40,30,10,.04)}
.side-item{border-radius:999px}
.side-item.active{box-shadow:0 1px 2px rgba(0,0,0,.04)}
.mail{border-radius:20px;background:#fffcf7}
.pick label{border-radius:14px}
'''
  },
}

INDEX = '''<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>TravelWatch · 原型入口</title>
  <style>
    *{box-sizing:border-box}
    body{margin:0;font-family:ui-sans-serif,system-ui,-apple-system,"Segoe UI",sans-serif;background:#0b0b0f;color:#eee;min-height:100vh;padding:48px 24px}
    .wrap{width:min(960px,100%);margin:0 auto}
    .badge{display:inline-flex;align-items:center;gap:6px;padding:4px 10px;border-radius:999px;background:#14532d;color:#86efac;font-size:12px;font-weight:500;margin-bottom:16px}
    h1{margin:0 0 10px;font-size:32px;letter-spacing:-0.03em;font-weight:600}
    .lead{margin:0 0 8px;color:#d4d4d8;font-size:15px;line-height:1.55;max-width:640px}
    .note{margin:0 0 28px;color:#71717a;font-size:13px;line-height:1.5}
    .cards{display:grid;gap:16px;grid-template-columns:repeat(auto-fit,minmax(260px,1fr))}
    a.card{display:flex;flex-direction:column;padding:22px;border-radius:16px;text-decoration:none;color:inherit;border:1px solid #27272a;background:#141418;min-height:180px;transition:border-color .15s}
    a.card:hover{border-color:#6366f1}
    .tag{font-size:11px;color:#a5b4fc;margin-bottom:10px;font-weight:500;letter-spacing:.02em}
    .card h2{margin:0 0 8px;font-size:18px}
    .card p{margin:0;font-size:13px;color:#a1a1aa;line-height:1.45;flex:1}
    .card .go{margin-top:16px;font-size:12px;color:#818cf8}
    .meta{margin-top:32px;padding-top:20px;border-top:1px solid #27272a;font-size:12px;color:#71717a;line-height:1.6}
    .meta a{color:#a5b4fc}
  </style>
</head>
<body>
  <div class="wrap">
    <div class="badge">5 主屏 · 版心 1080px · 跳转已加固</div>
    <h1>TravelWatch 原型</h1>
    <p class="lead">主路径：首页（含登录/已发送）→ 监控列表（含空态）→ 新建 → 到货邮件；运营台独立。</p>
    <p class="note">点下方卡片进入对应风格；页内顶部黑条只切 5 个主屏。登录与查收邮件并入首页同页态；空列表在监控列表内切换，不再单独成屏。</p>
    <div class="cards">
      <a class="card" href="./A-linear.html">
        <div class="tag">A · Linear</div>
        <h2>克制深色列表</h2>
        <p>深底细分割、靛紫强调、紧凑行高。适合工程向监控台。</p>
        <span class="go">打开 A →</span>
      </a>
      <a class="card" href="./B-github.html">
        <div class="tag">B · GitHub Issues</div>
        <h2>浅色多客户流</h2>
        <p>绿主 CTA + 状态过滤芯片。适合运营扫列表、多客户并行。</p>
        <span class="go">打开 B →</span>
      </a>
      <a class="card" href="./C-stripe-claude.html">
        <div class="tag">C · Stripe + Claude</div>
        <h2>暖纸设置气质</h2>
        <p>紫 CTA #635BFF + 暖纸底与大圆角。适合订阅 / 计费感产品壳。</p>
        <span class="go">打开 C →</span>
      </a>
    </div>
    <p class="meta">仓库：<a href="https://github.com/fanfan0222/design-library/tree/main/travelwatch-proto">design-library/travelwatch-proto</a><br>
    本机：F:/project/Trip/design/variants/ · F:/project/design-library/travelwatch-proto/</p>
  </div>
</body>
</html>
'''


def write_variant(filename, meta):
    body = BODY.format(label=meta["label"], list_extra=meta["list_extra"])
    html = f'''<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>{meta["title"]}</title>
  <style>{meta["css"]}</style>
</head>
<body>
{body}
{JS}
</body>
</html>
'''
    path = OUT / filename
    path.write_text(html, encoding="utf-8")
    print(f"wrote {path} ({path.stat().st_size} bytes)")

for name, meta in THEMES.items():
    write_variant(name, meta)
(OUT / "index.html").write_text(INDEX, encoding="utf-8")
print("wrote index.html")
print("done")
