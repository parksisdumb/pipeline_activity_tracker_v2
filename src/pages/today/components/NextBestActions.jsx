import React, { useEffect, useState } from 'react';
import Button from '../../../components/ui/Button';
import { nbaService } from '../../../services/nbaService';
import { useAuth } from '../../../contexts/AuthContext';

const MAX_ITEMS = 5;

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

const NextBestActions = ({ className = '', onStartQueueItem, completedTaskId = null, refreshToken = 0 }) => {
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
    </div>
  );
};

export default NextBestActions;
