import { Link } from "react-router-dom";

export function SupportDonePage() {
  return (
    <div className="container" style={{ padding: "32px 20px" }}>
      <div className="card" style={{ maxWidth: 480, margin: "0 auto" }}>
        <h2>문의가 접수되었습니다</h2>
        <p className="muted">
          답변이 등록되면 앱의 「설정 → 문의 내역」에서 확인할 수 있습니다.
        </p>
        <Link className="btn btn-primary" to="/">
          홈으로
        </Link>
      </div>
    </div>
  );
}
