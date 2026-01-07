import React, { useEffect, useState } from 'react';
import { useAuth } from '../../../contexts/AuthContext';
import { activitiesService } from '../../../services/activitiesService';
import { goalsService } from '../../../services/goalsService';
import { nbaService } from '../../../services/nbaService';

const ScoreboardMini = ({ className = '' }) => {
  const { userProfile, user } = useAuth();
  const userId = userProfile?.id || user?.id || null;
  const [loading, setLoading] = useState(true);
  const [scoreboard, setScoreboard] = useState({
    completedToday: 0,
    remaining: 0,
    pacePercent: null,
    dailyQuota: null
  });

  useEffect(() => {
    if (!userId) return;

    let isMounted = true;

    const loadScoreboard = async () => {
      setLoading(true);

      const todayStart = new Date();
      todayStart?.setHours(0, 0, 0, 0);
      const todayEnd = new Date();
      todayEnd?.setHours(23, 59, 59, 999);

      const [activityStatsResult, queueItems, goalsResult] = await Promise.all([
        activitiesService?.getActivityStats(userId, {
          dateFrom: todayStart?.toISOString(),
          dateTo: todayEnd?.toISOString()
        }),
        nbaService?.getQueue(userId),
        goalsService?.getCurrentWeekGoals(userId)
      ]);

      if (!isMounted) return;

      const completedToday = activityStatsResult?.success
        ? activityStatsResult?.data?.total || 0
        : 0;

      const remaining = Array.isArray(queueItems) ? queueItems?.length : 0;

      const weeklyTarget = goalsResult?.success
        ? (goalsResult?.data || [])?.reduce((sum, goal) => sum + (goal?.target_value || 0), 0)
        : 0;

      const dailyQuota = weeklyTarget > 0 ? weeklyTarget / 5 : null;
      const pacePercent = dailyQuota ? Math.round((completedToday / dailyQuota) * 100) : null;

      setScoreboard({
        completedToday,
        remaining,
        pacePercent,
        dailyQuota: dailyQuota ? Math.round(dailyQuota) : null
      });
      setLoading(false);
    };

    loadScoreboard();

    return () => {
      isMounted = false;
    };
  }, [userId]);

  const stats = [
    {
      label: 'Completed',
      value: loading ? '...' : String(scoreboard?.completedToday || 0),
      note: 'Today'
    },
    {
      label: 'Remaining',
      value: loading ? '...' : String(scoreboard?.remaining || 0),
      note: 'Queue'
    },
    {
      label: 'Pace',
      value: loading ? '...' : (scoreboard?.pacePercent !== null ? `${scoreboard?.pacePercent}%` : '--'),
      note: scoreboard?.dailyQuota ? `Goal ${scoreboard?.dailyQuota}/day` : 'No goal set'
    }
  ];

  return (
    <div className={`bg-card rounded-xl border border-border p-6 ${className}`}>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold text-foreground">Scoreboard</h2>
        <span className="text-xs text-muted-foreground">Mini</span>
      </div>
      <div className="grid grid-cols-2 lg:grid-cols-3 gap-4">
        {stats.map((stat) => (
          <div key={stat.label} className="rounded-lg border border-border/60 bg-background/60 p-3 text-center">
            <div className="text-2xl font-bold text-foreground">{stat.value}</div>
            <div className="text-xs font-medium text-muted-foreground uppercase tracking-wide mt-1">
              {stat.label}
            </div>
            <div className="text-[11px] text-muted-foreground mt-1">{stat.note}</div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ScoreboardMini;
