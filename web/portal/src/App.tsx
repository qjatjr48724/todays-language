import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import { AuthProvider } from "./hooks/useAuth";
import { PublicLayout } from "./components/PublicLayout";
import { AdminLayout } from "./components/AdminLayout";
import { RequireAdmin, RequireUser } from "./components/RouteGuards";
import { HomePage } from "./pages/HomePage";
import { SupportLoginPage } from "./pages/support/SupportLoginPage";
import { SupportNewPage } from "./pages/support/SupportNewPage";
import { SupportDonePage } from "./pages/support/SupportDonePage";
import { AdminLoginPage } from "./pages/admin/AdminLoginPage";
import { AdminInquiriesPage } from "./pages/admin/AdminInquiriesPage";
import { AdminInquiryDetailPage } from "./pages/admin/AdminInquiryDetailPage";

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route element={<PublicLayout />}>
            <Route index element={<HomePage />} />
            <Route path="support/login" element={<SupportLoginPage />} />
            <Route element={<RequireUser />}>
              <Route path="support/new" element={<SupportNewPage />} />
              <Route path="support/done" element={<SupportDonePage />} />
            </Route>
          </Route>

          <Route path="admin/login" element={<AdminLoginPage />} />
          <Route element={<RequireAdmin />}>
            <Route path="admin" element={<AdminLayout />}>
              <Route index element={<Navigate to="inquiries" replace />} />
              <Route path="inquiries" element={<AdminInquiriesPage />} />
              <Route path="inquiries/:inquiryId" element={<AdminInquiryDetailPage />} />
            </Route>
          </Route>

          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
