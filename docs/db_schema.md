# Database Schema (MVP)

본 문서는 `docs/concept_model.md`에서 정의한 도메인과 `docs/db_conventions.md`의 규칙을 기반으로, FastAPI MVP에서 사용할 PostgreSQL 물리 스키마를 테이블 정의서 형태로 정리한다. 용어는 `docs/glossary.md`와 일치시킨다.

---

## 참조 문서

- 개념 모델: `docs/concept_model.md`
- DB 네이밍/마이그레이션 규칙: `docs/db_conventions.md`
- 용어 사전: `docs/glossary.md`

---

## 관계 요약

- `app_user` 1 — N `resume`
- `resume` 1 — N `section`
- `resume` 1 — N `export`
- `app_user` 1 — N `quota` *(연-월 단위)*
- `template` 1 — N `export`

> 모든 테이블은 공통 감사 컬럼(`created_at`, `updated_at`)을 포함하며, `updated_at`은 애플리케이션 계층에서 `onupdate=func.now()` 등으로 갱신한다.

---

## 테이블 정의서

### 1. app_user (회원)

- **테이블 한글명**: 회원
- **테이블 영문명**: `app_user`
- **설명**: 서비스 로그인과 권한 관리에 필요한 사용자 계정을 저장한다.

| No. | 컬럼 한글명 | 컬럼 영문명 | 데이터 타입 | 제약조건 | NULL 허용 | 기본값 | 설명 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 회원 ID | `user_id` | `CHAR(26)` | PK | NOT NULL | - | ULID 기반 식별자. 애플리케이션에서 생성. |
| 2 | 이메일 | `email` | `VARCHAR(255)` | UQ | NOT NULL | - | 로그인 및 알림용 이메일. 중복 불가. |
| 3 | 패스워드 해시 | `password_hash` | `VARCHAR(255)` | - | NOT NULL | - | Bcrypt 등 해시 값만 저장. 원문 저장 금지. |
| 4 | 핸들 | `handle` | `VARCHAR(50)` | UQ | NOT NULL | - | 공개 URL 슬러그. 소문자, 하이픈만 허용. |
| 5 | 기본 언어 | `locale` | `VARCHAR(10)` | - | NOT NULL | `DEFAULT 'en-US'` | 사용자 선호 로케일(`en-US`, `ko-KR` 등). |
| 6 | 생성 일시 | `created_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 계정 생성 시각. |
| 7 | 수정 일시 | `updated_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 계정 정보 수정 시각. ORM `onupdate`로 갱신. |

---

### 2. resume (이력서)

- **테이블 한글명**: 이력서
- **테이블 영문명**: `resume`
- **설명**: 사용자별 이력서 메타 정보를 저장한다.

| No. | 컬럼 한글명 | 컬럼 영문명 | 데이터 타입 | 제약조건 | NULL 허용 | 기본값 | 설명 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 이력서 ID | `resume_id` | `CHAR(26)` | PK | NOT NULL | - | ULID. 애플리케이션에서 생성. |
| 2 | 회원 ID | `user_id` | `CHAR(26)` | FK(`app_user.user_id`) | NOT NULL | - | 이력서를 소유한 사용자. |
| 3 | 제목 | `title` | `VARCHAR(150)` | - | NOT NULL | - | 사용자 정의 이력서 제목. |
| 4 | 표시 언어 | `locale` | `VARCHAR(10)` | - | NOT NULL | - | 렌더링 기본 언어. |
| 5 | 공개 여부 | `is_public` | `BOOLEAN` | - | NOT NULL | `DEFAULT false` | 공개 프로필 사용 시 true. |
| 6 | 생성 일시 | `created_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 이력서 생성 시각. |
| 7 | 수정 일시 | `updated_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 이력서 콘텐츠 수정 시각. |

---

### 3. section (이력서 섹션)

- **테이블 한글명**: 이력서 섹션
- **테이블 영문명**: `section`
- **설명**: 이력서에 포함되는 섹션 단위(기본 정보, 요약, 경력 등)를 저장한다.

| No. | 컬럼 한글명 | 컬럼 영문명 | 데이터 타입 | 제약조건 | NULL 허용 | 기본값 | 설명 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 섹션 ID | `section_id` | `CHAR(26)` | PK | NOT NULL | - | ULID. 섹션 엔티티 식별자. |
| 2 | 이력서 ID | `resume_id` | `CHAR(26)` | FK(`resume.resume_id`) | NOT NULL | - | 소속 이력서. |
| 3 | 섹션 유형 | `section_type` | `VARCHAR(20)` | CK | NOT NULL | - | `basic_info|summary|work|projects|skills|links` 중 하나. |
| 4 | 정렬 순서 | `sort_order` | `INT` | CK | NOT NULL | - | 이력서 내 노출 순서 (0 이상). |
| 5 | 섹션 내용 | `content` | `JSONB` | - | NOT NULL | - | 타입별 구조화 데이터(JSON). |
| 6 | 생성 일시 | `created_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 섹션 생성 시각. |
| 7 | 수정 일시 | `updated_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 섹션 갱신 시각. |

> 제약조건: `section_type`은 체크 제약(`CK`)으로 허용값을 제한하고, `sort_order`는 0 이상의 정수로 검증한다(`CHECK (sort_order >= 0)`).

---

### 4. export (이력서 내보내기)

- **테이블 한글명**: 이력서 내보내기 이력
- **테이블 영문명**: `export`
- **설명**: 이력서를 PDF/HTML 등으로 변환한 기록과 상태를 보관한다.

| No. | 컬럼 한글명 | 컬럼 영문명 | 데이터 타입 | 제약조건 | NULL 허용 | 기본값 | 설명 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 내보내기 ID | `export_id` | `CHAR(26)` | PK | NOT NULL | - | ULID. 내보내기 트랜잭션 식별자. |
| 2 | 이력서 ID | `resume_id` | `CHAR(26)` | FK(`resume.resume_id`) | NOT NULL | - | 대상 이력서. |
| 3 | 템플릿 ID | `template_id` | `CHAR(26)` | FK(`template.template_id`) | NULL | - | 선택 템플릿. NULL 시 기본 템플릿. |
| 4 | 출력 포맷 | `format` | `VARCHAR(10)` | CK | NOT NULL | - | `pdf` 또는 `html`. |
| 5 | 처리 상태 | `status` | `VARCHAR(20)` | CK | NOT NULL | `DEFAULT 'pending'` | `pending|processing|succeeded|failed`. |
| 6 | 결과 파일 URL | `file_url` | `TEXT` | - | NULL | - | 성공 시 파일 접근 경로. |
| 7 | 오류 사유 | `error_reason` | `TEXT` | - | NULL | - | 실패 사유 메시지. |
| 8 | 생성 일시 | `created_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 요청 시각. |
| 9 | 수정 일시 | `updated_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 상태 변경 시각. |

---

### 5. quota (월간 사용량)

- **테이블 한글명**: 월간 사용량
- **테이블 영문명**: `quota`
- **설명**: 사용자별 월간 PDF 내보내기 횟수를 추적한다.

| No. | 컬럼 한글명 | 컬럼 영문명 | 데이터 타입 | 제약조건 | NULL 허용 | 기본값 | 설명 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 사용량 ID | `quota_id` | `CHAR(26)` | PK | NOT NULL | - | ULID. 레코드 식별자. |
| 2 | 회원 ID | `user_id` | `CHAR(26)` | FK(`app_user.user_id`) | NOT NULL | - | 사용량이 집계되는 사용자. |
| 3 | 기준 월 | `year_month` | `DATE` | - | NOT NULL | - | 해당 월의 1일. 사용자별로 유일(`UNIQUE(user_id, year_month)`). |
| 4 | PDF 사용 횟수 | `pdf_export_count` | `INT` | CK | NOT NULL | `DEFAULT 0` | 월간 PDF 생성 횟수 (0 이상). |
| 5 | 생성 일시 | `created_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 레코드 생성 시각. |
| 6 | 수정 일시 | `updated_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 사용량 업데이트 시각. |

> 제약조건: `pdf_export_count`는 `CHECK (pdf_export_count >= 0)`로 음수를 금지하고, `UNIQUE(user_id, year_month)`로 사용자-월 조합을 하나로 제한한다.

---

### 6. template (렌더링 템플릿, 옵션)

- **테이블 한글명**: 템플릿
- **테이블 영문명**: `template`
- **설명**: 내보내기 시 사용할 수 있는 템플릿 메타 정보를 저장한다. MVP에서는 기본 템플릿만 사용할 수도 있다.

| No. | 컬럼 한글명 | 컬럼 영문명 | 데이터 타입 | 제약조건 | NULL 허용 | 기본값 | 설명 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 템플릿 ID | `template_id` | `CHAR(26)` | PK | NOT NULL | - | ULID. 템플릿 식별자. |
| 2 | 템플릿 이름 | `name` | `VARCHAR(100)` | UQ | NOT NULL | - | 사용자에게 노출되는 이름. |
| 3 | 에셋 경로 | `asset_reference` | `TEXT` | - | NULL | - | CSS/JSON 등 렌더링 리소스 식별자. |
| 4 | 생성 일시 | `created_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 등록 시각. |
| 5 | 수정 일시 | `updated_at` | `TIMESTAMPTZ` | - | NOT NULL | `DEFAULT now()` | 템플릿 갱신 시각. |

---

## 운영 가이드

- 모든 DDL/마이그레이션은 `docs/db_conventions.md`의 네이밍 규칙과 Alembic 파일 템플릿 규칙을 따른다.
- JSON 컬럼(`section.content`)은 API 계층(Pydantic)에서 타입별 구조를 검증해 데이터 품질을 유지한다.
- `updated_at` 자동 갱신은 SQLAlchemy 모델에서 `onupdate=func.now()`를 지정하고, 추가 보장이 필요할 경우 별도 RFC로 PostgreSQL 트리거를 설계한다.
- 스키마 변경 시 본 문서를 즉시 갱신하여 테이블 정의서를 Living Document로 유지한다.
- 인덱스는 운영 중 필요 시에 추가한다. 이 때도 본 문서를 즉시 갱신한다.
