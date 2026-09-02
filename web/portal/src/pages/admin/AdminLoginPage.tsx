import { FormEvent, useState } from "react";
import { useNavigate } from "react-router-dom";
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "../../lib/firebase";
import { ADMIN_TOOLS_UID } from "../../lib/constants";
import { useAuth } from "../../hooks/useAuth";

export function AdminLoginPage() {
  const navigate = useNavigate();
  const { isAdmin, user } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  if (user && isAdmin) {
    navigate("/admin/inquiries", { replace: true });
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const cred = await signInWithEmailAndPassword(auth, email.trim(), password);
      if (cred.user.uid !== ADMIN_TOOLS_UID) {
        setError("관리자 계정이 아닙니다.");
        await auth.signOut();
        return;
      }
      navigate("/admin/inquiries");
    } catch {
      setError("로그인에 실패했습니다.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="container" style={{ padding: "48px 20px" }}>
      <div className="card" style={{ maxWidth: 420, margin: "0 auto" }}>
        <h2>관리자 로그인</h2>
        <form onSubmit={onSubmit}>
          <div className="form-field">
            <label htmlFor="admin-email">이메일</label>
            <input
              id="admin-email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="form-field">
            <label htmlFor="admin-password">비밀번호</label>
            <input
              id="admin-password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>
          {error && <p className="error-text">{error}</p>}
          <button type="submit" className="btn btn-primary" disabled={loading}>
            {loading ? "로그인 중…" : "로그인"}
          </button>
        </form>
      </div>
    </div>
  );
}
