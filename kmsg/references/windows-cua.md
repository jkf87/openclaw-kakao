# Windows CUA KakaoTalk Send Guide

Use this reference when the user asks to send KakaoTalk messages on Windows by direct computer use, especially when the user forbids `kmsg`.

## Scope

- Use the Windows KakaoTalk desktop app.
- Do not run `kmsg`, `kmsg send`, or other KakaoTalk CLI commands.
- Use screen observation plus real keyboard/mouse input. Prefer UI Automation or screenshots to identify the active target before clicking.

## Critical Rules

1. Do not use `Ctrl+A` in a KakaoTalk search field.
2. Do not click the top-right `+` or friend-add icon while trying to search.
3. If a `친구 추가` modal appears, stop. Close it, verify it is gone, and restart from the visible OpenChat or chat list state.
4. Never type into a field unless the target field is visually verified.
5. Verify the result row name before opening it.
6. Verify the opened chat title before entering the message.
7. Verify a new outgoing message bubble after sending.

## Stable OpenChat Workflow

1. Capture or inspect the current screen.
2. Confirm no modal is present. Abort search if any of these strings are visible:
   - `친구 추가`
   - `연락처로 추가`
   - `ID로 추가`
3. Confirm the `오픈채팅` tab is selected.
4. Confirm the search field placeholder says `채팅방, 참여자 검색`.
5. Click inside the left text area of that search field, away from the `+` icon and away from the window edge.
6. Paste the search text from the clipboard. Do not press `Ctrl+A` first.
7. Wait for results and read the visible result row text.
8. Open only a row whose visible room name matches the requested room. Use double-click only if single-click does not open it.
9. Confirm the opened window title matches the room name.
10. Click the message input area, paste the message, and confirm the send button is enabled.
11. Click send.
12. Confirm the new outgoing yellow bubble appears.

## Clearing Existing Search Text

Prefer one of these approaches:

- Ask the user to provide a blank search field.
- Click the search field's `X` clear button.
- Use Backspace/Delete only after visually confirming the caret is inside the search field.

Do not use `Ctrl+A`; in KakaoTalk Windows it can act on the wrong focus target and may trigger or interact with unexpected UI.

## Modal Recovery

If `친구 추가` appears:

1. Do not paste any search text.
2. Close the modal with its close button or `Alt+F4` while the modal is focused.
3. Take a screenshot and verify the modal is gone.
4. Return to the `오픈채팅` tab.
5. Continue only when `채팅방, 참여자 검색` is visible.

## Example Message Flow

For a request like "코난쌤 AI 쳐서 나오는 오픈채팅방에 인사메시지를 보내봐 윈도우에서 작업중이라는 문구와 함께":

1. Search OpenChat for `코난쌤 AI`.
2. Open the matching room, e.g. `코난쌤 AI연구소`.
3. Confirm the chat title.
4. Send: `안녕하세요! 윈도우에서 작업중입니다.`
5. Confirm the outgoing bubble.

## Failure Conditions

Abort and report if:

- The visible search results do not include the requested room.
- The opened chat title does not match the requested room.
- The message field cannot be identified.
- A modal appears repeatedly.
- The user corrects the workflow or asks to pause.
