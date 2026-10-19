#!/usr/bin/env sh

# Local provider
hermes config set providers.llama-local '{"base_url": "http://127.0.0.1:8080/v1", "default_model": "/etc/llama/models/qwen3.8-27b-q3.gguf", "extra_body": {"temperature": 0.5, "presence_penalty": 0.0, "top_p": 0.80, "min_p": 0.0, "max_tokens": 16384}}'

# Model
hermes config unset model.base_url
hermes config set model.provider llama-local
hermes config set model.default /etc/llama/models/qwen3.8-27b-q3.gguf

# Security, privacy and approvals
hermes config set security.redact_secrets true
hermes config set telemetry.shared_metrics.enabled false
hermes config set telemetry.shared_metrics.send false
hermes config set approvals.mode manual
hermes config set approvals.timeout 300
hermes config set approvals.cron_mode deny
hermes config set approvals.deny '["cat*.env*", "less*.env*", "more*.env*", "head*.env*", "tail*.env*", "grep*.env*", "sed*.env*", "awk*.env*", "cut*.env*", "base64*.env*", "strings*.env*", "od*.env*", "xxd*.env*", "diff*.env*", "cat*auth.json*", "less*auth.json*", "more*auth.json*", "head*auth.json*", "tail*auth.json*", "grep*auth.json*", "sed*auth.json*", "awk*auth.json*", "cut*auth.json*", "base64*auth.json*", "strings*auth.json*", "od*auth.json*", "xxd*auth.json*", "diff*auth.json*", "cat*.ssh*", "less*.ssh*", "more*.ssh*", "head*.ssh*", "tail*.ssh*", "grep*.ssh*", "sed*.ssh*", "awk*.ssh*", "cut*.ssh*", "base64*.ssh*", "strings*.ssh*", "od*.ssh*", "xxd*.ssh*", "diff*.ssh*"]'

# Agent
hermes config set agent.max_turns 30
hermes config set agent.budget_warning_ratio 0.75
hermes config set agent.run_budget_seconds 600
hermes config set agent.reasoning_effort none; sed -i 's/^\(\s*reasoning_effort:\).*$/\1 "none"/' $HOME/.hermes/config.yaml
hermes config set compression.enabled true
hermes config set compression.threshold 0.5
hermes config set compression.target_ratio 0.1
hermes config set memory.nudge_interval 0
hermes config set memory.write_approval true
hermes config set terminal.cwd $HOME/workspace; mkdir -p $HOME/workspace
hermes config set gateway.message_timestamps.enabled true

# Skills
hermes config set curator.prune_builtins false
hermes config set skills.creation_nudge_interval 0
hermes config set skills.write_approval true
hermes config set skills.disabled '["airtable", "architecture-diagram", "arxiv", "ascii-video", "baoyu-infographic", "blocked-page-recovery", "box", "claude-code", "claude-design", "codex", "competitor-news-monitor", "computer-use", "design-md", "document-to-action-items", "docx", "dogfood", "email-inbox-triage", "gif-search", "google-workspace", "grounded-citations", "inspecting-hermes-desktop-dom", "llm-wiki", "manim-video", "maps", "meeting-action-items", "notion", "obsidian", "opencode", "p5js", "pdf", "popular-web-designs", "powerpoint", "product-price-monitor", "requesting-code-review", "simplify-code", "songsee", "songwriting-and-ai-music", "spike", "teams-meeting-pipeline", "weekly-review-planning", "xlsx", "xurl", "youtube-content"]'

# Toolsets and plugins
hermes tools enable --platform cli clarify
hermes tools enable --platform cli code_execution
hermes tools enable --platform cli file
hermes tools enable --platform cli skills
hermes tools enable --platform cli terminal
hermes config set agent.disabled_toolsets '["web", "browser", "vision", "video", "image_gen", "video_gen", "x_search", "tts", "stt", "todo", "kanban", "memory", "context_engine", "session_search", "connections", "delegation", "cronjob", "yuanbao", "computer_use", "a2a"]'
hermes plugins install --enable t1t4nium/hermes-agent-env-secret-redactor

# Sessions
hermes config set sessions.auto_archive false
hermes config set sessions.auto_archive_days 7
hermes config set sessions.auto_prune true
hermes config set sessions.retention_days 90
hermes config set sessions.vacuum_after_prune true

# Miscellaneous
hermes config set updates.pre_update_backup quick
hermes config set display.streaming true
hermes config set display.timestamps true
hermes config set stt.enabled false