import React, { useEffect, useMemo, useState } from 'react';
import { startOfWeek, endOfWeek, format } from 'date-fns';
import { useNavigate } from 'react-router-dom';
import Icon from '../../../components/AppIcon';
import Button from '../../../components/ui/Button';
import { useAuth } from '../../../contexts/AuthContext';
import { activitiesService } from '../../../services/activitiesService';
import { goalsService } from '../../../services/goalsService';
import { prospectsService } from '../../../services/prospectsService';
import { opportunitiesService } from '../../../services/opportunitiesService';
import { nbaService } from '../../../services/nbaService';
import { growService } from '../../../services/growService';

const buildStatus = (actual, target, paceRatio) => {
  if (!target || target <= 0) {
    return { label: 'No Goal', tone: 'text-muted-foreground bg-muted/40' };
  }
  if (actual >= target) {
    return { label: 'Ahead', tone: 'text-success bg-success/10' };
  }
  if (actual >= target * paceRatio) {
    return { label: 'On Pace', tone: 'text-blue-600 bg-blue-100/60' };
  }
  return { label: 'Behind', tone: 'text-warning bg-warning/10' };
};

const ReviewMode = ({ className = '' }) => {
  const navigate = useNavigate();
  const { userProfile, session } = useAuth();
  const userId = userProfile?.id || session?.user?.id || null;
  const [loading, setLoading] = useState(true);
  const [pacingData, setPacingData] = useState([]);
  const [growthSummary, setGrowthSummary] = useState({
    accounts: 0,
    contacts: 0,
    touches: 0
  });
  const [funnelData, setFunnelData] = useState([]);
  const [pipelineValue, setPipelineValue] = useState({ total: 0, weighted: 0 });
  const [recentActivities, setRecentActivities] = useState([]);
  const [riskFlags, setRiskFlags] = useState([]);

  const weekRange = useMemo(() => {
    const now = new Date();
    const weekStart = startOfWeek(now);
    const weekEnd = endOfWeek(now);
    return {
      from: format(weekStart, 'yyyy-MM-dd'),
      to: format(weekEnd, 'yyyy-MM-dd'),
      label: `${format(weekStart, 'MMM d')} - ${format(weekEnd, 'MMM d, yyyy')}`,
      start: weekStart,
      end: weekEnd
    };
  }, []);

  useEffect(() => {
    if (!userId) return;
    let isMounted = true;

    const loadReviewData = async () => {
      setLoading(true);

      const [goalsResult, activityStatsResult, prospectsResult, pipelineResult, recentResult, overdueResult, queueItems, growthResult] = await Promise.all([
        goalsService?.getCurrentWeekGoals(userId),
        activitiesService?.getActivityStats(userId, { dateFrom: weekRange.from, dateTo: weekRange.to }),
        prospectsService?.getProspectStats(),
        opportunitiesService?.getPipelineMetrics(),
        activitiesService?.getRecentActivities(userId, 8),
        activitiesService?.getOverdueFollowUps(userId, 20),
        nbaService?.getQueue(userId),
        growService?.getGrowthCounts({
          userId,
          dateFrom: weekRange?.start?.toISOString(),
          dateTo: weekRange?.end?.toISOString()
        })
      ]);

      if (!isMounted) return;

      const goalsMap = {};
      (goalsResult?.success ? goalsResult?.data : [])?.forEach(goal => {
        goalsMap[goal?.goal_type] = goal?.target_value || 0;
      });

      const kpi = activityStatsResult?.success ? activityStatsResult?.data?.kpiMetrics || {} : {};
      const dayIndex = (() => {
        const day = new Date().getDay();
        if (day === 0) return 5;
        return Math.min(Math.max(day, 1), 5);
      })();
      const paceRatio = dayIndex / 5;

      const emailDmActual = (kpi?.emails_sent || 0) + (kpi?.dm_conversations || 0);
      const emailDmTarget = (goalsMap?.emails_sent || 0) + (goalsMap?.dm_conversations || 0);

      const pacingRows = [
        { key: 'pop_ins', label: 'Pop-ins', actual: kpi?.pop_ins || 0, target: goalsMap?.pop_ins || 0 },
        { key: 'phone_calls_made', label: 'Calls', actual: kpi?.phone_calls_made || 0, target: goalsMap?.phone_calls_made || 0 },
        { key: 'emails_dm', label: 'Emails / DMs', actual: emailDmActual, target: emailDmTarget },
        { key: 'assessments_booked', label: 'Assessments', actual: kpi?.assessments_booked || 0, target: goalsMap?.assessments_booked || 0 },
        { key: 'proposals_sent', label: 'Proposals', actual: kpi?.proposals_sent || 0, target: goalsMap?.proposals_sent || 0 },
        { key: 'wins', label: 'Wins', actual: kpi?.wins || 0, target: goalsMap?.wins || 0 }
      ].map(row => ({
        ...row,
        status: buildStatus(row.actual, row.target, paceRatio)
      }));

      const prospectCounts = prospectsResult?.success ? prospectsResult?.data : {};
      const pipelineMetrics = pipelineResult?.success ? pipelineResult?.data : [];

      const getStageCount = (stage) => {
        const metric = pipelineMetrics?.find(item => item?.stage === stage);
        return metric?.count_opportunities || 0;
      };

      const totalPipelineValue = pipelineMetrics?.reduce((sum, metric) => sum + (metric?.total_value || 0), 0);
      const weightedPipelineValue = pipelineMetrics?.reduce((sum, metric) => {
        const totalValue = metric?.total_value || 0;
        const avgProb = metric?.avg_probability || 0;
        return sum + (totalValue * avgProb) / 100;
      }, 0);

      const funnelRows = [
        { label: 'Prospects', value: prospectCounts?.total || 0 },
        { label: 'Contacted', value: prospectCounts?.contacted || 0 },
        { label: 'Qualified', value: getStageCount('qualified') },
        { label: 'Assessment', value: kpi?.assessments_booked || 0 },
        { label: 'Proposal', value: getStageCount('proposal_sent') },
        { label: 'Negotiation', value: getStageCount('negotiation') },
        { label: 'Won', value: getStageCount('won') }
      ];

      const overdueFollowUps = overdueResult?.success ? overdueResult?.data?.length || 0 : 0;
      const staleOpportunities = Array.isArray(queueItems)
        ? queueItems?.filter(item => item?.sourceType === 'opportunity')?.length
        : 0;

      const flags = [
        overdueFollowUps > 0 && {
          label: 'Overdue follow-ups',
          value: overdueFollowUps,
          tone: 'text-warning bg-warning/10',
          onClick: () => navigate('/activities')
        },
        staleOpportunities > 0 && {
          label: 'Stale opportunities',
          value: staleOpportunities,
          tone: 'text-orange-600 bg-orange-100/60',
          onClick: () => navigate('/opportunities')
        }
      ].filter(Boolean);

      setPacingData(pacingRows);
      setFunnelData(funnelRows);
      setPipelineValue({ total: totalPipelineValue || 0, weighted: weightedPipelineValue || 0 });
      setRecentActivities(recentResult?.success ? recentResult?.data : []);
      setRiskFlags(flags);
      if (growthResult?.success) {
        setGrowthSummary(growthResult?.data || { accounts: 0, contacts: 0, touches: 0 });
      }
      setLoading(false);
    };

    loadReviewData();

    return () => {
      isMounted = false;
    };
  }, [navigate, userId, weekRange]);

  return (
    <div className={`space-y-6 ${className}`}>
      <div className="bg-card rounded-xl border border-border p-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-lg font-semibold text-foreground">Performance Pacing</h2>
            <p className="text-sm text-muted-foreground">Week of {weekRange.label}</p>
          </div>
          {loading && <div className="animate-spin w-4 h-4 border-2 border-primary border-t-transparent rounded-full" />}
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {pacingData?.map(item => (
            <div key={item.key} className="flex items-center justify-between rounded-lg border border-border/60 bg-background/60 p-3">
              <div>
                <div className="text-sm font-semibold text-foreground">{item.label}</div>
                <div className="text-xs text-muted-foreground">{item.actual} / {item.target || 0}</div>
              </div>
              <span className={`text-xs font-medium px-2 py-1 rounded-full ${item.status?.tone}`}>
                {item.status?.label}
              </span>
            </div>
          ))}
        </div>
      </div>

      <div className="bg-card rounded-xl border border-border p-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-lg font-semibold text-foreground">Growth Performance</h2>
            <p className="text-sm text-muted-foreground">Week of {weekRange.label}</p>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          {[
            { label: 'New Accounts', actual: growthSummary?.accounts || 0, target: 10 },
            { label: 'New Contacts', actual: growthSummary?.contacts || 0, target: 15 },
            { label: 'Outbound Touches', actual: growthSummary?.touches || 0, target: 25 }
          ]?.map(item => (
            <div key={item.label} className="flex items-center justify-between rounded-lg border border-border/60 bg-background/60 p-3">
              <div>
                <div className="text-sm font-semibold text-foreground">{item.label}</div>
                <div className="text-xs text-muted-foreground">{item.actual} / {item.target}</div>
              </div>
              <span className={`text-xs font-medium px-2 py-1 rounded-full ${
                item.actual >= item.target ? 'text-success bg-success/10' : 'text-muted-foreground bg-muted/40'
              }`}>
                {item.actual >= item.target ? 'Hit' : 'In progress'}
              </span>
            </div>
          ))}
        </div>
      </div>

      <div className="bg-card rounded-xl border border-border p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-foreground">Funnel Health Snapshot</h2>
          <Button variant="ghost" size="sm" onClick={() => navigate('/opportunities')}>
            View pipeline
          </Button>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-7 gap-3">
          {funnelData?.map(item => (
            <div key={item.label} className="rounded-lg border border-border/60 bg-background/60 p-3 text-center">
              <div className="text-lg font-semibold text-foreground">{item.value}</div>
              <div className="text-xs text-muted-foreground">{item.label}</div>
            </div>
          ))}
        </div>
        <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-3 text-sm text-muted-foreground">
          <div className="flex items-center gap-2">
            <Icon name="DollarSign" size={14} />
            Total pipeline value: {new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(pipelineValue.total || 0)}
          </div>
          <div className="flex items-center gap-2">
            <Icon name="TrendingUp" size={14} />
            Weighted value: {new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(pipelineValue.weighted || 0)}
          </div>
        </div>
      </div>

      <div className="bg-card rounded-xl border border-border p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-foreground">Activity Summary</h2>
          <Button variant="ghost" size="sm" onClick={() => navigate('/activities')}>
            View all
          </Button>
        </div>
        <div className="space-y-3">
          {recentActivities?.map(activity => (
            <div key={activity?.id} className="rounded-lg border border-border/60 bg-background/60 p-3">
              <div className="flex items-center justify-between">
                <div className="text-sm font-semibold text-foreground">
                  {activity?.activity_type || 'Activity'}
                </div>
                <div className="text-xs text-muted-foreground">
                  {activity?.activity_date ? new Date(activity?.activity_date)?.toLocaleString() : ''}
                </div>
              </div>
              <div className="text-xs text-muted-foreground mt-1">
                {activity?.account?.name || 'Unknown Account'}
                {activity?.contact ? ` • ${activity?.contact?.first_name} ${activity?.contact?.last_name}` : ''}
              </div>
              {activity?.outcome && (
                <div className="mt-2 inline-flex rounded-full bg-muted/50 px-2 py-1 text-xs text-muted-foreground">
                  {activity?.outcome}
                </div>
              )}
            </div>
          ))}
          {!recentActivities?.length && (
            <div className="text-sm text-muted-foreground text-center py-6">
              No recent activities logged.
            </div>
          )}
        </div>
      </div>

      {riskFlags?.length > 0 && (
        <div className="bg-card rounded-xl border border-border p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-foreground">Risk & Attention</h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {riskFlags?.map(flag => (
              <button
                key={flag?.label}
                type="button"
                onClick={flag?.onClick}
                className="flex items-center justify-between rounded-lg border border-border/60 bg-background/60 p-3 text-left hover:border-primary/40 hover:bg-primary/5 transition-colors"
              >
                <div>
                  <div className="text-sm font-semibold text-foreground">{flag?.label}</div>
                  <div className="text-xs text-muted-foreground">Needs attention</div>
                </div>
                <span className={`text-sm font-semibold px-2 py-1 rounded-full ${flag?.tone}`}>
                  {flag?.value}
                </span>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default ReviewMode;
