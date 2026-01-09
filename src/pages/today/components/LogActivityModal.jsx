import React, { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import ActivityTypeSelector from '../../log-activity/components/ActivityTypeSelector';
import EntitySearchSelector from '../../log-activity/components/EntitySearchSelector';
import OutcomeNotesSection from '../../log-activity/components/OutcomeNotesSection';
import SelectedEntityInfo from '../../log-activity/components/SelectedEntityInfo';
import ActivityFormActions from '../../log-activity/components/ActivityFormActions';
import QuickEntityCreator from '../../log-activity/components/QuickEntityCreator';
import { activitiesService } from '../../../services/activitiesService';
import { accountsService } from '../../../services/accountsService';
import { contactsService } from '../../../services/contactsService';
import { propertiesService } from '../../../services/propertiesService';
import { prospectsService } from '../../../services/prospectsService';
import { opportunitiesService } from '../../../services/opportunitiesService';
import { tasksService } from '../../../services/tasksService';
import { useAuth } from '../../../contexts/AuthContext';
import Icon from '../../../components/AppIcon';
import Select from '../../../components/ui/Select';
import Button from '../../../components/ui/Button';

const ACTIVITY_MOTION_OPTIONS = [
  { value: 'prospecting', label: 'Prospecting', description: 'Early-stage outreach motion' },
  { value: 'follow_up', label: 'Follow-up', description: 'General follow-up on prior activity' },
  { value: 'opportunity_follow_up', label: 'Opportunity Follow-up', description: 'Follow-up tied to an opportunity' }
];

const ACTIVITY_TYPE_MAP = {
  call: 'Phone Call',
  email: 'Email',
  dm: 'Decision Maker Conversation',
  pop_in: 'Pop-in',
  follow_up: 'Follow-up'
};

const OUTCOME_MAP = {
  completed: 'Successful',
  contacted: 'Interested'
};

const resolveLinkedEntity = (data = {}) => {
  if (data?.opportunity) return { type: 'opportunity', id: data?.opportunity };
  if (data?.property) return { type: 'property', id: data?.property };
  if (data?.contact) return { type: 'contact', id: data?.contact };
  if (data?.account) return { type: 'account', id: data?.account };
  return { type: null, id: null };
};

const deriveDirectionFromTaskType = (taskType) => {
  if (taskType === 'follow_up') return 'outbound';
  if (taskType === 'admin' || taskType === 'system') return 'internal';
  return null;
};

const parseQueueItem = (queueItem) => {
  if (!queueItem) return { sourceType: null, sourceId: null };
  if (queueItem?.sourceId) {
    return { sourceType: queueItem?.sourceType || null, sourceId: queueItem?.sourceId };
  }
  const rawId = queueItem?.id ? String(queueItem.id) : '';
  if (rawId?.includes(':')) {
    const [prefix, id] = rawId.split(':');
    const resolvedType = queueItem?.sourceType || (prefix === 'opp' ? 'opportunity' : prefix);
    return { sourceType: resolvedType, sourceId: id };
  }
  return { sourceType: queueItem?.sourceType || null, sourceId: rawId || null };
};

const resolveFollowUpDueAt = (value) => {
  if (!value) return null;
  if (value instanceof Date) {
    if (Number.isNaN(value.getTime())) return null;
    return value.toISOString();
  }
  const raw = String(value);
  const hasTime = raw.includes('T') || raw.includes(':');
  const resolved = new Date(hasTime ? raw : `${raw}T09:00:00`);
  if (Number.isNaN(resolved.getTime())) return null;
  return resolved.toISOString();
};

const resolveEntityDisplayName = ({ task, selectedEntities }) => {
  const selectedName = selectedEntities?.contact?.label
    || selectedEntities?.opportunity?.label
    || selectedEntities?.property?.label
    || selectedEntities?.account?.label;
  if (selectedName) return selectedName;

  const contactName = [task?.contact?.first_name, task?.contact?.last_name]
    .filter(Boolean)
    .join(' ')
    .trim();
  return contactName
    || task?.opportunity?.name
    || task?.property?.name
    || task?.account?.name
    || null;
};

const resolveFollowUpTitle = ({ task, selectedEntities }) => {
  const displayName = resolveEntityDisplayName({ task, selectedEntities });
  if (displayName) return `Follow up: ${displayName}`;
  return task?.title || 'Follow up';
};

const LogActivityModal = ({
  isOpen,
  onClose,
  onLogged,
  onTaskCompleted,
  mode = 'default',
  task = null,
  prefillEntity = null,
  prefillType = null,
  prefillActivityType = null,
  prefillOutcome = null,
  prefillQueueItem = null,
  prefillMotion = null,
  prefillDirection = null,
  createdFromGrow = false
}) => {
  const { userProfile, user } = useAuth();
  const currentUserId = userProfile?.id || user?.id || null;
  const [isLoading, setIsLoading] = useState(false);
  const [showEntityCreator, setShowEntityCreator] = useState(false);
  const [creatorEntityType, setCreatorEntityType] = useState('account');
  const [selectedEntities, setSelectedEntities] = useState({
    account: null,
    property: null,
    contact: null,
    opportunity: null
  });
  const [followUpCreated, setFollowUpCreated] = useState(null);
  const [followUpState, setFollowUpState] = useState({ enabled: false, date: '' });
  const [followUpError, setFollowUpError] = useState('');
  const [toast, setToast] = useState(null);
  const [prefillApplied, setPrefillApplied] = useState(false);
  const [showAdvancedFields, setShowAdvancedFields] = useState(false);
  const isQuickStart = Boolean(prefillQueueItem);
  const isStartMode = mode === 'start';
  const showDetails = showAdvancedFields || (!isQuickStart && !isStartMode);
  const showQuickTarget = isQuickStart && !isStartMode && !showAdvancedFields;
  const showActivityType = !isStartMode || showAdvancedFields;
  const primaryEntityType = (() => {
    const queueItem = prefillQueueItem || {};
    const entity = prefillEntity || queueItem?.entity || {};

    if (entity?.contactId) return 'contact';
    if (entity?.opportunityId) return 'opportunity';
    if (entity?.propertyId) return 'property';
    return 'account';
  })();

  const {
    register,
    handleSubmit,
    watch,
    setValue,
    reset,
    formState: { errors, isValid }
  } = useForm({
    defaultValues: {
      activityType: 'Phone Call',
      account: '',
      property: '',
      contact: '',
      opportunity: '',
      motion: 'prospecting',
      direction: '',
      outcome: '',
      notes: ''
    }
  });

  useEffect(() => {
    register('account');
    register('property');
    register('contact');
    register('opportunity');
    register('motion');
    register('direction');
  }, [register]);

  const watchedValues = watch();
  const primaryEntityValue = watchedValues?.[primaryEntityType];
  const primarySelectedEntity = selectedEntities?.[primaryEntityType];

  useEffect(() => {
    if (!isOpen) {
      setPrefillApplied(false);
      setShowAdvancedFields(false);
      setFollowUpState({ enabled: false, date: '' });
      setFollowUpCreated(null);
      setFollowUpError('');
      setToast(null);
      return;
    }
    if (prefillApplied) return;

    const queueItem = prefillQueueItem || null;
    const entity = prefillEntity || queueItem?.entity || {};
    const actionType = prefillType || prefillActivityType || queueItem?.action || null;
    const outcomeValue = prefillOutcome || queueItem?.suggestedOutcome || null;

    if (entity?.contactId) {
      setValue('contact', entity?.contactId, { shouldDirty: true, shouldValidate: false });
    }
    if (entity?.accountId) {
      setValue('account', entity?.accountId, { shouldDirty: true, shouldValidate: false });
    }
    if (entity?.propertyId) {
      setValue('property', entity?.propertyId, { shouldDirty: true, shouldValidate: false });
    }
    if (entity?.opportunityId) {
      setValue('opportunity', entity?.opportunityId, { shouldDirty: true, shouldValidate: false });
    }

    if (actionType && ACTIVITY_TYPE_MAP?.[actionType]) {
      setValue('activityType', ACTIVITY_TYPE_MAP[actionType], { shouldDirty: true, shouldValidate: false });
    } else if (prefillActivityType) {
      setValue('activityType', prefillActivityType, { shouldDirty: true, shouldValidate: false });
    }

    if (prefillMotion) {
      setValue('motion', prefillMotion, { shouldDirty: true, shouldValidate: false });
    }

    if (prefillDirection) {
      setValue('direction', prefillDirection, { shouldDirty: true, shouldValidate: false });
    }

    if (outcomeValue) {
      setValue('outcome', OUTCOME_MAP?.[outcomeValue] || outcomeValue, { shouldDirty: true, shouldValidate: false });
    }

    setPrefillApplied(true);
    setShowAdvancedFields(isStartMode ? false : !isQuickStart);
  }, [
    isOpen,
    prefillApplied,
    prefillEntity,
    prefillActivityType,
    prefillType,
    prefillOutcome,
    prefillQueueItem,
    prefillMotion,
    prefillDirection,
    setValue,
    isQuickStart,
    isStartMode
  ]);

  useEffect(() => {
    if (!followUpState?.enabled || followUpState?.date) {
      setFollowUpError('');
    }
  }, [followUpState]);

  useEffect(() => {
    if (!toast) return;
    const timeout = setTimeout(() => setToast(null), 4500);
    return () => clearTimeout(timeout);
  }, [toast]);

  const handleEntityValueChange = (entityType, value) => {
    setValue(entityType, value || '', { shouldDirty: true, shouldValidate: false });
    if (!value) {
      setSelectedEntities(prev => ({ ...prev, [entityType]: null }));
    }
  };

  const handleEntityOptionSelected = (entityType, option) => {
    setSelectedEntities(prev => ({ ...prev, [entityType]: option ? { ...option } : null }));
    if (entityType === 'contact' && option?.account_id) {
      setValue('account', option?.account_id, { shouldDirty: true, shouldValidate: false });
      setSelectedEntities(prev => ({
        ...prev,
        account: {
          value: option?.account_id,
          label: option?.account_name || 'Account',
          description: 'Account'
        },
        contact: option ? { ...option } : null
      }));
    }
    if (entityType === 'opportunity' && option?.account_id) {
      setValue('account', option?.account_id, { shouldDirty: true, shouldValidate: false });
      setSelectedEntities(prev => ({
        ...prev,
        account: {
          value: option?.account_id,
          label: option?.account_name || 'Account',
          description: 'Account'
        },
        opportunity: option ? { ...option } : null
      }));
    }
  };

  const handleCreateEntity = (entityType) => {
    setCreatorEntityType(entityType);
    setShowEntityCreator(true);
  };

  const handleEntityCreated = (newEntity) => {
    setValue(creatorEntityType, newEntity?.id);
    setSelectedEntities(prev => ({
      ...prev,
      [creatorEntityType]: {
        value: newEntity?.id,
        label: newEntity?.name,
        description: newEntity?.type || 'New Entity'
      }
    }));
    setShowEntityCreator(false);
  };

  const submitPayload = async (data, resetAfter = false) => {
    setIsLoading(true);
    try {
      setFollowUpError('');
      if (!data?.activityType) {
        alert('Please select an activity type');
        return;
      }
      if (!data?.account && !isStartMode) {
        alert('Please select an account');
        return;
      }
      if ((isQuickStart || isStartMode) && !data?.outcome) {
        alert('Please select an outcome');
        return;
      }

      const subjectTarget = selectedEntities?.account?.label
        || selectedEntities?.opportunity?.label
        || 'Account Activity';

      const { sourceType, sourceId } = parseQueueItem(prefillQueueItem);
      const linkedEntity = resolveLinkedEntity(data || {});
      const followUpDueAt = followUpState?.enabled ? resolveFollowUpDueAt(followUpState?.date) : null;
      if (followUpState?.enabled && !followUpState?.date) {
        setFollowUpError('Select a follow-up date to continue.');
        return;
      }
      if (followUpState?.enabled && !followUpDueAt) {
        setFollowUpError('Select a valid follow-up date to continue.');
        return;
      }

      const followUpPayload = followUpState?.enabled && followUpDueAt
        ? {
          title: resolveFollowUpTitle({ task, selectedEntities }),
          status: 'open',
          assigned_to: task?.assigned_to || currentUserId || null,
          due_at: followUpDueAt,
          linked_entity_type: task?.linked_entity_type || linkedEntity?.type || null,
          linked_entity_id: task?.linked_entity_id || linkedEntity?.id || null,
          account_id: data?.account || task?.account_id || null,
          contact_id: data?.contact || task?.contact_id || null,
          property_id: data?.property || task?.property_id || null,
          opportunity_id: data?.opportunity || task?.opportunity_id || null
        }
        : null;

      const resolvedDirection = data?.direction
        || prefillDirection
        || (sourceType === 'task' ? deriveDirectionFromTaskType(prefillQueueItem?.taskType || task?.task_type) : null)
        || 'outbound';

      const activityData = {
        activity_type: data?.activityType,
        account_id: data?.account,
        contact_id: data?.contact || null,
        property_id: data?.property || null,
        opportunity_id: data?.opportunity || null,
        motion: data?.motion || 'prospecting',
        direction: resolvedDirection,
        outcome: data?.outcome || null,
        notes: data?.notes || '',
        activity_date: new Date()?.toISOString(),
        subject: `${data?.activityType} - ${subjectTarget}`,
        follow_up_date: null,
        created_from_grow: Boolean(createdFromGrow),
        source_task_id: sourceType === 'task' ? (task?.id || sourceId) : null,
        linked_entity_type: linkedEntity?.type,
        linked_entity_id: linkedEntity?.id
      };

      console.debug('createActivity payload', activityData);

      const response = sourceType === 'task'
        ? await tasksService?.completeTaskWithActivity?.(task || sourceId, activityData, null)
        : await activitiesService?.createActivity(activityData);

      const activityRecord = sourceType === 'task' ? response?.data?.activity : response?.data;

      if (response?.success && activityRecord) {
        const activityTimestamp = new Date()?.toISOString();
        const updateRequests = [];

        if (data?.account) {
          updateRequests.push(accountsService?.updateAccount?.(data?.account, { last_activity_at: activityTimestamp }));
        }
        if (data?.contact) {
          updateRequests.push(contactsService?.updateContact?.(data?.contact, { last_activity_at: activityTimestamp }));
        }
        if (data?.property) {
          updateRequests.push(propertiesService?.updateProperty?.(data?.property, { last_activity_at: activityTimestamp }));
        }
        if (data?.opportunity) {
          updateRequests.push(opportunitiesService?.updateOpportunity?.(data?.opportunity, { last_activity_at: activityTimestamp }));
        }
        if (sourceType === 'prospect' && sourceId) {
          updateRequests.push(prospectsService?.updateProspect?.(sourceId, {
            last_activity_at: activityTimestamp,
            status: 'contacted'
          }));
        }
        if (sourceType === 'opportunity' && sourceId && sourceId !== data?.opportunity) {
          updateRequests.push(opportunitiesService?.updateOpportunity?.(sourceId, { last_activity_at: activityTimestamp }));
        }

        if (updateRequests?.length) {
          await Promise.allSettled(updateRequests);
        }

        let createdFollowUpTask = null;
        if (followUpPayload) {
          const isStartModeTask = isStartMode && sourceType === 'task';
          const entityName = resolveEntityDisplayName({ task, selectedEntities });
          const followUpTitle = entityName ? `Follow up: ${entityName}` : (task?.title || 'Follow up');
          const followUpTaskPayload = isStartModeTask
            ? {
              assigned_to: task?.assigned_to || currentUserId || null,
              status: 'open',
              task_type: 'follow_up',
              due_at: followUpDueAt,
              title: followUpTitle,
              linked_entity_type: task?.linked_entity_type || linkedEntity?.type || null,
              linked_entity_id: task?.linked_entity_id || linkedEntity?.id || null,
              source_activity_id: activityRecord?.id || null,
              account_id: data?.account || task?.account_id || null,
              contact_id: data?.contact || task?.contact_id || null,
              property_id: data?.property || task?.property_id || null,
              opportunity_id: data?.opportunity || task?.opportunity_id || null
            }
            : {
              ...followUpPayload,
              source_activity_id: activityRecord?.id || null,
              linked_entity_type: followUpPayload?.linked_entity_type || null,
              linked_entity_id: followUpPayload?.linked_entity_id || null,
              account_id: followUpPayload?.account_id || null,
              contact_id: followUpPayload?.contact_id || null,
              property_id: followUpPayload?.property_id || null,
              opportunity_id: followUpPayload?.opportunity_id || null
            };

          console.debug('createTask payload', followUpTaskPayload);

          const followUpResult = await tasksService?.createTask?.(followUpTaskPayload);
          if (!followUpResult?.success) {
            console.error('Failed to create follow-up task:', followUpResult?.error);
            setToast({
              type: 'error',
              message: followUpResult?.error || 'Failed to create follow-up task.'
            });
            return;
          }
          createdFollowUpTask = followUpResult?.data;
        }

        if (createdFollowUpTask) {
          setFollowUpCreated({
            date: followUpState?.date,
            action: createdFollowUpTask?.title || 'Follow-up'
          });
          setToast({
            type: 'success',
            message: `Follow-up created for ${followUpState?.date}`
          });
        }

        if (sourceType === 'task' && response?.data?.completedTask) {
          onTaskCompleted?.(response?.data?.completedTask);
        }

        const finalizeSuccess = () => {
          onLogged?.(activityRecord);
          if (resetAfter) {
            reset({
              activityType: 'Phone Call',
              account: watchedValues?.account,
              property: watchedValues?.property,
              contact: watchedValues?.contact,
              opportunity: watchedValues?.opportunity,
              motion: watchedValues?.motion || 'prospecting',
              direction: watchedValues?.direction || '',
              outcome: '',
              notes: ''
            });
            setFollowUpState({ enabled: false, date: '' });
          } else {
            onClose?.();
          }
        };

        if (createdFollowUpTask && !resetAfter) {
          setTimeout(finalizeSuccess, 600);
        } else {
          finalizeSuccess();
        }
      } else {
        throw new Error(response?.error || 'Failed to save activity');
      }
    } catch (error) {
      console.error('Error logging activity:', error);
      setToast({
        type: 'error',
        message: error?.message || 'Failed to log activity. Please try again.'
      });
    } finally {
      setIsLoading(false);
    }
  };

  const onSubmit = (data) => submitPayload(data, false);
  const onSaveAndNew = (data) => submitPayload(data, true);

  const handleCancel = () => {
    onClose?.();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
      {toast && (
        <div className="fixed top-4 right-4 z-[60] max-w-sm">
          <div
            className={`flex items-start gap-2 rounded-lg border px-4 py-3 text-sm shadow-lg ${
              toast?.type === 'success'
                ? 'border-green-200 bg-green-50 text-green-700'
                : 'border-red-200 bg-red-50 text-red-700'
            }`}
          >
            <Icon
              name={toast?.type === 'success' ? 'CheckCircle' : 'AlertTriangle'}
              size={16}
              className={`mt-0.5 ${toast?.type === 'success' ? 'text-green-600' : 'text-red-600'}`}
            />
            <span>{toast?.message}</span>
          </div>
        </div>
      )}
      <div className="bg-card rounded-lg border border-border shadow-xl w-full max-w-3xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between px-6 py-4 border-b border-border">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
              <Icon name="Plus" size={20} color="var(--color-primary-foreground)" />
            </div>
            <div>
              <h2 className="text-xl font-semibold text-foreground">Log Activity</h2>
              <p className="text-sm text-muted-foreground">Quickly record an activity without leaving Today</p>
            </div>
          </div>
          <button
            className="text-muted-foreground hover:text-foreground"
            onClick={handleCancel}
            type="button"
          >
            ✕
          </button>
        </div>

        <div className="p-6 space-y-6">
          {followUpCreated && (
            <div className="p-3 bg-green-50 border border-green-200 rounded-lg">
              <div className="flex items-center space-x-2">
                <Icon name="CheckCircle" size={16} className="text-green-600" />
                <span className="text-sm font-medium text-green-800">
                  Follow-up created: {followUpCreated?.action || `Due ${new Date(followUpCreated.date)?.toLocaleDateString()}`}
                </span>
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
            <div className="space-y-6">
              {showDetails && (
                <div className="space-y-2">
                  <div className="flex items-center space-x-2">
                    <Icon name="Target" size={18} className="text-primary" />
                    <h3 className="text-sm font-medium text-foreground">Activity Motion</h3>
                  </div>
                  <Select
                    options={ACTIVITY_MOTION_OPTIONS}
                    value={watchedValues?.motion}
                    onChange={(value) => setValue('motion', value, { shouldDirty: true, shouldValidate: false })}
                    placeholder="Select activity motion"
                    required
                    searchable={false}
                    disabled={isLoading}
                    label="Activity Motion"
                    name="motion"
                    description="Tag the motion for reporting in Supabase"
                  />
                </div>
              )}

              {showActivityType && (
                <ActivityTypeSelector
                  value={watchedValues?.activityType}
                  onChange={(value) => setValue('activityType', value)}
                  error={errors?.activityType?.message}
                  disabled={isLoading}
                />
              )}

              {showQuickTarget ? (
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <h3 className="text-sm font-medium text-foreground">Target</h3>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setShowAdvancedFields(true)}
                      className="text-xs"
                    >
                      More details
                    </Button>
                  </div>
                  <EntitySearchSelector
                    entityType={primaryEntityType}
                    value={primaryEntityValue}
                    onChange={(value) => handleEntityValueChange(primaryEntityType, value)}
                    onOptionSelected={(option) => handleEntityOptionSelected(primaryEntityType, option)}
                    error={errors?.[primaryEntityType]?.message}
                    disabled={isLoading}
                    onCreateNew={primaryEntityType === 'property' || primaryEntityType === 'opportunity' ? null : () => handleCreateEntity(primaryEntityType)}
                  />

                  {primarySelectedEntity && (
                    <SelectedEntityInfo entityType={primaryEntityType} entityData={primarySelectedEntity} />
                  )}
                </div>
              ) : showDetails ? (
                <div className="space-y-4">
                  <EntitySearchSelector
                    entityType="contact"
                    value={watchedValues?.contact}
                    onChange={(value) => handleEntityValueChange('contact', value)}
                    onOptionSelected={(option) => handleEntityOptionSelected('contact', option)}
                    error={errors?.contact?.message}
                    disabled={isLoading}
                    onCreateNew={() => handleCreateEntity('contact')}
                  />

                  {selectedEntities?.contact && (
                    <SelectedEntityInfo entityType="contact" entityData={selectedEntities?.contact} />
                  )}

                  <EntitySearchSelector
                    entityType="account"
                    value={watchedValues?.account}
                    onChange={(value) => handleEntityValueChange('account', value)}
                    onOptionSelected={(option) => handleEntityOptionSelected('account', option)}
                    error={errors?.account?.message}
                    disabled={isLoading}
                    onCreateNew={() => handleCreateEntity('account')}
                  />

                  {selectedEntities?.account && (
                    <SelectedEntityInfo entityType="account" entityData={selectedEntities?.account} />
                  )}

                  <EntitySearchSelector
                    entityType="property"
                    value={watchedValues?.property}
                    onChange={(value) => handleEntityValueChange('property', value)}
                    onOptionSelected={(option) => handleEntityOptionSelected('property', option)}
                    error={errors?.property?.message}
                    disabled={isLoading}
                    onCreateNew={() => handleCreateEntity('property')}
                  />

                  {selectedEntities?.property && (
                    <SelectedEntityInfo entityType="property" entityData={selectedEntities?.property} />
                  )}

                  <EntitySearchSelector
                    entityType="opportunity"
                    value={watchedValues?.opportunity}
                    onChange={(value) => handleEntityValueChange('opportunity', value)}
                    onOptionSelected={(option) => handleEntityOptionSelected('opportunity', option)}
                    error={errors?.opportunity?.message}
                    disabled={isLoading}
                  />

                  {selectedEntities?.opportunity && (
                    <SelectedEntityInfo entityType="opportunity" entityData={selectedEntities?.opportunity} />
                  )}

                  {isQuickStart && !isStartMode && (
                    <div className="flex justify-end">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setShowAdvancedFields(false)}
                        className="text-xs"
                      >
                        Hide details
                      </Button>
                    </div>
                  )}

                  {isStartMode && (
                    <div className="flex justify-end">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setShowAdvancedFields(false)}
                        className="text-xs"
                      >
                        Hide details
                      </Button>
                    </div>
                  )}
                </div>
              ) : null}

              {isStartMode && !showAdvancedFields && (
                <div className="flex justify-end">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setShowAdvancedFields(true)}
                    className="text-xs"
                  >
                    More details
                  </Button>
                </div>
              )}

              <OutcomeNotesSection
                outcome={watchedValues?.outcome}
                onOutcomeChange={(value) => setValue('outcome', value)}
                notes={watchedValues?.notes}
                onNotesChange={(value) => setValue('notes', value)}
                outcomeError={errors?.outcome?.message}
                notesError={errors?.notes?.message}
                disabled={isLoading}
                onFollowUpChange={setFollowUpState}
                followUpError={followUpError}
                autoFocusNotes={(isQuickStart || isStartMode) && !showAdvancedFields}
                outcomeRequired={isQuickStart || isStartMode}
                showQuickActions={!isStartMode}
              />
            </div>

            <div className="bg-card rounded-lg border border-border p-4">
              <ActivityFormActions
                onSave={handleSubmit(onSubmit)}
                onSaveAndNew={handleSubmit(onSaveAndNew)}
                onCancel={handleCancel}
                isLoading={isLoading}
                disabled={!isValid || !watchedValues?.activityType || ((isQuickStart || isStartMode) && !watchedValues?.outcome)}
                showSaveAndNew={true}
              />
            </div>
          </form>
        </div>
      </div>

      <QuickEntityCreator
        entityType={creatorEntityType}
        isOpen={showEntityCreator}
        onClose={() => setShowEntityCreator(false)}
        onSave={handleEntityCreated}
        disabled={isLoading}
      />
    </div>
  );
};

export default LogActivityModal;
