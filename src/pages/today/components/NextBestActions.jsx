import React, { useEffect, useState } from 'react';
import Button from '../../../components/ui/Button';
import { nbaService } from '../../../services/nbaService';
import { useAuth } from '../../../contexts/AuthContext';

const MAX_ITEMS = 5;
const MAX_FOLLOW_UPS = 5;

const QUOTA_LABELS = {
  calls: 'Calls',
  new_contacts: 'New Contacts',
  touches: 'Touches'
};

const formatDueLabel = (dueAt) => {
  if (!dueAt) return null;
  const date = new Date(dueAt);
  if (Number.isNaN(date.getTime())) return null;
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const dueDay = new Date(date);
  dueDay.setHours(0, 0, 0, 0);

  if (dueDay.getTime() === today.getTime()) {
    return 'Today';
  }
  if (dueDay < today) {
    return 'Overdue';
  }
  return dueDay.toLocaleDateString();
};

const NextBestActions = ({
  className = '',
  onStartQueueItem,
  completedTaskId = null,
  refreshToken = 0,
  followUpsDue = [],
  quotaTasks = [],
  bestActionsLoading = false,
  onLogFollowUp,
  onLogQuota
}) => {
  const { userProfile, user } = useAuth();
  const userId = userProfile?.id || user?.id || null;
  const [isLoading, setIsLoading] = useState(true);
  const [queueItems, setQueueItems] = useState([]);

  useEffect(() => {
    if (!userId) return;
    let isMounted = true;

    const loadQueue = async () => {
      setIsLoading(true);
      const items = await nbaService?.getQueue(userId);
      if (!isMounted) return;
      setQueueItems(Array.isArray(items) ? items : []);
      setIsLoading(false);
    };

    loadQueue();

    return () => {
      isMounted = false;
    };
  }, [userId, refreshToken]);

  useEffect(() => {
    if (!completedTaskId) return;
    setQueueItems(prev => (prev || [])?.filter(item => {
      if (item?.sourceType !== 'task') return true;
      return String(item?.sourceId) !== String(completedTaskId);
    }));
  }, [completedTaskId]);

  const dedupedItems = (() => {
    const seen = new Set();
    const unique = [];
    (queueItems || []).forEach(item => {
      const key = item?.dedupeKey || (item?.sourceType === 'task' ? `task:${item?.sourceId || item?.id}` : item?.id);
      if (!key || seen.has(key)) return;
      seen.add(key);
      unique.push({ ...item, dedupeKey: key });
    });
    return unique;
  })();

  const visibleItems = dedupedItems?.slice(0, MAX_ITEMS);
  const followUpItems = (followUpsDue || [])?.slice(0, MAX_FOLLOW_UPS);
  const quotaItems = quotaTasks || [];

  const formatTemperature = (value) => {
    if (!value) return 'Cold';
    const normalized = String(value).toLowerCase();
    if (normalized === 'hot') return 'Hot';
    if (normalized === 'warm') return 'Warm';
    return 'Cold';
  };

  return (
    <div className={`bg-card rounded-xl border border-border p-6 ${className}`}>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold text-foreground">Next Best Actions</h2>
        <span className="text-xs text-muted-foreground">Queue</span>
      </div>
      <div className="space-y-3">
        {isLoading && (
          <div className="space-y-2">
            {[...Array(3)].map((_, index) => (
              <div
                key={`queue-skeleton-${index}`}
                className="h-16 rounded-lg border border-border/60 bg-muted/40 animate-pulse"
              />
            ))}
          </div>
        )}

        {!isLoading && visibleItems?.length === 0 && (
          <div className="rounded-lg border border-dashed border-border/60 p-4 text-sm text-muted-foreground text-center">
            You are caught up. No queued actions right now.
          </div>
        )}

        {!isLoading && visibleItems?.map((item) => {
          const dueLabel = formatDueLabel(item?.dueAt);
          const meta = [item?.reason, dueLabel].filter(Boolean).join(' - ');
          const itemKey = item?.sourceType === 'task'
            ? `task:${item?.sourceId || item?.id}`
            : item?.dedupeKey || item?.id;

          return (
            <div
              key={itemKey}
              className="flex flex-col gap-3 rounded-lg border border-border/60 bg-background/60 p-4 sm:flex-row sm:items-center sm:justify-between"
            >
              <div className="min-w-0">
                <div className="text-sm font-semibold text-foreground">{item?.title}</div>
                {item?.subtitle && (
                  <div className="text-xs text-muted-foreground mt-1">{item?.subtitle}</div>
                )}
                {meta && (
                  <div className="text-xs text-muted-foreground mt-1">{meta}</div>
                )}
              </div>
              <div className="flex items-center gap-2">
                <Button
                  size="sm"
                  onClick={() => onStartQueueItem?.(item)}
                  className="min-w-[88px]"
                >
                  Start
                </Button>
              </div>
            </div>
          );
        })}
      </div>

      <div className="mt-6 space-y-4">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-semibold text-foreground">Follow-ups Due</h3>
          <span className="text-xs text-muted-foreground">{followUpItems?.length || 0}</span>
        </div>
        {bestActionsLoading && (
          <div className="space-y-2">
            {[...Array(2)].map((_, index) => (
              <div
                key={`follow-up-skeleton-${index}`}
                className="h-14 rounded-lg border border-border/60 bg-muted/40 animate-pulse"
              />
            ))}
          </div>
        )}
        {!bestActionsLoading && followUpItems?.length === 0 && (
          <div className="rounded-lg border border-dashed border-border/60 p-3 text-xs text-muted-foreground text-center">
            No follow-ups due today.
          </div>
        )}
        {!bestActionsLoading && followUpItems?.map((item) => {
          const dueLabel = formatDueLabel(item?.next_touch_due_at);
          const temperatureLabel = formatTemperature(item?.temperature);
          const subtitle = item?.entity_type === 'contact'
            ? [item?.account_name, item?.stage].filter(Boolean).join(' - ')
            : item?.stage || null;
          const meta = [temperatureLabel, dueLabel].filter(Boolean).join(' - ');

          return (
            <div
              key={`${item?.entity_type}:${item?.entity_id}`}
              className="flex flex-col gap-3 rounded-lg border border-border/60 bg-background/60 p-4 sm:flex-row sm:items-center sm:justify-between"
            >
              <div className="min-w-0">
                <div className="text-sm font-semibold text-foreground">{item?.display_name}</div>
                {subtitle && (
                  <div className="text-xs text-muted-foreground mt-1">{subtitle}</div>
                )}
                {meta && (
                  <div className="text-xs text-muted-foreground mt-1">{meta}</div>
                )}
              </div>
              <div className="flex items-center gap-2">
                <Button
                  size="sm"
                  onClick={() => onLogFollowUp?.(item)}
                  className="min-w-[88px]"
                >
                  Log Touch
                </Button>
              </div>
            </div>
          );
        })}
      </div>

      <div className="mt-6 space-y-4">
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-semibold text-foreground">Daily Production Quota</h3>
        </div>
        {bestActionsLoading && (
          <div className="space-y-2">
            {[...Array(2)].map((_, index) => (
              <div
                key={`quota-skeleton-${index}`}
                className="h-16 rounded-lg border border-border/60 bg-muted/40 animate-pulse"
              />
            ))}
          </div>
        )}
        {!bestActionsLoading && quotaItems?.length === 0 && (
          <div className="rounded-lg border border-dashed border-border/60 p-3 text-xs text-muted-foreground text-center">
            No active quota goals yet.
          </div>
        )}
        {!bestActionsLoading && quotaItems?.map((item) => {
          const label = QUOTA_LABELS?.[item?.metric] || item?.metric;
          return (
            <div
              key={`quota:${item?.metric}`}
              className="flex flex-col gap-3 rounded-lg border border-border/60 bg-background/60 p-4 sm:flex-row sm:items-center sm:justify-between"
            >
              <div className="min-w-0">
                <div className="text-sm font-semibold text-foreground">{label}</div>
                <div className="text-xs text-muted-foreground mt-1">
                  Today: {item?.progress ?? 0}/{item?.targetToday ?? 0} - Week remaining: {item?.remainingWeek ?? 0}/{item?.goalWeek ?? 0}
                </div>
              </div>
              <div className="flex items-center gap-2">
                <Button
                  size="sm"
                  onClick={() => onLogQuota?.(item)}
                  className="min-w-[88px]"
                >
                  Log Call
                </Button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default NextBestActions;
