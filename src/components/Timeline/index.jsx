import React from 'react';
import Icon from '../AppIcon';
import Button from '../ui/Button';

const TASK_ICON_MAP = {
  follow_up: 'Phone',
  admin: 'Clipboard',
  system: 'Settings',
  meeting_setup: 'Users',
  assessment_scheduling: 'Calendar',
  proposal_review: 'FileText',
  pop_in: 'MapPin',
  dm_conversation: 'MessageCircle',
  follow_up_call: 'Phone',
  email: 'Mail',
  phone_call: 'Phone'
};

const ACTIVITY_ICON_MAP = {
  'Phone Call': 'Phone',
  'Email': 'Mail',
  'Meeting': 'Users',
  'Site Visit': 'MapPin',
  'Proposal Sent': 'FileText',
  'Follow-up': 'Clock',
  'Assessment': 'Clipboard',
  'Contract Signed': 'CheckCircle'
};

const CATEGORY_COLORS = {
  execute: 'bg-blue-100 text-blue-700',
  grow: 'bg-emerald-100 text-emerald-700',
  review: 'bg-purple-100 text-purple-700'
};

const STATUS_COLORS = {
  pending: 'bg-yellow-50 text-yellow-700 border-yellow-200',
  in_progress: 'bg-blue-50 text-blue-700 border-blue-200',
  overdue: 'bg-red-50 text-red-700 border-red-200',
  completed: 'bg-green-50 text-green-700 border-green-200',
  cancelled: 'bg-gray-50 text-gray-700 border-gray-200',
  canceled: 'bg-gray-50 text-gray-700 border-gray-200'
};

const OUTCOME_COLORS = {
  Successful: 'bg-green-100 text-green-700',
  'No Answer': 'bg-gray-100 text-gray-700',
  'Callback Requested': 'bg-yellow-100 text-yellow-700',
  'Not Interested': 'bg-red-100 text-red-700',
  Interested: 'bg-blue-100 text-blue-700',
  'Proposal Requested': 'bg-purple-100 text-purple-700',
  'Meeting Scheduled': 'bg-blue-100 text-blue-700',
  'Contract Signed': 'bg-emerald-100 text-emerald-700'
};

const formatLabel = (value) => {
  if (!value) return '';
  return String(value)
    .replace(/_/g, ' ')
    .replace(/\b\w/g, (letter) => letter.toUpperCase());
};

const getItemIcon = (item) => {
  if (item?.source_type === 'task') {
    const key = String(item?.category || item?.task_type || '').toLowerCase();
    return TASK_ICON_MAP[key] || 'CheckSquare';
  }
  return ACTIVITY_ICON_MAP?.[item?.activity_type] || 'Activity';
};

const getItemSubtitle = (item) => {
  const parts = [];
  if (item?.contact_name) parts.push(`Contact: ${item?.contact_name}`);
  if (item?.property_name) parts.push(`Property: ${item?.property_name}`);
  if (item?.opportunity_name) parts.push(`Opportunity: ${item?.opportunity_name}`);
  if (!parts?.length && item?.account_name) parts.push(`Account: ${item?.account_name}`);
  return parts.join(' | ');
};

const formatEventDate = (value) => {
  if (!value) return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '';

  const now = new Date();
  const dayMs = 1000 * 60 * 60 * 24;
  const diffDays = Math.round((date - now) / dayMs);

  if (diffDays === 0) return 'Today';
  if (diffDays === 1) return 'Tomorrow';
  if (diffDays === -1) return 'Yesterday';
  if (diffDays > 1 && diffDays < 7) return `In ${diffDays} days`;
  if (diffDays < -1 && diffDays > -7) return `${Math.abs(diffDays)} days ago`;

  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: date.getFullYear() !== now.getFullYear() ? 'numeric' : undefined
  });
};

const Timeline = ({
  title = 'Timeline',
  items = [],
  loading = false,
  onRefresh,
  onLogActivity,
  onCreateTask,
  emptyTitle = 'No timeline activity yet',
  emptyDescription = 'Tasks and activities for this record will show up here.'
}) => {
  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
        <span className="ml-3 text-muted-foreground">Loading timeline...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-3">
          <h3 className="text-lg font-semibold text-foreground">
            {title} ({items?.length || 0})
          </h3>
          {onRefresh && (
            <button
              onClick={onRefresh}
              className="p-1 text-muted-foreground hover:text-foreground transition-colors"
              title="Refresh timeline"
            >
              <Icon name="RefreshCw" size={16} />
            </button>
          )}
        </div>
        <div className="flex flex-wrap gap-2">
          {onCreateTask && (
            <Button size="sm" variant="outline" onClick={onCreateTask} iconName="Plus" iconPosition="left">
              Create Task
            </Button>
          )}
          {onLogActivity && (
            <Button size="sm" onClick={onLogActivity} iconName="Plus" iconPosition="left">
              Log Activity
            </Button>
          )}
        </div>
      </div>

      {items?.length === 0 ? (
        <div className="text-center py-12">
          <Icon name="Activity" size={48} className="text-muted-foreground mx-auto mb-4" />
          <h4 className="text-lg font-medium text-foreground mb-2">{emptyTitle}</h4>
          <p className="text-muted-foreground mb-4">{emptyDescription}</p>
          <div className="flex flex-wrap justify-center gap-2">
            {onCreateTask && (
              <Button onClick={onCreateTask} iconName="Plus" iconPosition="left">
                Create Task
              </Button>
            )}
            {onLogActivity && (
              <Button variant="outline" onClick={onLogActivity} iconName="Plus" iconPosition="left">
                Log Activity
              </Button>
            )}
          </div>
        </div>
      ) : (
        <div className="space-y-4">
          {items?.map((item, index) => {
            const subtitle = getItemSubtitle(item);
            const statusKey = String(item?.status || '').toLowerCase();
            const timelineCategory = String(item?.timeline_category || '').toLowerCase();
            const categoryClass = CATEGORY_COLORS?.[timelineCategory] || 'bg-muted text-muted-foreground';
            const statusClass = STATUS_COLORS?.[statusKey] || 'bg-muted text-muted-foreground border-border';
            const outcomeClass = OUTCOME_COLORS?.[item?.outcome] || 'bg-muted text-muted-foreground';
            const label = item?.source_type === 'task' ? 'Task' : 'Activity';

            return (
              <div key={`${item?.source_type || 'item'}:${item?.id || index}`} className="relative">
                {index < items?.length - 1 && (
                  <div className="absolute left-6 top-12 w-0.5 h-8 bg-border"></div>
                )}

                <div className="flex gap-4">
                  <div className="w-12 h-12 rounded-full bg-background border-2 border-border flex items-center justify-center flex-shrink-0">
                    <Icon name={getItemIcon(item)} size={20} className="text-foreground" />
                  </div>

                  <div className="flex-1 bg-card border border-border rounded-lg p-4">
                    <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-2 mb-2">
                      <div>
                        <div className="flex flex-wrap items-center gap-2">
                          <h4 className="font-medium text-foreground">{item?.title || label}</h4>
                          <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${categoryClass}`}>
                            {formatLabel(timelineCategory || 'execute')}
                          </span>
                          <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-muted text-muted-foreground">
                            {label}
                          </span>
                        </div>
                        {subtitle && (
                          <p className="text-sm text-muted-foreground mt-1">{subtitle}</p>
                        )}
                      </div>
                      <div className="text-sm text-muted-foreground">
                        {formatEventDate(item?.event_at)}
                      </div>
                    </div>

                    {item?.description && (
                      <p className="text-sm text-muted-foreground">{item?.description}</p>
                    )}

                    <div className="flex flex-wrap items-center gap-2 mt-3">
                      {item?.source_type === 'task' && item?.status && (
                        <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium border ${statusClass}`}>
                          {formatLabel(item?.status)}
                        </span>
                      )}
                      {item?.source_type === 'activity' && item?.outcome && (
                        <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${outcomeClass}`}>
                          {formatLabel(item?.outcome)}
                        </span>
                      )}
                      {item?.priority && (
                        <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-muted text-muted-foreground">
                          {formatLabel(item?.priority)}
                        </span>
                      )}
                      {item?.due_at && item?.source_type === 'task' && (
                        <span className="text-xs text-muted-foreground">
                          Due {formatEventDate(item?.due_at)}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default Timeline;
