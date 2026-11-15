# 계획: [Feature] Skip duplicate review comments in code review skill (evaluate two-stage check) (#29)

- 이슈: https://github.com/skaengus2012/nlab-agent/issues/29
- 요구사항: docs/spec/issue29/requirements.md
- 생성일: 2026-11-16
- 최종 갱신일: 2026-11-16

## 맥락/목표
`requesting-code-review` 스킬의 리뷰어 지침은 코멘트 초안이 같은 PR의 기존 리뷰 코멘트와 중복되는지 확인하지 않는다. 게시 직전에 기존 코멘트와 비교해 중복 초안을 보류하고 사용자에게 알리도록 지침을 보강한다. 검사 시점(검증 단계 vs 게시 직전)의 결정 근거는 별도 문서로 남긴다.

## 요구사항
- FR-1: 유사한 초안은 게시하지 않고 보류한다.
- FR-2/FR-3: 검사 시점 두 곳을 평가하고, 필요 여부를 결정해 근거를 `docs/spec/issue29/` 아래 문서로 남긴다.
- FR-4: "유사"의 기준을 정의한다.
- 범위: `requesting-code-review`만, 비교 대상은 같은 PR의 이전 리뷰 코멘트, 보류 시 사용자에게 보류 사실과 사유를 알린다. (`requirements.md` 참고)

## 아키텍처/설계
1. **검사 시점**: GitHub 게시 직전 1회만 검사한다 (사용자 결정). 근거: 기존 코멘트 조회 결과가 가장 최신이고, 검토 중 새로 달린 코멘트도 잡으며, 로직이 한 곳에 모인다. 검증 단계 검사는 초안 검증 비용을 아끼는 이점뿐이라 추가하지 않는다. 대신 검증 단계에서 검사하면 게시 전에 새로 달린 코멘트를 놓친다.
2. **유사 판정 기준** (Opus 논의 결과): "같은 코드에 대한 같은 문제 지적인가"를 기준으로 한다. 같은 파일/라인 범위는 후보를 찾는 단서일 뿐이며, 라인은 커밋 사이에 이동하므로 라인 번호만으로 판정하지 않는다.

   | 경계 사례 | 결정 |
   |---|---|
   | 후속 커밋으로 라인이 이동·outdated | 문제가 같으면 중복, 보류 |
   | 같은 라인, 다른 문제 | 중복 아님, 게시 |
   | 같은 문제, 다른 위치 | 중복 아님, 게시 (위치마다 따로 고쳐야 하므로) |
   | resolved 스레드 | 기존 코멘트로 보고 중복이면 보류 |
   | 기존 코멘트 작성자가 본인/타인 | 구분하지 않음 |

3. **조회 방식**: resolved 여부를 보고해야 하므로(사용자 결정) `gh api graphql`로 `reviewThreads`를 조회한다. 스레드마다 `isResolved`, `isOutdated`, 코멘트 본문과 위치(`path`, `line`, `originalLine`)를 가져온다. REST `pulls/{n}/comments`는 resolved 여부를 주지 않는다. 스레드 수가 한 페이지(100)를 넘을 수 있으므로 `pageInfo`로 끝까지 읽는다.
4. **보류 보고**: 보류한 초안마다 어느 기존 코멘트와 일치했는지, 이유를 사용자에게 알린다. 일치한 스레드가 resolved이거나 outdated인데 문제가 현재 코드에 남아 있으면 그 사실도 알린다.
5. **기존 스레드 답글 (적절성 검토 결과)**: 자동 게시는 하지 않고 제안만 한다. 초안이 기존 지적과 같은 문제이면서 새 정보(재현 경로, 수정안)를 더하는 경우, 보류 보고에 "기존 스레드에 답글로 달 수 있음"과 답글 문안을 함께 제시하고 사용자가 승인하면 게시한다. 이유는 다음과 같다.
   - 답글 API(`POST pulls/{n}/comments/{id}/replies`)는 리뷰와 별개로 즉시 게시되며 대기 중인 리뷰에 묶이지 않는다. 게시 전 사용자 확인 없이는 한 리뷰 안에서 일관되게 검토할 수 없다.
   - 답글은 최상위 코멘트에만 달 수 있고, resolved 스레드에 달아도 resolved 상태는 유지되며 참여자에게 알림이 간다. 다시 여는 효과가 있어 사용자 판단이 필요하다.
   - "새 정보가 있는가"는 주관적 판단이라 자동화하면 중복 억제 목적이 약해진다.
6. **지침 문안**: `SKILL.md` Reviewer Guidelines에 4번 항목으로 추가한다. 기존 문서가 영어이므로 영어로, 강조 표현 없이 짧게 쓴다.

   ```markdown
   4. **Skip Duplicates**: Right before posting, fetch this PR's existing review threads, including outdated and resolved ones, and compare each draft against them. A draft is a duplicate when an existing comment already raises the same problem in the same code. Judge by the code and the problem, not by line numbers alone, since lines shift between commits. Who wrote the existing comment does not matter.
      - A different problem on the same line, or the same problem at a different location, is not a duplicate.
      - Hold duplicates instead of posting them, and tell the user which drafts were held, which existing comment each one matched, and why. If the matched thread is resolved or outdated but the problem is still in the current code, say so.
   - If a held draft adds new information (a repro path or a fix), offer it as a reply to the existing thread and post it only after the user agrees.
   ```

## 작업
1. 수동 확인용 시나리오와 통과 조건을 `docs/spec/issue29/scenarios.md`에 작성한다.
   - 시나리오 A: 후속 커밋으로 라인이 바뀐 PR에서 같은 지적을 다시 리뷰한다. 보류되어야 한다.
   - 시나리오 B: 같은 라인에 다른 문제를 지적한다. 게시되어야 한다.
   - 시나리오 C: resolved 스레드와 같은 문제이면서 수정안을 더한 초안이다. 보류되고, resolved 여부와 답글 제안이 보고되며, 승인 전에는 답글이 게시되지 않아야 한다.
   - **Verify**: 파일에 시나리오 3개와 각각의 통과 조건(보류/게시, 사용자 보고 포함 여부)이 있다.
2. 변경 전 스킬로 시나리오 A를 수동 실행해 중복이 게시 대상에 남는지 확인하고 결과를 `scenarios.md`에 기록한다 (Red).
   - **Verify**: `scenarios.md`에 변경 전 결과(통과/실패)가 기록되어 있다. A가 이미 통과하면 시나리오를 수정한다.
3. `skills/requesting-code-review/SKILL.md` Reviewer Guidelines에 설계 5의 4번 항목을 추가한다.
   - **Verify**: `grep -n "Skip Duplicates" skills/requesting-code-review/SKILL.md` 가 1줄을 반환하고, 항목 번호가 1~4로 이어진다.
4. 변경 후 스킬로 시나리오 A, B, C를 수동 실행하고 결과를 기록한다 (Green).
   - **Verify**: A는 보류되어 사용자 보고(일치한 기존 코멘트, 이유)가 있고, B는 게시 대상이고, C는 보류되어 resolved 여부와 답글 제안이 보고되며 승인 전에는 답글이 게시되지 않는다. 결과가 `scenarios.md`에 기록되어 있다.
5. 검사 시점 결정 근거를 `docs/spec/issue29/checkpoint-rationale.md`에 작성한다 (두 시점 비교, 게시 직전 1회를 택한 이유, 포기한 이점).
   - **Verify**: 파일에 두 시점 각각의 장단점과 결정, 근거가 있다.
6. 최종 점검: `requirements.md`의 인수 기준 3개를 대조해 모두 충족됨을 확인하고, 체크박스를 갱신한다.
   - **Verify**: 인수 기준 3개 각각이 어느 산출물로 충족되는지 목록이 있고, `git diff --stat` 이 계획한 파일만 포함한다.

## 검증
- 스킬 지침 변경이므로 시나리오를 수동으로 확인한다. A/B 통과가 핵심이며 "위치만으로 판정하지 않는다"를 양방향으로 확인한다. 사용자가 정한 1~2개에서 답글 제안 검토 결과를 확인하는 C를 하나 더했다.
- `grep`으로 지침 항목 존재를 확인한다.
- `gh api` 호출은 #27에서 자동 허용에서 빠졌으므로, 조회마다 권한 확인이 한 번 더 뜨는 비용은 수용한다.

---

## 변경 이력
| 날짜 | 변경 내용 | 출처 |
|------|-----------|------|
| 2026-11-16 | 최초 작성 | requirements.md, 사용자 답변, Opus 설계 논의 |
| 2026-11-16 | resolved 여부 보고를 위해 조회를 GraphQL `reviewThreads`로 변경. 기존 스레드 답글은 적절성을 검토해 "제안 후 사용자 승인 시 게시"로 결정하고 시나리오 C 추가 | 사용자 답변 |
