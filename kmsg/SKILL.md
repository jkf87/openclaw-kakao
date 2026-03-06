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

### 0. 화면/창 컨텍스트 검증 (필수)

`kmsg` 실행 전 아래를 먼저 확인:

1. **카카오톡 메인 목록창("카카오톡")이 전면인지 확인**
2. **이미 열린 채팅창이 있으면 닫기** (목록창만 남기기)
3. 목록에서 대상을 찾을 때는 **첫 번째 결과 자동 선택 금지**
4. **순번(1/2/3번) 기준 선택 금지** — 화면에 보이는 채팅방 이름 텍스트를 읽고 요청 대상과 완전일치 행만 선택
5. 대상 진입 후에는 **현재 창 제목이 요청한 채팅방 이름과 일치하는지 재확인**
6. 불일치 시 즉시 중단 후 목록으로 복귀

권장 점검 명령:

```bash
kmsg chats --limit 30 --verbose   # 목록/미리보기 확인
kmsg inspect --depth 2            # 현재 포커스 창/목록 구조 확인
```

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

### 4. 다중 방 대량 요약(미읽음 기준) 안정화 워크플로우

대량 테스트(예: "100+ 미읽음 방 전부 요약")에서는 아래 순서를 고정한다.

1) **카카오톡 메인 목록창으로 복귀 + 열린 채팅창 닫기**
2) `kmsg inspect --depth 6`로 채팅 목록 AX 트리 스냅샷 저장
3) AX 트리에서 **채팅방 이름 + unread 카운트(숫자/300+)** 추출
4) 임계치 이상 방만 선별 (예: `>=100`, `>=300`)
5) 선별된 방만 `kmsg read "방이름" --limit 120~300 --json`로 읽기
6) 요약 생성 후, **탐지된 방 수 / 실제 처리 방 수**를 함께 보고

권장 원칙:
- unread 뱃지는 화면 상태에 따라 변동될 수 있으므로, **매 실행마다 inspect 재수집**
- `Count Label` 값은 참여자 수일 수 있으므로, unread는 행 하단 숫자 배지(예: `105`, `300+`)를 우선 사용
- 동명이인/유사방 방지를 위해 항상 **AX 행의 방 이름 텍스트 완전일치**로만 처리

예시(임계치 선별):
```bash
# 1) 스냅샷
kmsg inspect --depth 6 > /tmp/kmsg_inspect.txt

# 2) 파싱 스크립트로 100+ 방 추출 (환경별로 스크립트 재사용 가능)
python3 - <<'PY'
# /tmp/kmsg_inspect.txt를 읽어 "방 이름 + unread"를 추출하는 로컬 파서 작성/실행
# (환경마다 AX 트리 구조가 달라질 수 있으므로 정규식은 현장 보정)
PY
```

요약 포맷(권장):
- 대상 방 / 미읽음 수
- 핵심 흐름(3줄)
- 주요 주제 TOP 3
- 분위기/톤
- 한 줄 결론

## Safety Rules

1. **전송 전 반드시 사용자 확인** - 절대 무단 전송 금지
2. **--dry-run 우선** - 의심스러우면 먼저 드라이런
3. **비공식 도구** - 과도한 사용 시 계정 제한 가능
4. **Accessibility 권한** - System Settings > Privacy & Security > Accessibility에서 kmsg 허용 필요
5. **창 이름 검증 필수** - 대상 진입 후 현재 창 제목이 요청한 채팅방 이름과 일치하지 않으면 즉시 중단
6. **방 내부 재검색 금지** - 채팅방 내부 화면에서 추가 검색/재탐색하지 말고 목록창으로 돌아간 뒤 재시도
7. **결과 행 텍스트 검증 우선** - 검색 결과에서 행 텍스트를 직접 확인한 뒤 요청 이름과 완전일치할 때만 열기(순번 클릭 금지)

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
| `WINDOW_NOT_READY` | 다른 창이 전면/채팅창 미오픈 | 목록창(`카카오톡`) 전면화, 열린 채팅창 정리 후 재시도 |
| `SEARCH_MISS` | 유사 이름/오픈채팅 검색 누락 | 검색어 축소 후 **이름 완전일치** 확인, 필요 시 사용자가 방을 먼저 열기 |
