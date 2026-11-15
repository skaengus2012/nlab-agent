# 변경 후 재측정 결과 (작업 15)

- 변경 후 지시문: 문구 조정 20곳(skills 13곳, 문서 7곳. 전수 목록으로는 21행인데 `NEVER`와 `INSTEAD`를 한 문장으로 합쳤기 때문)을 반영한 현재 `skills/` (작업 2, 6, 11)
- 조건과 채점은 `baseline.md`와 같다. 채점은 `claude-opus-5-5` 블라인드 채점이다

## 평가 대상과 재측정 (2026-11-15, PR #28 리뷰 반영)
- 평가 입력은 `skills/`의 SKILL.md 5개(`systematic-debugging`, `receiving-code-review`, `create-gh-issue`, `requesting-code-review`, `writing-skills`)뿐이다. `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `PERMISSIONS.md`는 입력이 아니므로 이 문서들이 이후 크게 바뀐 것은 이 평가의 유효성과 무관하다(그 문서들의 조정은 평가하지 않았다).
- 아래 표의 "변경 후" 실행은 커밋 `764c824` 시점의 SKILL.md로 했다. 이후 `de4b638`이 `requesting-code-review`(한 문장 추가)와 `writing-skills`(트리거 설명 한 줄)를 바꿨다. 그래서 해당 두 시나리오(`review-no-fluff`, `skill-description-style`)를 현재 문구로 Sonnet 3회씩 다시 실행하고 같은 Opus 블라인드 채점을 적용했다: 둘 다 **3/3**으로 기존과 같고 정규식 판정도 일치한다(`results-raw.tsv`의 `after-head` 행, 비용 약 0.14달러+채점 0.18달러). 나머지 5개 시나리오의 SKILL.md는 `764c824` 이후 바뀌지 않았다.
- 이 재측정은 위 표를 바꾸지 않고, 표가 현재 문구에 대해서도 성립함을 확인한 것이다. 두 시나리오 모두 표본 3회이며 `review-no-fluff`는 비판별이므로 "회귀가 관측되지 않았다"는 같은 약한 근거다.
- 앞으로 SKILL.md를 바꾸면 해당 skill의 시나리오(`scenarios.json`의 `skill` 필드)를 다시 실행해야 이 표가 유지된다.

## 비교 (Sonnet, Opus 채점, 통과/표본)

| 시나리오 | 대조 | 기준선 | 변경 후 | 판정 |
|---|---|---|---|---|
| `debug-one-change` | 2/3 | 8/8 | 8/8 | 회귀 없음. 비판별 |
| `review-reproduce-first` | 3/3 | 3/3 | 3/3 | 회귀 없음. 비판별 |
| `review-verification` | 3/3 | 3/3 | 3/3 | 회귀 없음. 비판별 |
| `review-no-sycophancy` | 0/3 | 3/3 | 3/3 | **회귀 없음. 판별** |
| `gh-issue-newline` | 0/3 | 8/8 | 8/8 | **회귀 없음. 판별** |
| `review-no-fluff` | 3/3 | 3/3 | 3/3 | 회귀 없음. 비판별 |
| `skill-description-style` (의도 변화) | 3/3 | 0/3 | 3/3 | **의도한 변화 확인.** 구 지침은 강한 문체를 유도했고 조정 후 사라짐 |

## 결론
- 회귀 판정 기준(판별 시나리오에서 변경 후가 기준선보다 2회 이상 낮음)에 해당하는 항목은 **없다**
- 단 판별 시나리오가 2개뿐이라 계획의 최소 3개에 못 미친다. 규칙에 따라 이 평가는 통과가 아니라 **보고**로 남긴다. 확인된 것은 "회귀가 관측되지 않았다"이지 "문제없다"가 아니다
- 비판별 4개(`debug-one-change`, `review-reproduce-first`, `review-verification`, `review-no-fluff`)는 대조(해당 skill 없음)에서도 통과가 관측된 행동이다. 표본이 3회라 해당 강조(`ONE`, `Mandatory`)를 푸는 것이 안전하다는 근거라기보다 위험이 낮을 수 있다는 약한 신호로만 읽는다. 인용 범위는 "`claude-sonnet-5-5`, `--effort medium`, 시스템 프롬프트 주입 조건"에 한정한다
- `review-no-sycophancy`, `gh-issue-newline`은 지시문이 실제로 일을 하는 항목이다. 강조(`NEVER`, `Do NOT`)를 이유 문장으로 바꿔도 행동이 유지되었다

## 한계
- 대조는 "지시문 없음"이 아니라 "해당 skill 없음"이다. 전역 `~/.claude/CLAUDE.md`(응답 언어 등)가 모든 조건에 함께 유입되었다
- 회귀 검출은 통계적 유의성이 아니라 휴리스틱이다. 판별 시나리오가 2개이고 표본이 3~8회다
- 시스템 프롬프트 주입으로 전후가 모두 전부 통과하는 천장에 붙으면 회귀를 과소 검출할 수 있다. 판별 시나리오 2개의 변경 후가 모두 천장(3/3, 8/8)이다
- 정규식은 세 번 수정했고, 최종 판정은 Opus 채점에 의존한다. Opus 채점 자체의 신뢰도는 정규식 불일치 6건을 직접 확인한 범위에서만 검증했다
- `description` 트리거와 도구를 쓰는 다단계 행동은 평가하지 않았다. 문서 4개의 조정 항목은 평가 대상이 아니다
- Fable은 한도와 비용 때문에 돌리지 않았다. 가장 최신 모델에서도 같다는 직접 증거는 없다
