---
name: kmsg
description: >
  macOS 카카오톡(KakaoTalk) 메시지 자동화 CLI 도구.
  메시지 읽기, 보내기, 채팅 목록 조회를 지원하며 MCP 서버를 통한 에이전트 통합 가능.
  Use when: (1) 카카오톡 메시지를 읽거나 보내야 할 때,
  (2) "카톡 보내줘", "카카오톡 메시지 읽어줘", "채팅 목록 보여줘" 요청 시,
  (3) KakaoTalk 자동화 또는 kmsg CLI 관련 작업,
  (4) MCP를 통한 카카오톡 에이전트 통합 설정 시.
  macOS 13+, KakaoTalk macOS 앱, Accessibility 권한 필요.
---

# kmsg - KakaoTalk CLI

macOS Accessibility API를 활용하여 카카오톡 메시지를 읽고 보내는 비공식 CLI 도구.

## Prerequisites Check

작업 전 반드시 확인:

```bash
# 1. 설치 확인
kmsg status

# 2. 미설치 시 → scripts/install.sh 실행
bash <skill-path>/scripts/install.sh
```

## Quick Reference

```bash
kmsg status                              # 상태 확인
kmsg chats                               # 채팅 목록
kmsg read "채팅방" --limit 20 --json      # 메시지 읽기 (JSON)
kmsg send "채팅방" "메시지"                # 메시지 전송
kmsg send "채팅방" "메시지" --dry-run      # 전송 테스트 (실제 발송 안 함)
```

## Workflow

### 1. 메시지 읽기

```bash
# 기본 읽기
kmsg read "홍길동" --limit 20

# JSON 출력 (파싱용 - 반드시 --json 플래그 사용)
kmsg read "홍길동" --limit 20 --json

# 창 탐색 실패 시 복구 모드
kmsg read "홍길동" --limit 20 --json --deep-recovery
```

JSON 출력 구조:
```json
{
  "chat": "홍길동",
  "fetched_at": "2026-02-26T01:23:45.678Z",
  "count": 20,
  "messages": [
    {"author": "홍길동", "time_raw": "00:27", "body": "메시지 내용"}
  ]
}
```

### 2. 메시지 보내기

**CRITICAL: 사용자에게 반드시 전송 확인을 받은 후 실행.**

```bash
# 실제 전송
kmsg send "홍길동" "안녕하세요"

# 테스트 (전송 안 함)
kmsg send "홍길동" "테스트" --dry-run

# 윈도우 유지하며 전송
kmsg send "홍길동" "메시지" --keep-window
```

### 3. 디버깅

문제 발생 시:
```bash
kmsg inspect --window 0 --depth 20       # UI 구조 검사
kmsg read "채팅방" --limit 5 --trace-ax   # AX 트레이싱
kmsg send "채팅방" "test" --trace-ax --dry-run
```

## Safety Rules

1. **전송 전 반드시 사용자 확인** - 절대 무단 전송 금지
2. **--dry-run 우선** - 의심스러우면 먼저 드라이런
3. **비공식 도구** - 과도한 사용 시 계정 제한 가능
4. **Accessibility 권한** - System Settings > Privacy & Security > Accessibility에서 kmsg 허용 필요

## Sequential Send (다수 수신자 전송)

여러 명에게 순차 전송이 필요할 때: [references/sequential-send.md](references/sequential-send.md)
- 호칭 포함 메시지 템플릿, 안전 규칙, 실패 처리
- kmsg 없이 AppleScript로 직접 전송하는 Fallback 방식 포함

## MCP Integration

에이전트에서 직접 사용하려면 MCP 서버 설정 참조: [references/mcp-setup.md](references/mcp-setup.md)

## Common Errors

| 에러 | 원인 | 해결 |
|------|------|------|
| `KMSG_BIN_NOT_FOUND` | kmsg 미설치 | `scripts/install.sh` 실행 |
| `ACCESSIBILITY_PERMISSION_DENIED` | 권한 미부여 | System Settings에서 권한 허용 |
| `KAKAO_WINDOW_UNAVAILABLE` | 카톡 미실행/창 없음 | 카카오톡 실행 후 재시도, `--deep-recovery` |
| `CHAT_NOT_FOUND` | 채팅방 검색 실패 | 채팅방 이름 확인, `--deep-recovery` |
