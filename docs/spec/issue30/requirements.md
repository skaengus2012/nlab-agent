# 요구사항 분석: [Feature] Add Claude-only skill space and enter-worktree-on-claude-desktop skill (#30)

- 이슈: https://github.com/skaengus2012/nlab-agent/issues/30
- 상위 이슈: 없음
- 라벨: skills, platform
- 생성일: 2026-11-16
- 최종 갱신일: 2026-11-17
- 분석 기준점: 2026-11-16T15:36:29Z

## 배경 및 문제
- 기존 worktree로 세션을 옮기려면 Claude desktop app의 `change_directory` 도구(`mcp__ccd_directory__change_directory`)가 필요하다. 이를 쓰는 스킬은 agent-neutral하지 않다.
- `skills/`는 Claude, Antigravity, Codex가 함께 링크하므로, 여기에 두면 실행할 수 없는 agent에도 노출된다. 아직 Claude 전용 스킬 위치가 없다.
- Claude CLI와 desktop app은 같은 스킬 디렉터리를 읽고, 스킬 frontmatter에는 desktop app 전용으로 제한하는 필드가 없다(문서로 검증되지 않음). CLI에서 숨길 수 없고 런타임에서만 차단할 수 있다.

## 목표
기존 git worktree 목록에서 하나를 골라 세션을 그 worktree로 전환하는 `enter-worktree-on-claude-desktop` 스킬을 만든다. 이 스킬은 Claude에만 제공하고, desktop app 밖에서는 실행을 거부한다.

## 범위
### 포함
- Claude 전용 스킬 공간 `platforms/claude/skills/` 추가
- `enter-worktree-on-claude-desktop` 스킬 추가 (worktree 목록 표시, 선택, `change_directory`로 세션 전환)
- `link_skills.sh`가 두 위치를 모두 `~/.claude/skills`에 링크
- 스킬의 desktop 전용 가드(Step 0)
- README 문서화, 검증

### 제외
- Antigravity, Codex 링크 스크립트 변경 (변경 금지)

## 기능 요구사항
| ID | 요구사항 | 출처 |
|----|----------|------|
| FR-1 | Claude 전용 스킬 공간 `platforms/claude/skills/`를 추가한다. | 본문 |
| FR-2 | `platforms/claude/skills/enter-worktree-on-claude-desktop/SKILL.md`를 추가한다. | 본문 |
| FR-3 | `platforms/claude/link_skills.sh`가 `skills/*`와 `platforms/claude/skills/*`를 모두 `~/.claude/skills`에 링크한다. | 본문 |
| FR-4 | Antigravity, Codex의 link 스크립트는 변경하지 않는다. | 본문 |
| FR-5 | 스킬 Step 0 가드: ToolSearch로 `change_directory`를 로드하고, 없으면 desktop 전용 스킬임을 안내한 뒤 중단한다. | 본문 |
| FR-6 | 스킬에서 중립 fallback(`ask_question`, 비-desktop 분기, Linux `stat`)을 제거한다. | 본문 |
| FR-7 | README Claude Code 섹션에 `platforms/claude/skills/`를 설명하는 한 줄을 추가한다. | 본문 |
| FR-8 | 스킬은 기존 git worktree 목록을 보여 주고, 사용자가 하나를 고르면 `change_directory`로 세션의 작업 디렉터리를 그 worktree로 전환한다. | 본문 (Verification) |

## 비기능 요구사항
| ID | 요구사항 | 출처 |
|----|----------|------|
| NFR-1 | `platforms/antigravity`, `platforms/codex` setup이 `platforms/claude/skills/`를 가져가지 않아야 한다. | 본문 |

## 인수 조건
- [ ] Claude desktop app에서 worktree 목록 표시 → 선택 → `change_directory`로 세션이 전환된다.
- [ ] Claude CLI에서 가드가 "desktop 전용" 메시지와 함께 중단한다.
- [ ] Antigravity, Codex setup이 `platforms/claude/skills/`를 링크하지 않는다.

## 영향 범위
- `platforms/claude/link_skills.sh` (작업 트리에 이미 수정 중)
- `platforms/claude/skills/enter-worktree-on-claude-desktop/SKILL.md` (작업 트리에 이미 존재, 미추적)
- `README.md` (작업 트리에 이미 수정 중)
- `platforms/antigravity`, `platforms/codex` link 스크립트 (비변경 확인 대상)
- `tests/` (현재 `permissions-apply.test.sh`만 존재)

## 미결 사항
- `AGENTS.md` platforms 섹션에 Claude 전용 공간을 언급할지 결정 필요 (본문: "Decide whether").
- `tests/`에 테스트를 추가할지 결정 필요, 추가한다면 범위(링크 분리 검증 등)도 결정 필요 (본문: "Decide whether").
- 선택 사항: desktop app 환경 변수로 가드를 "도구 부재"보다 엄격하게 할지 (본문: Optional).
- 작업 트리의 기존 변경(README, link_skills.sh, SKILL.md)이 FR-1~3, FR-7을 이미 일부 충족하는 것으로 보이나, 이 보고서는 코드 검증을 하지 않았다.

## 충돌 및 참고
댓글이 없고 본문 외 출처가 없어 충돌 없음. 상위 이슈 없음.

---

## 변경 이력
| 날짜 | 변경 | 출처 |
|------|------|------|
| 2026-11-17 | 초안 작성 | 본문 |
| 2026-11-17 | 목표에 스킬 생성을 명시하고 FR-8(스킬 핵심 동작) 추가 | 본문 |
