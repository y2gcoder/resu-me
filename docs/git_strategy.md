# Git 전략 (resu:me)

> 목표: **트렁크 기반 개발 + PR 필수(GitHub Flow)**
> `main`은 항상 배포 가능한 상태를 유지하고, 모든 변경은 작은 단위로 브랜치를 만들어 PR을 통해 머지한다.

---

## 브랜치 정책
- 기본 브랜치: `main` (보호 규칙 적용, 직접 push 금지)
- 작업 브랜치는 `main`에서 분기하고 짧은 주기로 유지한다.
- 네이밍 규칙: `타입/주제`
  - 문서: `docs/<topic>` (예: `docs/glossary`)
  - 기능: `feat/<scope>` (예: `feat/auth-signup`)
  - 버그 수정: `fix/<scope>`
  - 리팩터링: `refactor/<scope>`
  - 빌드·인프라: `ci/<scope>`, `chore/<scope>`
- 모두 소문자·하이픈 사용, 길이는 50자 이하를 권장한다.

## 작업 플로우
1. `main`에서 새 브랜치를 생성한다 (`git checkout -b feat/...`).
2. 작은 단위로 작업하고, 관련 테스트/린트(`pnpm lint`, `pnpm test`, `uv run ruff check`, `uv run pytest --cov`)를 수시로 실행한다.
3. 변경 사항은 **기능별·문서별로 분리**하여 PR을 만든다.

## PR 규칙
- 대상 브랜치: 항상 `main`.
- 규모: 리뷰 10~15분 이내가 되도록 작게 유지한다.
- 제목 형식: `<type>: <summary>` (`feat|fix|docs|refactor|test|ci|chore`).
  - 예: `feat: add POST /auth/signup`
- 본문에 포함할 내용(체크리스트 권장)
  - 변경 요약 및 배경
  - 영향 범위(코드, DB, 문서, CI 등)
  - 테스트 방법/결과 (명령어, 스크린샷, 로그)
  - 관련 문서 및 `docs/mvp_checklist.md` 업데이트 여부
- 리뷰: 셀프 리뷰 후 PR 제출, 협업 시 최소 1인 승인.

## 커밋 스타일
- 하나의 커밋은 하나의 목적에 집중하며 작은 단위로 나눈다.
- 메시지 형식: `<type>: <change>` (`feat`, `fix`, `docs`, `refactor`, `test`, `ci`, `chore`).
  - 예: `docs: add conceptual model`, `feat: implement GET /resumes`
- 코드·문서·설정 변경은 가능하면 별도 커밋으로 분리한다.

## CI / Required Checks
- PR은 아래 검사를 통과해야 한다.
  - Frontend: `pnpm lint`(Biome), `pnpm test`(Vitest), `pnpm exec playwright test`(필요 시).
  - Backend: `uv run ruff check`, `uv run ruff format --check`, `uv run mypy`, `uv run pytest --cov`.
- GitHub Actions에 동일한 워크플로 이름을 설정하고 `main` 브랜치 보호 규칙의 Required Checks로 등록한다.

## 머지 전략
- 머지 방식: **Squash merge + 작업 브랜치 삭제**.
- 머지 전 `git fetch && git rebase origin/main`으로 최신화하고, 충돌 해결 후 강제 push(`--force-with-lease`).
- Squash 머지 시 PR 제목이 최종 커밋 메시지가 되므로 제목을 정갈하게 유지한다.
- 문제 발생 시 `git revert <merge-commit>`으로 손쉽게 롤백한다.

## 릴리스 & 배포
- `main` 머지 후 CI에서 빌드/이미지 푸시 및 스테이징 배포를 자동화할 계획이다.
- 릴리스 태그는 필요 시 `v0.x.y` 형식으로 관리한다.

## 문서 & 자동화
- PR 템플릿: `.github/PULL_REQUEST_TEMPLATE.md` (작성 시 체크리스트 활용).
- 라벨: `type:feat`, `type:fix`, `scope:backend`, `scope:frontend`, `docs`, `ci` 등 필요에 따라 사용.
- GitHub 보호 규칙이나 Actions 워크플로 변경도 PR로 관리한다.
