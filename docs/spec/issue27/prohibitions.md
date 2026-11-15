# 이관 목록 (#27, 작업 3)

- 작성일: 2026-11-15
- 승인: 사용자 위임, Fable 2라운드 토론 합의 (2026-11-15)
- 원본: `docs/spec/issue27/emphasis-inventory.md`의 "이관" 판정 6행. `git commit`은 이관하지 않기로 결정함
- 범위 재조정(2026-11-15): 사용자 결정으로 commit-msg hook도 이 PR에서 제외했다(커밋 형식은 지시문으로 지킨다). deny·ask는 저장소 안의 `.claude/settings.json`으로는 nlab-agent 안에서만 적용되어 setup으로 설정을 가져다 쓰는 다른 프로젝트를 보호하지 못해 앞서 제외했다. 따라서 이 문서의 내용(이관 목록, 패턴, 수동 검증, Codex·agy 실측, 한계)은 모두 후속 이슈의 설계 입력이며 이 저장소에는 구현이 없다.

## 분류 기준
- deny: 특정 도구나 명령을 정적으로 막을 수 있는 규칙 (Claude Code `permissions.deny`)
- ask: 매번 사용자 승인이 필요한 규칙 (Claude Code `permissions.ask`)
- hook: 입력을 검사해 차단하는 규칙
- 지시문: 위 수단으로 강제할 수 없는 서술형 규칙. 강조 대신 이유를 적는다.

## 이관 항목

| 전수 목록 위치 | 규칙 | 수단 | 구현 작업 | Claude Code | Antigravity | Codex |
|---|---|---|---|---|---|---|
| `CONTRIBUTING.md:7` | 커밋 메시지 형식 | hook (`.githooks/commit-msg`) | 4, 8, 9 | 적용 | 적용 (setup이 `core.hooksPath` 설정) | 적용 (같음) |
| `CONTRIBUTING.md:28` | Git 작업 전 규칙 확인 | hook (`commit-msg`) | 4, 8, 9 | 적용 | 적용 | 적용 |
| `README.md:11`, `README.md:76` | 커밋 규칙 안내 문구 | hook (`commit-msg`), 문구 정리는 작업 6 | 6 | 적용 | 적용 | 적용 |
| (우회 차단) | `--no-verify` 계열 | deny 6패턴 (후속 이슈, 이 PR에서 제외) | 13 (취소) | 구현 없음 | 구현 없음 | 구현 없음 |
| `PERMISSIONS.md:45`, `PERMISSIONS.md:47` | 원격·파괴 명령은 매번 승인 | ask 4항목 (`git push`, `gh pr merge`, `gh repo create`, `gh repo delete`) (후속 이슈, 이 PR에서 제외) | 10 (취소) | 구현 없음 | 현재 `prompt-required` 블록을 반영하지 않음 (기록만) | 변환 없음 |

## 파생하지 않는 항목과 이유
- `git fetch`, `git pull`, `git clone`, `git remote`: 원격 서버를 바꾸지 않고 로컬 참조·설정만 바꾸므로(PR 리뷰 반영) `PERMISSIONS.md`의 `prompt-required`에서도 뺐다.
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
