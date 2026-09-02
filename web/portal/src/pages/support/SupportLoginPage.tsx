import { FormEvent, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "../../lib/firebase";

export function SupportLoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await signInWithEmailAndPassword(auth, email.trim(), password);
      navigate("/support/new");
    } catch {
      setError("로그인에 실패했습니다. 앱과 동일한 이메일·비밀번호를 사용해 주세요.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="container" style={{ padding: "32px 20px" }}>
      <div className="card" style={{ maxWidth: 480, margin: "0 auto" }}>
        <h2>문의하기 — 로그인</h2>
        <p className="muted">
          앱과 동일한 Firebase 계정으로 로그인합니다. 브라우저 세션은 앱과
          별도이므로 웹에서 한 번 더 로그인해야 할 수 있습니다.
        </p>
        <form onSubmit={onSubmit}>
          <div className="form-field">
            <label htmlFor="email">이메일</label>
            <input
              id="email"
              type="email"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="form-field">
            <label htmlFor="password">비밀번호</label>
            <input
              id="password"
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          {error && <p className="error-text">{error}</p>}
          <button type="submit" className="btn btn-primary" disabled={loading}>
            {loading ? "로그인 중…" : "로그인 후 문의 작성"}
          </button>
        </form>
        <p className="muted" style={{ marginTop: 16 }}>
          <Link to="/">홈으로</Link>
        </p>
      </div>
    </div>
  );
}
