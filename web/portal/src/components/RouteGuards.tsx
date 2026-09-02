import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "../hooks/useAuth";

export function RequireUser() {
  const { user, loading } = useAuth();
  if (loading) return <p className="container">로딩 중…</p>;
  if (!user) return <Navigate to="/support/login" replace />;
  return <Outlet />;
}

export function RequireAdmin() {
  const { user, loading, isAdmin } = useAuth();
  if (loading) return <p className="container">로딩 중…</p>;
  if (!user) return <Navigate to="/admin/login" replace />;
  if (!isAdmin) return <p className="container">관리자 권한이 없습니다.</p>;
  return <Outlet />;
}
