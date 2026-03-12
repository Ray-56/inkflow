# Tasks: InkFlow MVP

**Input**: Design documents from `/specs/001-inkflow-mvp/`  
**Prerequisites**: plan.md, spec.md

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 准备 Flutter 工程的 DDD 目录与工具链

- [X] T001 创建 DDD 目录骨架 `lib/domain`, `lib/application`, `lib/infrastructure`, `lib/presentation`, `test/` 子目录
- [X] T002 更新 `analysis_options.yaml` 以启用严格 lint & 命名规则，确保中英文命名约束
- [X] T003 在 `pubspec.yaml` 加入 Riverpod、path_provider、crypto 依赖并执行 `flutter pub get`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 建立所有故事共享的核心设施

- [X] T004 定义统一输入模型 `InputEvent` 与 `InputDeviceKind` 于 `lib/domain/input/input_event.dart`
- [X] T005 实现可持久化的 `UndoRedoStack` 基类于 `lib/domain/services/undo_redo_stack.dart`
- [X] T006 定义 `StorageSecurityService` 接口以支撑透明加密于 `lib/domain/services/storage_security_service.dart`
- [X] T007 构建 `AutoSaveScheduler` 与 `StorageHealthMonitor` 框架于 `lib/application/coordinators/autosave_scheduler.dart`

**Checkpoint**: 输入、撤销和安全框架就绪，可进入用户故事实现。

---

## Phase 3: User Story 1 - 创建并管理多页面笔记 (Priority: P1) 🎯 MVP

**Goal**: 用户能创建笔记、增删/复制/排序页面并在重启后保持结果  
**Independent Test**: 仅通过 Note 管理 UI 操作即可新增 1 本含 3 页的笔记、调整顺序、删除页后重启仍如预期

### Implementation

- [X] T008 [US1] 建立 Page 实体（含背景/尺寸）与页面操作方法于 `lib/domain/pages/page.dart`
- [X] T009 [US1] 建立 Note 聚合与页面集合一致性约束于 `lib/domain/notes/note.dart`
- [X] T010 [US1] 定义 `NoteRepository` 接口（含 CRUD 与排序 API）于 `lib/domain/notes/note_repository.dart`
- [X] T011 [US1] 实作 `CreateNoteUseCase`/`DeleteNoteUseCase` 于 `lib/application/usecases/notes/manage_note_usecase.dart`
- [X] T012 [US1] 实作页面增删/复制/排序用例于 `lib/application/usecases/pages/manage_page_usecase.dart`
- [X] T013 [US1] 创建 `NoteListViewModel` 管理笔记与页面状态于 `lib/presentation/viewmodels/note_list_viewmodel.dart`
- [X] T014 [US1] 实作 `NoteListPage`/页面缩略图 UI 与操作入口于 `lib/presentation/pages/note_list_page.dart`
- [X] T015 [US1] 编写 `NoteRepositoryImpl`（调用 JSON store）于 `lib/infrastructure/repositories/note_repository_impl.dart`
- [X] T016 [US1] 实作透明加密 JSON 存储 `NoteStore` 于 `lib/infrastructure/persistence/json/note_store.dart`

**Checkpoint**: 完成后可独立演示“创建/管理多页笔记”并持久化。

---

## Phase 4: User Story 2 - 流畅手写与工具切换 (Priority: P1)

**Goal**: Stylus 默认绘制、finger 平移缩放，三种工具切换并保持 60fps in-progress 渲染  
**Independent Test**: 在 Canvas 页面连续书写 30 秒、切换工具/手势，确认笔迹无断裂、误触与延迟

### Implementation

- [X] T017 [US2] 定义 `StrokePoint` 值对象（含位置/pressure/tilt）于 `lib/domain/strokes/stroke_point.dart`
- [X] T018 [US2] 定义 `DrawingTool` 值对象（类型/宽度/颜色/透明度）于 `lib/domain/tools/drawing_tool.dart`
- [X] T019 [US2] 创建 `Stroke` 聚合（含 points、tool、缓存引用）于 `lib/domain/strokes/stroke.dart`
- [X] T020 [US2] 定义 `CanvasSession`（含 Viewport、activeTool）于 `lib/domain/sessions/canvas_session.dart`
- [X] T021 [US2] 实作 `StrokeRecordUseCase`（start/append/complete）于 `lib/application/usecases/strokes/stroke_record_usecase.dart`
- [X] T022 [US2] 实作 `ChangeDrawingToolUseCase` 与预设管理于 `lib/application/usecases/tools/change_tool_usecase.dart`
- [X] T023 [US2] 统一 Flutter 输入为 `InputEvent` 的 `InputNormalizer` 于 `lib/application/coordinators/input_normalizer.dart`
- [X] T024 [US2] 创建 `CanvasViewModel` 处理 in-progress strokes 于 `lib/presentation/viewmodels/canvas_viewmodel.dart`
- [X] T025 [US2] 实作 `GestureController` 将 stylus/finger 区分于 `lib/presentation/controllers/gesture_controller.dart`
- [X] T026 [US2] 构建 Canvas 页面与工具栏交互于 `lib/presentation/pages/canvas_page.dart`
- [X] T027 [US2] 编写 `CanvasPainter` 分层渲染 in-progress 与缓存层于 `lib/presentation/painters/canvas_painter.dart`
- [X] T028 [US2] 实作 `InProgressStrokeRenderer` 服务以流式更新于 `lib/application/usecases/renderer/in_progress_renderer.dart`
- [X] T029 [US2] 提供 `StrokeCacheStore` 缓存已完成 stroke 于 `lib/infrastructure/persistence/cache/stroke_cache_store.dart`

**Checkpoint**: 完成后可演示低延迟书写、工具切换与手势隔离。

---

## Phase 5: User Story 3 - Stroke 级撤销、持久化与导出 (Priority: P2)

**Goal**: 支持 stroke 级 undo/redo、自动保存/恢复、单页 PNG 导出及 Apple Pencil 参数补偿  
**Independent Test**: 在同一页面书写多条 stroke，执行 100 次撤销/重做、强退恢复，并导出 PNG 成功

### Implementation

- [X] T030 [US3] 实作 `StrokeHistory` 聚合记录 stroke 顺序/快照于 `lib/domain/strokes/stroke_history.dart`
- [X] T031 [US3] 定义 `ExportTask` 实体（状态/进度）于 `lib/domain/export/export_task.dart`
- [X] T032 [US3] 开发 `UndoRedoUseCase` 连接 CanvasSession 与 StrokeHistory 于 `lib/application/usecases/strokes/undo_redo_usecase.dart`
- [X] T033 [US3] 实作 `PersistNoteUseCase`（save/load + RendererState）于 `lib/application/usecases/notes/persist_note_usecase.dart`
- [X] T034 [US3] 实作 `ExportPageUseCase` 调用 ExportTask + 适配器于 `lib/application/usecases/export/export_page_usecase.dart`
- [X] T035 [US3] 扩展 `Toolbar` Widget 提供 undo/redo/export 控件于 `lib/presentation/widgets/toolbar.dart`
- [X] T036 [US3] 更新 `CanvasViewModel` 支持加载保存数据与导出状态于 `lib/presentation/viewmodels/canvas_viewmodel.dart`
- [X] T037 [US3] 编写缓存重建逻辑，加载持久化 stroke 时复用缓存于 `lib/application/usecases/renderer/cache_rebuilder.dart`
- [X] T038 [US3] 实作 `StrokeRepositoryImpl`（JSON+加密）于 `lib/infrastructure/repositories/stroke_repository_impl.dart`
- [X] T039 [US3] 完成 `AutoSaveService` 调用 scheduler + repositories 于 `lib/infrastructure/persistence/json/auto_save_service.dart`
- [X] T040 [US3] 构建 `PngExportAdapter`（PictureRecorder → PNG）于 `lib/infrastructure/adapters/png_export_adapter.dart`
- [X] T041 [US3] （可选）实现 `IosPencilBridgeAdapter` 捕获 pressure/tilt 于 `lib/infrastructure/adapters/ios_pencil_bridge_adapter.dart`

**Checkpoint**: 完成后可展示撤销/恢复、保存/加载与 PNG 导出，iOS Bridge 为增强功能。

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 文档、可观测性与性能完善

- [X] T042 更新 `specs/001-inkflow-mvp/quickstart.md` 记录端到端验证步骤
- [X] T043 添加 Telemetry/Logging 方案于 `lib/infrastructure/telemetry/usage_logger.dart`
- [X] T044 整理手势/工具使用指南到 `docs/inkflow_user_guide.md`

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 → 所有用户故事 → Phase 6
- User Story 顺序：US1（P1）→ US2（P1）→ US3（P2）；US2 依赖 US1 的 Note/Page 结构，US3 依赖前两者的 stroke/canvas 实现
- Renderer/cache（T027～T029，T037）依赖前置 Domain/Application 任务完成
- Export 与 iOS bridge（T040～T041）依赖 Stroke 持久化与 Canvas 渲染完成

### Parallel Opportunities

- [P] 标记任务（当前阶段暂无）可在不同文件并行；目录创建与依赖安装（T001～T003）也可并行执行
- US1 完成后，US2/US3 的部分 Application 与 Presentation 可由不同成员并行

### Independent Test Criteria

- US1：通过 NoteListPage 操作新增/排序/删除页面并重启验证  
- US2：在 CanvasPage 进行 30 秒连续书写与工具切换，观察延迟和手势隔离  
- US3：执行多次 undo/redo、强退恢复、PNG 导出并比对输出

## Implementation Strategy

- MVP 里程碑：Phase 3（US1）完成即可演示基础笔记管理  
- 增量扩展：Phase 4 引入实时书写体验；Phase 5 完成数据安全、导出与可选 iOS bridge  
- 始终保持 Domain → Application → Presentation → Renderer/Caching → Persistence → Export → Bridge 的任务顺序，确保层次内聚

### Parallel Example: User Story 1

```bash
# 域模型并行
Task: "T008 [US1] page.dart"
Task: "T009 [US1] note.dart"

# 应用用例并行
Task: "T011 [US1] manage_note_usecase.dart"
Task: "T012 [US1] manage_page_usecase.dart"
```

### Parallel Example: User Story 2

```bash
# 输入与工具模型
Task: "T017 [US2] stroke_point.dart"
Task: "T018 [US2] drawing_tool.dart"

# 交互层
Task: "T024 [US2] canvas_viewmodel.dart"
Task: "T025 [US2] gesture_controller.dart"
Task: "T027 [US2] canvas_painter.dart"
```

### Parallel Example: User Story 3

```bash
# Undo/Redo 与导出逻辑
Task: "T032 [US3] undo_redo_usecase.dart"
Task: "T034 [US3] export_page_usecase.dart"

# 持久化
Task: "T038 [US3] stroke_repository_impl.dart"
Task: "T039 [US3] auto_save_service.dart"
```

## Notes

- 任务均提供明确文件路径，便于直接着手  
- 若需自动化测试，可在对应 `test/` 子目录新增任务再执行  
- 完成每个 Phase 后建议运行 quickstart 流程验证
