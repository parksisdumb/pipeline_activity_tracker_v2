import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import Header from '../../components/ui/Header';
import SidebarNavigation from '../../components/ui/SidebarNavigation';
import Button from '../../components/ui/Button';
import Input from '../../components/ui/Input';
import Select from '../../components/ui/Select';
import { Checkbox } from '../../components/ui/Checkbox';
import Icon from '../../components/AppIcon';
import { followUpRulesService } from '../../services/followUpRulesService';

const ENTITY_OPTIONS = [
  { label: 'Account', value: 'account' },
  { label: 'Contact', value: 'contact' }
];

const TEMPERATURE_OPTIONS = [
  { label: 'Cold', value: 'cold' },
  { label: 'Warm', value: 'warm' },
  { label: 'Hot', value: 'hot' }
];

const STAGE_SUGGESTIONS = [
  'default',
  '*',
  'onboarding',
  'proposal_sent',
  'negotiation',
  'estimating',
  'site_visit_scheduled'
];

const buildDefaultRule = () => ({
  entity_type: 'account',
  temperature: 'cold',
  stage: 'default',
  interval_days: 30,
  priority: 100,
  is_active: true
});

const FollowUpRulesSettings = () => {
  const { session, userProfile, ctx } = useAuth();
  const userRole = userProfile?.role || ctx?.user_data?.role || session?.user?.user_metadata?.role || 'rep';
  const tenantId = userProfile?.tenant_id || ctx?.user_data?.tenant_id || null;
  const canManage = ['manager', 'admin', 'super_admin'].includes(userRole);

  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [rules, setRules] = useState([]);
  const [deletedRuleIds, setDeletedRuleIds] = useState([]);
  const [newRule, setNewRule] = useState(buildDefaultRule());
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  const [lastRefresh, setLastRefresh] = useState(null);

  const sortedRules = useMemo(() => {
    return [...(rules || [])].sort((a, b) => {
      if (a?.entity_type !== b?.entity_type) {
        return String(a?.entity_type || '').localeCompare(String(b?.entity_type || ''));
      }
      if (a?.temperature !== b?.temperature) {
        return String(a?.temperature || '').localeCompare(String(b?.temperature || ''));
      }
      const aPriority = Number.parseInt(a?.priority ?? 100, 10) || 100;
      const bPriority = Number.parseInt(b?.priority ?? 100, 10) || 100;
      if (aPriority !== bPriority) {
        return aPriority - bPriority;
      }
      return String(a?.stage || '').localeCompare(String(b?.stage || ''));
    });
  }, [rules]);

  const loadRules = useCallback(async () => {
    if (!tenantId) {
      setLoading(false);
      setError('Tenant ID is missing. Please re-authenticate.');
      return;
    }

    setLoading(true);
    setError('');
    setSuccessMessage('');

    const result = await followUpRulesService?.fetchRules(tenantId);
    if (result?.success) {
      setRules(result?.data || []);
      setDeletedRuleIds([]);
      setLastRefresh(new Date());
    } else {
      setError(result?.error || 'Unable to load follow-up rules.');
    }
    setLoading(false);
  }, [tenantId]);

  useEffect(() => {
    loadRules();
  }, [loadRules]);

  const handleRuleChange = (index, field, value) => {
    setRules(prev => {
      const updated = [...(prev || [])];
      updated[index] = { ...updated[index], [field]: value };
      return updated;
    });
  };

  const handleRemoveRule = (index) => {
    setRules(prev => {
      const updated = [...(prev || [])];
      const [removed] = updated.splice(index, 1);
      if (removed?.id) {
        setDeletedRuleIds(current => [...current, removed.id]);
      }
      return updated;
    });
  };

  const handleAddRule = () => {
    if (!newRule?.stage) {
      setError('Stage is required for a follow-up rule.');
      return;
    }
    setError('');
    setRules(prev => [...(prev || []), { ...newRule }]);
    setNewRule(buildDefaultRule());
  };

  const handleSave = async () => {
    if (!tenantId) {
      setError('Tenant ID is missing. Please re-authenticate.');
      return;
    }

    if (!canManage) {
      setError('You do not have permission to update follow-up rules.');
      return;
    }

    if (!rules?.length) {
      setError('Add at least one rule before saving.');
      return;
    }

    setSaving(true);
    setError('');
    setSuccessMessage('');

    const saveResult = await followUpRulesService?.saveRules(tenantId, rules);
    if (!saveResult?.success) {
      setError(saveResult?.error || 'Failed to save follow-up rules.');
      setSaving(false);
      return;
    }

    if (deletedRuleIds?.length) {
      const deleteResults = await Promise.all(
        deletedRuleIds?.map(ruleId => followUpRulesService?.deleteRule(ruleId))
      );
      const deleteError = deleteResults?.find(result => result?.success === false);
      if (deleteError?.error) {
        setError(deleteError?.error || 'Failed to delete one or more rules.');
        setSaving(false);
        return;
      }
    }

    setSuccessMessage('Follow-up rules updated.');
    setSaving(false);
    loadRules();
  };

  const toggleSidebar = () => setSidebarCollapsed(prev => !prev);
  const toggleMobileMenu = () => setMobileMenuOpen(prev => !prev);

  if (!tenantId) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center px-6 text-center">
        <div className="space-y-4 max-w-md">
          <h2 className="text-xl font-semibold text-foreground">Unable to load follow-up rules</h2>
          <p className="text-sm text-muted-foreground">
            We could not identify your tenant. Please sign out and sign back in, or contact your administrator.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <div className="hidden lg:block">
        <SidebarNavigation
          userRole={userRole}
          isCollapsed={sidebarCollapsed}
          onToggleCollapse={toggleSidebar}
        />
      </div>
      <div className="lg:hidden">
        <Header
          userRole={userRole}
          onMenuToggle={toggleMobileMenu}
          isMenuOpen={mobileMenuOpen}
        />
      </div>
      {mobileMenuOpen && (
        <div className="fixed inset-0 z-200 lg:hidden">
          <div className="fixed inset-0 bg-black/50" onClick={toggleMobileMenu} />
          <SidebarNavigation
            userRole={userRole}
            isCollapsed={false}
            onToggleCollapse={() => {}}
            className="relative z-210"
          />
        </div>
      )}
      <main className={`pt-16 lg:pt-0 transition-all duration-200 ${sidebarCollapsed ? 'lg:ml-16' : 'lg:ml-60'}`}>
        <div className="p-6 space-y-6">
          <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
            <div className="space-y-2">
              <h1 className="text-2xl font-bold text-foreground">Follow-up Rules</h1>
              <p className="text-sm text-muted-foreground">
                Configure next-touch intervals by entity, temperature, and stage. Lowest priority wins.
              </p>
              {lastRefresh && (
                <p className="text-xs text-muted-foreground">
                  Last updated: {lastRefresh.toLocaleTimeString()}
                </p>
              )}
            </div>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                iconName="RefreshCw"
                iconPosition="left"
                onClick={loadRules}
              >
                Refresh
              </Button>
              {canManage && (
                <Button
                  size="sm"
                  iconName="Save"
                  iconPosition="left"
                  onClick={handleSave}
                  loading={saving}
                >
                  Save Changes
                </Button>
              )}
            </div>
          </div>

          <div className="rounded-lg border border-border bg-card p-4 text-sm text-muted-foreground">
            <div className="flex items-start gap-3">
              <Icon name="Info" size={18} className="text-primary" />
              <div className="space-y-2">
                <p>
                  Rules are evaluated in order of <span className="font-medium text-foreground">priority</span> (lower
                  wins). Use <span className="font-medium text-foreground">default</span> for a catch-all rule or
                  <span className="font-medium text-foreground"> *</span> for wildcard stages.
                </p>
                <p>
                  Reps can override the interval per account or contact using the override field in the entity record.
                </p>
              </div>
            </div>
          </div>

          {!canManage && (
            <div className="rounded-lg border border-border bg-amber-50 px-4 py-3 text-sm text-amber-700">
              You have read-only access. Contact a manager or admin to update follow-up rules.
            </div>
          )}

          {error && (
            <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
              {error}
            </div>
          )}

          {successMessage && (
            <div className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
              {successMessage}
            </div>
          )}

          {canManage && (
            <div className="rounded-lg border border-border bg-card p-6 space-y-4">
              <div className="flex items-center gap-2">
                <Icon name="PlusCircle" size={18} className="text-primary" />
                <h2 className="text-lg font-semibold text-foreground">Add Rule</h2>
              </div>
              <div className="grid gap-4 md:grid-cols-5">
                <Select
                  label="Entity"
                  options={ENTITY_OPTIONS}
                  value={newRule?.entity_type}
                  onChange={(value) => setNewRule(prev => ({ ...prev, entity_type: value }))}
                />
                <Select
                  label="Temperature"
                  options={TEMPERATURE_OPTIONS}
                  value={newRule?.temperature}
                  onChange={(value) => setNewRule(prev => ({ ...prev, temperature: value }))}
                />
                <Input
                  label="Stage"
                  value={newRule?.stage}
                  list="follow-up-stage-options"
                  onChange={(e) => setNewRule(prev => ({ ...prev, stage: e?.target?.value }))}
                />
                <Input
                  label="Interval (days)"
                  type="number"
                  min="1"
                  max="365"
                  value={newRule?.interval_days}
                  onChange={(e) => setNewRule(prev => ({ ...prev, interval_days: e?.target?.value }))}
                />
                <Input
                  label="Priority"
                  type="number"
                  min="1"
                  value={newRule?.priority}
                  onChange={(e) => setNewRule(prev => ({ ...prev, priority: e?.target?.value }))}
                />
              </div>
              <div className="flex items-center justify-between">
                <Checkbox
                  checked={newRule?.is_active}
                  label="Active"
                  onChange={(checked) => setNewRule(prev => ({ ...prev, is_active: checked }))}
                />
                <Button
                  variant="secondary"
                  size="sm"
                  iconName="Plus"
                  iconPosition="left"
                  onClick={handleAddRule}
                >
                  Add Rule
                </Button>
              </div>
            </div>
          )}

          <div className="rounded-lg border border-border bg-card p-6 space-y-4">
            <div className="flex items-center justify-between">
              <div className="space-y-1">
                <h2 className="text-lg font-semibold text-foreground">Current Rules</h2>
                <p className="text-sm text-muted-foreground">
                  Changes are saved only when you click "Save Changes".
                </p>
              </div>
              <span className="text-xs text-muted-foreground">{rules?.length || 0} rules</span>
            </div>

            {loading && (
              <div className="space-y-2">
                {[...Array(3)].map((_, index) => (
                  <div
                    key={`rule-skeleton-${index}`}
                    className="h-16 rounded-lg border border-border/60 bg-muted/40 animate-pulse"
                  />
                ))}
              </div>
            )}

            {!loading && sortedRules?.length === 0 && (
              <div className="rounded-lg border border-dashed border-border/60 p-4 text-sm text-muted-foreground text-center">
                No rules found yet. Add one to get started.
              </div>
            )}

            {!loading && sortedRules?.length > 0 && (
              <div className="space-y-3">
                <div className="hidden lg:grid lg:grid-cols-12 gap-3 text-xs uppercase text-muted-foreground">
                  <div className="lg:col-span-2">Entity</div>
                  <div className="lg:col-span-2">Temperature</div>
                  <div className="lg:col-span-2">Stage</div>
                  <div className="lg:col-span-2">Interval</div>
                  <div className="lg:col-span-2">Priority</div>
                  <div className="lg:col-span-1">Active</div>
                  <div className="lg:col-span-1 text-right">Actions</div>
                </div>
                {sortedRules?.map((rule, index) => (
                  <div
                    key={rule?.id || `rule-${index}`}
                    className="grid gap-3 rounded-lg border border-border/60 bg-background/60 p-4 lg:grid-cols-12 lg:items-end"
                  >
                    <div className="lg:col-span-2">
                      <Select
                        options={ENTITY_OPTIONS}
                        value={rule?.entity_type}
                        onChange={(value) => handleRuleChange(index, 'entity_type', value)}
                        disabled={!canManage}
                      />
                    </div>
                    <div className="lg:col-span-2">
                      <Select
                        options={TEMPERATURE_OPTIONS}
                        value={rule?.temperature}
                        onChange={(value) => handleRuleChange(index, 'temperature', value)}
                        disabled={!canManage}
                      />
                    </div>
                    <div className="lg:col-span-2">
                      <Input
                        value={rule?.stage || ''}
                        list="follow-up-stage-options"
                        onChange={(e) => handleRuleChange(index, 'stage', e?.target?.value)}
                        disabled={!canManage}
                      />
                    </div>
                    <div className="lg:col-span-2">
                      <Input
                        type="number"
                        min="1"
                        max="365"
                        value={rule?.interval_days ?? ''}
                        onChange={(e) => handleRuleChange(index, 'interval_days', e?.target?.value)}
                        disabled={!canManage}
                      />
                    </div>
                    <div className="lg:col-span-2">
                      <Input
                        type="number"
                        min="1"
                        value={rule?.priority ?? ''}
                        onChange={(e) => handleRuleChange(index, 'priority', e?.target?.value)}
                        disabled={!canManage}
                      />
                    </div>
                    <div className="lg:col-span-1">
                      <Checkbox
                        checked={rule?.is_active !== false}
                        onChange={(checked) => handleRuleChange(index, 'is_active', checked)}
                        disabled={!canManage}
                      />
                    </div>
                    <div className="lg:col-span-1 flex justify-end">
                      {canManage && (
                        <Button
                          variant="ghost"
                          size="sm"
                          iconName="Trash2"
                          iconPosition="left"
                          onClick={() => handleRemoveRule(index)}
                        >
                          Remove
                        </Button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </main>

      <datalist id="follow-up-stage-options">
        {STAGE_SUGGESTIONS?.map(stage => (
          <option key={stage} value={stage} />
        ))}
      </datalist>
    </div>
  );
};

export default FollowUpRulesSettings;
