import React, { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Header from '../../components/ui/Header';
import SidebarNavigation from '../../components/ui/SidebarNavigation';
import Button from '../../components/ui/Button';
import Input from '../../components/ui/Input';
import Select from '../../components/ui/Select';
import { Checkbox } from '../../components/ui/Checkbox';
import Timeline from '../../components/Timeline';
import CreateTaskModal from '../create-task-modal';
import { useAuth } from '../../contexts/AuthContext';
import { timelineService } from '../../services/timelineService';

const SOURCE_OPTIONS = [
  { label: 'All Items', value: 'all' },
  { label: 'Tasks', value: 'task' },
  { label: 'Activities', value: 'activity' }
];

const ENTITY_OPTIONS = [
  { label: 'All Entities', value: '' },
  { label: 'Accounts', value: 'account' },
  { label: 'Properties', value: 'property' },
  { label: 'Contacts', value: 'contact' },
  { label: 'Opportunities', value: 'opportunity' },
  { label: 'Prospects', value: 'prospect' }
];

const TimelinePage = () => {
  const navigate = useNavigate();
  const { user, loading: authLoading } = useAuth();
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [sourceType, setSourceType] = useState('all');
  const [entityType, setEntityType] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [showCompletedTasks, setShowCompletedTasks] = useState(true);
  const [showMineOnly, setShowMineOnly] = useState(true);
  const [showCreateTaskModal, setShowCreateTaskModal] = useState(false);
  const [lastRefresh, setLastRefresh] = useState(null);

  const loadTimeline = async () => {
    if (!user) return;
    setLoading(true);
    setError('');

    const result = await timelineService?.getTimeline({
      sourceType,
      entityType: entityType || null,
      userId: showMineOnly ? user?.id : null,
      includeCompletedTasks: showCompletedTasks,
      limit: 200,
      sortDirection: 'desc'
    });

    if (result?.success) {
      setItems(result?.data || []);
      setLastRefresh(new Date());
    } else {
      setItems([]);
      setError(result?.error || 'Failed to load timeline.');
    }

    setLoading(false);
  };

  useEffect(() => {
    if (!authLoading && user) {
      loadTimeline();
    }
  }, [authLoading, user, sourceType, entityType, showCompletedTasks, showMineOnly]);

  const filteredItems = useMemo(() => {
    if (!searchTerm) return items;
    const term = searchTerm?.toLowerCase();
    return (items || []).filter((item) => {
      const haystack = [
        item?.title,
        item?.description,
        item?.account_name,
        item?.property_name,
        item?.contact_name,
        item?.opportunity_name
      ]
        .filter(Boolean)
        .join(' ')
        .toLowerCase();
      return haystack.includes(term);
    });
  }, [items, searchTerm]);

  const handleLogActivity = () => {
    navigate('/log-activity');
  };

  const handleCreateTask = () => {
    setShowCreateTaskModal(true);
  };

  if (authLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div>Loading...</div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center space-y-4">
          <p>Please sign in to view the timeline.</p>
          <Button onClick={() => navigate('/login')}>Go to Login</Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Header
        userRole={user?.user_metadata?.role || 'rep'}
        onMenuToggle={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
        isMenuOpen={isMobileMenuOpen}
      />
      <SidebarNavigation
        userRole={user?.user_metadata?.role || 'rep'}
        isCollapsed={isSidebarCollapsed}
        onToggleCollapse={() => setIsSidebarCollapsed(!isSidebarCollapsed)}
        className="hidden lg:block"
      />
      {isMobileMenuOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div
            className="absolute inset-0 bg-black/50"
            onClick={() => setIsMobileMenuOpen(false)}
          />
          <SidebarNavigation
            userRole={user?.user_metadata?.role || 'rep'}
            isCollapsed={false}
            onToggleCollapse={() => setIsMobileMenuOpen(false)}
            className="relative z-10"
          />
        </div>
      )}

      <main className={`pt-16 transition-all duration-200 ${isSidebarCollapsed ? 'lg:pl-16' : 'lg:pl-60'}`}>
        <div className="p-6 space-y-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div className="space-y-2">
              <h1 className="text-2xl font-semibold text-foreground">Unified Timeline</h1>
              <p className="text-sm text-muted-foreground">
                Tasks and activities in one chronological feed.
              </p>
              {lastRefresh && (
                <p className="text-xs text-muted-foreground">
                  Last updated: {lastRefresh.toLocaleTimeString()}
                </p>
              )}
            </div>
            <div className="flex flex-wrap gap-2">
              <Button
                variant="outline"
                size="sm"
                iconName="RefreshCw"
                iconPosition="left"
                onClick={loadTimeline}
              >
                Refresh
              </Button>
              <Button
                variant="outline"
                size="sm"
                iconName="Plus"
                iconPosition="left"
                onClick={handleCreateTask}
              >
                Create Task
              </Button>
              <Button
                size="sm"
                iconName="Plus"
                iconPosition="left"
                onClick={handleLogActivity}
              >
                Log Activity
              </Button>
            </div>
          </div>

          {error && (
            <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
              {error}
            </div>
          )}

          <div className="rounded-lg border border-border bg-card p-4 space-y-4">
            <div className="grid gap-4 md:grid-cols-4">
              <Select
                label="Source"
                options={SOURCE_OPTIONS}
                value={sourceType}
                onChange={(value) => setSourceType(value)}
              />
              <Select
                label="Entity"
                options={ENTITY_OPTIONS}
                value={entityType}
                onChange={(value) => setEntityType(value)}
              />
              <Input
                label="Search"
                placeholder="Search timeline..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e?.target?.value)}
              />
            </div>
            <div className="flex flex-wrap gap-4 text-sm text-muted-foreground">
              <Checkbox
                checked={showMineOnly}
                label="Only my items"
                onChange={(checked) => setShowMineOnly(checked)}
              />
              <Checkbox
                checked={showCompletedTasks}
                label="Include completed tasks"
                onChange={(checked) => setShowCompletedTasks(checked)}
              />
            </div>
            <p className="text-xs text-muted-foreground">
              Showing the latest {filteredItems?.length || 0} items (max 200).
            </p>
          </div>

          <div className="rounded-lg border border-border bg-card p-6">
            <Timeline
              title="Timeline"
              items={filteredItems}
              loading={loading}
              onRefresh={loadTimeline}
              onCreateTask={handleCreateTask}
              onLogActivity={handleLogActivity}
            />
          </div>
        </div>
      </main>

      <CreateTaskModal
        isOpen={showCreateTaskModal}
        onClose={() => setShowCreateTaskModal(false)}
        onTaskCreated={() => {
          setShowCreateTaskModal(false);
          loadTimeline();
        }}
      />
    </div>
  );
};

export default TimelinePage;
