import { Link } from "react-router-dom";

export function HomePage() {
  return (
    <div className="container hero">
      <h1>매일 조금씩, 오늘의 언어</h1>
      <p>
        Today&apos;s Language는 단어·문장·퀴즈로 꾸준히 학습하는 언어 앱입니다.
        앱에서 학습하고, 웹에서 문의를 남길 수 있습니다.
      </p>
      <div className="button-row">
        <Link className="btn btn-primary" to="/support/login">
          문의하기
        </Link>
        <span className="btn btn-secondary" aria-disabled="true">
          앱 다운로드 (준비 중)
        </span>
      </div>

      <div className="feature-grid">
        <article className="feature-card">
          <h3>일일 학습</h3>
          <p>매일 정해진 분량의 단어·문장·퀴즈로 꾸준히 학습합니다.</p>
        </article>
        <article className="feature-card">
          <h3>커리큘럼</h3>
          <p>난이도와 언어별 진도에 맞춘 학습 콘텐츠를 제공합니다.</p>
        </article>
        <article className="feature-card">
          <h3>고객 지원</h3>
          <p>앱 계정으로 로그인해 버그·계정·제안 문의를 접수할 수 있습니다.</p>
        </article>
      </div>
    </div>
  );
}
