# HANDOFF — 카페24 골라담기 옵션 UI

다른 컴퓨터/세션에서 이어서 작업하기 위한 인수인계 문서.

## 1. 과제 한 줄 요약
카페24 상품 상세에서 **기본 구매 흐름을 유지**하면서 "골라담기" 형태의 커스텀 옵션 UI를
구현한다. 디자인 재현보다 **카페24 옵션 연동/구매 흐름 안정성**이 우선.

- 과제 상세: `egnis_task.md`
- 피그마 시안(모바일): https://www.figma.com/design/MZB9FuyyLBYD8aK7Q3sRvK/?node-id=27-373

## 2. 테스트몰 / URL
- 스토어프론트(PC): https://leemjaejun.cafe24.com/product/detail.html?product_no=11
- 모바일 스킨: https://leemjaejun.cafe24.com/m/product/detail.html?product_no=11
- 편집: 카페24 관리자 → 디자인(PC/모바일) → 디자인 보관함 → "베이직" 스킨 디자인 편집
- ⚠️ 저장 후 반드시 **"대표 디자인"으로 설정**해야 스토어프론트에 반영됨
- 확인은 **시크릿 창(로그아웃)** 으로

## 3. 리포지토리 구조 (스킨 경로와 1:1 대응)
```
product/detail.html          # 상품상세. 상단 @css/@js include + #pickOptions 마운트 섹션
css/pick-options.css         # 골라담기 UI 스타일 (PC 인라인 + 모바일 바텀시트)
js/pick-options.config.js    # 표시 데이터(가격/할인/뱃지 등) — 값만 바꾸는 설정 파일
js/pick-options.js           # 동작 로직 (옵션 동기화/중복방지/횟수제한/모바일 시트)
egnis_task.md                # 과제 원문
QA_checklist.md              # QA 확인 절차 (제출 시 결과 채우기)
READMD.md                    # 작업 메모(진행 상태)
```
카페24 스킨에 올릴 때 경로를 그대로 맞춰야 함:
`/css/pick-options.css`, `/js/pick-options.config.js`, `/js/pick-options.js`.
detail.html 상단 include 지시자가 이 경로를 참조함.

## 4. 배포 방법 (중요)
detail.html은 파일을 "참조"만 한다. 카페24 편집창에서:
1. `product/detail.html` → 편집창 상품상세에 반영 (상단 @css/@js 3줄 + `#pickOptions` 섹션)
2. css/js 3개 파일 → 편집창 파일 목록에서 각 경로(`/css/`, `/js/`)에 생성/업로드
3. 저장 → 대표 디자인 설정
4. 반영 확인: 브라우저에서 파일 URL 직접 열기
   - https://leemjaejun.cafe24.com/css/pick-options.css (코드 보이면 OK, 404면 미업로드)
   - https://leemjaejun.cafe24.com/js/pick-options.js
- **JS/CSS만 수정한 경우 그 2개만 재업로드 + 강력 새로고침(Cmd+Shift+R)**

## 5. 구현 방식 요약
### 옵션 UI
- 카페24 기본 텍스트버튼 옵션(옵션값 8개: `10/30/50/100개입_1,_2`)은 DOM에 유지.
- JS가 그 옵션 버튼을 스캔해 `10/30/50/100개입` 그룹으로 묶고, `#pickOptionsList`에
  그룹별 카드(행)를 렌더링.
- 카드 클릭 → 해당 그룹의 "아직 안 담긴 다음 옵션값"의 **네이티브 옵션을 click** → 카페24
  선택상품 목록(`#totalProducts`)에 품목 추가. 구매/장바구니/금액은 전부 카페24 기본 로직.

### 동기화 / 중복방지 / 횟수제한
- `#totalProducts`를 `MutationObserver`로 감시 → 담기/삭제가 카드 카운트·활성화 상태에 양방향 반영.
- `state.pending`(낙관적 잠금)으로 연타 시 같은 옵션 중복 클릭 방지 (`PENDING_TIMEOUT` 800ms).
- suffix(_1,_2) 개수 = 그룹별 최대 추가 횟수. 초과 클릭 시 안내 메시지.

### 설정 분리
- 뱃지/가격/할인율/개당가/노출순서 등 **표시 데이터는 `pick-options.config.js`에만** 존재.
  값만 바꾸면 화면이 바뀜(구매 로직 무관).

### 모바일 (바텀시트)
- 카페24 **베이직 PC 스킨은 반응형 뷰포트가 없어** CSS `@media`가 모바일에서 안 켜짐.
- 그래서 `pick-options.js`가 **UA/화면폭으로 모바일을 감지해 `body.pick-mobile` 클래스**를 부여하고,
  CSS는 `body.pick-mobile ...` 규칙으로 하단 바텀시트(트리거 버튼 + 백드롭 + 시트 + 완료 버튼)를 켬.
- PC(데스크톱)는 그대로 인라인 카드. 모바일만 모달.

## 6. 현재 상태
- [x] 커스텀 옵션 UI 노출 (#1) — 초기화/카드 렌더 정상
- [x] 설정 JS 분리 (#8)
- [x] CSS (시안 토큰 기반) + 모바일 바텀시트
- [x] 스토어프론트 배포 + 대표 디자인 (PC/모바일 마운트·JS·CSS 로딩 확인됨)
- [ ] **실제 클릭 동작 QA 미완료** (#2 동기화 / #3 중복방지 / #4 횟수제한 / #6 구매흐름 / #7 활성화표시)
      → 시크릿 창에서 눌러보며 검증 필요. 절차: `QA_checklist.md`
- [ ] README(제출용) 미작성 — ① 구현방식 ② 설정 JS 구조 ③ 동기화 방식
- [ ] GIF 녹화(#2/#3/#4/#7) 미완료
- [ ] config.js 가격값은 시안 예시 숫자 → 실제 테스트상품 금액으로 교체 필요(표시용)

## 7. 다음 작업(권장 순서)
1. 시크릿 창에서 QA_checklist #2~#7 실제 클릭 검증. 막히면 `findNativeOptionButtons`
   셀렉터/`getSelectedOptionNames` 로직부터 점검.
2. 통과하면 GIF 녹화.
3. 제출용 README 작성(HANDOFF 5장 내용 정리).
4. config.js 가격 실제값 반영.

## 8. 주의사항
- 운영몰 금지(테스트몰만). 계정/API 키 등 민감정보 커밋 금지.
- 카페24 기본 구매/장바구니 로직 재구현 금지 — 보조 UI로만.
- 옵션 외 영역(이미지/상세설명/배너/구매버튼 외형) 수정 금지. PC 스킨이 비반응형이라
  브라우저 폭만 줄이면 스킨 자체가 깨지는데, 이는 과제 범위 밖(우리 UI 문제 아님).
- 콘솔의 `optimizer_user.php ... ERR_UNKNOWN_URL_SCHEME`는 카페24 자체 스크립트 최적화기
  로그로 우리 코드와 무관.

## 9. 로컬 셋업(다른 컴퓨터)
```bash
git clone <이 저장소 URL>
cd egnis
# 정적 파일이라 빌드 없음. 편집 후 카페24 편집창에 반영(4장 참고).
node --check js/pick-options.js   # 문법 확인용(선택)
```
