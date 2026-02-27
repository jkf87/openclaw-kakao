# kmsg Skill for Claude Code

macOS 카카오톡(KakaoTalk) 메시지 자동화를 위한 Claude Code 스킬.

[kmsg CLI](https://github.com/channprj/kmsg)를 활용하여 카카오톡 메시지 읽기, 보내기, 채팅 목록 조회를 지원합니다.

## 설치

### 1. kmsg CLI 설치

```bash
mkdir -p ~/.local/bin && \
curl -fL https://github.com/channprj/kmsg/releases/latest/download/kmsg-macos-universal \
-o ~/.local/bin/kmsg && chmod +x ~/.local/bin/kmsg
```

### 2. 스킬 설치

다운로드한 `kmsg.skill` 파일을 Claude Code에 추가:

```bash
claude install-skill kmsg.skill
```

또는 수동으로 `kmsg/` 폴더를 스킬 디렉토리에 복사.

## 스킬 구조

```
kmsg/
├── SKILL.md                  # 핵심 가이드 (CLI 사용법, 안전 규칙)
├── scripts/
│   └── install.sh            # 원클릭 설치 스크립트
└── references/
    ├── mcp-setup.md          # MCP 서버 통합 가이드
    └── sequential-send.md    # 순차 전송 가이드 (호칭 템플릿, AppleScript fallback)
```

## 주요 기능

| 기능 | 명령어 |
|------|--------|
| 상태 확인 | `kmsg status` |
| 채팅 목록 | `kmsg chats` |
| 메시지 읽기 | `kmsg read "채팅방" --limit 20 --json` |
| 메시지 보내기 | `kmsg send "채팅방" "메시지"` |
| 전송 테스트 | `kmsg send "채팅방" "메시지" --dry-run` |

## 요구 사항

- macOS 13+
- [KakaoTalk macOS](https://apps.apple.com/kr/app/kakaotalk/id869223134) 앱 설치
- Accessibility 권한 (System Settings > Privacy & Security > Accessibility)

## 레퍼런스

- [kmsg - KakaoTalk CLI Tool](https://github.com/channprj/kmsg) — 원본 kmsg 프로젝트
- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code/skills) — Claude Code 스킬 문서
- [MCP (Model Context Protocol)](https://modelcontextprotocol.io/) — MCP 프로토콜 사양

## 라이선스

MIT
