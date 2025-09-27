# Product Requirements Document (PRD)

## Product: resu:me — AI Resume & Portfolio Generator

## Version: 0.1 (MVP)

## Tech: Python + FastAPI, PostgreSQL, Next.js, Docker

---

## 1. Overview

resu:me는 사용자가 간단한 폼 입력만으로 웹 포트폴리오 페이지와 PDF 이력서를 생성/공유할 수 있는 서비스이다.
목표는 1개월 내 MVP 출시이며, 글로벌(EN) 기본 + 한국어(KO) 지원을 포함한다.
AI 기능은 필수는 아니지만 요약/번역 보조를 통해 차별화한다.

### Goals

- **폼 기반 이력서 작성/편집**
- **공개 URL 포트폴리오 제공**
- **템플릿 기반 PDF 내보내기**
- (선택) AI 보조: 요약/번역

### Non-Goals (MVP 범위 밖)

- 템플릿 마켓플레이스
- 소셜 로그인
- 채용 플랫폼/ATS 연동
- 팀/조직 계정, 멀티테넌시

---

## 2. Target Users

- **구직자/학생/프리랜서**: 빠르게 포맷된 이력서를 만들어 제출/공유하려는 사용자
- **Global 1순위**, **한국 1.5순위**

---

## 3. Core Use Cases (MVP)

1. 계정 생성/로그인 (JWT 인증)
2. 이력서 CRUD
   - 속성: `title`, `locale (en-US|ko-KR)`, `isPublic`
3. 섹션 관리
   - 타입: basic_info, summary, work, projects, skills, links
   - 순서 변경 및 내용 수정
4. 공개 보기
   - URL `/u/{handle}/{resumeId}`, 조건: `isPublic = true`
5. PDF 내보내기
   - HTML → (Playwright/Chromium) → PDF 변환 후 오브젝트 스토리지(S3/R2)에 저장
   - 다운로드 링크 반환
   - 월간 무료 PDF 쿼터 제한
   - 요청 시 템플릿 키를 지정할 수 있으며, 생략되면 시스템 기본 템플릿이 적용
6. (선택) AI 보조
   - 경력/스킬 기반 요약문 생성
   - EN↔KO 번역

---

## 4. Functional Requirements

### 4.1 Auth

- 이메일+비밀번호 가입/로그인
- JWT 발급/갱신
- 핸들(handle) 고유성 보장
- 비밀번호 해싱(BCrypt)

### 4.2 Resume

- CRUD 지원
- 무료 플랜 제한: 이력서 최대 1개

### 4.3 Section

- 타입별 JSON 데이터 저장
- 순서(order) 필드로 정렬 가능
- 타입 스키마 검증

### 4.4 Public Portfolio

- SSR/CSR 모두 지원
- 접근 조건: `isPublic=true` && handle+resumeId 매칭

### 4.5 Export

- 상태 전이: `pending → processing → succeeded|failed`
- 완료 시 fileUrl 반환
- DB에 export 이력 기록
- 요청 시 템플릿 키를 전달할 수 있으며, 생략 시 시스템 기본 템플릿 사용

### 4.6 AI (Optional)

- `/api/ai/summary`: 요약문 생성
- `/api/ai/translate`: 번역
- 토큰/호출 횟수 제한

---

## 5. Non-Functional Requirements

- 성능: PDF 생성은 BackgroundTask 처리
- 보안: 개인정보(이메일, 연락처 등) 보호, 기본은 비공개
- 국제화: locale 필드 기반 다국어 지원
- 가용성: 서버리스 Postgres(Neon/Supabase)로 시작, 추후 RDS 승급
- 관측성: structlog 기반 JSON 로그 + 에러 로깅(Sentry), `/health` 엔드포인트

---

## 6. Data Model (Conceptual)

- **User**: id, email, password_hash, handle, created_at
- **Resume**: id, user_id, title, locale, isPublic, updated_at
- **Section**: id, resume_id, type, order, data(JSON), updated_at
- **Export**: id, resume_id, kind(pdf/html), template, status, file_url, created_at
- (옵션) **Quota**: user_id, year_month, pdf_export_count

---

## 7. API (요약)

- Auth: `POST /api/auth/signup`, `POST /api/auth/login`
- Me: `GET /api/me`, `PATCH /api/me`
- Resume: CRUD (`/api/resumes`)
- Section: CRUD + reorder (`/api/sections`)
- Public: `GET /u/{handle}/{resumeId}`
- Export: `POST /api/resumes/{id}/exports`, `GET /api/exports/{id}`
- AI: `POST /api/ai/summary`, `POST /api/ai/translate`

---

## 8. Business Rules

- 무료 플랜: Resume 1개, Template 1종, PDF 5회/월
- 공개 URL은 `(handle, resumeId)` 조합으로 접근
- Export 요청은 quota 초과 시 거절
- AI 기능은 비용 제어를 위해 제한적 제공

---

## 9. Risks & Open Questions

- PDF 포맷 호환성 (폰트/레이아웃 깨짐 가능)
- 서버리스 Postgres의 연결 제한 → pgbouncer 필요
- AI 호출 비용 관리 전략 필요
