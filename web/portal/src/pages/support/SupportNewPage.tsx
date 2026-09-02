import { FormEvent, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { httpsCallable } from "firebase/functions";
import { functions } from "../../lib/firebase";
import { SUPPORT_CATEGORIES } from "../../lib/constants";

export function SupportNewPage() {
  const navigate = useNavigate();
  const [category, setCategory] = useState("bug");
  const [subject, setSubject] = useState("");
  const [body, setBody] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const submit = httpsCallable(functions, "submitSupportInquiry");
      await submit({ category, subject, body });
      navigate("/support/done");
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "문의 접수에 실패했습니다.";
      setError(message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="container" style={{ padding: "32px 20px" }}>
      <div className="card" style={{ maxWidth: 640, margin: "0 auto" }}>
        <h2>새 문의</h2>
        <form onSubmit={onSubmit}>
          <div className="form-field">
            <label htmlFor="category">유형</label>
            <select
              id="category"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
            >
              {SUPPORT_CATEGORIES.map((item) => (
                <option key={item.value} value={item.value}>
                  {item.label}
                </option>
              ))}
            </select>
          </div>
          <div className="form-field">
            <label htmlFor="subject">제목</label>
            <input
              id="subject"
              maxLength={100}
              value={subject}
              onChange={(e) => setSubject(e.target.value)}
              required
            />
          </div>
          <div className="form-field">
            <label htmlFor="body">내용</label>
            <textarea
              id="body"
              maxLength={2000}
              value={body}
              onChange={(e) => setBody(e.target.value)}
              required
            />
          </div>
          {error && <p className="error-text">{error}</p>}
          <div className="button-row">
            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? "접수 중…" : "문의 접수"}
            </button>
            <Link className="btn btn-secondary" to="/">
              취소
            </Link>
          </div>
        </form>
      </div>
    </div>
  );
}
