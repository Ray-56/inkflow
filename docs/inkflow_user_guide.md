# InkFlow 使用指南（MVP）

## 主要概念
- **Note**：笔记本集合，可包含多页面。
- **Page**：单独画布，支持背景样式与 stroke 历史。
- **Stroke**：一次连续书写轨迹，Undo/Redo 的基本单元。
- **Tools**：Pen、Highlighter、Eraser。

## 快速操作
1. 启动应用后在 NoteList 页面创建或选择笔记。
2. 在页面面板中点击某页进入 Canvas。
3. Stylus 默认绘制；手指用于平移、双指缩放；工具栏可切换笔刷/撤销/导出。
4. 导出的 PNG 保存到应用文档目录，可通过 Files App 或 Finder 访问。

## 手势与行为
- **Stylus**：Down→Move→Up 直接生成 stroke。
- **Finger**：拖动平移，双指缩放。
- **Undo/Redo**：按钮位于 CanvasToolbar 左侧，以 stroke 为单位。
- **Export PNG**：CanvasToolbar 右侧按钮，完成后显示提示。

## 约束与提示
- 当前版本只针对单用户本地数据，不含同步/协作能力。
- 所有数据自动加密存储，如需迁移请将整个 Documents 目录备份。
- 如遇写入失败或空间不足，StorageHealthMonitor 会提示释放空间；请清理后重试。
