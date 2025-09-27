# Environment & Secrets Guide

MVP 개발을 위해 필요한 환경 변수와 시크릿 관리 방식을 정리한다. 예시 값은 로컬 개발( Docker Compose 기반 )을 가정하며, 실제 프로덕션 값은 별도 비밀 저장소(예: GitHub Actions Secrets, Vercel/Render 환경 변수, AWS Parameter Store 등)에 저장한다.

## 파일 구조

- `backend/.env` – FastAPI 앱에서 사용하는 환경 변수 (uv/uvicorn 실행 시 로드)
- `frontend/.env.local` – Next.js(App Router)에서 사용하는 변수
- `docker/.env` (선택) – docker compose가 공유하는 값이 필요할 때
- 공통 예시는 `backend/.env.example`, `frontend/.env.example`에 제공하며, 복사하여 사용한다.

```bash
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env.local
```

`.env`/`.env.local` 파일은 Git에 커밋하지 않는다. 로컬에서는 `.gitignore`를 통해 제외하고, CI/배포 환경은 해당 서비스의 Secret Store를 사용한다.

## Backend 환경 변수 (`backend/.env`)

| 변수 | 설명 | 예시 값 | 비고 |
|------|------|---------|------|
| `RESUME_ENV` | 실행 환경 | `development` | `production`, `staging` 등 |
| `RESUME_DATABASE_URL` | PostgreSQL 연결 문자열 | `postgresql+asyncpg://resume:resume@postgres:5432/resume` | Docker Compose의 PostgreSQL 서비스와 일치 |
| `RESUME_JWT_SECRET` | JWT 서명 비밀키 | `change-me-in-prod` | 프로덕션에서는 난수/비밀 저장소 사용 |
| `RESUME_JWT_ALGORITHM` | JWT 알고리즘 | `HS256` | |
| `RESUME_ACCESS_TOKEN_MINUTES` | 액세스 토큰 유효 시간(분) | `60` | |
| `RESUME_REFRESH_TOKEN_MINUTES` | 리프레시 토큰 유효 시간(분) | `43200` | 30일 |
| `RESUME_ALLOWED_ORIGINS` | CORS 허용 Origin 목록 | `http://localhost:3000` | 쉼표로 다중 값 지정 |
| `RESUME_DEFAULT_TEMPLATE_KEY` | 기본 PDF 템플릿 키 | `classic` | |
| `RESUME_PDF_MONTHLY_QUOTA` | 무료 플랜 PDF 제한 | `5` | PRD 명세와 일치 |
| `RESUME_STORAGE_ENDPOINT` | S3 호환 엔드포인트 | `http://storage:9000` | 예: MinIO, Cloudflare R2 |
| `RESUME_STORAGE_REGION` | 스토리지 리전 | `auto` | R2는 `auto`, S3는 `ap-northeast-2` 등 |
| `RESUME_STORAGE_ACCESS_KEY` | 스토리지 액세스 키 | `local-access-key` | |
| `RESUME_STORAGE_SECRET_KEY` | 스토리지 시크릿 키 | `local-secret-key` | |
| `RESUME_STORAGE_BUCKET` | PDF 저장 버킷/컨테이너 | `resume-exports` | |
| `RESUME_PLAYWRIGHT_TIMEOUT_MS` | Playwright 렌더 타임아웃(ms) | `60000` | 필요 시 조정 |
| `RESUME_LOG_LEVEL` | 로그 레벨 | `INFO` | structlog 구성에 사용 |
| `RESUME_SENTRY_DSN` | (선택) Sentry DSN | `` | 비워두면 비활성화 |
| `OPENAI_API_KEY` | (선택) AI 요약/번역 제공자 키 | `` | AI 기능 사용 시 필수 |

## Frontend 환경 변수 (`frontend/.env.local`)

| 변수 | 설명 | 예시 값 | 비고 |
|------|------|---------|------|
| `NEXT_PUBLIC_API_BASE_URL` | 백엔드 API 베이스 URL | `http://localhost:8000` | 클라이언트에서 fetch 시 사용 |
| `NEXT_PUBLIC_APP_URL` | 프런트엔드 앱 기본 URL | `http://localhost:3000` | Public 링크 생성 시 활용 |
| `NEXT_PUBLIC_EXPORT_POLL_INTERVAL_MS` | PDF 상태 폴링 주기(밀리초) | `2000` | UI 피드백용 |
| `NEXT_PUBLIC_DEFAULT_LOCALE` | 기본 로케일 | `en-US` | `ko-KR` 등 |
| `NEXT_PUBLIC_SENTRY_DSN` | (선택) Sentry Frontend DSN | `` | 없으면 비활성화 |

프런트엔드에서 노출되면 안 되는 비밀 값은 `NEXT_PUBLIC_` 접두사를 사용하지 않는 변수에 저장하고, 서버 컴포넌트/Route Handler에서만 참조한다.

## Secret 관리 원칙

- **로컬 개발**: `.env` / `.env.local` 파일만 사용, 실제 비밀은 placeholder로 대체.
- **GitHub Actions**: Repository Secrets에 저장(`Settings → Secrets and variables → Actions`). 필요한 경우 환경별( staging / production )로 구분.
- **호스팅 환경**: Vercel, Render, Fly.io, AWS ECS 등 제공자의 Secret / Config 기능 사용.
- **접근 권한**: 최소 권한 원칙을 적용하고, 팀 확장 시 1Password, Bitwarden, AWS SSM 등 중앙 관리 도구 도입을 검토한다.

## 샘플 파일 존재 여부

- `backend/.env.example`
- `frontend/.env.example`
- (`docker/.env.example`은 docker compose 정의가 정해지는 시점에 함께 추가한다.)

새 기여자는 각 파일을 복사해 로컬 환경을 구성한 뒤, 필요한 값만 수정하면 된다. 샘플 파일은 지속적으로 최신 필드와 일치하도록 관리한다.

## 다음 단계

- Docker Compose 정의 시 위 변수와 동일한 키로 환경을 주입한다.
- GitHub Actions 워크플로 작성 시 Secrets 이름을 매핑한다.
- 프로덕션 배포 대상이 확정되면, 해당 플랫폼의 비밀 관리 가이드를 추가한다.
