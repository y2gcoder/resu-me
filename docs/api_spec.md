# API Spec (MVP — Lite)

본 문서는 Resu:me MVP 백엔드 API의 0차 스펙 초안을 정의한다. 구현 과정에서 발견되는 요구사항은 이 문서를 갱신하며 추적한다.

---

## 공통 규칙

- **Base URL**: `/api`
- **Protocol**: HTTPS, `Content-Type: application/json; charset=utf-8`
- **Auth**: `Authorization: Bearer <JWT>` (없으면 `401 unauthorized`)
- **ID 스펙**: 모든 리소스 ID는 ULID 문자열(26자, 대문자+숫자) — `user_id`, `resume_id`, `section_id` 등.
- **타임스탬프**: ISO-8601 UTC (`2024-03-01T12:34:56Z`). `last_updated_at`은 DB의 `updated_at`을 매핑한다.
- **오류 응답**: RFC 7807 Problem Details(`Content-Type: application/problem+json`)를 사용한다.

```json
{
  "type": "https://resu.me/errors/email-taken",
  "title": "Conflict",
  "status": 409,
  "detail": "이미 사용 중인 이메일입니다.",
  "instance": "/api/auth/signup",
  "code": "email_taken",
  "fields": {
    "email": "already_taken"
  }
}
```

> `type`은 오류 유형을 설명하는 URI이다. 별도 문서를 생성하기 전에는 `https://resu.me/errors/<slug>` 패턴을 사용하고, 구체적인 문서가 없으면 `about:blank`를 사용할 수 있다. `code`, `fields`는 서비스 확장 필드로 정의한다.

### 오류 매핑

| HTTP | type (slug) | 기본 title | detail 예시 |
| --- | --- | --- | --- |
| 400 | `invalid-request` | Bad Request | 요청 스키마 오류, 필드 누락. |
| 401 | `unauthorized` | Unauthorized | 토큰 누락/만료/검증 실패. |
| 403 | `forbidden` | Forbidden | 리소스 접근 권한 없음 (예: 다른 사용자의 리소스). |
| 404 | `not-found` | Not Found | 존재하지 않는 리소스(`resume`, `section` 등). |
| 409 | `conflict` | Conflict | 중복 핸들, 섹션 순서 충돌 등. 세부 `code` 예: `email_taken`. |
| 422 | `validation-error` | Unprocessable Entity | 섹션 content schema 위반, 필드 유효성 실패. |
| 429 | `rate-limited` | Too Many Requests | 쿼터 초과, 호출 제한. |
| 500 | `internal-error` | Internal Server Error | 미처리 예외, 서버 내부 오류. |

> 세부 도메인 코드는 `code` 필드에 작성(`quota_exceeded`, `section_content_invalid` 등). 필드별 오류는 `fields` 객체에 `{ "field_name": "reason" }` 형식으로 전달한다.

### 페이징 / 정렬

- 목록 API는 기본적으로 정렬 기준을 명시한다 (예: `last_updated_at DESC`). 초기 버전은 전체 목록 반환을 허용하고, 추후 `limit`, `offset` 혹은 `cursor`를 도입한다.

---

## 1. Auth

### POST `/api/auth/signup`

- **설명**: 이메일/비밀번호로 신규 사용자 생성.
- **Request**

```json
{
  "email": "user@example.com",
  "password": "P@ssw0rd!",
  "handle": "jane-doe",
  "locale": "ko-KR"
}
```

- **Response 201**

```json
{
  "user_id": "01HX3ZQ2F7T3J9E7W7S9F1R1VT",
  "token": "<jwt>"
}
```

> 실패 케이스: Problem Details `status=409`, `code=email_taken|handle_taken`; `status=422`, `code=signup_payload_invalid` 등.

### POST `/api/auth/login`

- **설명**: 이메일/비밀번호 인증 후 토큰 발급.
- **Request**

```json
{
  "email": "user@example.com",
  "password": "P@ssw0rd!"
}
```

- **Response 200**: `signup`과 동일 구조.
- **오류**: Problem Details `status=401`, `code=invalid_credentials`.

### GET `/api/auth/me`

- **설명**: JWT 기반 현재 사용자 프로필 조회.
- **Response 200**

```json
{
  "user_id": "01HX3ZQ2F7T3J9E7W7S9F1R1VT",
  "email": "user@example.com",
  "handle": "jane-doe",
  "locale": "ko-KR"
}
```

---

## 2. Resume

### POST `/api/resumes`

- **설명**: 새 이력서 생성. 기본 템플릿은 서버 설정을 사용.
- **Request**

```json
{
  "title": "Product Manager Resume",
  "locale": "en-US",
  "template_id": "01HX3ZTFK3E2S0MRNN9P0A7E4S",
  "is_public": false
}
```

- **Response 201**

```json
{
  "resume_id": "01HX3ZV0A6Q2FB7F8E3B1M8KJC"
}
```

### GET `/api/resumes`

- **설명**: 로그인 사용자의 이력서 목록.
- **Response 200**

```json
{
  "items": [
    {
      "resume_id": "01HX3ZV0A6Q2FB7F8E3B1M8KJC",
      "title": "Product Manager Resume",
      "locale": "en-US",
      "is_public": false,
      "last_updated_at": "2024-03-01T12:00:00Z"
    }
  ]
}
```

### GET `/api/resumes/{resume_id}`

- **설명**: 단일 이력서 메타 정보 조회.
- **Response 200**: `GET /resumes`의 항목과 동일 구조.

### PATCH `/api/resumes/{resume_id}`

- **설명**: 제목/언어/공개 여부 등 갱신.
- **Request** (partial)

```json
{
  "title": "Updated Resume",
  "locale": "ko-KR",
  "template_id": "01HX3ZTFK3E2S0MRNN9P0A7E4S",
  "is_public": true
}
```

- **Response 200**: 갱신된 이력서 메타 정보.

### DELETE `/api/resumes/{resume_id}`

- **설명**: 이력서, 하위 섹션/내보내기 레코드 정리. Soft-delete 미구현.
- **Response 204**

---

## 3. Sections

- **Section Type 허용값**: `basic_info`, `summary`, `work`, `projects`, `skills`, `links`
- **Content 최소 스키마**
  - **basic_info**: `{ "name", "job_title", "email", "phone?", "location?", "profile_image_url?" }`
  - **summary**: `{ "text" }`
  - **work**: `{ "items": [ { "company", "title", "period": { "start", "end?" }, "employment_type?", "highlights?", "tech_stack?" } ] }`
  - **projects**: `{ "items": [ { "name", "role", "period": { "start", "end?" }, "summary", "results?", "links?" } ] }`
  - **skills**: `{ "keywords": [string], "proficiencies?": [string] }`
  - **links**: `{ "items": [ { "label", "url" } ] }`

### GET `/api/resumes/{resume_id}/sections`

- **설명**: 이력서의 섹션 목록 (정렬 순서 포함).
- **Response 200**

```json
{
  "items": [
    {
      "section_id": "01HX40H0HNQ8VAQST4YQ2E3R6T",
      "type": "summary",
      "order": 0,
      "content": {
        "text": "8년 경력의 제품 관리자..."
      },
      "last_updated_at": "2024-03-01T12:05:00Z"
    }
  ]
}
```

### POST `/api/resumes/{resume_id}/sections`

- **설명**: 섹션 생성. `order`가 없으면 맨 끝으로 배치.
- **Request**

```json
{
  "type": "summary",
  "order": 0,
  "content": {
    "text": "프로덕트 매니저로서..."
  }
}
```

- **Response 201**

```json
{
  "section_id": "01HX40H0HNQ8VAQST4YQ2E3R6T"
}
```

### PATCH `/api/resumes/{resume_id}/sections/{section_id}`

- **설명**: 섹션 내용/순서 수정.
- **Request** (예시)

```json
{
  "order": 1,
  "content": {
    "text": "업데이트된 요약"
  }
}
```

- **Response 200**: 갱신된 섹션 객체.

### DELETE `/api/resumes/{resume_id}/sections/{section_id}`

- **Response 204**

### PATCH `/api/resumes/{resume_id}/sections/reorder`

- **설명**: 복수 섹션의 순서를 일괄 수정. 섹션 수와 동일한 배열을 요구.
- **Request**

```json
{
  "orders": [
    { "section_id": "01HX40H0HNQ8VAQST4YQ2E3R6T", "order": 0 },
    { "section_id": "01HX40H4CE3V37EBM4NYC9WM9B", "order": 1 }
  ]
}
```

- **Response 200**

```json
{ "ok": true }
```

> 검증 실패 시 Problem Details `status=422`, `code=section_order_invalid`, `fields.section_id="duplicate"` 등으로 응답한다.

---

## 4. Export

### POST `/api/resumes/{resume_id}/exports`

- **설명**: 비동기 내보내기 작업 생성. 기본은 PDF만 지원.
- **Request**

```json
{
  "kind": "pdf"
}
```

- **Response 202**

```json
{
  "export_id": "01HX41M1HWB3R2FQX5DQY1YV5K",
  "status": "pending"
}
```

> 쿼터 초과 시 Problem Details `status=429`, `code=quota_exceeded`; 내보내기 실패 시 후속 `GET` 호출에서 `status: failed`와 `error_reason` 제공.

### GET `/api/exports/{export_id}`

- **설명**: 내보내기 상태 조회. 폴링 주기 권장 2~3초.
- **Response 200**

```json
{
  "export_id": "01HX41M1HWB3R2FQX5DQY1YV5K",
  "resume_id": "01HX3ZV0A6Q2FB7F8E3B1M8KJC",
  "status": "succeeded",
  "file_url": "https://cdn.resu.me/exports/01HX41M1HWB3R2FQX5DQY1YV5K.pdf",
  "error_reason": null
}
```

- **상태 전이**: `pending` → `processing` → (`succeeded`|`failed`). 성공 시 `file_url` 필수.

---

## 5. Public View (No Auth)

### GET `/api/u/{handle}/{resume_id}`

- **설명**: 공개 설정된 이력서를 JSON 형태로 제공한다. 비공개거나 미존재 시 `404 not_found`.
- **Response 200** (요약 구조 예시)

```json
{
  "resume": {
    "resume_id": "01HX3ZV0A6Q2FB7F8E3B1M8KJC",
    "title": "Product Manager Resume",
    "locale": "en-US",
    "sections": [
      {
        "type": "summary",
        "content": { "text": "8년 경력의 제품 관리자..." }
      }
    ]
  }
}
```

> HTML 렌더링이 필요하면 별도의 Frontend 라우트(`/u/{handle}`)에서 처리한다.

---

## 추후 고려 사항

- Refresh Token & Token Rotation 정책 정의.
- 섹션 타입 확장(`education`, `certificates` 등) 시 content 스키마 및 검증 문서화.
- 목록 API에 페이징/필터 파라미터 추가.
- 다국어 응답 메시지 템플릿 정리.
