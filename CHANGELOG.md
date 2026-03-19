# Changelog

## [0.1.0] - 2026-03-18

Batterie-wide consistency pass: docs consolidation, versioning.

### Added
- OAuth client credentials for Agent Builder

## 2026-03-07–09 — Agent Builder & Cloud Function

### Added
- BQ query Cloud Function with markdown table output
- Agent Builder Slide-Bot: playbooks, examples, tools, setup runbook
- BQ Conversational Analytics research docs

### Changed
- Pivoted from direct Claude skill to Agent Builder approach
- Rewritten examples for WUAK v1 table structure

## 2026-02-27 — Plugin System

### Added
- Plugin manifest for Claude Code plugin system
- Skill directory renamed from `consomme` to `analysis` for `/consomme:analysis` command

## 2026-02-16 — Multi-Source Analysis

### Added
- `/consomme-sheets` for BQ-free analysis of Google Sheets
- `/consomme-ingest` for Sheets-to-BQ onboarding
- `/consomme` meta-command as orientation entry point
- Google Sheets external table pattern in SQL reference
- Gemini CLI extension scaffold for cross-harness distribution

### Changed
- Renamed skill from `bq-analyst` to `consomme` for kitchen naming consistency

## 2026-02-14 — Initial Release

### Added
- BQ analyst skill with extension tools and Anthropic data methodology
