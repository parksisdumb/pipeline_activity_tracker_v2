import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Header from '../../components/ui/Header';
import SidebarNavigation from '../../components/ui/SidebarNavigation';
import Button from '../../components/ui/Button';
import { useAuth } from '../../contexts/AuthContext';

const ProspectingPage = () => {
  const navigate = useNavigate();
  const { userProfile } = useAuth();
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    document.title = 'Prospecting - Pipeline Activity Tracker';
  }, []);

  return (
    <div className="min-h-screen bg-background">
      {/* Mobile Header */}
      <div className="lg:hidden">
        <Header
          userRole={userProfile?.role || 'rep'}
          onMenuToggle={() => setMobileMenuOpen(!mobileMenuOpen)}
          isMenuOpen={mobileMenuOpen}
        />
      </div>

      {/* Desktop Sidebar */}
      <div className="hidden lg:block">
        <SidebarNavigation
          userRole={userProfile?.role || 'rep'}
          isCollapsed={sidebarCollapsed}
          onToggleCollapse={() => setSidebarCollapsed(!sidebarCollapsed)}
        />
      </div>

      {/* Mobile Sidebar Overlay */}
      {mobileMenuOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div className="fixed inset-0 bg-black/50" onClick={() => setMobileMenuOpen(false)} />
          <SidebarNavigation
            userRole={userProfile?.role || 'rep'}
            isCollapsed={false}
            onToggleCollapse={() => setMobileMenuOpen(false)}
            className="relative z-10"
          />
        </div>
      )}

      {/* Main Content */}
      <main
        className={`transition-all duration-200 ease-out pt-16 lg:pt-0 ${
          sidebarCollapsed ? 'lg:ml-16' : 'lg:ml-60'
        }`}
      >
        <div className="p-6 max-w-5xl mx-auto space-y-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <h1 className="text-2xl lg:text-3xl font-bold text-foreground">Prospecting</h1>
              <p className="text-muted-foreground">
                Start new outreach motions and keep your pipeline full.
              </p>
            </div>
            <Button
              iconName="Plus"
              iconPosition="left"
              onClick={() => navigate('/contacts')}
            >
              Add New Contact
            </Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-card rounded-xl border border-border p-6 space-y-3">
              <h2 className="text-lg font-semibold text-foreground">Import / Build List</h2>
              <p className="text-sm text-muted-foreground">
                Connect lead sources, upload CSVs, or generate target lists.
              </p>
              <Button variant="secondary" disabled>
                Coming soon
              </Button>
            </div>

            <div className="bg-card rounded-xl border border-border p-6 space-y-3">
              <h2 className="text-lg font-semibold text-foreground">Prospecting cadence tips</h2>
              <ul className="text-sm text-muted-foreground space-y-2">
                <li>Day 1: Phone call + quick email</li>
                <li>Day 3: Follow-up call + voicemail recap</li>
                <li>Day 7: Decision maker outreach and site visit offer</li>
              </ul>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default ProspectingPage;
