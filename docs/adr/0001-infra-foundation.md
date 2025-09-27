# 인프라 기본 전략 (2025-09-27)

## 컨텍스트

MVP 스텝 1~3을 진행하려면 어디에 배포하고 어떤 스토리지/워커 구성을 쓸지 먼저 결정해야 한다. PDF 생성은 Playwright 기반으로 헤드리스 브라우저가 필요하고, 객체 스토리지와 서버리스 Postgres 선택도 동시에 이뤄져야 개발 방향이 명확해진다.

## 결정

- 프런트엔드는 Next.js에 최적화된 Vercel에 배포하고, 백엔드는 Docker 이미지 기반으로 Fly.io에 배포한다.
- PostgreSQL은 서버리스 플랜을 제공하는 Neon을 사용하고, 로컬에서는 Docker Compose의 Postgres 컨테이너로 대체한다.
- PDF 결과물은 S3 호환이면서 저렴한 Cloudflare R2에 저장하고, 로컬 개발에서는 MinIO를 사용한다.
- PDF 생성은 같은 리포의 별도 워커 프로세스(Playwright 런타임 포함)가 `exports` 테이블을 폴링해 처리하고, API 서버는 작업을 enqueue하는 역할만 맡는다.

## 영향 & 할 일

- `docker-compose.yml`에 프런트/백엔드/Postgres/MinIO를 추가해 로컬 환경을 구성한다.
- 백엔드 이미지를 Fly.io에서도 Playwright가 동작하도록 빌드 단계에 브라우저 바이너리를 포함시켜야 한다.
- Export 워커용 엔트리포인트(예: `uv run python -m app.workers.export_pdf`)를 구현하고 배포 시 별도 프로세스로 실행한다.
- 배포 시 필요한 환경 변수(Neon, R2 크레덴셜 등)를 `docs/env_setup.md`와 `.env.example`에 정리한다.
