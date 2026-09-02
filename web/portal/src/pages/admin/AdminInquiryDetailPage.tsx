import { FormEvent, useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { httpsCallable } from "firebase/functions";
import { functions } from "../../lib/firebase";
import { INQUIRY_STATUS_LABELS, SUPPORT_CATEGORIES } from "../../lib/constants";

type InquiryDetail = {
  inquiryId: string;
  subject: string;
  category: string;
  status: string;
  email: string;
  body: string;
  createdAtMs: number;
};

type MessageItem = {
  messageId: string;
  authorType: "user" | "admin";
  text: string;
  createdAtMs: number;
};

function categoryLabel(value: string): string {
  return SUPPORT_CATEGORIES.find((item) => item.value === value)?.label ?? value;
}

function formatDate(ms: number): string {
  return new Date(ms).toLocaleString("ko-KR");
}

export function AdminInquiryDetailPage() {
  const { inquiryId = "" } = useParams();
  const [inquiry, setInquiry] = useState<InquiryDetail | null>(null);
  const [messages, setMessages] = useState<MessageItem[]>([]);
  const [reply, setReply] = useState("");
  const [closeAfterReply, setCloseAfterReply] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  async function loadDetail() {
    setLoading(true);
    setError(null);
    try {
      const getDetail = httpsCallable(functions, "getSupportInquiryAdmin");
      const result = await getDetail({ inquiryId });
      const data = result.data as {
        inquiry: InquiryDetail;
        messages: MessageItem[];
      };
      setInquiry(data.inquiry);
      setMessages(data.messages);
    } catch {
      setError("문의를 불러오지 못했습니다.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    if (inquiryId) loadDetail();
  }, [inquiryId]);

  async function onSubmit(event: FormEvent) {
    event.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      const replyFn = httpsCallable(functions, "replySupportInquiryAdmin");
      await replyFn({
        inquiryId,
        text: reply,
        status: closeAfterReply ? "closed" : "answered",
      });
      setReply("");
      await loadDetail();
    } catch {
      setError("답변 등록에 실패했습니다.");
    } finally {
      setSubmitting(false);
    }
  }

  if (loading) return <p>로딩 중…</p>;
  if (error && !inquiry) return <p className="error-text">{error}</p>;
  if (!inquiry) return <p>문의를 찾을 수 없습니다.</p>;

  return (
    <>
      <p>
        <Link to="/admin/inquiries">← 목록</Link>
      </p>
      <h1>{inquiry.subject}</h1>
      <p className="muted">
        {categoryLabel(inquiry.category)} · {inquiry.email} ·{" "}
        {INQUIRY_STATUS_LABELS[inquiry.status] ?? inquiry.status} ·{" "}
        {formatDate(inquiry.createdAtMs)}
      </p>

      <div className="message-list" style={{ margin: "24px 0" }}>
        {messages.map((message) => (
          <article
            key={message.messageId}
            className={`message-item ${message.authorType === "admin" ? "admin" : ""}`}
          >
            <div className="message-meta">
              {message.authorType === "admin" ? "관리자" : "사용자"} ·{" "}
              {formatDate(message.createdAtMs)}
            </div>
            <p style={{ margin: 0, whiteSpace: "pre-wrap" }}>{message.text}</p>
          </article>
        ))}
      </div>

      <div className="card">
        <h2>답변 작성</h2>
        <form onSubmit={onSubmit}>
          <div className="form-field">
            <label htmlFor="reply">답변</label>
            <textarea
              id="reply"
              maxLength={2000}
              value={reply}
              onChange={(e) => setReply(e.target.value)}
              required
            />
          </div>
          <label style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 16 }}>
            <input
              type="checkbox"
              checked={closeAfterReply}
              onChange={(e) => setCloseAfterReply(e.target.checked)}
            />
            답변 후 문의 종료
          </label>
          {error && <p className="error-text">{error}</p>}
          <button type="submit" className="btn btn-primary" disabled={submitting}>
            {submitting ? "등록 중…" : "답변 등록"}
          </button>
        </form>
      </div>
    </>
  );
}
