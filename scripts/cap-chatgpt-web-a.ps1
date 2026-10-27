. F:\project\design-library\scripts\opencli-lib.ps1
$A='ChatGPT Web'; $G='chatgpt-web'
function Home { OC open https://chatgpt.com/ | Out-Null; OCw 4 }
function Esc { OC keys Escape | Out-Null; OCw 1 }
Home
OC click --role button --name 'Search' | Out-Null; OCw 2
Snap $G $A search '搜索对话' @('command-palette','modal','search') 'centered search modal over sidebar' 'Sidebar > Search' @('click Search') 'Chat search palette'
Esc
OC click --role button --name 'Open profile menu' | Out-Null; OCw 1.5
Snap $G $A profile-menu '个人资料菜单' @('popover-menu','account') 'bottom-left popover menu' 'Sidebar footer > profile' @('click Open profile menu') 'Profile menu'
Esc
OC click --role button --name 'Add files and more' | Out-Null; OCw 1.5
Snap $G $A composer-plus-menu '输入框 + 菜单' @('composer','popover-menu','tools') 'composer attached dropdown' 'Composer > +' @('click Add files and more') 'Attach / tools menu'
Esc
OC click --role button --name 'Explore' | Out-Null; OCw 1.5
Snap $G $A explore-menu 'Explore 菜单' @('sidebar','popover-menu') 'sidebar flyout menu' 'Sidebar > Explore' @('click Explore') 'Explore flyout'
Esc
OC click --role button --name 'Recents' | Out-Null; OCw 1.5
Snap $G $A recents-menu 'Recents 菜单' @('sidebar','popover-menu') 'sidebar flyout' 'Sidebar > Recents' @('click Recents') ''
Esc
OC click --role button --name 'Filter chats and work' | Out-Null; OCw 1.5
Snap $G $A recents-filter '最近对话筛选' @('sidebar','filter-menu') 'sidebar dropdown' 'Recents > filter' @('click Filter chats and work') ''
Esc
OC click --role button --name 'Add new project' | Out-Null; OCw 2
Snap $G $A new-project-modal '新建项目弹窗' @('modal','form','projects') 'centered modal' 'Projects > +' @('click Add new project') ''
Esc
OC click --role button --name 'Hide sidebar' | Out-Null; OCw 1.5
Snap $G $A sidebar-collapsed '侧栏收起' @('collapsed-rail','centered-composer','minimal') 'icon rail + centered composer' 'Hide sidebar' @('click Hide sidebar') ''
OC click --role button --name 'Show sidebar' | Out-Null; OCw 1
OC click --role button --name 'Temporary chat' | Out-Null; OCw 2
Snap $G $A temporary-chat '临时对话' @('temporary-chat','centered-composer') 'centered composer, temp mode banner' 'Header > Temporary chat' @('click Temporary chat') ''
Home
OC click --role button --name 'Work' | Out-Null; OCw 2
Snap $G $A work-mode 'Work 模式' @('mode-switch','upsell') 'segmented Chat/Work switch' 'Header > Work' @('click Work') 'Work mode (requires upgrade)'
Esc; Home
OC click --role button --name 'Think' | Out-Null; OCw 1.5
Snap $G $A think-toggle 'Think 推理开关' @('composer','toggle') 'composer chip' 'Composer > Think' @('click Think') ''
OC click --role button --name 'Think' | Out-Null; Esc
foreach ($p in @(@('images','https://chatgpt.com/images','图片'), @('library','https://chatgpt.com/library','资料库'), @('explore-gpts','https://chatgpt.com/gpts','探索 GPTs'), @('pricing','https://chatgpt.com/#pricing','升级套餐'), @('codex-web','https://chatgpt.com/codex','Codex 网页'), @('sora','https://chatgpt.com/sora','Sora'), @('gpts-mine','https://chatgpt.com/gpts/mine','我的 GPTs'), @('gpt-editor','https://chatgpt.com/gpts/editor','GPT 编辑器'))) {
  OC open $p[1] | Out-Null; OCw 5
  Snap $G $A $p[0] $p[2] @('page') 'sidebar + content page' $p[2] @("open $($p[1])") ''
}
Home
foreach ($b in @(@('scheduled','Scheduled','定时任务'), @('plugins','Plugins','插件'))) {
  OC click --role button --text $b[1] | Out-Null; OCw 4
  Snap $G $A $b[0] $b[2] @('page') 'sidebar + content page' $b[1] @("click $($b[1])") ''
  Home
}
OC click --role link --name '英语翻译' | Out-Null; OCw 5
Snap $G $A chat-thread '对话线程' @('chat-thread','message-bubbles','composer-bottom') 'sidebar + thread + bottom composer' 'Pinned chat' @('click pinned chat') 'Real conversation content'
OC click --role button --name 'Conversation options' | Out-Null; OCw 1.5
Snap $G $A chat-options-menu '对话选项菜单' @('popover-menu','thread-header') 'header dropdown' 'Thread > ...' @('click Conversation options') ''
Esc
OC click --role button --name 'Share' | Out-Null; OCw 2.5
Snap $G $A share-modal '分享对话弹窗' @('modal','share') 'centered modal' 'Thread > Share' @('click Share') 'Did not create link'
Esc
'DONE-A'