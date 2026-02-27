# 카카오톡 순차 전송 가이드

여러 수신자에게 메시지를 하나씩 안전하게 전송하는 워크플로우.

## 기본 루프

```bash
for recipient in "홍길동" "김철수" "이영희"; do
  kmsg send "$recipient" "메시지 내용" --dry-run  # 먼저 테스트
done
```

확인 후 실제 전송:
```bash
for recipient in "홍길동" "김철수" "이영희"; do
  kmsg send "$recipient" "메시지 내용"
  sleep 1  # 안전 간격
done
```

## 호칭 포함 메시지 템플릿

수신자에 호칭이 포함된 경우, 메시지 앞에 호칭 붙이기:

| 호칭 | 메시지 예시 |
|------|-----------|
| 형님 | `형님, 새해 복 많이 받으세요` |
| 선생님 | `선생님, 새해 복 많이 받으세요` |
| 대표님 | `대표님, 새해 복 많이 받으세요` |
| 교수님 | `교수님, 새해 복 많이 받으세요` |
| 호칭 없음 | `새해 복 많이 받으세요` |

## 안전 규칙

1. **전체 dry-run 먼저** - 전체 수신자 목록을 `--dry-run`으로 1회 돌린 후 실제 전송
2. **전송 간 간격** - `sleep 1` 이상 권장 (과도한 연속 전송 방지)
3. **사용자 확인 필수** - 수신자 목록 + 메시지 내용을 사용자에게 보여주고 승인 후 전송
4. **오발송 방지** - 호칭 포함 시 메시지를 구성한 뒤 전송 전 한 번 더 확인
5. **이름 완전일치 검증** - 대상 채팅방을 연 직후 창 제목(또는 상단 채팅방명)이 요청 대상과 정확히 일치하는지 확인
6. **방 내부 재검색 금지** - 잘못 열린 경우 방 안에서 검색하지 말고 목록으로 복귀해서 다시 찾기
7. **순번/첫 결과 클릭 금지** - 검색 결과 번호가 아니라 행의 채팅방 이름 텍스트를 보고 완전일치 항목만 선택

## 실패 처리

```bash
# 실패한 수신자 재시도 (--deep-recovery 옵션)
kmsg send "실패한수신자" "메시지" --deep-recovery
```

실패 사유:
- `CHAT_NOT_FOUND` → 검색어 축소 (호칭 없이 핵심 이름만)
- `KAKAO_WINDOW_UNAVAILABLE` → 카카오톡 재실행 후 재시도
- 반복 실패 → 사용자에게 해당 채팅을 수동으로 열어달라고 요청
- `WINDOW_NOT_READY` 반복 시 → 열린 채팅창을 닫고 목록창(`카카오톡`)만 남긴 뒤 재시도

## 보고 형식

실행 후 간결하게 보고:

```
OK: 홍길동, 김철수, 이영희
FAIL: 박지성 (채팅방 검색 실패)
총 4건 / 성공 3건 / 실패 1건
```

## Fallback: AppleScript 방식 (kmsg 없이)

kmsg CLI를 사용할 수 없는 환경에서의 대안. Accessibility API를 osascript로 직접 사용.

### 핵심 원칙

| 느린 방식 | 빠른 방식 (AX 직접) |
|----------|-------------------|
| `cmd+f` → 문자별 타이핑 | `set value of searchField` (즉시 설정) |
| 클릭 + 더블클릭 | `perform action "AXPress"` (직접 액션) |
| `peekaboo window list` | `title of every window` (인프로세스 조회) |
| 좌표 계산 → 클릭 | `set focused of textArea to true` |
| 문자별 메시지 타이핑 | 클립보드 `cmd+v` (즉시 입력) |

### 전송 스크립트

```applescript
-- 1) 카카오톡 활성화
tell application "KakaoTalk" to activate
delay 0.3
tell application "System Events"
    tell process "KakaoTalk"
        set frontmost to true
    end tell
end tell

-- 2) 검색 열기 + 대상 입력
tell application "System Events"
    tell process "KakaoTalk"
        tell window "카카오톡"
            keystroke "f" using command down
            delay 0.3
            set searchField to text field 1
            set focused of searchField to true
            set value of searchField to "대상이름"
            delay 0.5
        end tell
    end tell
end tell

-- 3) 검색 결과에서 AXPress로 열기
tell application "System Events"
    tell process "KakaoTalk"
        tell window "카카오톡"
            set resultRows to every row of table 1 of scroll area 1
            repeat with r in resultRows
                try
                    set rowText to value of static text 1 of r
                    if rowText contains "대상이름" then
                        perform action "AXPress" of r
                        exit repeat
                    end if
                end try
            end repeat
        end tell
    end tell
end tell

-- 4) 창 열림 검증
tell application "System Events"
    tell process "KakaoTalk"
        set chatWindowFound to false
        repeat 15 times
            delay 0.2
            set windowNames to title of every window
            repeat with wName in windowNames
                if wName contains "대상이름" then
                    set chatWindowFound to true
                    exit repeat
                end if
            end repeat
            if chatWindowFound then exit repeat
        end repeat
    end tell
end tell

-- 5) 메시지 입력 (클립보드 방식)
set the clipboard to "메시지 내용"
tell application "System Events"
    keystroke "v" using command down
    delay 0.1
    keystroke return
end tell

-- 6) 닫기
tell application "System Events"
    keystroke "w" using command down
    delay 0.2
    tell process "KakaoTalk"
        tell window "카카오톡"
            perform action "AXRaise" of it
        end tell
    end tell
end tell
```

### KakaoTalk AX UI 구조

```
AXApplication "KakaoTalk"
  AXWindow "카카오톡"                    -- 메인 창
    AXToolbar                            -- 탭 바 (친구/채팅/...)
    AXTextField                          -- 검색 필드 (cmd+f 후)
    AXScrollArea > AXTable > AXRow       -- 친구/채팅 목록
  AXWindow "홍길동"                      -- 채팅 창 (제목=대상 이름)
    AXScrollArea > AXTable > AXRow       -- 메시지 목록
    AXScrollArea > AXTextArea            -- 메시지 입력 필드 (하단)
```

- Bundle ID: `com.kakao.KakaoTalkMac`
- 메시지 입력 필드: 창 하단 45% 영역의 `AXTextArea`
- Accessibility 권한 필수: System Settings > Privacy & Security > Accessibility
