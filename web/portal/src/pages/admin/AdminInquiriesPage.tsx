import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { httpsCallable } from "firebase/functions";
import { functions } from "../../lib/firebase";
import { INQUIRY_STATUS_LABELS, SUPPORT_CATEGORIES } from "../../lib/constants";

type InquiryItem = {
  inquiryId: string;
  subject: string;
  category: string;
  status: string;
  email: string;
  createdAtMs: number;
};

function categoryLabel(value: string): string {
  return SUPPORT_CATEGORIES.find((item) => item.value === value)?.label ?? value;
}

function formatDate(ms: number): string {
  return new Date(ms).toLocaleString("ko-KR");
}

export function AdminInquiriesPage() {
  const [items, setItems] = useState<InquiryItem[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const list = httpsCallable(functions, "listSupportInquiriesAdmin");
        const result = await list({ limit: 100 });
        const data = result.data as { items: InquiryItem[] };
        setItems(data.items ?? []);
      } catch {
        setError("목록을 불러오지 못했습니다.");
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  if (loading) return <p>로딩 중…</p>;
  if (error) return <p className="error-text">{error}</p>;

  return (
    <>
      <h1>문의 목록</h1>
      {items.length === 0 ? (
        <p className="muted">접수된 문의가 없습니다.</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>제목</th>
              <th>유형</th>
              <th>상태</th>
              <th>이메일</th>
              <th>접수일</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item) => (
              <tr key={item.inquiryId}>
                <td>
                  <Link to={`/admin/inquiries/${item.inquiryId}`}>{item.subject}</Link>
                </td>
                <td>{categoryLabel(item.category)}</td>
                <td>
                  <span className="badge">
                    {INQUIRY_STATUS_LABELS[item.status] ?? item.status}
                  </span>
                </td>
                <td>{item.email}</td>
                <td>{formatDate(item.createdAtMs)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </>
  );
}
