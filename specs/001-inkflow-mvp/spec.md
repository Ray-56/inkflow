# Feature Specification: InkFlow MVP

**Feature Branch**: `[001-inkflow-mvp]`  
**Created**: 2026-03-10  
**Status**: Draft  
**Input**: User description: "请使用中文撰写 spec。 为 InkFlow 定义一个 MVP 规格。InkFlow 是一个以 iPad 为主、未来支持 Android 和 Windows 的手写笔记应用。目标体验达到 Notability 的核心书写水平。 MVP 必须支持以下用户能力： 1. 用户可以创建笔记，并在笔记下管理多个页面。 2. 用户可以在页面上进行流畅手写。 3. 当设备支持时，书写应支持 pressure-sensitive strokes。 4. 默认情况下，stylus 用于绘制，finger 用于平移与缩放。 5. 用户可以使用 pen、highlighter、eraser 三种工具。 6. 用户可以按 stroke 粒度执行 undo / redo。 7. 用户可以本地保存并重新加载笔记与页面内容。 8. 用户可以将页面导出为 PNG。 请明确以下内容： - 领域对象与术语 - 用户场景 - 功能边界 - 非功能需求，尤其是书写响应性 - 第一版不包含的内容：OCR、云同步、协作、形状识别、复杂笔刷引擎、图层系统 请始终使用中文描述需求，但不要在 spec 中写实现代码。"

## Clarifications

### Session 2026-03-10

- Q: 本地持久化数据是否需要加密？ → A: 所有本地持久化笔记与 stroke 数据以透明磁盘加密存储

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 创建并管理多页面笔记 (Priority: P1)

作为一名使用 iPad 的学生，我可以创建新的笔记本、为其命名，并在其中灵活增删、复制、排序页面，以准备不同课程的讲义记录。

**Why this priority**: 没有可靠的笔记与页面结构就无法承载任何书写内容，是后续所有操作的前提。

**Independent Test**: 通过仅使用页面管理流程（无书写功能）即可验证是否能创建含多页的笔记并在重启后保持结果。

**Acceptance Scenarios**:

1. **Given** 初次启动应用且无笔记，**When** 用户新建笔记并添加三页，**Then** 应显示三页缩略图并支持自由切换。
2. **Given** 已有多页笔记，**When** 用户删除或重新排序页面，**Then** 页面顺序立即更新且撤销记录保持一致。

---

### User Story 2 - 流畅手写与工具切换 (Priority: P1)

作为使用 Apple Pencil 的创作者，我进入页面后即可立即用 stylus 绘制低延迟的笔迹，指尖默认负责平移与缩放，并可随时切换 pen、highlighter、eraser。

**Why this priority**: 流畅书写是 MVP 的核心价值，直接决定是否达到 Notability 级体验。

**Independent Test**: 隔离单页书写模块即可测试笔迹渲染延迟、工具响应与 stylus/finger 行为。

**Acceptance Scenarios**:

1. **Given** stylus 接触画布，**When** 用户连续书写 30 秒，**Then** 笔迹需实时呈现且无明显断裂或延迟。
2. **Given** 正在绘制笔记，**When** 用户切换到 eraser 并擦除指定 stroke，**Then** 该 stroke 被移除且可通过 Undo 恢复。

---

### User Story 3 - Stroke 级撤销与持久化 (Priority: P2)

作为重度笔记用户，我希望可以按 stroke 粒度撤销/重做，并在退出后重新打开仍可看到完整内容，必要时还能导出单页 PNG 分享。

**Why this priority**: 撤销/重做与持久化是保障使用安全感与后续复盘分享的必要能力。

**Independent Test**: 通过记录 stroke 操作历史、存储并重新加载数据以及导出流程即可独立验证。

**Acceptance Scenarios**:

1. **Given** 页面存在多条 stroke，**When** 用户多次 Undo/Redo，**Then** 每次操作都准确按时间顺序恢复或移除整条 stroke。
2. **Given** 用户保存并强制关闭应用，**When** 下次启动加载同一笔记，**Then** 内容与操作历史仍可继续（至少最近 50 条 stroke 可撤销）。
3. **Given** 用户选择某页导出，**When** 导出完成，**Then** 生成的 PNG 分辨率与画布一致且包含所有可见笔迹。

---

### Edge Cases

- 当设备或操作系统不提供压力/倾斜数据时，笔迹需回退到默认宽度但保持笔划连续性。
- 当同时侦测到多指且含 stylus 输入时，系统需优先判定 stylus 为绘制、指尖为导航，避免误绘。
- 当存储空间不足或写入失败时，应提示用户并允许释放空间后重试，不得 silent fail。
- 当用户快速切换页面或工具时，缓存需保证渲染状态一致，不出现空白或错页。
- 当导出 PNG 的页面包含超大画布或大量 stroke 时，应提示进度并避免阻塞主线程，让用户可取消。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 系统必须允许用户创建、重命名、删除笔记，并在笔记中添加、复制、重排、删除页面，所有操作需记录在 undo/redo 栈中。
- **FR-002**: 用户进入页面后必须立即看到可书写画布，stylus 默认进入绘制模式，finger 默认进入平移与缩放模式，且两者互斥以避免误操作。
- **FR-003**: 系统必须将来自 stylus、触摸、鼠标的输入统一转换为 InputEvent（包含位置、时间戳、压力、倾斜、工具类型）后才进入 Domain/Application 层。
- **FR-004**: 书写必须生成 Stroke 实体，记录 strokeId、所属 Page、Tool 参数、起止时间、压力曲线，并在支持设备上利用 pressure-sensitive 数据调整笔迹宽度。
- **FR-005**: 用户可在 pen、highlighter、eraser 三种 Tool 之间即时切换，每种工具需提供至少两档粗细与颜色预设，切换操作必须可撤销至切换前的工具状态。
- **FR-006**: 系统必须在书写过程中实时渲染 in-progress stroke，并在 stroke 完成后将其加入缓存，后续平移或缩放时优先复用缓存以避免全量重绘。
- **FR-007**: Undo/Redo 必须以整条 Stroke 为粒度运作，覆盖书写、擦除、页面管理和工具配置变更，至少可追溯 100 条操作，且在跨会话加载后仍可继续。
- **FR-008**: 系统必须本地持久化 Note、Page、Stroke、工具配置与操作历史，支持自动保存及手动保存，重新加载时需恢复 RendererState（当前页面、缩放、选择的 Tool）。
- **FR-009**: 用户必须能够浏览现有笔记列表并打开指定笔记，系统需在 3 秒内完成加载并显示第一页缩略图与内容。
- **FR-010**: 用户可将任意页面导出为 PNG，需提供分辨率选择（默认画布尺寸）与导出完成提示，导出文件保存到本地共享目录，失败时给出可重试的错误信息。
- **FR-011**: 系统必须提供基础手势指引或首次使用提示，明确 stylus 与 finger 的默认行为，降低学习成本。
- **FR-012**: 当设备支持 Apple Pencil 独有参数（压力、倾斜、工具种类）时，系统必须通过最薄的原生桥接获取并注入 InputEvent；当参数不可用时需回退到默认值并提示用户。

### Key Entities / 领域对象与术语

- **Note**（Notes 限界上下文）: 用户的笔记本，包含元数据（标题、封面、最近修改时间）与 Page 列表。
- **Page**（Canvas 上下文）: Note 下的单个书写画布，包含背景样式、尺寸、stroke 集合与 RendererState。
- **Stroke**（Input 上下文）: 一次连续书写操作，包含 strokeId、Tool、开始/结束时间、StrokePoint 序列及缓存引用。
- **StrokePoint**: Stroke 中的单个采样点，记录 x/y、pressure、tilt、timestamp，用于重建笔迹。
- **Tool**: 描述 pen、highlighter、eraser 的值对象，包含类型、颜色、宽度、混合/擦除模式、透明度。
- **RendererState**: 当前视图层的状态值对象，包含 zoom、pan、当前 Tool、选中 Page、缓存 meta。
- **ExportJob**（Export 限界上下文）: 表示单次导出任务的聚合，持有目标 Page、输出规格、进度与结果。
- **InputEvent**: 规范化后的输入数据，包含来源（stylus/finger/mouse）、位置、压力、倾斜、按钮状态，用于保持领域层独立于 Flutter/平台实现。

### 非功能需求

- **书写响应性**: in-progress stroke 显示延迟不超过 20ms，整体渲染需维持 60fps，长 stroke（≥5 秒）不得出现分段或断裂。
- **缓存策略**: 已完成 stroke 必须支持增量缓存，平移或缩放只重绘视窗内增量数据；缓存更新不得阻塞主线程超过 16ms。
- **持久性**: 自动保存间隔不超过 10 秒或 20 条 stroke（取先到者），异常退出后数据完整率需达 99%。
- **跨平台策略**: iPad 优先，Android/Windows 需复用相同 Domain/Application 层，仅在必要时新增原生桥接获取硬件能力。
- **可用性**: 新用户完成“创建笔记-书写-导出”路径不应超过 3 分钟；所有关键操作需提供可视化反馈。
- **安全性**: 所有本地 Note/Page/Stroke/Undo 日志文件需由应用以透明磁盘加密（自动密钥管理）方式保存，即使设备被非授权访问也无法读取内容。

### 功能边界

- 包含：笔记/页面 CRUD、基础手写、压力感知、工具切换、stroke 级 undo/redo、本地持久化、单页 PNG 导出、基本手势引导。
- 不包含：OCR、云同步、协作、实时共享、形状识别、复杂笔刷引擎（例如纹理或粒子笔刷）、多图层系统、音频录制、模板市场。
- 外部依赖：文件系统写入权限、系统相册/文件共享接口（用于导出）。

### 假设

- 用户使用单账号（无需登录），所有数据保存在本地设备存储。
- 书写画布默认大小接近 A4 比例，可根据设备尺寸自适应缩放。
- Undo/Redo 历史保存在笔记级别（跨页面共享），方便用户跨页调整。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 90% 的 Beta 用户能在 3 分钟内完成“创建笔记-添加两页-书写-导出 PNG”流程且无指导。
- **SC-002**: 连续手写 5 分钟期间，95% 的 stroke 从触笔到屏幕呈现的可见延迟低于 20ms，帧率保持在 60fps±5fps。
- **SC-003**: 在支持压力感应的设备上，80% 的用户认为笔迹粗细反馈与实际压力“准确或非常准确”（可通过可用性调研问卷衡量）。
- **SC-004**: Undo/Redo 操作响应时间不超过 200ms，且在 100 条操作内准确率达 100%（未出现跳步或遗漏）。
- **SC-005**: 本地保存及重新加载笔记失败率低于 1%，即 100 次随机强退恢复测试中至少 99 次能完整恢复最近会话。
- **SC-006**: 单页 PNG 导出在标准分辨率下完成时间不超过 5 秒，并成功导出的文件在第三方查看器中无缺笔迹或模糊现象。
