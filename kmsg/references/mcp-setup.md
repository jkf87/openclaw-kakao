# kmsg MCP Integration

## Claude Code / OpenClaw 설정

`~/.claude.json` 또는 프로젝트 `.mcp.json`에 추가:

```json
{
  "mcpServers": {
    "kmsg": {
      "command": "python3",
      "args": ["<kmsg-repo-path>/tools/kmsg-mcp.py"],
      "env": {
        "KMSG_BIN": "$HOME/.local/bin/kmsg",
        "KMSG_DEFAULT_DEEP_RECOVERY": "false",
        "KMSG_TRACE_DEFAULT": "false"
      }
    }
  }
}
```

`<kmsg-repo-path>`를 실제 kmsg 레포 클론 경로로 교체.

## MCP Tools

### kmsg_read

메시지 읽기 (read-only).

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| chat | string | Yes | - | 채팅방/사용자 이름 |
| limit | integer | No | 20 | 메시지 수 (1-100) |
| deep_recovery | boolean | No | false | 창 탐색 복구 모드 |
| keep_window | boolean | No | false | 열린 창 유지 |
| trace_ax | boolean | No | false | AX 트레이싱 로그 |

```json
{"name": "kmsg_read", "arguments": {"chat": "홍길동", "limit": 20}}
```

### kmsg_send

메시지 전송. **`confirm=true` 필수** (없으면 거부됨).

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| chat | string | Yes | - | 채팅방/사용자 이름 |
| message | string | Yes | - | 메시지 본문 |
| confirm | boolean | No | false | true여야 실제 전송 |
| deep_recovery | boolean | No | false | 창 탐색 복구 모드 |
| keep_window | boolean | No | false | 열린 창 유지 |
| trace_ax | boolean | No | false | AX 트레이싱 로그 |

```json
{"name": "kmsg_send", "arguments": {"chat": "홍길동", "message": "안녕하세요", "confirm": true}}
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KMSG_BIN` | `~/.local/bin/kmsg` | kmsg 바이너리 경로 |
| `KMSG_DEFAULT_DEEP_RECOVERY` | `false` | 기본 deep recovery 모드 |
| `KMSG_TRACE_DEFAULT` | `false` | 기본 AX 트레이싱 |
| `KMSG_AX_TIMEOUT` | (내장값) | Accessibility 타임아웃 조정 |

## Response Format

### 성공
```json
{
  "ok": true,
  "chat": "홍길동",
  "fetched_at": "2026-02-26T01:23:45.678Z",
  "count": 20,
  "messages": [{"author": "홍길동", "time_raw": "00:27", "body": "메시지"}],
  "meta": {"latency_ms": 1234}
}
```

### 실패
```json
{
  "ok": false,
  "error": {
    "code": "CHAT_NOT_FOUND",
    "message": "kmsg read failed",
    "hint": "Chat was not found in search results.",
    "raw_stdout": "...",
    "raw_stderr": "..."
  },
  "meta": {"latency_ms": 567}
}
```

## Error Codes

| Code | Meaning | Recovery |
|------|---------|----------|
| `KMSG_BIN_NOT_FOUND` | 바이너리 없음 | KMSG_BIN 설정 또는 kmsg 설치 |
| `KAKAO_WINDOW_UNAVAILABLE` | 카톡 창 없음 | 카카오톡 실행 후 재시도 |
| `CHAT_NOT_FOUND` | 채팅방 못 찾음 | 이름 확인, deep_recovery 활성화 |
| `ACCESSIBILITY_PERMISSION_DENIED` | 권한 없음 | System Settings에서 허용 |
| `CONFIRMATION_REQUIRED` | confirm 미설정 | confirm=true로 재호출 |
| `PROCESS_TIMEOUT` | 타임아웃 | 카톡 상태 확인 후 재시도 |
