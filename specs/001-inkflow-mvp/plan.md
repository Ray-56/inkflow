# Implementation Plan: InkFlow MVP

**Branch**: `[001-inkflow-mvp]` | **Date**: 2026-03-10 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/001-inkflow-mvp/spec.md`

## Summary

InkFlow MVP 需在 iPad 端实现 Notability 水准的手写体验，并保持跨平台可扩展性。整体方案采用 DDD 分层：Domain 负责 Note/Page/Stroke 等核心模型，Application 编排 use cases（创建笔记、渲染笔迹、导出 PNG 等），Infrastructure 提供 JSON 持久化、PNG 导出与可选的 iOS Pencil bridge，Presentation 以 Flutter 为主实现 Canvas 交互与状态管理。输入统一化、stroke 缓存、undo/redo 及安全存储为关键技术重点。

## Technical Context

**Language/Version**: Dart 3.x + Flutter 3.x  
**Primary Dependencies**: Flutter rendering 引擎、Riverpod/ValueNotifier（状态管理，可替换）、Isolate（异步导出）  
**Storage**: 本地 JSON 文件 + stroke 缓存（二进制/纹理）  
**Testing**: Flutter test、golden 测试（后续扩展）  
**Target Platform**: iPadOS 17+（首发），兼容 Android/Windows（Flutter 桌面）  
**Project Type**: Flutter 多平台应用（手写笔记）  
**Performance Goals**: 60fps in-progress 渲染、in-progress latency <20ms、PNG 导出 <5s  
**Constraints**: 输入事件必须统一、stroke 级 undo/redo、持久化需透明加密、防止整幅重绘  
**Scale/Scope**: 单用户离线笔记，单笔记可含上百页、每页上千 stroke

## Constitution Check

- ✅ 交流语言：文档使用中文，代码命名限定英文  
- ✅ DDD 架构分层：Domain/Application/Infrastructure/Presentation 明确  
- ✅ 输入统一、stroke 缓存、Undo 粒度、持久化策略与平台策略均符合宪章

## Project Structure

### Documentation (this feature)

```text
specs/001-inkflow-mvp/
├── plan.md              # 当前文件
├── research.md          # 待调研
├── data-model.md        # 待建模
├── quickstart.md        # 待编写
├── contracts/           # 接口契约（后续补充）
├── spec.md              # 规格
└── tasks.md             # 本次输出
```

### Source Code (repository root)

```text
lib/
├── domain/
│   ├── notes/
│   ├── pages/
│   ├── strokes/
│   ├── tools/
│   ├── viewport/
│   └── services/
├── application/
│   ├── usecases/
│   ├── commands/
│   ├── dto/
│   └── coordinators/
├── infrastructure/
│   ├── persistence/
│   ├── repositories/
│   ├── adapters/
│   └── serialization/
└── presentation/
    ├── pages/
    ├── widgets/
    ├── viewmodels/
    ├── controllers/
    └── painters/

test/
├── domain/
├── application/
├── presentation/
└── integration/
```

**Structure Decision**: 采用单 Flutter 工程，通过 `lib/` 下 DDD 子目录隔离分层，`test/` 目录按分层与场景分类。后续平台桥接（如 iOS Pencil bridge）放在 `infrastructure/adapters/`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Repository + Use Case 结构 | 支撑跨平台和可测试性 | 直接在 Widget 中访问存储无法保持领域独立性 |
| 输入統一模型 | 保障 stylus/finger/鼠标一致性 | 直接使用 Flutter 手势事件会让 Domain 依赖 UI |
