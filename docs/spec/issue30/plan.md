# 계획: [Feature] Add Claude-only skill space and enter-worktree-on-claude-desktop skill (#30)

- 이슈: https://github.com/skaengus2012/nlab-agent/issues/30
- 요구사항: docs/spec/issue30/requirements.md
- 생성일: 2026-11-17
- 최종 갱신일: 2026-11-17

## 맥락/목표
기존 git worktree로 세션을 옮기는 `enter-worktree-on-claude-desktop` 스킬은 Claude desktop app의 `change_directory` 도구에 의존하므로 agent-neutral하지 않다. `skills/`는 세 플랫폼이 함께 링크하기 때문에, Claude 전용 스킬 공간(`platforms/claude/skills/`)을 만들어 Claude setup만 링크하게 하고, 스킬 자체는 desktop app 밖에서 실행을 거부한다.

작업 트리에는 `link_skills.sh`, `README.md`, `SKILL.md`가 이미 작성되어 있다(요구사항 보고서는 이를 검증하지 않았다). 이 계획은 그 변경을 검증하고, 남은 항목(AGENTS.md 언급, 자동 테스트, 수동 인수 확인)을 채우는 데 초점을 둔다.

## 요구사항
요구사항 ID는 `requirements.md`를 따른다.
- FR-1 ~ FR-8, NFR-1: `requirements.md` 참조.
- 미결 사항 결정 (2026-11-17, 사용자 답변):
  - D-1: ~~`tests/`에 링크 분리 검증 테스트를 추가한다.~~ (번복: PR #31 리뷰에서 필요성을 재검토해 **추가하지 않는다**. 격리는 Antigravity, Codex 스크립트가 `skills/*`만 순회하는 구조로 성립하고, 테스트가 지키는 대상이 glob 한 줄이라 유지 비용이 더 크다. NFR-1은 스크립트 비변경 확인과 `grep`으로 검증한다.)
  - D-2: `AGENTS.md` `<platforms>` 섹션 Claude Code 항목에 Claude 전용 스킬 공간을 한 줄 **언급**한다.
  - D-3: Step 0 가드는 **"`change_directory` 도구 부재"만** 확인한다. desktop 환경 변수는 확인하지 않는다 (변수 이름이 문서로 검증되지 않아 오탐 위험이 있고, 도구가 없으면 어차피 실행할 수 없다).

## 아키텍처/설계
- **스킬 공간 분리**: Claude 전용 스킬은 `platforms/claude/skills/<name>/SKILL.md`에 둔다. `skills/`(공용)와 달리 Antigravity, Codex의 `link_skills.sh`는 `skills/*`만 순회하므로 이 공간을 가져가지 않는다. 두 스크립트는 변경하지 않는다 (FR-4).
- **링크**: `platforms/claude/link_skills.sh`는 `"$SKILLS_SRC"/*`와 `"$CLAUDE_ONLY_SKILLS_SRC"/*`를 한 루프로 순회해 `~/.claude/skills/<name>`에 링크한다. 디렉터리가 없을 때 glob이 그대로 남아도 `[ -d ]` 검사에서 걸러진다. 공용 스킬을 먼저 링크하므로 같은 이름이 있으면 Claude 전용이 덮어쓴다. 현재 충돌은 없다.
- **가드**: SKILL.md Step 0이 `ToolSearch`로 `mcp__ccd_directory__change_directory`를 로드하고, 없으면 desktop 전용임을 안내한 뒤 아무것도 하지 않고 중단한다. CLI에서 스킬 목록 노출 자체를 막을 수는 없고(frontmatter에 제한 필드가 없다) 런타임에서만 차단한다.
- **중립 fallback 제거**: SKILL.md에는 비-desktop 분기, Linux `stat`, 중립 `ask_question`이 없어야 한다 (FR-6). 사용자 선택은 Claude 도구 `AskUserQuestion`만 쓴다.
- **테스트**: 링크 분리 전용 테스트 파일은 만들지 않는다 (D-1). NFR-1은 Antigravity, Codex 스크립트가 변경되지 않았고 `skills/*`만 순회한다는 점을 Task 4의 명령으로 확인한다.

## Tasks
1. 작업 트리의 기존 변경이 FR-1, 2, 3, 5, 6, 7, 8을 충족하는지 검토하고 결과를 기록한다. 필요하면 수정한다.
   - 확인 항목: `platforms/claude/skills/enter-worktree-on-claude-desktop/SKILL.md` 존재(FR-2), Step 0 가드 문구(FR-5), fallback 부재(FR-6), worktree 목록 → 선택 → `change_directory` 흐름(FR-8), README의 한 줄(FR-7), `link_skills.sh`의 두 경로 순회(FR-3).
   - **Verify**: `grep -nE "ask_question|stat -c|비-desktop|non-desktop" platforms/claude/skills/enter-worktree-on-claude-desktop/SKILL.md`가 결과 없음, `grep -n "change_directory" platforms/claude/skills/enter-worktree-on-claude-desktop/SKILL.md`가 Step 0과 Step 3에서 모두 매칭, `grep -n "platforms/claude/skills" README.md platforms/claude/link_skills.sh`가 각 파일에서 매칭, `bash -n platforms/claude/link_skills.sh`가 종료 코드 0.
2. `AGENTS.md` `<platforms>` 섹션 Claude Code 항목에 `platforms/claude/skills/`가 Claude 전용이라는 한 줄을 추가한다 (D-2).
   - **Verify**: `grep -n "platforms/claude/skills" AGENTS.md`가 Claude Code 항목 안에서 매칭. `CLAUDE.md`는 `AGENTS.md`로 링크되므로 같은 줄이 `git diff --stat`에 `AGENTS.md` 한 파일 변경으로만 나타난다.
~~3. `tests/claude-only-skills.test.sh` 추가~~ (Dropped: D-1 번복, PR #31 리뷰 "해당 sh 가 반드시 필요한지 검토해주세요")
4. 기존 테스트와 비변경 검증을 실행한다.
   - **Verify**: `bash tests/permissions-apply.test.sh`가 종료 코드 0. `git diff --name-only main -- platforms/antigravity platforms/codex`가 빈 출력 (FR-4). `grep -n 'SKILLS_SRC"/\*' platforms/antigravity/link_skills.sh platforms/codex/link_skills.sh`가 각 파일에서 `$SKILLS_SRC` 한 경로만 순회함을 보여 준다 (NFR-1).
5. 수동 인수 확인(자동화 불가): Claude desktop app과 Claude CLI에서 스킬을 실행한다.
   - **Verify**: (desktop) `/enter-worktree-on-claude-desktop` → worktree 목록 표시 → 하나 선택 → 턴 종료 후 세션의 작업 디렉터리가 선택한 worktree로 바뀐다. (CLI) 같은 스킬 호출 시 "desktop 전용" 안내만 출력하고 목록이나 질문 없이 중단한다. 결과를 이슈 인수 조건 체크리스트에 기록한다.

## Verification
- 자동: `bash tests/permissions-apply.test.sh`, Task 1의 `grep`/`bash -n` 점검, Task 4의 비변경 확인.
- 수동: Task 5. desktop 전환 성공과 CLI 가드 중단은 도구 환경에 의존하므로 자동 테스트로 대체할 수 없다.
- 인수 조건 대응: desktop 전환 → Task 5, CLI 가드 → Task 5, Antigravity/Codex 비링크 → Task 4.
- 완료 주장 전에 `verification-before-completion`에 따라 위 명령의 실제 출력을 확인한다.

---

## Change History
| Date | Change | Source |
|------|--------|--------|
| 2026-11-17 | Initial draft. 미결 사항 결정(D-1 테스트 추가, D-2 AGENTS.md 언급, D-3 도구 부재 가드만) 반영 | requirements.md, 사용자 답변 |
| 2026-11-17 | D-1 번복: 링크 분리 테스트를 추가하지 않음. Task 3 취소, Task 4와 Verification의 검증 수단을 비변경 확인과 `grep`으로 교체 | PR #31 리뷰 댓글 (tests/claude-only-skills.test.sh) |
