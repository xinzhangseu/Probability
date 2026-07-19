# ElegantBook PDF Format Extension for Quarto

将 ElegantBook LaTeX 模板的视觉样式完整移植到 Quarto 的自定义 PDF 格式扩展，
同时兼容 HTML 输出。面向中文学术写作场景（数学、统计、金融等领域）。

## 功能概览

### PDF 输出（核心）

- **标题页** — 自定义 `\maketitle`：封面图片 + 色条 + 标题信息 + logo 叠加
- **页面版式** — 页眉居中显示章名，章首页底部居中页码；目录页码大写罗马数字（I, II, III…）；章从奇数页起始
- **定理环境** — 12 种 tcolorbox 彩色框，带花色符号结尾
  - 定义类（绿色框 ♣）：definition, example, exercise, problem
  - 定理类（橙色框 ♥）：theorem, lemma, corollary, axiom, postulate
  - 命题类（蓝色框 ♠）：proposition, note, assumption, conclusion, property
- **中文全流程** — 定理标签、目录标题、参考文献标题均为中文；中文字体（macOS: Songti SC / Heiti SC / FangSong）
- **参考文献** — natbib 编号制 + `plainnat-doi.bst`（DOI 超链接支持），引用格式 `[1]`, `[1,2,5]`
- **特殊环境** — introduction（章节导读 double-column 框）、problemset（章后习题，装饰标题）
- **公式编号** — 仅带 `{#eq-xxx}` 标签的公式编号，无标签公式不编号；编号格式 `(1.1)`, `(1.2)` 按章编号；交叉引用自动加括号

### HTML 输出（辅助）

- 基于 cosmo 主题的自定义 SCSS（亮色/暗色双主题）
- Font Awesome 图标（页脚 ORCID / GitHub / Creative Commons 等）
- 可变章节标题（`[3]{.chapter-number}`）、自定义 callout 样式
- 侧边栏导航、页面搜索

### 双格式公用

- 同一套 `.qmd` 源文件，`quarto render --to html` 与 `quarto render --to elegantbook-pdf` 均可用
- 交叉引用（`@thm:label`、`@def:label`）在两种格式间通用

## 项目结构

```
quarto-elegantbook-pdf/
├── _quarto.yml                          # 项目配置（含标题页内嵌 LaTeX）
├── _variables.yml                       # 模板变量（ORCID, GitHub, PGP 等）
├── references.bib                       # 参考文献数据库
├── styles.css                           # HTML 布局 CSS
├── theme.scss / theme-dark.scss         # HTML 亮色/暗色主题
├── div-environments.lua                 # Lua 过滤器（环境映射 + 页码控制）
├── images/
│   ├── cover.jpg                        # 封面图片
│   ├── logo-blue.png                    # ElegantBook logo
│   └── openscapes_hex.png              # 侧边栏图标
├── index.qmd                            # 首页 / 引言
├── chap1.qmd                            # 测试章 1
├── chap2.qmd                            # 测试章 2
├── ref.qmd                              # 参考文献页
├── template_chapter1.qmd                # 模板章（随机控制理论 / SDE）
└── _extensions/
    ├── elegantbook/                     # 格式扩展（核心）
    │   ├── _extension.yml              # 扩展元数据 & LaTeX 配置
    │   ├── div-environments.lua        # 扩展内 Lua 过滤器（定理环境）
    │   ├── math-no-auto-number.lua     # Lua 过滤器（公式编号控制：仅标签公式编号）
    │   ├── orcidlink.sty               # ORCID 图标 LaTeX 包
    │   ├── plainnat-doi.bst            # BibTeX 样式（DOI 支持）
    │   ├── includes/
    │   │   ├── header-includes.tex     # LaTeX 导言区（颜色/字体/定理/页眉页脚/标题页/公式引用括号）
    │   │   └── before-body.tex         # 文档体起始定义（定理环境重定义）
    │   └── partials/
    │       ├── title.tex               # 标题元数据模板
    │       ├── author.tex              # 作者渲染模板
    │       ├── affiliation.tex         # 机构渲染模板
    │       ├── before-bib.tex          # 参考文献页眉抑制
    │       └── after-body.tex          # 作者简介（bio）
    └── quarto-ext/
        └── fontawesome/                # Font Awesome 扩展（HTML 图标短代码）
```

## 安装

### 方法一：本地使用（推荐）

将 `_extensions/elegantbook/` 目录复制到你的 Quarto 项目根目录：

```bash
cp -r quarto-elegantbook-pdf/_extensions/elegantbook/ your-project/_extensions/
```

如果你的项目需要 Font Awesome 图标（HTML 输出），一并复制：

```bash
cp -r quarto-elegantbook-pdf/_extensions/quarto-ext/fontawesome/ your-project/_extensions/quarto-ext/
```

### 方法二：Quarto 全局安装

```bash
quarto add /path/to/quarto-elegantbook-pdf/_extensions/elegantbook
```

## 快速开始

### 最小 `_quarto.yml`

```yaml
project:
  type: book
  output-dir: _book

book:
  title: "你的书名"
  author:
    - name: 作者名
      affiliations:
        - name: 机构名
          department: 系所
          city: 城市
          country: 国家
  chapters:
    - index.qmd
    - chapter1.qmd
    - chapter2.qmd
    - references.qmd

bibliography: references.bib

format:
  elegantbook-pdf:
    pdf-engine: xelatex
    keep-tex: true                    # 保留中间 .tex 文件（调试用）
    toc: true
    toc-depth: 2                      # 1=仅章标题, 2=章+节标题
    number-sections: true
    filters:
      - div-environments.lua
    include-in-header:
      - text: |
          \subtitle{你的副标题}
          \institute{你的机构全称}
          \version{v1.0}

  html:
    lang: zh
    theme: cosmo
    toc: false
```

### 标题页定制

在 `_quarto.yml` 的 `elegantbook-pdf` 格式下，通过 `include-in-header` 内嵌 LaTeX 代码设置副标题、机构和版本：

```yaml
include-in-header:
  - text: |
      \subtitle{你的副标题}
      \institute{你的机构全称}
      \version{v1.0}
```

### 编译

```bash
# 生成 PDF
quarto render --to elegantbook-pdf

# 生成 HTML
quarto render --to html

# 同时生成两种格式
quarto render
```

## 支持的环境

在 `.qmd` 文件中使用 fenced div 语法调用环境。带 `*` 的为不编号版本。

### 定理类环境

| 环境 | 颜色 | 符号 | .qmd 语法 |
|------|------|------|-----------|
| 定义 (Definition) | 绿色框 | ♣ | `::: {#def-label}` 或 `::: {.definition}` |
| 定理 (Theorem) | 橙色框 | ♥ | `::: {#thm-label}` 或 `::: {.theorem}` |
| 引理 (Lemma) | 橙色框 | ♥ | `::: {#lem-label}` 或 `::: {.lemma}` |
| 推论 (Corollary) | 橙色框 | ♥ | `::: {.corollary}` |
| 命题 (Proposition) | 蓝色框 | ♠ | `::: {#prp-label}` 或 `::: {.proposition}` |
| 公理 (Axiom) | 橙色框 | ♥ | `::: {.axiom}` |
| 公设 (Postulate) | 橙色框 | ♥ | `::: {.postulate}` |

用法示例：

```markdown
::: {#thm-hjb}

**HJB 方程。** 值函数 $V(t,x)$ 满足以下 Hamilton-Jacobi-Bellman 方程：

$$ -\frac{\partial V}{\partial t} = \sup_{u \in U} \left\{ f(t,x,u) + \mathcal{L}^u V(t,x) \right\}, \quad V(T,x) = g(x). $$

:::

参见 @thm-hjb。
```

### 其他环境

| 环境 | .qmd 语法 | 编号 | PDF 标签 |
|------|-----------|------|----------|
| 例 (Example) | `::: {.example}` | 否 | 例 |
| 练习 (Exercise) | `::: {.exercise}` | 否 | 练习 |
| 问题 (Problem) | `::: {.problem}` | 否 | 问题 |
| 注 (Note) | `::: {.note}` | 否 | 注 |
| 证明 (Proof) | `::: {.proof}` | 否 | 证明 |
| 解 (Solution) | `::: {.solution}` | 否 | 解 |
| 注记 (Remark) | `::: {.remark}` | 否 | 注记 |
| 假设 (Assumption) | `::: {.assumption}` | 否 | 假设 |
| 结论 (Conclusion) | `::: {.conclusion}` | 否 | 结论 |
| 性质 (Property) | `::: {.property}` | 否 | 性质 |
| 自定义 (Custom) | `::: {.custom}` | 否 | 自定义 |

### 特殊环境

**章节导读 (Introduction)**：

```markdown
::: {.introduction}

本章主要内容：随机微分方程的基本理论、Itô 公式及其在金融中的应用。

:::
```

**章后习题 (Problemset)**：

```markdown
::: {.problemset}

1. 证明 Black-Scholes 公式满足 Black-Scholes PDE。
2. 推导随机最优控制问题的最大值原理。

:::
```

## 参考文献配置

扩展使用 `natbib` + `plainnat-doi.bst`（编号制）。

### 引用语法

| 语法 | 输出 |
|------|------|
| `@karatzas1991brownian` | `[1]` |
| `[@karatzas1991brownian; @yong1999sch]` | `[1,2]` |

### 参考文献页

在你的 `.qmd` 文件末尾创建参考页：

```markdown
# 参考文献 {.unnumbered}

::: {#refs}
:::
```

### 参考文献数据库

`references.bib` 为标准 BibTeX 格式。模板已预置约 80 条随机控制、金融数学、保险数学相关文献。

## 页面版式细节

| 特性 | 实现方式 |
|------|----------|
| 页眉居中 | `\fancyhead[C]{\leftmark}` — 显示当前章名 |
| 章首页页码 | `\fancypagestyle{plain}` 添加 `\fancyfoot[C]{\thepage}` |
| 目录页码 | `\maketitle` 末尾设置 `\pagenumbering{Roman}`；文档体起始处 Lua filter 注入 `\pagenumbering{arabic}` |
| 目录深度 | `_quarto.yml` → `toc-depth: 2`（章 + 节） |
| 章奇数页起始 | 重定义 `\cleardoublepage` 覆盖 `oneside` 下的默认行为 |
| 公式编号 | `\numberwithin{equation}{chapter}` + Lua 过滤器（仅标签公式编号） |
| 公式引用括号 | `header-includes.tex` 中重定义 `\ref` → 检测 `eq-` 前缀后包裹括号 |
| 参考文献页眉 | `before-bib.tex` 清除 running header |
| Bio 页无页码 | `after-body.tex` 开头 `\pagestyle{empty}` |
| 标题页日期 | 使用 `\zhtoday`（ctex 提供的中文日期，如 "2026 年 6 月 14 日"） |
| 标题页封面与色条 | `\nointerlineskip` 消除基线间距 |

## 公式编号控制

Quarto 默认对所有 display math（`$$...$$`）使用 `\begin{equation}` 环境（即全部编号）。本扩展通过 Lua 过滤器 `math-no-auto-number.lua` 实现：**仅带 `{#eq-xxx}` 标签的公式编号，无标签公式不编号**。

```markdown
$$ E = mc^2 $$                    <!-- 无编号 -->

$$ \nabla \cdot \mathbf{E} = \frac{\rho}{\varepsilon_0} $$ {#eq-maxwell}  <!-- 编号 (1.1) -->
```

公式交叉引用通过 `@eq-xxx` 语法，输出自动带括号：

```markdown
由 @eq-maxwell 可知...           <!-- PDF: 由 (1.1) 可知... -->
```

**技术实现**：

- `math-no-auto-number.lua` — 在 Pandoc AST 阶段拦截无标识符的 DisplayMath，转为 `RawInline("latex", "\\[...\\]")`
- `header-includes.tex` — 重定义 `\ref`（通过 xstring 检测 `eq-` 前缀）手动包裹括号，解决 Quarto 不使用 `\eqref{}` 的已知缺陷

## 颜色主题

当前使用 **Blue 主题**（默认）。颜色定义：

| 变量 | RGB | 用途 |
|------|-----|------|
| `structurecolor` | 60,113,183 | 章标题、页眉页脚、TOC |
| `main` | 0,166,82 | 定义类环境边框 |
| `second` | 255,134,24 | 定理类环境边框、封面导引线 |
| `third` | 0,174,247 | 命题类环境边框 |
| `winered` | rgb(0.5,0,0) | 超链接颜色 |
| `coverlinecolor` | RGB(255,134,24) | 封面底部色条 |

如需切换主题，编辑 `_extensions/elegantbook/includes/header-includes.tex` 中的颜色定义。

## 自定义指南

### 修改中文字体

`header-includes.tex` 第 178-183 行已配置 macOS 字体（Songti SC, Heiti SC, FangSong_GB2312）。

Windows / Linux 用户需改为：

```latex
\setCJKmainfont{SimSun}[BoldFont=SimHei, ItalicFont=KaiTi]
\setCJKsansfont{SimHei}
\setCJKmonofont{FangSong}
```

### 修改定理环境标签

编辑 `before-body.tex` 中 `\DeclareTColorBox` 的内部标题文本（如将 `定理` 改为 `Theorem`）。

### 修改标题页信息

直接编辑 `_quarto.yml` 中 `elegantbook-pdf` 格式下的 `include-in-header` 内嵌 LaTeX：

```yaml
include-in-header:
  - text: |
      \subtitle{新的副标题}
      \institute{新的机构名}
      \version{v2.0}
```

### 修改变量

编辑 `_variables.yml`：

```yaml
orcid: "0000-0001-2345-6789"
github-url: "https://github.com/yourname/yourrepo"
years: "2026"
```

## 依赖

### LaTeX 宏包

模板依赖以下 LaTeX 宏包（均为 TeX Live 标准分发）：

`geometry`, `xcolor`, `titlesec`, `fancyhdr`, `tcolorbox`, `enumitem`, `tikz`,
`bbding`, `manfnt`, `adforn`, `multicol`, `amsmath`, `amsthm`, `caption`,
`booktabs`, `multirow`, `natbib`, `etoolbox`, `ctex`, `hyperref`, `orcidlink`, `xstring`

### 字体

- **中文字体**（macOS 默认可用）：Songti SC, Heiti SC, FangSong_GB2312
- **英文字体**：Times New Roman（需单独安装或通过 `mainfont` 配置）

### 其他

- Quarto ≥ 1.4
- XeLaTeX（`pdf-engine: xelatex`）

## 已知限制

1. **ElegantBook 特有功能不完整**：封面装饰花纹、版本历史表等功能尚未完全移植
2. **中文字体平台依赖**：当前中文字体配置为 macOS 默认字体；Windows/Linux 需手动修改
3. **颜色主题固定为 Blue**：切换其他 ElegantBook 内置主题（Green, Cyan, Custom 等）需手动编辑 `header-includes.tex`
4. **PDF 编译需多次 xelatex + bibtex**：Quarto 自动处理，但首次编译较慢
5. **`page-footer` 中的 `{{< fa >}}` 短代码在 PDF 编译时报 warning**：这不影响 PDF 输出，可忽略；如需消除，将 `page-footer` 从 `book:` 层移到 `format: html:` 层

## 版本历史

- **v1.0.0** (2026-06-13) — 初始版本
  - ElegantBook Blue 主题完整移植
  - 12 种定理环境 + 10 种其他环境 + introduction / problemset
  - natbib 编号制 + plainnat-doi.bst
  - 页眉居中、章首页页码、目录罗马数字、章奇数页起始
  - 中文标题页日期（`\zhtoday`）
  - 中文字体支持（macOS）
  - HTML 双主题（亮色/暗色）支持
  - 双格式（PDF + HTML）共用同一套 `.qmd` 源文件

## 许可证

ElegantBook 模板使用 [LPPL-1.3c](https://www.latex-project.org/lppl/lppl-1-3c/) 许可证。

本扩展在此基础上开发。

## 作者

Alex (AI Assistant)
