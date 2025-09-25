# Glossary (용어 사전, MVP)

> 본 문서는 Resu:me 서비스 개발 과정에서 사용하는 주요 용어를 정의한다.
> 이해관계자 간 동일한 의미로 소통하기 위한 기준 문서이며,
> 서비스가 발전함에 따라 지속적으로 업데이트된다.
---

| 분류 | 명칭 | 전체 영문명 | 축약어 | 설명 | 관련 시스템 요소 |
|------|------|-------------|--------|------|------------------|
| 엔티티 | user | User | - | 이메일 기반으로 가입한 서비스 이용자. 인증, 권한, 개인 설정의 기준 단위. | Auth, User 서비스 |
| 엔티티 | resume | Resume | - | 사용자가 생성하는 이력서 문서. 섹션 집합으로 구성되며 공개/비공개를 설정할 수 있다. | Resume, Editor |
| 엔티티 | section | Section | - | 이력서를 이루는 구조적 블록. 타입별로 데이터 스키마가 다르며 사용자 정렬이 가능하다. | Section, API |
| 엔티티 | export | Export | - | 이력서를 PDF/HTML 등으로 내보낸 이력. 비동기 처리 상태가 포함된다. | Export 서비스, Storage |
| 엔티티 | quota | Quota | - | 사용자별 월간 사용량 기록. 무료 플랜의 PDF 내보내기 횟수(5회)를 `year_month` 단위로 집계한다. | Quota, Billing 정책 |
| 엔티티 | template | Template | - | 이력서 렌더링을 위한 시각적 스타일 정의. 기본 키는 `template_id`. | Template, Rendering |
| 주요 속성 | handle | Handle | - | 공개 포트폴리오 URL에서 사용하는 식별자. 사용자마다 고유하며 URL-safe 해야 한다. | Public Portfolio |
| 주요 속성 | locale | Locale | - | 사용자와 문서에서 사용하는 언어/지역 코드. BCP 47 형식(`en-US`, `ko-KR`). | Resume, Rendering |
| 주요 속성 | email | Email | - | 로그인 및 알림용 전자메일 주소. | Auth, Notification |
| 주요 속성 | password | Password | - | 사용자가 설정한 비밀 문자열. 저장 시에는 `password_hash`로 변환한다. | Auth |
| 주요 속성 | hash | Hash | - | 원본 데이터를 고정 길이 값으로 변환한 결과. `password_hash` 등 보안 필드에 사용한다. | Auth, Security |
| 주요 속성 | token | Token | - | 로그인 후 발급되는 인증 토큰. 만료 및 갱신 정책을 따른다. | Auth, API |
| 주요 속성 | title | Title | - | 문서나 섹션의 제목. | Resume |
| 주요 속성 | job | Job | - | 사용자의 직무/직함을 나타내는 단어. | Resume |
| 주요 속성 | public | Public | - | 공개 여부를 나타내는 불리언 속성. `is_public`와 같이 사용한다. | Resume |
| 주요 속성 | phone | Phone Number | - | 연락 가능한 전화번호. | Resume |
| 주요 속성 | location | Location | - | 사용자가 거주하거나 활동하는 지역 정보. | Resume |
| 주요 속성 | profile | Profile | - | 사용자의 요약 정보나 프로필 영역을 지칭. | Resume |
| 주요 속성 | image | Image | - | 이미지 리소스. 프로필 사진 등 미디어와 연계된다. | Storage |
| 주요 속성 | url | Uniform Resource Locator | URL | 웹 리소스를 가리키는 경로 문자열. | Web, Storage |
| 주요 속성 | format | Format | - | 내보내기 결과 유형(`pdf`, `html`). | Export |
| 주요 속성 | content | Content | - | 섹션의 실제 데이터 페이로드(예: JSON). | Section |
| 주요 속성 | order | Order | - | 사용자 정의 정렬 순서(정수 인덱스). | Section |
| 주요 속성 | item | Item | - | 목록형 데이터의 개별 요소. | Section |
| 주요 속성 | company | Company | - | 경력/프로젝트와 연관된 조직 이름. | Resume |
| 주요 속성 | period | Period | - | 시작/종료 시점을 포함하는 기간 정보. | Resume |
| 주요 속성 | start | Start | - | 기간의 시작 시점. 필요 시 `_at`/`_date` 규칙을 따른다. | Resume |
| 주요 속성 | end | End | - | 기간의 종료 시점. 필요 시 `_at`/`_date` 규칙을 따른다. | Resume |
| 주요 속성 | employment | Employment | - | 고용 형태(정규직, 계약직 등)를 나타내는 속성. | Resume |
| 주요 속성 | type | Type | - | 구분을 나타내는 이넘/문자열. 섹션 타입 등에 사용. | Section |
| 주요 속성 | highlight | Highlight | - | 핵심 성과나 강조 포인트. | Resume |
| 주요 속성 | tech | Technology | - | 사용 기술을 나타내는 단어. | Resume |
| 주요 속성 | stack | Stack | - | 기술 스택을 나타내는 용어. `tech_stack` 구성에 사용. | Resume |
| 주요 속성 | role | Role | - | 프로젝트나 경력에서 맡은 역할. | Resume |
| 주요 속성 | keyword | Keyword | - | 태그나 기술 키워드. | Resume |
| 주요 속성 | proficiency | Proficiency | - | 숙련도 수준을 표현하는 값. | Resume |
| 주요 속성 | label | Label | - | 사용자에게 노출되는 짧은 텍스트 표시. | Resume |
| 주요 속성 | text | Text | - | 본문/요약 등 자유 텍스트 필드. | Resume |
| 주요 속성 | result | Result | - | 프로젝트나 작업의 결과 내용을 기록. | Resume |
| 주요 속성 | link | Link | - | 외부 리소스를 연결하는 항목. | Resume |
| 주요 속성 | file | File | - | 저장된 파일이나 문서를 나타내는 참조. | Export, Storage |
| 주요 속성 | error | Error | - | 실패 상태와 관련된 에러 정보. | Export |
| 주요 속성 | reason | Reason | - | 실패 원인을 설명하는 텍스트. | Export |
| 주요 속성 | month | Month | - | 1~12 범위의 월 정보를 나타내는 값. | Quota |
| 주요 속성 | year | Year | - | 4자리 연도 값. | Quota |
| 주요 속성 | year_month | Year-Month | - | `YYYY-MM` 포맷으로 결합한 기간 키. | Quota |
| 주요 속성 | pdf | Portable Document Format | PDF | 문서 포맷의 한 종류. | Export |
| 주요 속성 | count | Count | - | 개수나 횟수를 나타내는 정수 값. | Quota |
| 주요 속성 | asset | Asset | - | 템플릿 렌더링에 필요한 정적 자원. | Template |
| 주요 속성 | reference | Reference | - | 다른 리소스를 참조하는 식별자. | Template |
| 주요 속성 | attachment | Attachment | - | 업로드된 파일이나 문서. | Storage |
| 주요 속성 | filename | File Name | - | 파일 시스템 또는 스토리지에 저장된 이름. | Storage |
| 주요 속성 | size | Size | - | 용량 또는 길이를 나타내는 수치. | Storage |
| 주요 속성 | description | Description | - | 추가 설명이나 비고 텍스트. | Resume |
| 주요 속성 | organization | Organization | - | 기관이나 회사명. | Resume |
| 주요 속성 | institution | Institution | - | 교육 기관 이름. | Resume |
| 주요 속성 | degree | Degree | - | 학위 종류. | Resume |
| 주요 속성 | major | Major | - | 전공 분야. | Resume |
| 주요 속성 | score | Score | - | 평가 점수나 성취도. | Resume |
| 주요 속성 | level | Level | - | 숙련도 또는 단계. | Resume |
| 행위 | create | Create | - | 데이터가 새로 생성되는 행위. `created_at` 컬럼 명명에 사용. | Backend |
| 행위 | update | Update | - | 데이터가 변경되는 행위. `updated_at` 컬럼 명명에 사용. | Backend |
| 행위 | delete | Delete | - | 데이터가 삭제되는 행위. `deleted_at` 컬럼 명명에 사용. | Backend |
| 날짜/시간 | at | Actual Timestamp | at | 특정 이벤트가 실제 발생한 시점(날짜+시간)을 기록할 때 사용. 컬럼은 `_at` 접미사를 따른다. | created_at, updated_at, deleted_at |
| 날짜/시간 | datetime | DateTime | dt | 예약·희망과 같이 사용자가 지정한 변경 가능한 시점(날짜+시간). 컬럼은 `_dt` 접미사를 따른다. | reservation_dt, desired_delivery_dt |
| 날짜/시간 | date | Date | date | 시간 정보를 제외한 날짜를 표현. 주로 생년월일, 공개 일자 등에 사용. | birth_date, release_date |
| 날짜/시간 | time | Time | time | 날짜를 제외한 시간대 정보. 반복 일정이나 알림 시간 등에 사용. | opening_time, notification_time |
| 상태 | status | Status | - | 엔티티의 현재 상태를 나타내는 값. 컬럼은 `[entity]_status`를 따른다. | resume_status, export_status |
| 상태 | pending | Pending | - | 처리가 시작되기 전 대기 상태. | Export |
| 상태 | processing | Processing | - | 비동기 작업이 실행 중인 상태. | Export |
| 상태 | succeeded | Succeeded | - | 작업이 정상적으로 완료된 상태. | Export |
| 상태 | failed | Failed | - | 작업이 오류로 종료된 상태. 오류 메시지나 재시도가 필요하다. | Export |
| 섹션 타입 | basic_info | Basic Info Section | - | 이름, 연락처 등 기본 정보를 담는 섹션. | Resume, Section |
| 섹션 타입 | summary | Summary Section | - | 사용자 소개 요약 문단을 표현하는 섹션. | Resume, Section |
| 섹션 타입 | work | Work Section | - | 경력 정보를 담는 섹션. 다중 항목을 포함한다. | Resume, Section |
| 섹션 타입 | projects | Projects Section | - | 프로젝트 경험을 담는 섹션. 다중 항목과 링크를 포함한다. | Resume, Section |
| 섹션 타입 | skills | Skills Section | - | 보유 기술 키워드를 나열하는 섹션. | Resume, Section |
| 섹션 타입 | links | Links Section | - | 외부 링크를 모아두는 섹션. | Resume, Section |
| AI | summary | Summary | - | AI 보조 기능이 생성하는 이력서 요약 텍스트. 저장 여부는 기능 확장 시 결정. | AI 서비스 |
| AI | translate | Translation | - | AI가 수행하는 언어 번역 작업. 입력/출력 로케일을 명시해야 한다. | AI 서비스 |

> **Naming Rule:** 여기 정의된 단일어를 조합해 컬럼/필드명을 만든다. 예) `resume` + `id` → `resume_id`, `user` + `handle` → `user_handle`.

```text
예시 조합
- resume + status → resume_status
- pdf + export + count → pdf_export_count
- year + month → year_month
- section + summary → section_summary_type
```
