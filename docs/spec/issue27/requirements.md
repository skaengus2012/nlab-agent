# 요구사항 분석: [Task] Review harness for model advancements, including emphasis expressions (#27)

- 이슈: https://github.com/skaengus2012/nlab-agent/issues/27
- 상위 이슈: 없음
- 라벨: skills, configuration
- 생성일: 2026-11-15
- 최종 갱신일: 2026-11-15
- 분석 기준점: 2026-11-15T02:37:35Z

## 배경 및 문제
모델이 발전함에 따라, 기존 하네스(skills, 프로토콜, 지시문)가 여전히 적절한지 검토할 필요가 있다. 특히 강조 표현(전부 대문자, "MUST", "NEVER", 경고 스타일 문구 등)은 이전 세대 모델을 위해 작성되었을 수 있으므로 재평가가 필요하다.

## 목표
- 하네스 전반의 강조 표현을 재평가하고, 불필요해진 것은 조정한다.
- "절대 하면 안 된다"류의 절대 금지 사항은 지시문의 강조 문구가 아니라 hook 등의 메커니즘으로 강제한다.

## 범위
### 포함
- 하네스 전반(skills, 프로토콜, 지시문)의 강조 표현 재평가 및 조정
- 절대 금지 사항의 hook 등 강제 메커니즘 이관

### 제외
- 커밋 메시지 형식을 git hook으로 강제하는 것: 사용자 결정으로 채택하지 않았다. 커밋 형식은 `CONTRIBUTING.md`의 지시문으로 두고 에이전트가 지킨다.

## 기능 요구사항
| ID | 요구사항 | 출처 |
|----|----------|------|
| FR-1 | 하네스 전반의 강조 표현(전부 대문자, "MUST", "NEVER", 경고 스타일 문구 등)을 재평가한다. | 본문 (Needs) |
| FR-2 | 재평가 결과 더 이상 필요하지 않은 강조 표현은 조정한다. | 본문 (Needs) |
| FR-3 | 절대 금지 사항("must never do")은 강조 문구에 의존하지 않고 hook 등의 메커니즘으로 강제한다. | 본문 (Needs) |
| FR-4 | 강제 수단은 각 플랫폼 setup이 `PERMISSIONS.md`의 블록(`auto-allow`, `prompt-required`)을 해당 플랫폼의 사용자 수준 권한 설정으로 변환해 적용하는 방식으로 제공한다. 대상은 Antigravity(기존), Claude Code, Codex이며, 이 저장소를 setup으로 가져다 쓰는 모든 프로젝트에 적용된다. | 사용자 요청 (PR #28 리뷰 논의, 2026-11-15) |
| FR-5 | `prompt-required`는 원격 저장소나 그 설정을 실제로 바꾸는 명령(`git push`, `gh repo create`, `gh repo delete`, `gh pr merge`)으로 한정한다. 원격을 바꾸지 않는 `git fetch`, `git pull`, `git clone`, `git remote`는 `auto-allow`로 옮긴다. | 사용자 요청 (PR #28 리뷰 논의, 2026-11-15) |

## 비기능 요구사항
| ID | 요구사항 | 출처 |
|----|----------|------|
| - | 명시된 비기능 요구사항 없음 | - |

## 인수 조건
- [ ] 하네스 전반의 강조 표현이 재평가되었다 (FR-1).
- [ ] 불필요하다고 판단된 강조 표현이 조정되었다 (FR-2).
- [ ] 절대 금지 사항이 hook 등의 메커니즘으로 강제되며, 지시문의 강조 문구에만 의존하지 않는다 (FR-3).
- [ ] Claude Code와 Codex의 setup이 `PERMISSIONS.md`를 읽어 각자의 사용자 수준 설정에 적용하고, 재실행해도 기존 설정을 잃지 않는다 (FR-4).
- [ ] `prompt-required`가 원격을 바꾸는 4개 명령뿐이고, 나머지 4개 명령이 `auto-allow`에 있다 (FR-5).

## 영향 범위
코드베이스에서 확인한 내용이다.

- 대문자 강조 표현(`MUST`, `NEVER`, `STOP` 등)은 소수만 존재한다.
  - `README.md:11` — "(MUST follow)"
  - `skills/receiving-code-review/SKILL.md:70` — "**NEVER** use performative agreement ..."
  - `skills/writing-skills/SKILL.md:39` — "Red Flags - STOP and Start Over"
- 소문자를 포함한 금지/의무 표현(`never`, `must`, `always`, `do not`, `don't`)은 다음 파일에 분포한다.
  - `skills/create-gh-issue-analysis-report/SKILL.md` (13건), `skills/create-plans/SKILL.md` (12건), `AGENTS.md` (6건), `skills/create-gh-issue/SKILL.md` (5건), `skills/writing-skills/SKILL.md` (4건)
  - 그 외 `CONTRIBUTING.md`, `README.md`, `PERMISSIONS.md`, `brainstorming`, `requesting-code-review`, `receiving-code-review`, `systematic-debugging`, `skillify`
- 여러 skill에 `Red Flags` 섹션이 있다: `systematic-debugging`, `create-plans`, `writing-skills`, `create-gh-issue`, `verification-before-completion`, `create-gh-issue-analysis-report`.
- 저장소에 hook 관련 설정이나 문서는 현재 없다. `platforms/`에는 플랫폼별 `setup.sh`, `link_skills.sh`가 있고, 기준 상태에서는 antigravity에만 `configure_permissions.py`가 있었다(PR #28 리뷰 반영으로 `platforms/lib/permissions.py`에 합쳐 삭제).
- `PERMISSIONS.md`는 명령어 권한 허용 목록을 정의하며, 플랫폼 setup 스크립트가 이를 파싱한다.

## 미결 사항
- `auto-allow`에는 `git config`, `gh api`, `git reset`, `git clean`처럼 범위가 넓거나 되돌리기 어려운 항목이 있다. 이 목록을 Claude Code와 Codex의 사용자 수준 설정으로 퍼뜨려도 되는지 검토가 필요하다. 특히 Codex에서 `allow`는 "샌드박스 밖에서 프롬프트 없이 실행"을 뜻한다.

## 충돌 및 참고
- 댓글과 상위 이슈가 없어 본문과 충돌하는 내용은 없다.
- FR-4와 FR-5는 이슈 본문이나 댓글이 아니라 PR #28 리뷰 논의에서 사용자가 요청한 내용이다. FR-3의 "hook 등"을 이 저장소의 구조(다른 프로젝트가 setup으로 설정을 가져다 쓰는 원본)에 맞게 해석한 결과이며, 그 근거는 변경 이력에 있다.
- FR-3의 강제 수단으로 git hook은 채택하지 않았다. 저장소 안의 hook이나 `.claude/settings.json`은 이 저장소에서 작업할 때만 적용되어 setup으로 설정을 가져다 쓰는 프로젝트를 보호하지 못하고, 커밋 형식은 이 저장소 고유의 규칙이기 때문이다.

---

## 변경 이력
| 날짜 | 변경 내용 | 출처 |
|------|-----------|------|
| 2026-11-15 | 최초 작성 | 본문 |
| 2026-11-15 | 범위 확정: 이 저장소가 다른 프로젝트에 설정을 배포하는 원본이라는 점을 반영해 FR-4(setup이 `PERMISSIONS.md`를 Claude Code·Codex 사용자 수준 설정으로 적용), FR-5(`prompt-required` 한정과 `git fetch`·`pull`·`clone`·`remote`의 `auto-allow` 이동)를 추가하고 인수 조건을 보강. 미결 사항 중 다음을 결정하고 목록에서 제거: 검토 범위(`AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `PERMISSIONS.md`, `skills/`, `platforms/`), 불필요한 강조의 판단 기준(대문자·절대 표현만 대상이 아니라 `Red Flags` 등 경고 문구도 전수 판정, `emphasis-inventory.md`), 조정 방식(이유를 설명하는 문장으로 교체), 절대 금지 목록(`prompt-required` 4개), hook 대상 플랫폼과 위치(git hook 미채택, setup이 배포하는 권한 규칙으로 대체), 서술형 규칙의 처리(지시문에 이유를 적음), 산출물 범위(문구 조정과 권한 배포 구현, 행동 평가 포함). 새 미결 사항으로 `auto-allow` 범위 검토를 추가 | 사용자 요청 |
| 2026-11-15 | PR #28 리뷰 반영: Antigravity도 Claude Code·Codex와 같은 `platforms/lib/permissions.py`·`apply_permissions`를 쓰도록 하고 `configure_permissions.py`를 삭제. 영향 서술(Impact)만 고쳤고 요구사항은 바뀌지 않음 | 리뷰 코멘트 |
