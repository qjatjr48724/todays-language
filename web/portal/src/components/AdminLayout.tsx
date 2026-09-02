import { Link, Outlet } from "react-router-dom";
import { signOut } from "firebase/auth";
import { auth } from "../lib/firebase";
import { useAuth } from "../hooks/useAuth";

export function AdminLayout() {
  const { user } = useAuth();

  return (
    <>
      <header className="site-header">
        <div className="container site-header-inner">
          <Link to="/admin/inquiries" className="logo">
            TL Admin
          </Link>
          <nav className="nav-links">
            <span className="muted">{user?.email}</span>
            <button
              type="button"
              className="btn btn-secondary"
              onClick={() => signOut(auth)}
            >
              로그아웃
            </button>
          </nav>
        </div>
      </header>
      <main className="container" style={{ padding: "24px 20px 48px" }}>
        <Outlet />
      </main>
    </>
  );
}
