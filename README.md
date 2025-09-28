# resu:me — AI Resume & Portfolio (FastAPI + Next.js)
Monorepo: `/docs`, `/backend`, `/frontend`

- Goal: 1-month MVP
- Stack: FastAPI, PostgreSQL (Neon in prod), Next.js
- Deploy: Vercel (frontend) + Fly.io (backend/Playwright 워커)
- Storage: Cloudflare R2 (prod) + MinIO (local)

## Local dev (Docker Compose)

1. 복사해서 로컬 환경 변수를 준비합니다.
   ```bash
   cp backend/.env.example backend/.env
   cp frontend/.env.example frontend/.env.local
   cp docker/.env.example .env  # 선택: 포트/크레덴셜 오버라이드
   ```
2. 스택을 실행합니다.
   ```bash
   docker compose up --build
   ```
   - `storage-init` 컨테이너는 MinIO 버킷을 만든 후 종료됩니다 (정상 동작).
   - 프론트엔드/백엔드 코드가 아직 없다면 각 컨테이너는 `tail -f /dev/null` 상태로 대기합니다.
3. 주요 엔드포인트
   - Backend API: http://localhost:8000
   - Next.js App: http://localhost:3000
   - PostgreSQL: localhost:5432 (user `resume` / pw `resume`)
   - MinIO S3 API: http://localhost:9000 (콘솔 http://localhost:9001)

종료 시 `docker compose down -v`로 볼륨까지 정리할 수 있습니다.
