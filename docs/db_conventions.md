# Database Conventions

본 문서는 resu-me 프로젝트의 **논리/물리 모델링 공통 규칙**을 정의한다. 모든 새 테이블과 컬럼은 본 가이드를 참고하여 일관성을 유지한다.

---

## Scope

- 대상: PostgreSQL 메인 데이터베이스 (애플리케이션, 마이그레이션, ORM 모델)
- 대상 제외: 분석/로그 DB, 외부 SaaS가 관리하는 스키마
- 적용 레이어: Alembic 마이그레이션, SQLAlchemy 모델, Pydantic 스키마 (DB 스키마에 직접 맵핑되는 필드)

---

## Naming Rules

- **스키마**: 기본 `public` 사용. 별도 스키마 필요 시 사전에 논의한다.
- **테이블**: 소문자 스네이크 케이스(`snake_case`) + **단수형**. 모듈 접두어로 관련 테이블을 그룹화한다. 예: `user`, `resume`, `resume_section`.
- **컬럼**: 소문자 스네이크 케이스. 동일 의미의 FK는 가능한 한 동일 이름을 유지하되, 도메인에 맞춰 구체적으로(`creator_id`, `profile_id` 등) 사용할 수 있다. boolean에는 `is_`/`has_` 접두어를 권장한다.
- **PK 컬럼**: 주 테이블 명 + `_id` (`user_id`, `resume_id`).
- **FK 컬럼**: 참조 대상 테이블 명 기반 `_id` (`resume_id`, `user_id`).
- **타임스탬프 컬럼**: `*_at`, 날짜 컬럼은 `*_date` 접미사를 사용한다.
- **제약/인덱스 네이밍**: PostgreSQL 기본 패턴을 따른다.
  - 기본키: `{table}_pkey`
  - 고유 제약: `{table}_{column}_key`
  - 외래키: `{table}_{column}_fkey`
  - 체크 제약: `{table}_{constraint}_check`
  - 인덱스: `{table}_{column}_idx`
- **시퀀스/디폴트**: ULID/UUID 기반이므로 시퀀스 네이밍은 해당 없음.

> SQLAlchemy `MetaData`에 naming convention을 설정해 위 규칙을 자동으로 적용한다. Alembic autogenerate 시 일관된 제약 이름을 유지하고, 리비전 간 충돌을 줄여준다.

```python
from sqlalchemy import MetaData
from sqlalchemy.orm import declarative_base

POSTGRES_NAMING_CONVENTION = {
    "ix": "%(table_name)s_%(column_0_name)s_idx",
    "uq": "%(table_name)s_%(column_0_name)s_key",
    "ck": "%(table_name)s_%(constraint_name)s_check",
    "fk": "%(table_name)s_%(column_0_name)s_fkey",
    "pk": "%(table_name)s_pkey",
}
metadata = MetaData(naming_convention=POSTGRES_NAMING_CONVENTION)
Base = declarative_base(metadata=metadata)
```

---

## Keys & Relationships

### Primary Keys

- 모든 테이블은 **단일 컬럼 PK**를 사용한다.
- PK 타입은 `UUID` (RFC4122) 또는 `CHAR(26)` ULID 중 하나로 통일한다. 초기 구현은 ULID 문자열 사용을 기본으로 한다.
- PK는 애플리케이션에서 생성하며 DB default는 두지 않는다.

### Foreign Keys

- FK는 **항상 단일 컬럼**으로 정의한다. 복합 키/복합 FK는 허용하지 않는다.
- FK 컬럼에는 `NOT NULL`을 기본 적용한다. 정당한 비식별 관계(선택 관계)가 필요한 경우에만 nullable로 허용하며, 문서화한다.
- 모든 FK에는 `ON DELETE`/`ON UPDATE` 정책을 명시한다. 기본은 `ON DELETE RESTRICT`, 관계 특성상 필요 시 `CASCADE` 또는 `SET NULL`을 사용한다.

### Relationship Style

- **비식별 관계(Non-identifying)**를 기본으로 한다. FK 컬럼은 PK에 포함되지 않는다.
- 조인 테이블(join table)이 필요한 경우에도 surrogate key + unique 제약으로 구현한다. (예: `id` PK + `UNIQUE (left_id, right_id)`)
- 1:N 관계에서 FK는 자식 테이블에 위치한다.

---

## Common Columns

- 모든 영속 테이블은 아래 컬럼을 기본 포함한다:
  - `created_at TIMESTAMPTZ NOT NULL DEFAULT now()`
  - `updated_at TIMESTAMPTZ NOT NULL DEFAULT now()`
- 감사 추적이 필요한 테이블은 추가로 `created_by`, `updated_by` (`UUID`/`ULID`) 컬럼을 고려한다.
- Soft delete는 MVP 범위 밖이다. 필요할 경우 별도 RFC로 다룬다.

> ORM에서는 `sqlalchemy.sql.func.now()`를 디폴트로 매핑하고, DB 레벨에서는 `DEFAULT now()`를 명시한다.
> PostgreSQL은 MySQL의 `ON UPDATE`와 같은 내장 옵션이 없으므로, `updated_at` 자동 갱신은 애플리케이션(예: SQLAlchemy `onupdate=func.now()`)에서 처리한다. 서버 측 트리거가 필요한 경우 별도 RFC로 논의한다.

---

## Data Types

- 문자열: 기본 `VARCHAR`, 길이 제한이 명확하지 않을 경우 `TEXT`. 이메일/핸들과 같이 검증 가능한 값은 길이 제한을 명시한다.
- 정수: `INT` / `BIGINT`. 카운터나 순서 값에는 `INT`.
- 금액/정밀 값: `NUMERIC(precision, scale)`.
- Boolean: `BOOLEAN` (`is_` 접두어 컬럼).
- JSON: 구조가 유연한 섹션 등은 `JSONB` 사용.
- Enum 후보: PostgreSQL enum 대신 애플리케이션 레벨 검증 + 체크 제약(`CHECK`)을 우선 고려한다. 반복적으로 사용되는 enum은 도메인 확정 시 enum 타입 생성.

---

## Indexing Strategy

- PK/FK는 자동 인덱스를 활용한다. FK에 대한 조회 패턴이 잦은 경우 **명시적으로 추가 인덱스**를 만든다.
- 컬럼 단일 인덱스는 정렬/검색에 사용되는 컬럼에 한정한다 (예: `section.order`).
- 부분 인덱스/조건부 인덱스는 실제 요구가 확인된 이후에 도입한다.
- 중복 인덱스 방지를 위해 마이그레이션 작성 시 `pg_indexes` 확인.

---

## Constraints & Validation

- 비즈니스 규칙은 가능한 DB 제약으로 명시한다 (예: 유니크, 체크).
- 데이터 정합성이 중요하지 않은 경우라도 **애플리케이션 레벨 검증**을 보완해야 한다.
- 타임존은 모두 UTC 기준 `TIMESTAMPTZ` 사용. 애플리케이션에서 로케일 포맷 변환.
- `NOT NULL`을 기본으로 하고, nullable은 명확한 이유가 있을 때만 허용한다.

---

## Migration Guidelines

- 마이그레이션은 **결정적(deterministic)**이어야 하고 언제든 **reversible** 해야 한다. 구조를 정의하는 DDL은 고정 값으로 작성하고, 동적으로 계산된 데이터는 별도 시딩 스크립트에서 다룬다.
- Alembic 마이그레이션은 **DDL + 기본 데이터 시딩**을 명확히 구분한다.
- 새 리비전은 날짜 기반 `YYYY-MM-DD_slug` 패턴의 파일명을 사용하고, slug는 변경 요약으로 작성한다. `alembic.ini`의 `file_template`을 아래와 같이 설정해 강제한다.

```ini
# alembic.ini
file_template = %(year)d-%(month).2d-%(day).2d_%(slug)s
```

- `alembic revision --autogenerate -m "add_resume_table"`처럼 모든 리비전에 slug 메시지를 제공한다.
- 다운그레이드는 구조적 변경 시 반드시 구현하고, 마이그레이션 리뷰 때 docs/db_schema.md를 최신 상태로 유지한다.

---

## Application Access Patterns

### Async Dependencies (FastAPI)

- FastAPI dependency 함수는 가능하면 `async def`로 정의해 이벤트 루프가 동기 DB 세션으로 블로킹되지 않게 한다.
- SQLAlchemy는 `AsyncEngine` + `async_sessionmaker` 조합과 `postgresql+asyncpg://` 드라이버를 사용한다. 동기 세션(`Session`)과 혼용하지 않는다.
- DB 세션 dependency는 `async with` 블록으로 세션을 열고 닫도록 구현한다. 세션을 생성만 하고 반환하지 말 것.

```python
async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session() as session:  # context manager가 에러 시 롤백하고 세션을 닫는다
        yield session
```

- 엔드포인트/서비스는 `Depends(get_db_session)`으로 `AsyncSession`만 주입받고, 추가 커밋이 필요하면 `await session.commit()`을 명시한다.
- 비즈니스 로직 내부에서도 `await session.execute(...)`, `await session.flush()` 등 비동기 API만 사용하고, 동기 helper를 호출하지 않는다.

---

## Review Checklist

- [ ] 테이블/컬럼 네이밍이 규칙을 따른다.
- [ ] PK/FK가 단일 컬럼이며 비식별 관계로 설계되었다.
- [ ] 감사 컬럼(`created_at`, `updated_at`)이 포함되었다.
- [ ] 필요한 제약(UNIQUE, CHECK, DEFAULT)이 정의되었다.
- [ ] 인덱스 전략이 쿼리 패턴을 고려한다.
- [ ] 관련 문서(PRD, Concept Model, Schema)가 업데이트되었다.
