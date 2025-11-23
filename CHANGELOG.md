# Changelog

All notable changes to piq will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- `PracticeEngine` - state machine for managing practice sessions
  - States: `.idle`, `.inBlock`, `.betweenBlocks`, `.finished`
  - Timer control with tick, pause, resume
  - Block transitions (finish, skip, extend)
  - Feedback recording
  - Progress tracking (session and block)
- `PracticeEngineTests` - 39 tests for TDD implementation
- Initial Xcode project structure with iOS 17 target
- App entry point (`PiqApp.swift`) with SwiftUI lifecycle
- `RootView` with TabView (Today, History, Settings tabs)
- Placeholder views for all three tabs
- Asset catalog with AppIcon and AccentColor
- Domain models in `Modules/PracticeDomain/`:
  - `PracticeBlockKind` - enum for block types (warmup, song, solo, techniqueOrTheory)
  - `PracticeBlock` - model for a single practice block
  - `PracticeSession` - model for a complete session
  - `PracticeBlockFeedback` - enum for feedback (easy, good, hard)
- `PracticeSessionTests` - initial test file for domain models
- Project documentation (`design.md`, `claude.md`, `agents.md`, `tests.md`)

## [0.0.1] - 2024-11-23

### Added
- Phase 0 complete: Domain skeleton and barebones app running on simulator
