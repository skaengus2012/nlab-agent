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
- 이슈에 명시된 제외 범위 없음 (미결 사항 참고)

## 기능 요구사항
| ID | 요구사항 | 출처 |
|----|----------|------|
| FR-1 | 하네스 전반의 강조 표현(전부 대문자, "MUST", "NEVER", 경고 스타일 문구 등)을 재평가한다. | 본문 (Needs) |
| FR-2 | 재평가 결과 더 이상 필요하지 않은 강조 표현은 조정한다. | 본문 (Needs) |
| FR-3 | 절대 금지 사항("must never do")은 강조 문구에 의존하지 않고 hook 등의 메커니즘으로 강제한다. | 본문 (Needs) |

## 비기능 요구사항
| ID | 요구사항 | 출처 |
|----|----------|------|
| - | 명시된 비기능 요구사항 없음 | - |

## 인수 조건
- [ ] 하네스 전반의 강조 표현이 재평가되었다 (FR-1).
- [ ] 불필요하다고 판단된 강조 표현이 조정되었다 (FR-2).
- [ ] 절대 금지 사항이 hook 등의 메커니즘으로 강제되며, 지시문의 강조 문구에만 의존하지 않는다 (FR-3).

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
- 저장소에 hook 관련 설정이나 문서는 현재 없다. `platforms/`에는 플랫폼별 `setup.sh`, `link_skills.sh`와 antigravity의 `configure_permissions.py`가 있다.
- `PERMISSIONS.md`는 명령어 권한 허용 목록을 정의하며, 플랫폼 setup 스크립트가 이를 파싱한다.

## 미결 사항
- 검토 대상 "하네스"의 범위: `skills/`, `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `PERMISSIONS.md`, `platforms/` 중 어디까지 포함하는가?
- "불필요한 강조"를 판단하는 기준은 무엇인가? 대문자 표현만 대상인가, 소문자 금지 표현("never", "do not")과 `Red Flags` 섹션까지 포함하는가?
- 조정 방식: 강조를 제거하고 이유를 설명하는 문장으로 바꿀 것인가, 단순히 톤만 낮출 것인가?
- "절대 금지 사항"의 목록은 무엇인가? 후보로는 `receiving-code-review`의 NEVER 항목, `verification-before-completion`의 "검증 없이 완료 주장 금지" 등이 있다.
- hook 적용 대상 플랫폼: Claude Code만인가, Antigravity와 Codex도 포함하는가? 플랫폼별 hook 지원 여부가 다르다.
- hook 설정을 저장소에 둘 위치와, `platforms/*/setup.sh`가 이를 배포할지 여부.
- hook으로 강제하기 어려운 항목(예: 말투 금지 같은 서술형 규칙)은 어떻게 처리할 것인가?
- 이 이슈의 산출물 범위: 재평가 결과 문서만 만들 것인가, 실제 수정과 hook 구현까지 포함하는가?

## 충돌 및 참고
- 댓글과 상위 이슈가 없어 본문과 충돌하는 내용은 없다.
- 이슈 본문이 간결하여 구체적 범위와 판단 기준은 위 미결 사항에서 결정이 필요하다.

---

## 변경 이력
| 날짜 | 변경 내용 | 출처 |
|------|-----------|------|
| 2026-11-15 | 최초 작성 | 본문 |
