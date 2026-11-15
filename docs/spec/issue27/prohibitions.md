# 이관 목록 (#27, 작업 3)

- 작성일: 2026-11-15
- 승인: 사용자 위임, Fable 2라운드 토론 합의 (2026-11-15)
- 원본: `docs/spec/issue27/emphasis-inventory.md`의 "이관" 판정 6행. `git commit`은 이관하지 않기로 결정함
- 범위 확정(2026-11-15): git hook은 채택하지 않았다(커밋 형식은 nlab-agent 고유 규칙이라 지시문으로 지킨다). 이 저장소는 다른 프로젝트가 setup으로 설정을 가져다 쓰는 원본이므로 저장소 안 `.claude/settings.json`이 아니라 `PERMISSIONS.md`를 각 플랫폼 setup이 사용자 수준 권한 설정으로 적용하는 방식(FR-4)을 쓴다. `deny`는 우회 차단 대상이던 hook이 없어 도입하지 않는다. 아래 "작업 13 수동 검증", "플랫폼별 실제 에이전트 검증"(hook)과 한계의 hook·deny 항목은 hook·deny를 시험했던 기록이며 이 저장소에는 구현이 없다.

## 분류 기준
- deny: 특정 도구나 명령을 정적으로 막을 수 있는 규칙 (Claude Code `permissions.deny`)
- ask: 매번 사용자 승인이 필요한 규칙 (Claude Code `permissions.ask`)
- hook: 입력을 검사해 차단하는 규칙
- 지시문: 위 수단으로 강제할 수 없는 서술형 규칙. 강조 대신 이유를 적는다.

## 이관 항목

| 전수 목록 위치 | 규칙 | 수단 | 구현 작업 | Claude Code | Antigravity | Codex |
|---|---|---|---|---|---|---|
| `CONTRIBUTING.md:7` | 커밋 메시지 형식 | 지시문 (hook 미채택) | 6 | 지시문 | 지시문 | 지시문 |
| `CONTRIBUTING.md:28` | Git 작업 전 규칙 확인 | 지시문 (원문 유지) | 6 | 지시문 | 지시문 | 지시문 |
| `README.md:11`, `README.md:76` | 커밋 규칙 안내 문구 | 지시문 (이유 중심으로 정리) | 6 | 지시문 | 지시문 | 지시문 |
| (우회 차단) | `--no-verify` 계열 | 해당 없음 (hook 미채택으로 대상이 없음) | 13 (취소) | 해당 없음 | 해당 없음 | 해당 없음 |
| `PERMISSIONS.md:45`, `PERMISSIONS.md:47` | 원격을 바꾸는 명령은 매번 승인 | `prompt-required` 4개 (`git push`, `gh pr merge`, `gh repo create`, `gh repo delete`)를 setup이 적용 | 17, 18, 19 | `permissions.ask` | 적용하지 않음 (`auto-allow`에 없는 명령은 기본적으로 프롬프트) | `prefix_rule(decision="prompt")` |

## 파생하지 않는 항목과 이유
- `git fetch`, `git pull`, `git clone`, `git remote`: 원격 서버를 바꾸지 않고 로컬 참조·설정만 바꾸므로(PR 리뷰 반영) `prompt-required`에서 빼고 `auto-allow`로 옮겼다(FR-5).
- `git commit`: 이 저장소의 일부 skill이 코멘트별 커밋을 지시하고, hook은 사용자의 요청 여부를 판정할 수 없어 이관하지 않는다.

## 한계
- Bash 규칙은 보안 경계가 아니다. 결합 플래그(`git commit -anm "..."`)는 deny 패턴으로 막지 못하며, 수동 검증에서 실제로 거부되지 않고 hook을 건너뛴 커밋이 만들어졌다 (아래 표). 환경변수(`GIT_CONFIG_COUNT`) 등도 막지 못한다고 본다. `git -C . commit --no-verify`는 `Bash(git *--no-verify*)`가 잡아 거부되었다.
- `Bash(git *core.hooksPath*)`는 `git config --get core.hooksPath` 같은 읽기 명령도 막는다. `Bash(git commit * -n *)`는 메시지에 ` -n `이 들어간 커밋을 오탐할 수 있다.
- `gh api`와 `git config`는 auto-allow라서 ask를 우회할 수 있다 (예: `gh api -X PUT .../merge`). 별도 이슈 후보다.
- Antigravity 기존 설치에는 `PERMISSIONS.md` 변경이 소급되지 않는다. 이미 setup을 실행했다면 `gh pr merge`가 자동 허용된 상태로 남고, `gh pr` 분할 뒤에는 `gh pr edit`, `close` 등에 새 프롬프트가 생긴다.
- git 설정 키는 대소문자를 구분하지 않는다. 소문자 `core.hookspath`가 통과하는 것을 실측하여 `Bash(git *hookspath*)`를 추가했지만 `core.HooksPath` 같은 혼합 표기는 여전히 막지 못한다. 완전하게 막으려면 glob 대신 인자를 파싱하는 PreToolUse hook이 필요하며 별도 이슈 후보다.
- deny 패턴의 오탐: `Bash(git *--no-verify*)`, `Bash(git *core.hooksPath*)`, `Bash(git *hookspath*)`는 해당 단어가 들어간 `git commit -m "..."`, `git log --grep`, `git grep`도 막는다. README가 안내하는 `git config core.hooksPath .githooks`도 이 저장소의 Claude 에이전트는 실행할 수 없으므로 사용자가 직접 실행해야 한다.
- hook 자체: 독립 검토에서 확인된 우회 세 가지(`#`로 시작하는 제목, `Merge `·`Revert ` 접두어만 붙인 제목, `amend!` 오탐)와 긴 제목 성능 문제는 수정했다. `git commit -m` 외의 경로(예: `GIT_EDITOR`가 만든 메시지)나 `core.commentChar`를 바꾼 환경에서의 주석 처리는 검증하지 않았다.
- 로컬 hook과 deny는 모두 우회 가능하다. 우회할 수 없는 강제는 서버 측 CI의 커밋 제목 검사뿐이며 별도 이슈 후보다.
- 권한 배포의 한계(작업 17~19): setup은 Claude Code의 `settings.json`에 항목을 더하기만 하고 지우지 않으므로 `PERMISSIONS.md`에서 뺀 항목이 이미 적용된 환경에는 남는다(Antigravity와 같다). `auto-allow`의 `gh api`와 `git config`는 `ask`를 우회할 수 있다(예: `gh api -X PUT .../merge`). Codex의 `allow`는 "샌드박스 밖에서 프롬프트 없이 실행"이라 Claude Code의 `allow`보다 강하다. `CODEX_HOME`로 규칙 위치가 바뀌는지는 문서에 없고 시험하지 않았다(setup은 `link_skills.sh`와 같은 변수를 쓴다). Claude Code는 `CLAUDE_HOME`(저장소 관례)을 쓰며 `CLAUDE_CONFIG_DIR`는 읽지 않는다.

## 작업 13 수동 검증 결과 (2026-11-15, 이 세션의 Bash 도구에서 수행)

| 확인 항목 | 결과 |
|---|---|
| `git commit --no-verify -m ...` 거부 | 거부됨 |
| `git commit -n -m ...` 거부 | 거부됨 |
| `git commit -m ... -n` (플래그가 끝에 옴) | 처음에는 거부되지 않음 → `Bash(git commit * -n)` 추가 후 거부됨 |
| `git config --get core.hooksPath` (읽기) | 거부됨 (설계대로 읽기도 막힘) |
| `git -C . commit --no-verify -m ...` | 거부됨 (`Bash(git *--no-verify*)`가 잡음) |
| `git commit -anm "..."` (결합 플래그) | **거부되지 않음.** `-a`로 스테이징되어 실제 커밋이 생겼고 hook도 건너뜀. 한계로 기록 |
| `--permission-mode bypassPermissions`에서 `git push --dry-run` | ask 규칙이 유지되어 거부됨 (`claude -p --permission-prompts none`, 출력의 `permission_denials`로 확인) |
| `-p --permission-prompts none`에서 거부 | `git status`는 실행되고 `git push --dry-run`은 거부됨 |
| `git -C . push --dry-run` 통과 여부 | 구분 불가. 비대화형 기본 모드에서는 ask 규칙에 맞지 않아도 push가 승인 대상이라 거부되므로 규칙 일치 여부를 가릴 수 없음. 대화형 기본 모드에서는 어느 쪽이든 프롬프트가 뜸 |
| 인자 없는 `git push`가 ask에 잡히는지 | 구분 불가 (위와 같은 이유). `Bash(git push)` 패턴을 함께 두어 대응 |

참고: `git commit -anm` 시험은 `-a`가 추적 파일을 자동 스테이징한다는 점을 놓치고 수행해 의도하지 않은 커밋(`c884f20`)이 만들어졌다. 푸시 전이었고 `git reset --mixed ce89007`로 되돌려 작업 트리는 보존되었다. 이후 시험은 `-a`가 없는 형태만 사용한다.

## 플랫폼별 실제 에이전트 검증 (2026-11-15)

임시 저장소 복사본에서 `platforms/lib/commit_hook.sh`의 `enable_commit_hook`만 실행해 hook을 켠 뒤(실제 `~/.codex`, `~/.gemini` 설정은 건드리지 않음), 각 CLI에 같은 지시를 주었다: `probe.txt`를 만들어 메시지 `bad message`로 커밋하고, 거부되면 `Chore N/A - add probe file`로 다시 커밋.

| 플랫폼 | 버전 | `bad message` 커밋 | `Chore N/A - add probe file` 커밋 | 비고 |
|---|---|---|---|---|
| Codex | codex-cli 0.169.0 (`exec`, workspace-write) | hook이 거부, 커밋 없음 | 생성됨 | 기본 샌드박스는 `.git` 쓰기를 막아 `git add`에서 멈췄다(hook과 무관한 샌드박스 오류). `.git` 경로만 쓰기 가능으로 열어 재실행 |
| Antigravity | agy 1.5.9 (`-p`, 기본 모드) | hook이 거부, 커밋 없음 | 생성됨 | `--mode auto`는 이 계정에서 쓸 수 없어 기본 모드로 실행됨 |

- 확인한 것: git hook이 두 에이전트의 커밋에도 동작한다. 거부 메시지가 에이전트에게 그대로 전달되었고, 에이전트는 우회하지 않고 지시된 대체 메시지로 다시 시도했다.
- 확인하지 못한 것: 각 에이전트가 hook을 우회하려 할 때의 동작(이 시험은 우회를 유도하지 않았다), 표본은 플랫폼당 1회다. deny와 ask는 Claude Code 설정이라 두 플랫폼에는 적용되지 않으며 이 시험 대상도 아니다.

## 권한 배포 검증 (작업 21, 2026-11-15)

단위·통합 시험은 `tests/permissions-apply.test.sh`(32건, 임시 홈 디렉터리만 사용). 실제 에이전트로는 다음을 확인했다.

| 대상 | 방법 | 결과 |
|---|---|---|
| Claude Code | 실제 `PERMISSIONS.md`로 만든 `settings.json`만 적용되게 `claude -p --setting-sources project --settings <파일> --permission-prompts none`을 임시 저장소에서 실행 | `git status --short`와 `git fetch --dry-run`은 승인 없이 실행됨. `fetch`는 기본 모드에서 프롬프트 대상이므로 새 `allow` 규칙이 적용된 증거다. `git push --dry-run`은 거부됨. 단 이 모드에서는 허용 목록에 없는 명령이 모두 거부되므로 `ask` 규칙 때문인지 구분되지 않는다 |
| Codex 0.169.0 | 사용자 위치 `~/.codex/rules/`에 무해한 시험 규칙 파일(`echo nlab-probe-token-7f3a`를 `forbidden`)을 잠깐 두고 `codex exec`로 통제 명령(`echo control-token-1`)과 시험 명령을 실행한 뒤 파일과 디렉터리를 지움 | 통제 명령은 실행되고 시험 명령은 "policy forbids commands starting with `echo nlab-probe-token-7f3a`"로 거부됨. 사용자 위치의 규칙이 로드됨을 확인. 시험 전 `~/.codex/rules`는 없었고 시험 후 다시 없음 |

- 확인하지 못한 것: `CODEX_HOME`로 위치를 바꿨을 때의 로드, Claude Code에서 `ask`가 `allow`보다 우선하는 것(문서상 `deny` > `ask` > `allow`)의 실측, 사용자 수준 `~/.claude/settings.json` 경로에서의 로드(같은 스키마를 `--settings`로 시험했고 위치는 문서로 확인).
