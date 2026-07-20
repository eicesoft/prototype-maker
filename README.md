# prototype-maker

把一句话的系统描述，变成一个**可运行、看起来像真实产品**的高保真原型项目。

技术栈固定为：**Vue 3 + Vite + Element Plus + vue-router**。

> 这是一个 Claude Code Skill。安装到 `~/.claude/skills/prototype-maker/` 后，当你说"生成高保真原型""做个原型""画个原型页面"等，会自动触发。

## 它解决什么问题

产品/业务同学想看一个系统"长什么样、点起来是什么手感"，传统做法要么靠线框图（太糙），要么真去搭工程（太重）。这个 skill 让你一句话描述需求，Claude 先问清几个关键点，然后直接产出一个能 `npm run dev` 跑起来、mock 数据真实、交互闭环的 Vue 项目——拿给业务看就是产品级观感。

## 触发方式

直接用自然语言描述即可，无需命令：

- "帮我做个订单管理后台的原型"
- "给我看看一个航运采购系统长什么样"
- "生成高保真原型：电商后台，含数据看板、订单、售后"
- "画个原型页面，用户权限管理"

即使只粗略描述了一个系统，也会主动触发，先问清需求再生成。

## 前置依赖

- **无需提前装 Node**：脚手架脚本开头会自检，发现没有 Node 或版本不符时自动安装 **Node v22.23.x** 到用户目录（免 sudo / 免管理员权限），并写好 shell profile；已有合用的 Node 则直接复用。跨平台覆盖：
  - macOS / Linux：`scripts/create-project.sh` → 经 nvm 安装，写入 `.zshrc`/`.bashrc`
  - Windows：`scripts/create-project.ps1` → 经 fnm 安装，写入 PowerShell profile
- 联网（首次拉取 vite 模板与依赖；自动安装 Node 时还会从 GitHub 拉 nvm / fnm 安装包）。
- 可选：pnpm —— 默认流程走 npm，想用 pnpm 时手动跑一次 `ensure-node.sh --pnpm` / `ensure-node.ps1 --pnpm` 启用。
- 需要图表时，skill 会在项目内 `npm install echarts`，无需提前装。

## 目录结构

```
prototype-maker/
├── SKILL.md                 # Skill 主指令（流程 + 高保真验收标准 + 页面通用模式）
├── README.md                # 本文件
├── scripts/
│   ├── ensure-node.sh        # Node 自检 (mac/Linux)：缺失则经 nvm 装 v22.23.x，可选 --pnpm
│   ├── ensure-node.ps1       # Node 自检 (Windows)：同上，经 fnm 安装
│   ├── create-project.sh     # 脚手架 (mac/Linux)：生成项目骨架，开头先 source ensure-node.sh
│   └── create-project.ps1    # 脚手架 (Windows)：同上，开头先 dot-source ensure-node.ps1
├── assets/
│   └── template/             # 脚手架写入的模板文件（main.js / App.vue / Home.vue / theme.css / router）
├── references/
│   └── style-guide.md        # 清新浅色风格规范（色板、层次、列表页结构、Dialog 尺寸、删除约定）
└── evals/
    └── evals.json            # 测试用例与断言
```

## 生成的项目长什么样

跑完脚手架后，项目里有：

- `src/router/index.js` — 路由表，**所有模块在这里注册**
- `src/views/Home.vue` — 首页，自动读取路由表生成原型卡片列表
- `src/App.vue` — 顶栏导航，自动读取路由表生成切换入口
- `src/styles/theme.css` — 清新浅色主题（CSS 变量 + Element Plus 主题色覆盖）

每加一个模块，只需：写一个 `src/views/<Module>.vue`，在路由表注册一条并填 `meta.title` / `meta.desc`——首页卡片和顶部导航自动就有了，不用改别处。

## 页面约定（高保真）

skill 对生成页面有几条硬约定，保证原型不像线框图：

1. **Mock 数据要像真的**：张三李四王五、"杭州云杉网络科技有限公司"、¥12,800.00、真实日期与状态流转，每页 10+ 条。禁止"测试数据1""abc"。
2. **列表页 = 顶部筛选 panel + 表格 + 分页**：筛选区统一收进一个 `el-card`，内部 `el-form` + `el-row`/`el-col` 响应式 grid（`xs:24 sm:12 md:8 lg:6`）。
3. **点击表格行不跳转页面，弹 Dialog**：`@row-click` 打开 `el-dialog`，宽度按内容分小/中/大三档（30% / 50% / 70%）。
4. **删除必须二次确认**：`ElMessageBox.confirm`，文案点明"删除后不可恢复"+对象名，确认后本地更新数据 + `ElMessage.success`。
5. **交互闭环 + 状态覆盖**：点按钮有反应，关键页面有 `v-loading` / `el-empty`。
6. 优先用 Element Plus 现成组件，不手写组件库里已有的东西。

视觉风格集中改 `src/styles/theme.css` 的 CSS 变量，页面里不写死颜色。详见 `references/style-guide.md`。

## 交付前自检

skill 会自行完成，无需手动：

1. `npm run build` 通过
2. `npm run dev` 后台启动，确认 dev server 正常监听
3. 把访问地址（如 http://localhost:5173）和项目路径交付，并简要说明有哪些页面

## 使用示例

对 Claude 说：

> 生成高保真原型：一个电商订单管理后台。模块包括：数据看板（核心指标卡片+销售趋势图）、订单列表（多条件筛选、分页、状态标签）、订单详情（商品明细、物流轨迹、操作记录）、售后管理（退换货工单处理）。

Claude 会：先确认是否有遗漏需求 → 跑脚手架 → 逐模块写页面并注册路由 → 构建验证 → 起服务 → 给你访问地址。

## 注意

- 每次"生成高保真原型"都是**独立新项目**，不会往已有项目里塞。
- 原型是给产品/业务看的，美观和真实感的优先级高于代码优雅；但也不会交付一打开控制台全是 warning 的代码。
- 用户中途改需求（加模块、改风格）直接在当前项目增量改，不推倒重来。
