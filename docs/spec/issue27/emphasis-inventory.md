# 강조 표현 전수 목록 (#27)

- 작성일: 2026-11-15
- 대상: 문서 4개(`AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `PERMISSIONS.md`)와 `skills/*/SKILL.md` 11개 (작업 7, 12)
- 조사 방법: 11개 skill과 문서 4개를 전문 읽기. 패턴 grep(검증 절)과 소문자 절대·금지·의무 표현 grep(56줄)을 함께 사용
- 판정: 유지 / 조정(문구를 이유 중심으로 변경) / 이관(hook·deny·ask로 강제하고 문구 정리는 작업 6)
- 줄 번호는 작성 시점 기준이며, 대조 키는 파일과 원문이다.

## 1. 검증 절 패턴에 걸리는 줄 (12줄)

| 파일:줄 | 표현 원문 | 판정 | 강제 수단 | 사유 |
|---|---|---|---|---|
| `CONTRIBUTING.md:7` | `must follow this strict format` | 이관 | hook (`commit-msg`) | 형식 위반은 hook이 차단하므로 `strict`는 불필요. 작업 6에서 문구 정리 |
| `README.md:11` | `(MUST follow)` | 이관 | hook (`commit-msg`) | 같은 규칙의 안내 문구. 이유와 안내만 남김 (작업 6) |
| `skills/systematic-debugging/SKILL.md:14` | `and WHY.` | 조정 | 지시문 | 대문자 제거. 이유를 말하라는 의도는 평서문으로 충분 |
| `skills/systematic-debugging/SKILL.md:15` | `Change ONE thing` | 조정 | 지시문 | "한 번에 하나만 바꿔야 결과를 변경과 연결할 수 있다"는 이유 문장으로 |
| `skills/receiving-code-review/SKILL.md:16` | `**Mandatory**: ... reproduce it first` | 조정 | 지시문 | 버그는 재현을 먼저 한다는 평서문과 이유로 |
| `skills/receiving-code-review/SKILL.md:23` | `**Mandatory**: Run the verification-before-completion skill` | 조정 | 지시문 | 단계 안에 이미 있는 절차이므로 평서문으로 |
| `skills/receiving-code-review/SKILL.md:70` | `**NEVER** use performative agreement` | 조정 | 지시문 | 이유 없는 말투 금지. 맞장구는 검토자에게 정보가 없다는 이유로 바꿈 |
| `skills/receiving-code-review/SKILL.md:71` | `**INSTEAD**: Just state ...` | 조정 | 지시문 | 70줄과 한 문장으로 합침 |
| `skills/receiving-code-review/SKILL.md:79` | `Clarify anything unclear FIRST.` | 조정 | 지시문 | 번호 순서가 이미 우선순위를 나타냄 |
| `skills/create-gh-issue/SKILL.md:31` | `Do NOT use \n literal strings` | 조정 | 지시문 | 대문자 제거. 이유(가독성)는 이미 같은 줄과 Red Flags에 있음 |
| `skills/writing-skills/SKILL.md:12` | `must strictly adhere` | 조정 | 지시문 | `strictly` 제거 |
| `skills/writing-skills/SKILL.md:39` | `## Red Flags - STOP and Start Over` | 조정 | 지시문 | 제목에서 `STOP and Start Over` 제거 (작업 11) |

## 2. 소문자 절대·금지·의무 표현 (패턴 밖, 행으로 싣는 것)

| 파일:줄 | 표현 원문 | 판정 | 강제 수단 | 사유 |
|---|---|---|---|---|
| `AGENTS.md:7` | `Never claim completion without running verification` | 유지 | 지시문 | 완료 주장의 진위는 hook이 판정할 수 없음. 근거 skill 명시됨 |
| `AGENTS.md:34` | `**Always check the skills/ directory ...**` | 조정 | 지시문 | 굵게와 Always 제거. 목록이 낡을 수 있다는 이유를 적음 |
| `AGENTS.md:17` | `Always browse it to discover the latest tools` | 유지 | 지시문 | 같은 줄에 이유(원천)가 있음 |
| `CONTRIBUTING.md:28` | `Always check this file before performing any Git operations` | 이관 | hook (`commit-msg`) | hook이 강제하므로 지시문은 이유 중심으로 정리 (작업 6) |
| `README.md:76` | `All commits must follow the repository convention` | 이관 | hook (`commit-msg`) | 위와 같음 (작업 6) |
| `PERMISSIONS.md:45` | `(Must Ask Every Time)` | 이관 | ask (`permissions.ask`) | 강제 수단이 없는 현재 상태. 작업 10 |
| `PERMISSIONS.md:47` | `the agent **must** ask for user approval` | 이관 | ask (`permissions.ask`) | 위와 같음. 작업 10 |
| `skills/create-gh-issue-analysis-report/SKILL.md:132` | `Do not commit unless the user asks.` | 유지 | 지시문 | 이 skill의 보고 단계에 한정된 지시이고 hook은 사용자 요청 여부를 판정할 수 없음. `receiving-code-review`의 코멘트별 커밋 지시와도 충돌하지 않도록 이관하지 않음 (사용자 결정, 선택지 A) |
| `skills/test-driven-development/SKILL.md:14-16` | `You are not allowed to write ...` (3줄) | 유지 | 지시문 | TDD 규율 자체가 규칙의 정의. hook으로 판정 불가 |
| `skills/requesting-code-review/SKILL.md:35` | `Avoid generic praise or "fluff."` | 조정 | 지시문 | 이유 없는 말투 금지. 원하는 형태(기술 사항 중심)로 서술 |
| `skills/systematic-debugging/SKILL.md:9` | `**Do not change code until you have a hypothesis ...**` | 유지 | 지시문 | 핵심 원칙이며 이유(검증 가능성)가 문장 안에 있음 |
| `skills/create-plans/SKILL.md` (Never/Do not 5줄, Red Flags 중복) | `Never append ...`, `Do not delete a dropped task ...` 등 | 유지 | 지시문 | 이유("현재 상태를 나타낸다")가 앞 문장에 있고 Red Flags의 반복은 작동하는 중복 |
| `skills/create-gh-issue-analysis-report/SKILL.md` (Never/Do not 8줄) | `Never rewrite past rows` 등 | 유지 | 지시문 | 위와 같음 |
| `skills/create-gh-issue/SKILL.md:9` | `**All content ... must be written in English.**` | 유지 | 지시문 | 저장소 정책 제약 |
| `skills/create-gh-issue/SKILL.md:32` | `Always assign at least one relevant label` | 유지 | 지시문 | 정책 제약. 존재 확인 절차가 함께 있음 |
| `skills/receiving-code-review/SKILL.md:12,86` | `Do not start implementing immediately`, `Always handle unresolved comments` | 유지 | 지시문 | 작업 순서 규칙. 핵심 원칙과 맞물림 |
| `skills/requesting-code-review/SKILL.md:34` | `Always attach comments to specific code lines` | 유지 | 지시문 | 도구 계약에 가까움 |
| `skills/brainstorming/SKILL.md:16` | `Do not ask the user to evaluate ideas while still in the divergence phase` | 유지 | 지시문 | 단계 정의의 일부 |
| `skills/writing-skills/SKILL.md:22` | `add explicit counters (e.g., "No exceptions: ...")` | 조정 | 지시문 | 우회마다 금지 문구를 쌓는 지침. 최소 문구와 이유 중심으로 (작업 11) |
| `skills/writing-skills/SKILL.md:26` | `Use a **Pushy Description**` | 조정 | 지시문 | 강한 트리거 문체를 권장하는 지침 자체. 과잉 트리거를 유도 (작업 11) |
| `skills/writing-skills/SKILL.md:33` | `Must include name and description (with pushy trigger words)` | 조정 | 지시문 | 위와 같음 (작업 11) |
| `skills/*/SKILL.md` frontmatter `description` (brainstorming, create-gh-issue, create-gh-issue-analysis-report, create-plans, skillify) | `Make sure to trigger this skill whenever ...` | 유지 | 지시문 | 트리거 문구는 라우팅용이라 보정된 강도가 허용됨. 트리거 평가가 없어 변경하지 않음 (평가 범위 밖) |
| `skills/*/SKILL.md` 평서형 `must` (create-plans, requesting-code-review, writing-skills 등) | `A plan must contain`, `must adhere ...` | 유지 | 지시문 | 평서형 정의. 파일별 요약 처리 |
| `AGENTS.md:6,14,15` | `must begin`, `must follow`, `must be` | 유지 | 지시문 | 평서형 정의 |

## 3. 범위 밖이지만 발견한 것 (별도 이슈 후보)
- `AGENTS.md:21-24`: `.nlab/state`, `.nlab/memory`는 저장소 어디에서도 쓰이지 않음. `.nlab/plans`는 작업 1에서 제거
- `AGENTS.md:36-47`: 스킬 목록에 `create-gh-issue-analysis-report` 누락
- `skills/requesting-code-review/SKILL.md:36`: `view_file`은 특정 플랫폼 도구 이름
- `skills/writing-skills/SKILL.md:3,51`, `skills/skillify/SKILL.md:3`: Antigravity 전용 표현

## 4. 요약

| 판정 | 행 수 |
|---|---|
| 조정 | 15 (1절 10 + 2절 5) |
| 이관 | 6 (1절 2 + 2절 4, 작업 6·10) |
| 유지 | 16 (평서형 요약 포함) |

## 5. 행동 평가 근거 (`evals/results.md`, Sonnet, Opus 블라인드 채점)

조건: `claude-sonnet-5-5`, `--effort medium`, 시스템 프롬프트 주입. 표본이 작은 휴리스틱이다.

| 조정한 표현 | 시나리오 | 대조 | 기준선 | 변경 후 | 해석 |
|---|---|---|---|---|---|
| `ONE`, `WHY` (`systematic-debugging`) | `debug-one-change` | 2/3 | 8/8 | 8/8 | 지시문 없이도 대부분 지킴. 강조를 풀어도 위험이 낮음 |
| `Mandatory` (`receiving-code-review:16`) | `review-reproduce-first` | 3/3 | 3/3 | 3/3 | 지시문 없이도 지킴 |
| `Mandatory` (`receiving-code-review:23`) | `review-verification` | 3/3 | 3/3 | 3/3 | 지시문 없이도 지킴 |
| `NEVER`, `INSTEAD` (`receiving-code-review:70,71`) | `review-no-sycophancy` | 0/3 | 3/3 | 3/3 | 지시문이 일을 함. 이유 문장으로 바꿔도 유지됨 |
| `Do NOT` (`create-gh-issue:31`) | `gh-issue-newline` | 0/3 | 8/8 | 8/8 | 지시문이 일을 함. 이유 문장으로 바꿔도 유지됨 |
| `Avoid generic praise` (`requesting-code-review:35`) | `review-no-fluff` | 3/3 | 3/3 | 3/3 | 지시문 없이도 지킴 |
| `Pushy Description` 등 (`writing-skills`) | `skill-description-style` | 3/3 | 0/3 | 3/3 | 의도한 변화. 구 지침은 강한 문체를 유도했고 조정 후 사라짐 |

`FIRST`, `strictly`, `STOP`, 문서 4개의 표현은 평가 대상이 아니다.
