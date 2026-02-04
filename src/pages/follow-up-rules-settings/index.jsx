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
  { label: 'Contact', value: 'contact' },
  { label: 'Property', value: 'property' }
];

const TEMPERATURE_OPTIONS = [
  { label: 'Cold', value: 'cold' },
  { label: 'Warm', value: 'warm' },
  { label: 'Hot', value: 'hot' }
];

const STAGE_SUGGESTIONS = {
  account: [
    'default',
    '*',
    'Prospect',
    'Contacted',
    'Vendor Packet Request',
    'Vendor Packet Submitted',
    'Approved for Work',
    'Actively Engaged'
  ],
  contact: [
    'default',
    '*',
    'Identified',
    'Reached',
    'DM Confirmed',
    'Engaged',
    'Dormant'
  ],
  property: [
    'default',
    '*',
    'Unassessed',
    'Assessment Scheduled',
    'Assessed',
    'Proposal Sent',
    'In Negotiation',
    'Won',
    'Lost'
  ]
};

const DEFAULT_STAGE_OPTIONS = ['default', '*'];

const CUSTOM_STAGE_VALUE = '__custom_stage__';

const mapStageOptions = (stages = []) => (stages || []).map(stage => ({ label: stage, value: stage }));

const STAGE_OPTIONS_BY_ENTITY = Object.fromEntries(
  Object.entries(STAGE_SUGGESTIONS).map(([entity, stages]) => [entity, mapStageOptions(stages)])
);

const DEFAULT_STAGE_OPTION_ITEMS = mapStageOptions(DEFAULT_STAGE_OPTIONS);

const makeClientId = () => `rule-${Date.now()}-${Math.random().toString(16).slice(2)}`;

const withClientId = (rule) => {
  if (rule?.client_id) return rule;
  return { ...rule, client_id: makeClientId() };
};

const buildDefaultRule = () => ({
  entity_type: 'account',
  temperature: 'cold',
  stage: 'default',
  interval_days: 30,
  priority: 100,
  is_active: true,
  custom_stage: false
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

  const rulesToRender = useMemo(() => rules || [], [rules]);

  const getStageBaseOptions = useCallback((entityType) => {
    return STAGE_SUGGESTIONS?.[entityType] || DEFAULT_STAGE_OPTIONS;
  }, []);

  const buildStageOptions = useCallback((entityType, currentStage) => {
    const baseStages = getStageBaseOptions(entityType);
    const options = [...(STAGE_OPTIONS_BY_ENTITY?.[entityType] || DEFAULT_STAGE_OPTION_ITEMS)];
    if (currentStage && !baseStages?.includes(currentStage)) {
      options.unshift({ label: currentStage, value: currentStage });
    }
    options.push({ label: 'Custom...', value: CUSTOM_STAGE_VALUE });
    return options;
  }, [getStageBaseOptions]);

  const isCustomStage = useCallback((entityType, stageValue) => {
    if (!stageValue) return false;
    const baseOptions = getStageBaseOptions(entityType);
    return !baseOptions?.includes(stageValue);
  }, [getStageBaseOptions]);

  const normalizeRuleForUi = useCallback((rule) => {
    const normalized = withClientId(rule);
    const entityType = normalized?.entity_type || 'account';
    const stageValue = normalized?.stage || 'default';
    const customStage = typeof normalized?.custom_stage === 'boolean'
      ? normalized.custom_stage
      : isCustomStage(entityType, stageValue);

    return {
      ...normalized,
      entity_type: entityType,
      temperature: normalized?.temperature || 'cold',
      stage: stageValue,
      interval_days: normalized?.interval_days ?? 30,
      priority: normalized?.priority ?? 100,
      is_active: normalized?.is_active !== false,
      custom_stage: customStage
    };
  }, [isCustomStage]);

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
      setRules((result?.data || []).map(normalizeRuleForUi));
      setDeletedRuleIds([]);
      setLastRefresh(new Date());
    } else {
      setError(result?.error || 'Unable to load follow-up rules.');
    }
    setLoading(false);
  }, [normalizeRuleForUi, tenantId]);

  useEffect(() => {
    loadRules();
  }, [loadRules]);

  const handleRuleChange = (clientId, field, value) => {
    setRules(prev => (prev || []).map(rule => {
      if (rule?.client_id !== clientId) return rule;
      if (field === 'entity_type') {
        return { ...rule, entity_type: value, stage: 'default', custom_stage: false };
      }
      return { ...rule, [field]: value };
    }));
  };

  const handleRuleStageSelect = (clientId, value) => {
    if (value === CUSTOM_STAGE_VALUE) {
      setRules(prev => (prev || []).map(rule => {
        if (rule?.client_id !== clientId) return rule;
        return { ...rule, stage: '', custom_stage: true };
      }));
      return;
    }
    setRules(prev => (prev || []).map(rule => {
      if (rule?.client_id !== clientId) return rule;
      return { ...rule, stage: value, custom_stage: false };
    }));
  };

  const handleRemoveRule = (clientId) => {
    setRules(prev => {
      const updated = (prev || []).filter(rule => rule?.client_id !== clientId);
      const removed = (prev || []).find(rule => rule?.client_id === clientId);
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
    const customStage = newRule?.custom_stage || isCustomStage(newRule?.entity_type, newRule?.stage);
    setRules(prev => [
      ...(prev || []),
      withClientId({ ...newRule, custom_stage: customStage })
    ]);
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
                  onChange={(value) => setNewRule(prev => ({ ...prev, entity_type: value, stage: 'default', custom_stage: false }))}
                />
                <Select
                  label="Temperature"
                  options={TEMPERATURE_OPTIONS}
                  value={newRule?.temperature}
                  onChange={(value) => setNewRule(prev => ({ ...prev, temperature: value }))}
                />
                <div className="space-y-2">
                  <Select
                    label="Stage"
                    key={`new-rule-stage-${newRule?.entity_type}-${newRule?.custom_stage ? 'custom' : 'base'}`}
                    options={buildStageOptions(newRule?.entity_type, newRule?.stage)}
                    value={newRule?.custom_stage ? CUSTOM_STAGE_VALUE : (newRule?.stage || '')}
                    onChange={(value) => {
                      if (value === CUSTOM_STAGE_VALUE) {
                        setNewRule(prev => ({ ...prev, stage: '', custom_stage: true }));
                      } else {
                        setNewRule(prev => ({ ...prev, stage: value, custom_stage: false }));
                      }
                    }}
                  />
                  {(newRule?.custom_stage || isCustomStage(newRule?.entity_type, newRule?.stage)) && (
                    <Input
                      label="Custom Stage"
                      value={newRule?.stage}
                      onChange={(e) => setNewRule(prev => ({ ...prev, stage: e?.target?.value, custom_stage: true }))}
                    />
                  )}
                </div>
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

            {!loading && rulesToRender?.length === 0 && (
              <div className="rounded-lg border border-dashed border-border/60 p-4 text-sm text-muted-foreground text-center">
                No rules found yet. Add one to get started.
              </div>
            )}

            {!loading && rulesToRender?.length > 0 && (
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
                {rulesToRender?.map((rule) => (
                  <div
                    key={rule?.id || rule?.client_id}
                    className="grid gap-3 rounded-lg border border-border/60 bg-background/60 p-4 lg:grid-cols-12 lg:items-end"
                  >
                    <div className="lg:col-span-2">
                      <Select
                        options={ENTITY_OPTIONS}
                        value={rule?.entity_type}
                        onChange={(value) => handleRuleChange(rule?.client_id, 'entity_type', value)}
                        disabled={!canManage}
                      />
                    </div>
                    <div className="lg:col-span-2">
                      <Select
                        options={TEMPERATURE_OPTIONS}
                        value={rule?.temperature}
                        onChange={(value) => handleRuleChange(rule?.client_id, 'temperature', value)}
                        disabled={!canManage}
                      />
                    </div>
                    <div className="lg:col-span-2">
                    <div className="space-y-2">
                      <Select
                        key={`${rule?.client_id}-stage-${rule?.entity_type}-${rule?.custom_stage ? 'custom' : 'base'}`}
                        options={buildStageOptions(rule?.entity_type, rule?.stage)}
                        value={rule?.custom_stage ? CUSTOM_STAGE_VALUE : (rule?.stage || '')}
                        onChange={(value) => handleRuleStageSelect(rule?.client_id, value)}
                        disabled={!canManage}
                      />
                        {(rule?.custom_stage || isCustomStage(rule?.entity_type, rule?.stage)) && (
                          <Input
                            value={rule?.stage || ''}
                            onChange={(e) => handleRuleChange(rule?.client_id, 'stage', e?.target?.value)}
                            disabled={!canManage}
                          />
                        )}
                      </div>
                    </div>
                    <div className="lg:col-span-2">
                      <Input
                        type="number"
                        min="1"
                        max="365"
                        value={rule?.interval_days ?? ''}
                        onChange={(e) => handleRuleChange(rule?.client_id, 'interval_days', e?.target?.value)}
                        disabled={!canManage}
                      />
                    </div>
                    <div className="lg:col-span-2">
                      <Input
                        type="number"
                        min="1"
                        value={rule?.priority ?? ''}
                        onChange={(e) => handleRuleChange(rule?.client_id, 'priority', e?.target?.value)}
                        disabled={!canManage}
                      />
                    </div>
                    <div className="lg:col-span-1">
                      <Checkbox
                        checked={rule?.is_active !== false}
                        onChange={(checked) => handleRuleChange(rule?.client_id, 'is_active', checked)}
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
                          onClick={() => handleRemoveRule(rule?.client_id)}
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
    </div>
  );
};

export default FollowUpRulesSettings;
