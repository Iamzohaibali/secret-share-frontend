import { Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar.jsx";
import ProtectedRoute from "./components/ProtectedRoute.jsx";
import Landing from "./pages/Landing.jsx";
import Dashboard from "./pages/Dashboard.jsx";
import CreateSecret from "./pages/CreateSecret.jsx";
import SecretDetail from "./pages/SecretDetail.jsx";
import ShareView from "./pages/ShareView.jsx";
import NotFound from "./pages/NotFound.jsx";

//jhfjsdhajfag

export default function App() {
  return (
    <div className="min-h-screen bg-slate-950">
      <Navbar />
      <Routes>
        <Route path="/" element={<Landing />} />
        <Route path="/s/:shareId" element={<ShareView />} />
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          }
        />
        <Route
          path="/create"
          element={
            <ProtectedRoute>
              <CreateSecret />
            </ProtectedRoute>
          }
        />
        <Route
          path="/secrets/:id"
          element={
            <ProtectedRoute>
              <SecretDetail />
            </ProtectedRoute>
          }
        />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </div>
  );
}