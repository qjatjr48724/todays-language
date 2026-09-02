import { Link, Outlet } from "react-router-dom";

export function PublicLayout() {
  return (
    <>
      <header className="site-header">
        <div className="container site-header-inner">
          <Link to="/" className="logo">
            Today&apos;s Language
          </Link>
          <nav className="nav-links">
            <Link to="/support/login">문의하기</Link>
          </nav>
        </div>
      </header>
      <main>
        <Outlet />
      </main>
      <footer className="site-footer">
        <div className="container">
          <p>운영: seok77 · 문의: qjatjr1285@naver.com</p>
          <p>
            <a href="/legal/privacy-ko.html" target="_blank" rel="noreferrer">
              개인정보 처리방침
            </a>
            {" · "}
            <a href="/legal/terms-ko.html" target="_blank" rel="noreferrer">
              이용약관
            </a>
          </p>
        </div>
      </footer>
    </>
  );
}
