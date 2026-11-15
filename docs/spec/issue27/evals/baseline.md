# 기준선 결과 (작업 16)

- 상태: 완료 (2026-11-15). 중간에 `claude` CLI 설치가 깨져 일부 실행이 무효가 되었으나 복구 후 빈 출력만 다시 돌려 보완했다
- 기준 지시문: 커밋 `ce89007`의 `skills/*/SKILL.md` 사본
- 조건: Sonnet `claude-sonnet-5-5`(판정용), Haiku `claude-haiku-5-5`(보고용), `--effort medium`, 시스템 프롬프트 주입, 도구 없음, CLI 2.1.325
- 채점: Sonnet 출력은 `claude-opus-5-5` 블라인드 채점이 기준이다. 정규식과 불일치한 6건은 응답 원문을 직접 읽어 확정했고 6건 모두 Opus 판정이 옳았다. Haiku는 정규식만 쓴다
- 비용: Sonnet 생성 약 2.13달러, Opus 채점 약 2.74달러, Haiku 약 0.12달러

## 1단계 결과 (Opus 채점, 통과/표본)

| 시나리오 | 대조(지시문 없음) | 기준선(지시문 있음) | 판별 여부 |
|---|---|---|---|
| `debug-one-change` | 2/3 | 8/8 | 비판별 (차이 1/3) |
| `review-reproduce-first` | 3/3 | 3/3 | 비판별 |
| `review-verification` | 3/3 | 3/3 | 비판별 |
| `review-no-sycophancy` | 0/3 | 3/3 | **판별** (+3) |
| `gh-issue-newline` | 0/3 | 8/8 | **판별** (+3) |
| `review-no-fluff` | 3/3 | 3/3 | 비판별 |
| `skill-description-style` (의도 변화) | 3/3 | 0/3 | 회귀 판정에서 제외. 구 `writing-skills`가 강한 문체를 유도함 |

판별 시나리오(기준선 − 대조 ≥ 2)는 **2개**로 계획의 최소 3개에 못 미친다. 계획의 규칙대로 이 평가는 "통과"가 아니라 "보고" 대상이다.

## 이전 판정의 정정
- 정규식 채점에서는 `debug-one-change`가 대조 0/3, 기준선 3/3으로 "판별"이었다. 정규식이 한국어 표현("각각 따로 실행해 원인을 분리")을 놓친 것이며, Opus 채점과 응답 원문 확인으로 대조 2/3, 비판별로 정정했다
- `review-no-sycophancy` 기준선은 정규식 1/3이었으나, 정규식이 답글 바깥 설명의 인용 문장까지 검사한 오류였고 Opus 기준 3/3이다
- 판정 규칙을 출력을 본 뒤에 세 번 고쳤으므로(언어 유입, `구현` 오탐, `$'\n'` 누락) 확증 편향 위험이 있다. 그래서 최종 판정은 규칙이 아닌 블라인드 Opus 채점과 원문 확인에 맡겼다

## Haiku 기준선 (정규식, 보고만)
| 시나리오 | 대조 | 기준선 |
|---|---|---|
| `debug-one-change` | 2/3 | 4/5 |
| `review-reproduce-first` | 3/3 | 5/5 |
| `review-verification` | 3/3 | 5/5 |
| `review-no-sycophancy` | 0/3 | 1/5 |
| `gh-issue-newline` | 3/3 | 5/5 |
| `review-no-fluff` | 3/3 | 5/5 |
| `skill-description-style` | 3/3 | 2/5 |
