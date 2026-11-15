# 계획: [Task] Review harness for model advancements, including emphasis expressions (#27)

- 이슈: https://github.com/skaengus2012/nlab-agent/issues/27
- 요구사항: docs/spec/issue27/requirements.md
- 생성일: 2026-11-15
- 최종 갱신일: 2026-11-15

## 맥락/목표
모델이 발전하여 이전 세대용 강조 표현(`MUST`, `NEVER` 등)을 재평가하고, 절대 금지 사항은 지시문 강조가 아니라 hook 등으로 강제한다. 감사(`/claude-api prompt-audit`)는 참고 자료로만 쓰며, 문서·설정 변경의 완료 판정은 결정적 명령(grep, 테스트 종료 코드)으로 한다. 지시문 변경이 에이전트 행동에 미치는 영향은 반복 실행 평가로 확인한다.

## 요구사항
- FR-1: 하네스 전반의 강조 표현을 재평가한다.
- FR-2: 불필요한 강조 표현은 조정한다.
- FR-3: 절대 금지 사항은 hook 등으로 강제한다.
- 추가 요구(사용자 요청): 지시문 변경 전후의 에이전트 행동을 평가해 회귀가 없음을 확인한다. 이 저장소의 산출물은 에이전트가 읽는 지시문이기 때문이다.

## 아키텍처/설계
- **검토 범위**: `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `PERMISSIONS.md`, `skills/*/SKILL.md`, `platforms/` (`PERMISSIONS.md`의 `prompt-required` 블록과 `platforms/*/setup.sh`의 강제 여부 포함).
- **조정 방식**: 강조를 제거하고 이유를 문장으로 적는다. 소문자 표현과 `Red Flags` 섹션도 대상이지만, 행으로 싣는 것은 굵게 쓴 표현, `never`/`always`, 금지·허용 선언(`do not`, `not allowed`)만이다. 그 밖의 `must`는 파일별 한 줄 요약으로 처리한다. 항목마다 유지/조정/이관을 판정한다.
- **강제 수단 분류 기준** (4분류):
  - deny: 특정 도구나 명령을 정적으로 막을 수 있는 규칙 (Claude Code `permissions.deny`)
  - ask: 매번 사용자 승인이 필요한 규칙 (Claude Code `permissions.ask`)
  - hook: 입력을 검사해 차단하는 규칙
  - 지시문: 위 수단으로 강제할 수 없는 서술형 규칙. 강조 대신 이유를 적는다.
- **hook 종류**: 커밋 메시지 형식은 git `commit-msg` hook(`.githooks/commit-msg`)으로 강제한다. 최종 메시지 파일을 직접 검사하므로 명령 문자열 파싱이 필요 없고, 세 플랫폼과 사람의 커밋에 모두 적용된다.
  - 예외 제목: git이 만드는 형태만 허용한다 (`Merge branch `, `Merge pull request `, `Merge remote-tracking branch `, `Merge tag `, `Merge commit `, `Revert "`, `Reapply "`, `fixup! `, `squash! `, `amend! `). 임의의 `Merge `·`Revert ` 접두어는 예외가 아니다
  - 제목 판정: git의 주석 줄(`#` 단독 또는 `# `로 시작)과 선행 빈 줄을 건너뛴 첫 유효 줄. `#bad`처럼 `#` 바로 뒤에 글자가 이어지는 줄은 제목으로 검사한다. 제목은 500자를 넘으면 거부한다
  - 활성화: `platforms/*/setup.sh`가 `--help`를 제외한 모든 분기에서 별도 함수로 `git -C "$REPO_ROOT" rev-parse --show-toplevel`의 결과가 `REPO_ROOT`의 실제 경로(`pwd -P`)와 같을 때만 `git -C "$REPO_ROOT" config core.hooksPath .githooks`를 실행하고, 아니면 `skip`을 출력한다. `set -e` 환경에서 git 저장소가 아닌 사본(zip 등)이 중단되지 않게 하고, 상위 디렉터리의 다른 저장소 설정을 바꾸지 않게 하는 가드다. 대상이 이 저장소뿐이므로 임의 프로젝트에는 영향이 없다. hook 파일에는 실행 권한이 필요하다.
  - 우회 차단: 이 저장소의 `.claude/settings.json` `permissions.deny`에 4개 패턴을 둔다: `Bash(git *--no-verify*)`, `Bash(git commit -n*)`, `Bash(git *core.hooksPath*)`, `Bash(git commit * -n *)` 에 더해, 수동 검증에서 끝에 오는 `-n`이 막히지 않아 `Bash(git commit * -n)`를 추가했다(5개). 검토에서 git 설정 키가 대소문자를 구분하지 않아 소문자 `core.hookspath`가 통과하는 것을 확인해 `Bash(git *hookspath*)`를 더했다(총 6개). 나머지 우회(결합 플래그 `-anm`, 환경변수 `GIT_CONFIG_COUNT` 등)는 Bash 규칙이 보안 경계가 아니므로 막지 못하며 한계로 `prohibitions.md`에 기록한다. 세 번째 패턴은 `git config --get core.hooksPath` 같은 읽기 명령도 막고, 네 번째는 메시지에 ` -n `이 들어간 `git commit -m "fix -n handling"`을 오탐할 수 있다.
- **원본과 파생물**: `PERMISSIONS.md`가 원본이다.
  - `PERMISSIONS.md`에 새 블록 `permissions:claude-ask`를 추가한다. 항목은 `git push`, `gh pr merge`, `gh repo create`, `gh repo delete` 4개다. `prompt-required` 블록은 그대로 둔다 (Antigravity 파서는 `auto-allow` 블록만 읽으므로 영향이 없다).
  - `.claude/settings.json`의 `permissions.ask`는 `claude-ask`에서 파생한다 (`Bash(git push *)` 형태, 인자 없는 `git push`는 `Bash(git push)`를 함께 둔다).
  - `git fetch`, `git pull`, `git clone`, `git remote`는 파생하지 않는다. Claude Code 기본 모드에서 이미 프롬프트 대상이고, 빈도가 높고 위험이 낮아 마찰만 커지기 때문이며 이 이유를 `prohibitions.md`에 적는다.
  - `auto-allow`의 `gh pr`는 `gh pr view`, `gh pr list`, `gh pr diff`, `gh pr checks`, `gh pr status`, `gh pr create`, `gh pr comment`로 분할한다. `platforms/claude/setup.sh`는 `PERMISSIONS.md`를 읽지 않으므로 이 충돌은 Antigravity에서만 실제로 일어난다. Antigravity 기존 설치에는 소급되지 않고(`gh pr merge`가 자동 허용된 상태로 남음) `gh pr edit`, `close` 등에 새 프롬프트가 생기는 점을 `prohibitions.md`에 기록한다.
  - `tests/permissions.test.sh`는 세 가지를 검사한다. (1) `.claude/settings.json`의 ask가 `claude-ask` 블록과 같다 (접두 `Bash(`와 접미 ` *)` 제거 후 집합 비교). (2) `claude-ask` ⊆ `prompt-required`. (3) `prompt-required` 항목이 `auto-allow` 항목을 접두로 갖지 않는다.
  - `gh api`, `git config`를 통한 ask 우회는 한계로 기록하고 별도 이슈 후보로 둔다.
- **적용 범위**: 커밋 형식은 `CONTRIBUTING.md:29`대로 이 저장소 전용 규칙이다. 다른 프로젝트로 배포하지 않으며 임의 프로젝트에 설정을 병합하는 setup 변경도 하지 않는다.
- **플랫폼**: git hook은 플랫폼 무관이다. deny/ask 설정은 Claude Code 전용이며, Antigravity와 Codex는 항목별 적용 여부를 기록만 한다.
- **문서 구성**: 전수 목록 `emphasis-inventory.md` 한 파일에 판정과 강제 수단 열을 함께 둔다. `prohibitions.md`에는 이관(deny/ask/hook) 판정 항목과 한계만 적는다.
- **결정 기록**: 아래 항목은 계획 승인과 사용자 위임(Fable과의 2라운드 토론 합의)으로 확정되었다.

| 요구사항 미결 사항 | 결정 | 상태 |
|---|---|---|
| 하네스 범위 | 위 검토 범위 | 확정 |
| "불필요한 강조" 기준 | 대문자·소문자 표현, `Red Flags` 포함, 항목별 판정 | 확정 |
| 조정 방식 | 강조 제거 + 이유 문장화 | 확정 |
| 절대 금지 목록 | `commit-msg` hook, deny 6패턴, ask 4항목 (`git push`, `gh pr merge`, `gh repo create`, `gh repo delete`). `git commit`은 이관하지 않음 | 확정 (사용자 위임, Fable 2라운드 합의) |
| hook 대상 플랫폼 | git hook(공통) + Claude Code deny/ask | 확정 |
| hook 설정 위치·배포 | `.githooks/`, 저장소 `.claude/settings.json`, setup이 `core.hooksPath`만 설정 | 확정 |
| hook 불가 항목 | 지시문으로 두고 이유를 적음 | 확정 |
| 산출물 범위 | 수정과 hook 구현까지 포함 | 확정 |
| 행동 평가 방식 | 위 "행동 평가 설계": 자동(`run.sh`), 2단계, Sonnet 5.5 판정 + Haiku 5.5 보고용, 총 캡 25달러 | 확정 (사용자 위임, Fable 2라운드 합의). 첫 모델 호출 전에 사용자에게 시작을 알림 |

- **행동 평가 설계**:
  - 격리: 빈 임시 디렉터리에서 `claude -p --disable-slash-commands --append-system-prompt-file <사본>/SKILL.md --model <모델> --effort medium --max-budget-usd <상한> --output-format stream-json --verbose --allowedTools <최소 목록> --strict-mcp-config --no-session-persistence --permission-prompts none` 로 실행한다. 사본을 시스템 프롬프트에 직접 주입하는 방식으로 고정한다. fixture `.claude/skills/` 로딩은 `description` 트리거 여부라는 별도 변수가 섞이기 때문이다. 작업 14의 격리 확인 때 두 방식이 모두 동작하는지 1회씩만 비교해 기록한다. 전역 `~/.claude/CLAUDE.md`의 응답 언어 규칙이 섞이므로 시나리오 프롬프트에 응답 언어를 명시하고 통과 조건을 언어에 의존하지 않게 쓴다.
  - 대상 범위: 본문 지시 준수만 측정한다. `description` 트리거 변경은 평가하지 않는다. 문서 4개의 조정 항목은 평가 제외, 이관 항목은 hook과 permission 테스트로 대체한다.
  - 시나리오(6개 + 의도 변화 검사 1개, 상한 8): 한 번에 하나만 바꾸기(`systematic-debugging`), 재현 먼저(`receiving-code-review`), 검증 skill 실행(`receiving-code-review`), 맞장구 금지(70·71 병합), `\n` 리터럴 금지(`create-gh-issue`), fluff 금지(`requesting-code-review`). `writing-skills`(작업 11)는 의도한 변화가 나타나는지 보는 의도 변화 검사 1개로 분리하고 회귀 판정에서 제외한다. 시나리오마다 임시 fixture와 최소 `--allowedTools`를 정하며 `git push`, `gh`는 제외한다.
  - 판정 대상: 최종 메시지만으로 판정할 수 없는 단계 수행 여부는 `stream-json` 출력 파일을 grep한다.
  - 모델: 판정용 `claude-sonnet-5-5`, 민감도 병행용 `claude-haiku-5-5`. Haiku 결과는 보고만 하며 재작성 트리거로 쓰지 않는다. Fable은 한도와 비용 때문에 돌리지 않으며 이를 `results.md`의 한계에 적는다.
  - 2단계: 1단계(선별)는 6 × (대조 3 + 기준선 3) = 36회이고, 판별 기준은 "기준선 − 대조 ≥ 2"다. 2단계에서 판별 시나리오는 기준선 +5(총 8), 변경 후 8회를 돌리고 비판별 시나리오는 변경 후 3회만 돌린다. 회귀 판정은 판별 시나리오에서 변경 후가 기준선보다 2회 이상 낮을 때(8회 기준)이며, 재작성은 최대 2회이고 넘으면 사용자에게 보고한다. 기준선이 0/n이면 시나리오나 통과 조건을 고쳐 기준선을 다시 잡는다.
  - 비판별 처리: 대조에서 기준선과 차이가 없는 시나리오는 제외하지 않고 "비판별"로 `baseline.md`에 남기며 `emphasis-inventory.md`의 사유 열에 인용한다. 판별 시나리오가 3개 미만이면 통과로 처리하지 않고 보고한다. 이는 "지시문 없이도 준수됨"의 근거이며, 인용할 때는 "`claude-sonnet-5-5`, `--effort medium`, 시스템 프롬프트 주입 조건에서"라고 범위를 한정한다.
  - 기준 커밋: 작업 시작 시점의 `ce89007`. 변경 후 사본은 작업 트리의 `skills/`를 복사해 만든다. 이 계획은 커밋을 전제하지 않으며, 커밋은 사용자가 요청할 때만 한다.
  - 비용·횟수: 실행당 Sonnet 0.50달러, Haiku 0.10달러, 총 하드 캡 25달러(추정 13~20달러, 가정에 기반하며 작업 14의 격리 확인에서 `total_cost_usd`로 재산정). 캡을 올리려면 사용자 승인이 필요하다. 횟수 상한은 Sonnet 125회(1단계 36, 2단계 최대 78, 격리 확인 2, 방식 비교 1~2, 의도 변화 검사 6), Haiku 60회(6 × (기준선 5 + 변경 후 5))이며, 무효 실행의 재실행도 이 상한과 캡 안에서만 한다. 예산 초과로 끝난 실행은 "실패"가 아니라 "무효"로 별도 집계한다.
  - 실행 방식: 구독 인증이면 달러 캡보다 사용 한도가 먼저 걸리므로 `run.sh`는 순차 실행하고, 이미 끝난 실행은 건너뛰고 재개할 수 있어야 한다.
  - 한계: 회귀 검출은 통계적 유의성이 아니라 휴리스틱이다. 시스템 프롬프트 주입으로 전후가 모두 전부 통과하는 천장에 붙으면 회귀를 과소 검출할 수 있다.
- **범위 밖**: `AGENTS.md`의 `.nlab/state`, `.nlab/memory`, 스킬 목록 누락 등 작업 1 외의 낡은 사실은 별도 이슈로 분리한다. 서버 측 CI의 커밋 제목 검사(로컬 hook과 deny는 모두 우회 가능)와 `gh api`·`git config` 우회 차단도 별도 이슈 후보다.

## 작업
실행 순서: 7 → 12 → 1 → 3 → 14 → 16 → 8 → 4 → 9 → 13 → 10 → 11 → 6 → 2 → 15

1. `AGENTS.md`의 낡은 경로 `.nlab/plans/` 줄을 제거한다 (plan은 `docs/spec/issue<number>/`에 있음).
   - **Verify**: `grep -n "\.nlab/plans" AGENTS.md` 결과가 없다.
2. 작업 7과 12의 목록에서 "조정" 판정을 받은 항목을 이유 중심 문장으로 바꾼다. 커밋 규칙 관련 문구는 작업 6에서 다룬다.
   - **Verify**: "조정" 판정 항목의 원문이 더 이상 grep되지 않는다 (`grep -rnF "<원문>" AGENTS.md README.md CONTRIBUTING.md PERMISSIONS.md skills`).
3. 작업 7과 12의 목록에서 "이관" 판정 항목을 deny/ask/hook으로 분류해 `docs/spec/issue27/prohibitions.md`에 기록한다. 항목별로 Antigravity·Codex 적용 여부 열을 둔다. 분류 기준은 `CONTRIBUTING.md`에 한 단락으로 남긴다. 사용자가 이관 목록과 분류를 승인한다.
   - **Verify**: 목록의 모든 "이관" 판정 항목이 `prohibitions.md`에 있고, 사용자 승인이 변경 이력에 기록되어 있다.
4. 승인된 hook 항목 중 커밋 메시지 형식을 `.githooks/commit-msg`로 구현하고 실행 권한을 부여한다.
   - **Verify**: `bash tests/commit-msg.test.sh; echo $?` 가 0이고 `test -x .githooks/commit-msg` 가 성공한다.
5. ~~작업 5~~ (Dropped: 커밋 형식이 저장소 전용 규칙이라 임의 프로젝트로 배포하지 않기로 함. 번호는 재사용하지 않는다.)

6. `prohibitions.md`에서 이관으로 판정된 항목의 지시문을 이유 중심 문장으로 정리한다. 예상 대상은 커밋 규칙 문구(`README.md:11`, `CONTRIBUTING.md:7,28`)이며, 최종 대상은 작업 3의 판정으로 정한다.
   - **Verify**: 이관 항목의 원문이 더 이상 grep되지 않는다.
7. 문서 4개(`AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `PERMISSIONS.md`)의 전수 목록 `docs/spec/issue27/emphasis-inventory.md`를 작성한다. 열: 파일, 표현 원문, 판정(유지/조정/이관), 강제 수단, 사유.
   - **Verify**: 검증 절의 패턴 grep이 문서 4개에서 반환하는 `파일:내용` 줄이 모두 목록에 존재한다. "유지" 판정 줄은 `docs/spec/issue27/emphasis-keep.txt`에 `grep -rE`(`-n` 없음) 출력 형식 그대로 둔다.
8. 커밋 메시지 테스트 `tests/commit-msg.test.sh`를 먼저 작성해 실패를 확인한다.
   - 통과해야 할 케이스: `Implement #12 - x`, `Chore N/A - x`, `Merge branch x`, `Revert "x"`, `fixup! x`, `squash! x`, `Co-Authored-By` 트레일러가 붙은 메시지, 선행 `#` 주석 줄이나 빈 줄이 있는 메시지
   - 차단해야 할 케이스: `Fix N/A`, `Fix 12 - x`(`#` 없음), `implement #1 - x`(소문자), `Fix #1 - `(빈 설명)
   - 통합 케이스: 임시 저장소에서 `git init`, `core.hooksPath` 설정 후 위반 커밋이 실패한다.
   - **Verify**: hook 구현 전 `bash tests/commit-msg.test.sh` 가 0이 아닌 종료 코드를 낸다.
9. 활성화를 마무리한다.
   - `platforms/antigravity/setup.sh`, `platforms/claude/setup.sh`, `platforms/codex/setup.sh`에 위 가드 함수를 추가하고 `--help`를 제외한 분기에서 호출한다.
   - `README.md`에 hook 안내를 추가하고, `CONTRIBUTING.md`에 "hook 수정 시 `bash tests/commit-msg.test.sh` 실행" 한 줄을 추가한다.
   - **Verify**: `grep -c "^enable_commit_hook()" platforms/*/setup.sh` 가 파일마다 1이고 `bash -n`이 통과한다. git 저장소 밖 `mktemp -d` 아래에 작업 트리를 `rsync -a --exclude .git`으로 복사하고 `git init`한 사본(이 worktree의 `.git`은 실제 저장소를 가리키는 파일이므로 복사하지 않는다)에서 `CLAUDE_HOME="$(mktemp -d)" ./platforms/claude/setup.sh --global` 을 실행한 뒤 `test "$(git -C <사본> rev-parse --git-path hooks)" = ".githooks"` 가 성공한다. `.git` 없는 사본(git 저장소 밖 `mktemp -d` 아래에 `rsync -a --exclude .git`)에서도 같은 명령이 종료 코드 0이고 상위 저장소 설정이 바뀌지 않는다. 실제 `~/.claude`, `~/.gemini` 설정과 이 저장소의 `core.hooksPath`는 검증에서 건드리지 않으며, 검증 끝에 이 저장소에서 `git rev-parse --git-path hooks` 가 `.githooks`가 아닌 기존 경로를 반환함을 확인한다 (`git config --get core.hooksPath`는 deny 패턴에 걸리므로 쓰지 않는다). Antigravity와 Codex setup은 실행하지 않는다.
10. `PERMISSIONS.md`에 `permissions:claude-ask` 블록(4개 항목)을 추가하고 `auto-allow`의 `gh pr`를 설계 절대로 분할한다. 같은 4개를 `.claude/settings.json`의 `permissions.ask`에 파생한다. 일치 검사는 `tests/permissions.test.sh`로 남긴다.
    - **Verify**: `bash tests/permissions.test.sh; echo $?` 가 0이다.
11. `skills/writing-skills/SKILL.md`의 작성 지침("No exceptions:" 카운터 추가, "Pushy Description")을 이유 중심 지침으로 조정한다.
    - **Verify**: `grep -nE "No exceptions|Pushy" skills/writing-skills/SKILL.md` 결과가 없다.
12. `skills/*/SKILL.md` 11개의 전수 목록을 `emphasis-inventory.md`에 추가한다. 트리거용 `description`의 유지 여부와 사유도 이 목록에서 판정한다.
    - **Verify**: 작업 7과 같은 방식으로 `skills/`의 grep 결과가 모두 목록에 존재하고, "유지" 줄은 `emphasis-keep.txt`에 추가한다.

13. `.claude/settings.json`에 설계 절의 `permissions.deny` 6패턴을 추가한다.
    - **Verify**: `python3 -c "import json;json.load(open('.claude/settings.json'))"` 가 성공한다. 설계 절의 각 우회 형태를 Claude Code 세션에서 수동으로 시도해 거부 여부를 `prohibitions.md`의 표에 기록하고, 거부되지 않은 형태는 한계로 적는다. 추가로 다음을 확인해 기록한다: `--permission-mode bypassPermissions`에서 `git push --dry-run`이 프롬프트를 띄우는지, `-p --permission-prompts none`에서 거부되는지, `git -C . push --dry-run`이 통과하는지(한계 기록), `git commit -m x -n`과 인자 없는 `git push`가 패턴에 잡히는지(안 잡히면 `Bash(git push)` 같은 인자 없는 형태를 함께 추가). 시도는 스테이징이 빈 상태에서 하고, `core.hooksPath` 시험은 값을 `.githooks`로 주어 부작용이 없게 한다.
14. 행동 평가 도구를 만든다. 설계 절의 시나리오마다 `docs/spec/issue27/evals/<skill>.md`에 시나리오와 통과 조건(grep 패턴)을 적고, 설계 절의 실행 명령을 고정한 `docs/spec/issue27/evals/run.sh <지시문 디렉터리> <출력 디렉터리>`를 작성한다. `run.sh`는 순차 실행하고 이미 끝난 실행은 건너뛴다.
    - **Verify**: `bash -n docs/spec/issue27/evals/run.sh` 가 성공한다. 전후 사본에 서로 다른 표식 문자열을 넣고 모델이 각각 해당 표식을 답하는지 1회씩 확인해 격리를 입증하고, 시스템 프롬프트 주입과 fixture 로딩 두 방식을 1회씩 비교해 기록한다. 격리 확인의 `total_cost_usd`로 캡을 재산정해 기록한다. 시나리오 수가 상한 8 이하이고 전역 설정 배제 여부가 `evals/README.md`에 기록되어 있다. `run.sh`는 실행마다 fixture를 새로 복사하며, 모델 ID와 CLI 버전(`claude --version`, `--append-system-prompt-file`이 문서화되지 않은 플래그임을 포함)을 `evals/README.md`와 결과 파일에 기록한다. 첫 모델 호출 전에 사용자에게 시작을 알리고 구독 사용 한도 상태를 확인한다.
15. 변경 후 같은 시나리오를 설계 절의 2단계 규칙대로 재실행해 기준선과 비교한다. 변경 전 사본은 기준 커밋 `ce89007`에서 `git show`로, 변경 후 사본은 작업 트리에서 만든 임시 디렉터리를 쓰며 실제 `~/.claude` 설정은 건드리지 않는다. 재작성이 있었다면 `emphasis-inventory.md`와 `emphasis-keep.txt`를 갱신하고 검증 절 전체를 다시 실행한다.
    - **Verify**: 판별 시나리오 전부가 설계 절의 판정 규칙을 통과하고(판별 시나리오가 3개 미만이면 보고 기록이 `results.md`에 있고), `writing-skills` 의도 변화 검사 결과와 Haiku 보고, 한계 문구가 포함된 결과 표가 `docs/spec/issue27/evals/results.md`에 있다. 검증 절의 모든 명령이 재실행되어 통과한다.
16. 변경 전 기준선을 실행한다. 기준 커밋 `ce89007`의 지시문 사본으로 설계 절의 1단계(시나리오당 대조 3 + 기준선 3)와, 판별 시나리오의 기준선 +5를 실행하고 결과를 `docs/spec/issue27/evals/baseline.md`에 기록한다. Haiku 기준선도 같은 파일에 기록한다. 설계 절의 비용·횟수 상한 안에서 실행한다.
    - **Verify**: 기준선 파일에 시나리오별 통과 횟수와 대조 실행 결과, 판별/비판별 표시가 있고, 기준선이 0/n인 시나리오는 수정되어 있다. 무효 실행은 별도 집계되어 있다.

## 검증
- 최종 grep: `diff <(grep -rE "\b(MUST|NEVER|STOP|NOT|ONE|WHY|FIRST|INSTEAD)\b|Mandatory|strict" AGENTS.md README.md CONTRIBUTING.md PERMISSIONS.md skills | sort) <(sort docs/spec/issue27/emphasis-keep.txt)` 가 빈 출력이다.
- `bash tests/commit-msg.test.sh` 종료 코드가 0이고 `test -x .githooks/commit-msg` 가 성공한다.
- 작업 10을 수행했다면 `bash tests/permissions.test.sh` 종료 코드가 0이다.
- `.claude/settings.json`이 유효한 JSON이다.
- 임시 사본에서 setup 실행 후 `git rev-parse --git-path hooks` 가 `.githooks`를 반환한다.
- 행동 평가가 작업 15의 판정 규칙을 통과한다 (`evals/results.md`).
- `/claude-api prompt-audit` 재실행 결과는 참고용으로만 기록한다.

---

## 변경 이력
| 날짜 | 변경 내용 | 출처 |
|------|-----------|------|
| 2026-11-15 | 최초 초안 | requirements.md, prompt-audit 결과 |
| 2026-11-15 | 범위에 PERMISSIONS.md·platforms 추가, 4분류(ask 추가), git commit-msg hook 채택, 작업 5 삭제, 작업 7~11 추가, 검증을 결정적 명령으로 교체, 미결 사항 결정 표 추가 | Fable 검토 1라운드 |
| 2026-11-15 | setup.sh가 core.hooksPath 설정, 실행 순서 재배치(6 → 2), 대조 키를 원문으로 변경, 우회 차단 형태 열거, 원본/파생물 관계 명시, 테스트 케이스 확대, 작업 7을 7·12로 분할, 문서 이중화 해소, 가정 확정 시점 명시 | Fable 검토 2라운드 |
| 2026-11-15 | 검증 명령이 전역 설정을 바꾸지 않도록 격리(임시 clone, CLAUDE_HOME), setup.sh 가드 추가, deny 작업을 13으로 분리, 작업 6 검증 순서 오류 수정, 유지 목록 파일(emphasis-keep.txt) 도입, 작업 5 표기 정정, 행동 평가 작업 14·15 추가 | Fable 검토 3라운드, 사용자 요청(행동 평가) |
| 2026-11-15 | 행동 평가 설계를 설계 절로 이동·구체화(격리 실행 방식, 시나리오 상한 8, 재측정·재작성 상한, 대조 실행, 비용 승인), 작업 14를 도구 제작으로 한정하고 기준선 실행을 작업 16으로 분리, setup 가드를 show-toplevel 비교로 강화, 작업 13 수동 시도 안전 조건, 맥락·요구사항에 행동 평가 출처 추가 | Fable 검토 4라운드 |
| 2026-11-15 | 대조 실행을 3회로 늘리고 3/3 통과 시나리오를 제외하지 않고 "비판별"로 보존(판별 3개 미만이면 보고), 비용 승인을 작업 14 이전으로 이동하고 횟수 산식 명시, 커밋 비전제(작업 트리 사본)로 변경, 검증 절 문구 통일, 재현 조건(fixture 복사, 모델·CLI 버전 기록) 추가 | Fable 검토 5라운드 |
| 2026-11-15 | worktree의 .git 파일 때문에 실제 저장소 설정이 바뀌는 검증 결함 수정(.git 제외 복사, hooksPath 미변경 확인), 비용 승인 문구를 작업 14로 일원화, 작업 15 검증을 판별 시나리오 기준으로 정정, 승인 횟수를 강제 상한으로 명시 | Fable 검토 6라운드 |
| 2026-11-15 | 사용자가 작업 시작을 지시해 결정 표의 가정을 확정으로 갱신("절대 금지 목록"과 "행동 평가 방식"은 승인 필요 유지). 작업 7·12 완료(`emphasis-inventory.md`, `emphasis-keep.txt`), 작업 1 완료 | 사용자 지시, 작업 수행 |
| 2026-11-15 | `Do not commit unless the user asks`(analysis-report:132)를 이관 후보에서 유지로 변경. 이관 후보는 0건이 되어 작업 3의 승인 대상은 `PERMISSIONS.md`의 ask 항목과 커밋 형식 hook으로 한정 | 사용자 결정(선택지 A) |
| 2026-11-15 | 결정 A(이관 목록)와 B(행동 평가)를 Fable과 2라운드 토론해 합의: deny 5패턴·ask 4항목(`claude-ask` 블록)·`gh pr` 분할·테스트 3종, 2단계 평가·Sonnet 판정+Haiku 보고·시나리오 7개·총 캡 25달러·시스템 프롬프트 주입 고정, 작업 9 검증 명령을 `git rev-parse --git-path hooks`로 교체, 작업 10·13~16 재작성, 범위 밖에 CI 검사 추가 | 사용자 위임, Fable 토론 2라운드 |
| 2026-11-15 | 작업 3 완료: `prohibitions.md` 작성(이관 항목·한계·수동 검증 표), `CONTRIBUTING.md`에 분류 기준 단락 추가. 승인은 사용자 위임과 Fable 합의로 기록 | 작업 수행, 사용자 위임 |
| 2026-11-15 | 작업 8(`tests/commit-msg.test.sh`, 구현 전 실패 확인), 작업 4(`.githooks/commit-msg`, 21건 통과), 작업 9(세 setup에 `enable_commit_hook` 추가·README/CONTRIBUTING 안내) 완료. 구현 중 기존 `core.hooksPath`가 다른 값이면 덮어쓰지 않고 경고하도록 보완하고, 검증 문구(`core.hooksPath` 개수 → 함수 정의 개수)를 구현에 맞게 수정 | 작업 수행 |
| 2026-11-15 | 작업 10(`PERMISSIONS.md`에 `claude-ask` 블록·`gh pr` 분할, `.claude/settings.json`, `tests/permissions.test.sh`)과 작업 13 완료. 수동 검증에서 끝에 오는 `-n`이 막히지 않아 deny 패턴을 5개로 늘림(테스트 먼저). 결합 플래그 `-anm`은 막지 못함을 확인(한계). 이 시험 중 의도치 않은 커밋이 생겨 `git reset --mixed ce89007`로 되돌림 | 작업 수행 |
| 2026-11-15 | 작업 11·6·2 완료(문구 조정 20건, 최종 grep 0줄·`emphasis-keep.txt` 빈 파일과 일치). 작업 14 완료(평가 도구, 격리 확인, 판정기 자체 점검), 작업 16 부분 완료(`evals/baseline.md`). 평가 중 `claude` CLI 설치가 깨져 중단: 작업 16 잔여분, 작업 13의 `-p` 수동 검증 4건, 작업 15는 CLI 복구 후 진행. 판정 규칙 3건을 수정(언어 유입, `구현` 오탐, `$'\n'` 누락)하고 규칙을 고정 | 작업 수행 |
| 2026-11-15 | 작업 16·15 완료: 기준선과 변경 후를 Sonnet 83회·Haiku 91회 실행하고 Sonnet은 `claude-opus-5-5` 블라인드 채점을 최종 판정으로 사용(정규식 불일치 6건을 원문으로 확인해 모두 Opus가 옳음). 회귀 판정 기준에 해당하는 항목은 없으나 판별 시나리오가 2개(계획 최소 3개 미만)라 규칙에 따라 통과가 아니라 보고로 기록. 작업 13의 `-p` 검증 완료(bypassPermissions에서도 ask 유지). 결과는 `evals/baseline.md`, `results.md`, `results-raw.tsv` | 작업 수행 |
| 2026-11-15 | 구현 후 독립 검토(Fable) 반영: ① hook 강제를 조건부로 서술하고 hook이 꺼진 환경을 위해 형식을 따르라는 지시를 복원(CONTRIBUTING, README, AGENTS) ② `enable_commit_hook`이 기존 `.git/hooks`·전역 hooksPath·hook 파일 없음이면 건너뛰고 경고하도록 변경, `tests/setup-hook.test.sh` 추가(RED 확인 후 구현) ③ 소문자 `core.hookspath` 우회를 확인(실측)하고 deny 패턴 추가 ④ 평가 결론의 수위를 낮추고 한계를 보강 ⑤ 문구 중복·사실 서술 정정 | Fable 독립 검토 |
| 2026-11-15 | 독립 검토에서 미뤘던 hook 결함 수정(테스트 5건을 먼저 추가해 RED 확인 후 구현, 29건 통과): `#` 접두 제목 우회, `Merge `·`Revert ` 접두어 우회(git이 만드는 형태로 한정), `amend!` 오탐, 제목 500자 상한. 알려진 우회 목록에서 해당 항목 제거 | 사용자 확인, Fable 독립 검토 |
