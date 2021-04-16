# church_diary_app

## 일기를 기록 및 공유할 수 있는 앱
## 디바이스 : 안드로이드 / iOS

### 1. 메인 기능(필수)
#### 1) 일기 기록 일기 기록 페이지에 4~5가지 문항에 따른 각각의 작성 섹션 필요 (1. 오늘 하루 가장 기억에 남는 일은? 2. 지금의 감정을 기록해보세요. 등등..)
#### 2) 회원가입 관리자의 승인 아래 지정된 회원이 가입할 수 있어야 함
#### 3) 캘린더 확인 내가 오늘 기록한 일기를 언제라도 열람 가능
#### 4) 관리자 페이지 회원가입 승인, 문항을 변경할 수 있는 기능, 팝업창 등록 기능(팝업 랜딩 가능)

### 2. 기타 기능(선택적)
#### 1) 피드에 공개 : 내가 오늘 기록한 일기를 공유하고 싶을 때 웹앱 내 피드 섹션에 공개 회원가입자 모두에게 공개
#### 2) 일기를 이미지로 저장 : 내가 오늘 기록한 일기를 이미지로 저장(추후 책으로 제작 가능하도록)

### 기타 참고 사항
#### - 총 가입자는 500명을 넘지 않을 예정 (200명 정도)
#### - 견적서 작성 시 디자인 견적 및 선택기능 견적 별도로 구성

## 진행사항
### 2021.02.26(금)
### - 페이지 구성 (Feed page, Calendar page, Myinfo page)
### - google login 까지 완료
### - table calendar 구성 중

### 2021.02.27(토)
### - table calendar 완료, apple sign in 완료
### - Write page 구현 중
### - Write page 디비에 저장 기능 추가
### - 질문 항목 불러오도록 구현 필요
### - 질문 항목 조회/수정 페이지 구현

### 2021.02.28(일)
### - 질문 항목 조회/수정 페이지 구현완료
### - 일기 작성시 질문항목 연동완료
### - 일기 작성완료 후 캘린더에서 조회 기능 구현완료
### - 피드 공유 기능 구현 완료
### - 일기 수정, 삭제 기능 구현 완료 (삭제하는 경우 피드에 공유된 게시글도 함께 삭제)
### - 피드 게시글 클릭시 팝업으로 전체 내용 나오게끔 구현완료

### 2021.03.04(목)
### - 피드 화면 스크롤 넣어주기
### - 구글 아닌 경우 프로필사진 없어서 가입할 때 동물그림으로 랜덤하게 넣어주도록 변경
### - 일기 등록시 사진 첨부 가능토록 변경 중 (현재 이미지 불러오기까지 완료)
### - PDF 추출 방법 연구

### 2021.03.06(토)
### - 질문 항목 캘린더로 관리

### 2021.03.07(일)
### - 일기 작성시 오늘날짜의 질문으로 초기 셋팅 (날짜도 오늘로 초기설정)
### - 일기 작성일자를 변경하는 경우 해당일자의 질문으로 불러와짐
### - 작성일자의 질문이 없는 경우 기본 질문항목으로 대체
### - image 불러와서 일기 업로드시 같이 업로드 되도록 구현 완료
### - 작성한 일기 수정시 피드에 올라간 항목까지 같이 업데이트
### - 피드 화면의 사진도 띄움
### - 내 정보 페이지 기본화면 구현 완료

### 2021.03.08(월)
### - 내 정보 페이지 및 정보수정 구현 완료 (이름, 전화번호)
### - 게시글에 최초 사진 첨부해서 게시할때 사진 업로드 안되는 오류 해결

### 2021.03.09(화)
### - 애플 자동로그인/로그아웃 구현 완료

### 2021.03.16(화)
### - 로그인화면, 폰트 변경
### - 전체 색상 변경
### - 앱 아이콘 생성
### - 로그인 화면 비율 조정

### 2021.03.18(목)
### - 회원가입시 이름, 또래 정보 UI 변경 (버튼 포함)
### - 작성완료 버튼 디자인변경
### - 일기 작성시 일기그림 삭제, 모서리 직사각형으로 변경 (일직선으로..)

### 2021.03.20(토)
### - 피드 공유 게시물에 작성자 정보 또래 / 이름 으로 변경
### - 프로필 사진 변경 가능하도록 변경
### - 글꼴 제목은 두껍게
### - 글 작성할때 날짜 선택하는 캘린더 디자인 변경 (명조폰트, 흰배경, 검은글씨)
### - 앱 실행 후 캘린더 화면으로 바로 가도록
### - 질문사항은 4가지는 고정, 날짜별 1개 추가질문 등록해서 총 5개
### - 토, 일 주말은 1개 질문만 나오도록..

### 2021.03.22(월)
### - 미래 날짜에 일기 작성 불가하도록 로직 추가
### - 회원가입 이후 phoneNumber 정보 -> grade로 변경 (구글로그인시)
### - 공유 취소 기능 추가

## 추가 구현 요청사항 ('21.03.20(토))
### - 관리자 변경할 수 있는 기능
### - 최초 가입시 승인 관련...

### 2021.03.25(목)
### - 애플 심사거절 : SNS로그인(애플로그인)시 정보입력화면 제거 요청 : 이름, 또래, 인바디점수 등)
### - 애플기기에서 SNS 로그인시 바로 홈화면으로 진입하도록 변경

### 2021.03.27(토)
### - 애플 심사거절 : 관리자 승인된 사용자만 앱 이용가능하도록 구현하면 안됨
### - 관리자 승인 기능 제
### - 최초 프로필이미지 없는 상태에서 등록할때 Red screen 나오는 오류 제거

### 2021.04.01(목)
### - pdf 변환부분 잘 안되고 있음
### - ttf 글꼴 다루는게 안되는  (Cannot open file, path = '/fonts/NanumMyeongjo.ttf' (OS Error: No such file or directory, errno = 2))

### 2021.04.15(목)
### - 이모티콘 깨지지 않도록 수정 (utf-16)
### - 피드 화면의 프로필 이미지 삭제
### - 이미지 전반적으로 퀄리티 낮춰서 데이터사용량 낮춤
<고정질문>
월~금
1. 오늘 하루를 돌아보며, 경험한 일들 중 떠오르는 것은 무엇인가요?
2. 그 경험 속에 하나님께서는 나에게 어떤 말씀을 하시나요?
3. 나에게 말씀하신 하나님께 나는 어떤 대답을 할 수 있을까요?
4. 내일의 일정을 정리하고, 하나님은 어떤 모습으로 함께하실지 정리해 보세요.
5. 오늘 내 신앙상태를 날씨로 표현한다면?
토
오늘 예배자로서의 내 모습을 한 문장으로 요약해보기
일
오늘 말씀을 요약하고, 내 삶에 어떻게 적용할 수 있는지 생각해보기

### 앱 스토어 출시 준비
### - 앱 소개