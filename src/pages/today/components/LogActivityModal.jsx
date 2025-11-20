import React, { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import ActivityTypeSelector from '../../log-activity/components/ActivityTypeSelector';
import EntitySearchSelector from '../../log-activity/components/EntitySearchSelector';
import OutcomeNotesSection from '../../log-activity/components/OutcomeNotesSection';
import SelectedEntityInfo from '../../log-activity/components/SelectedEntityInfo';
import ActivityFormActions from '../../log-activity/components/ActivityFormActions';
import QuickEntityCreator from '../../log-activity/components/QuickEntityCreator';
import { activitiesService } from '../../../services/activitiesService';
import Icon from '../../../components/AppIcon';

const LogActivityModal = ({ isOpen, onClose, onLogged }) => {
  const [isLoading, setIsLoading] = useState(false);
  const [showEntityCreator, setShowEntityCreator] = useState(false);
  const [creatorEntityType, setCreatorEntityType] = useState('account');
  const [selectedEntities, setSelectedEntities] = useState({
    account: null,
    property: null,
    contact: null
  });
  const [followUpCreated, setFollowUpCreated] = useState(null);

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
      outcome: '',
      notes: ''
    }
  });

  useEffect(() => {
    register('account');
    register('property');
    register('contact');
  }, [register]);

  const watchedValues = watch();

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

  const handleFollowUpCreated = (followUpInfo) => {
    setFollowUpCreated(followUpInfo);
  };

  const submitPayload = async (data, resetAfter = false) => {
    setIsLoading(true);
    try {
      if (!data?.activityType) {
        alert('Please select an activity type');
        return;
      }
      if (!data?.account) {
        alert('Please select an account');
        return;
      }

      const activityData = {
        activity_type: data?.activityType,
        account_id: data?.account,
        contact_id: data?.contact || null,
        property_id: data?.property || null,
        outcome: data?.outcome || null,
        notes: data?.notes || '',
        activity_date: new Date()?.toISOString(),
        subject: `${data?.activityType} - ${selectedEntities?.account?.label || 'Account Activity'}`,
        follow_up_date: null
      };

      const response = await activitiesService?.createActivity(activityData);

      if (response?.success) {
        onLogged?.(response?.data);
        if (resetAfter) {
          reset({
            activityType: 'Phone Call',
            account: watchedValues?.account,
            property: watchedValues?.property,
            contact: watchedValues?.contact,
            outcome: '',
            notes: ''
          });
        } else {
          onClose?.();
        }
      } else {
        throw new Error(response?.error || 'Failed to save activity');
      }
    } catch (error) {
      console.error('Error logging activity:', error);
      alert(`Failed to log activity: ${error?.message || 'Please try again.'}`);
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
              <ActivityTypeSelector
                value={watchedValues?.activityType}
                onChange={(value) => setValue('activityType', value)}
                error={errors?.activityType?.message}
                disabled={isLoading}
              />

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
              </div>

              <OutcomeNotesSection
                outcome={watchedValues?.outcome}
                onOutcomeChange={(value) => setValue('outcome', value)}
                notes={watchedValues?.notes}
                onNotesChange={(value) => setValue('notes', value)}
                outcomeError={errors?.outcome?.message}
                notesError={errors?.notes?.message}
                disabled={isLoading}
                selectedEntityData={{
                  account: watchedValues?.account,
                  contact: watchedValues?.contact,
                  property: watchedValues?.property
                }}
                onFollowUpCreated={handleFollowUpCreated}
              />
            </div>

            <div className="bg-card rounded-lg border border-border p-4">
              <ActivityFormActions
                onSave={handleSubmit(onSubmit)}
                onSaveAndNew={handleSubmit(onSaveAndNew)}
                onCancel={handleCancel}
                isLoading={isLoading}
                disabled={!isValid || !watchedValues?.activityType}
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
