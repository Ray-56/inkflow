# InkFlow MVP Quickstart

本指南用于验证 MVP 核心流程，所有步骤默认在 iPad 模拟器或真机上运行 `flutter run` 后执行。

## 1. 启动与笔记管理
1. 运行 `flutter run`，确保应用加载到 NoteList 页面。
2. 点击右上角 “+” 创建笔记并命名为 “Test Lecture”。
3. 在页面列表中新增两页，验证可拖拽排序并删除其中一页。

**期望结果**：重启应用后仍能看到 “Test Lecture” 笔记与排序后的页面列表。

## 2. 书写与工具切换
1. 在页面列表中点击第一页进入 Canvas。
2. 使用 Apple Pencil 或模拟 stylus 连续书写 30 秒，观察笔迹是否流畅、无明显延迟。
3. 切换高亮笔/橡皮擦，确认不同工具生效且 Undo/Redo 按钮可恢复 stroke。

**期望结果**：在 60fps 左右保持顺畅渲染，Undo/Redo 以 stroke 为粒度生效。

## 3. 自动保存与恢复
1. 在 Canvas 中绘制多条 stroke 后返回桌面强制结束应用。
2. 重新启动应用并打开同一页面，确认所有 stroke 被恢复，Undo/Redo 栈仍可使用。

## 4. 数据加密与导出
1. 完成书写后点击 “Export PNG” 并等待成功提示。
2. 使用 Finder 或 Files App 打开应用文档目录，确认 `inkflow_notes.json`、`*.strokes` 文件存在且内容为二进制（经 AES 加密）。
3. 打开导出的 PNG，确认笔迹完整、分辨率与画布一致。

## 5. Telemetry（可选）
1. 编写简单脚本模拟调用 `UsageLogger`，验证日志可写入控制台或后续目标通道。

完成以上步骤后，即可宣告 InkFlow MVP 端到端体验通过验收。
