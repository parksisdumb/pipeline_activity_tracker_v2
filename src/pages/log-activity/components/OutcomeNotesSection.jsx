import React, { useEffect, useState } from 'react';
import Select from '../../../components/ui/Select';
import Input from '../../../components/ui/Input';
import Button from '../../../components/ui/Button';
import Icon from '../../../components/AppIcon';
import { Checkbox } from '../../../components/ui/Checkbox';
import { Calendar, Clock, Phone, MessageCircle, Briefcase, FileText, Trophy } from 'lucide-react';

const OutcomeNotesSection = ({ 
  outcome, 
  onOutcomeChange, 
  notes, 
  onNotesChange, 
  outcomeError, 
  notesError, 
  disabled,
  onFollowUpChange = () => {},
  followUpError = '',
  autoFocusNotes = false,
  outcomeRequired = false,
  showQuickActions = true
}) => {
  const [showFollowUp, setShowFollowUp] = useState(false);
  const [followUpDate, setFollowUpDate] = useState('');
  const [followUpEnabled, setFollowUpEnabled] = useState(false);

  useEffect(() => {
    if (!followUpEnabled) {
      onFollowUpChange({ enabled: false, date: '' });
      return;
    }
    onFollowUpChange({ enabled: true, date: followUpDate || '' });
  }, [followUpDate, followUpEnabled, onFollowUpChange]);

  const activityOutcomes = [
    { 
      value: 'Successful', 
      label: 'Successful',
      description: 'Activity completed successfully' 
    },
    { 
      value: 'No Answer', 
      label: 'No Answer',
      description: 'No response received' 
    },
    { 
      value: 'Callback Requested', 
      label: 'Callback Requested',
      description: 'Client requested callback' 
    },
    { 
      value: 'Not Interested', 
      label: 'Not Interested',
      description: 'Client showed no interest' 
    },
    { 
      value: 'Interested', 
      label: 'Interested',
      description: 'Client expressed interest' 
    },
    { 
      value: 'Proposal Requested', 
      label: 'Proposal Requested',
      description: 'Client requested formal proposal' 
    },
    { 
      value: 'Meeting Scheduled', 
      label: 'Meeting Scheduled',
      description: 'Follow-up meeting arranged' 
    },
    { 
      value: 'Assessment Completed', 
      label: 'Assessment Completed',
      description: 'Property assessment finished successfully' 
    },
    { 
      value: 'Contract Signed', 
      label: 'Contract Signed',
      description: 'Agreement finalized and executed' 
    }
  ];

  // Follow-up date presets
  const followUpPresets = [
    {
      label: '+2 Days',
      value: 2,
      description: 'Quick follow-up'
    },
    {
      label: '+5 Days',
      value: 5,
      description: 'Standard follow-up'
    },
    {
      label: '+7 Days',
      value: 7,
      description: 'Weekly follow-up'
    },
    {
      label: '+14 Days',
      value: 14,
      description: 'Bi-weekly follow-up'
    }
  ];

  // Next step quick actions
  const nextStepActions = [
    {
      id: 'call',
      label: 'Call',
      icon: Phone,
      color: 'text-blue-600',
      bgColor: 'bg-blue-50 hover:bg-blue-100',
      borderColor: 'border-blue-200',
      description: 'Schedule a follow-up call',
      defaultFollowUp: 2
    },
    {
      id: 'dm_conversation',
      label: 'DM Conversation',
      icon: MessageCircle,
      color: 'text-green-600',
      bgColor: 'bg-green-50 hover:bg-green-100',
      borderColor: 'border-green-200',
      description: 'Decision maker conversation',
      defaultFollowUp: 3
    },
    {
      id: 'assessment',
      label: 'Book Assessment',
      icon: Briefcase,
      color: 'text-purple-600',
      bgColor: 'bg-purple-50 hover:bg-purple-100',
      borderColor: 'border-purple-200',
      description: 'Schedule property assessment',
      defaultFollowUp: 7
    },
    {
      id: 'proposal',
      label: 'Send Proposal',
      icon: FileText,
      color: 'text-orange-600',
      bgColor: 'bg-orange-50 hover:bg-orange-100',
      borderColor: 'border-orange-200',
      description: 'Prepare and send proposal',
      defaultFollowUp: 5
    },
    {
      id: 'win',
      label: 'Mark Win',
      icon: Trophy,
      color: 'text-green-700',
      bgColor: 'bg-green-50 hover:bg-green-100',
      borderColor: 'border-green-200',
      description: 'Mark as successful completion',
      defaultFollowUp: null // No follow-up needed for wins
    }
  ];

  // Calculate follow-up date based on preset days
  const calculateFollowUpDate = (days) => {
    const date = new Date();
    date?.setDate(date?.getDate() + days);
    return date?.toISOString()?.split('T')?.[0]; // YYYY-MM-DD format
  };

  // Handle follow-up preset click
  const handleFollowUpPreset = (days) => {
    const date = calculateFollowUpDate(days);
    setFollowUpDate(date);
    setShowFollowUp(true);
    setFollowUpEnabled(true);
  };

  // Handle next step action
  const handleNextStepAction = async (action) => {
    if (action?.id === 'win') {
      onOutcomeChange('Contract Signed');
      return;
    }

    if (action?.id === 'call') onOutcomeChange('Callback Requested');
    if (action?.id === 'dm_conversation') onOutcomeChange('Interested');
    if (action?.id === 'assessment') onOutcomeChange('Interested');
    if (action?.id === 'proposal') onOutcomeChange('Proposal Requested');

    if (action?.defaultFollowUp) {
      const date = calculateFollowUpDate(action?.defaultFollowUp);
      setFollowUpDate(date);
    }
    setShowFollowUp(true);
    setFollowUpEnabled(true);
  };

  return (
    <div className="space-y-6">
      {/* Outcome Section */}
      <div className="space-y-2">
        <div className="flex items-center space-x-2">
          <Icon name="Target" size={18} className="text-secondary" />
          <h3 className="text-sm font-medium text-foreground">Outcome</h3>
          <span className="text-xs text-muted-foreground">{outcomeRequired ? '(Required)' : '(Optional)'}</span>
        </div>
        <Select
          options={activityOutcomes}
          value={outcome}
          onChange={onOutcomeChange}
          placeholder="Select outcome..."
          error={outcomeError}
          disabled={disabled}
          clearable
        />
      </div>
      {showQuickActions && (
        <div className="space-y-3">
          <div className="flex items-center space-x-2">
            <Icon name="ArrowRight" size={18} className="text-primary" />
            <h3 className="text-sm font-medium text-foreground">Next Step</h3>
            <span className="text-xs text-muted-foreground">(Quick Actions)</span>
          </div>
          <div className="grid grid-cols-2 lg:grid-cols-5 gap-2">
            {nextStepActions?.map((action) => {
              const IconComponent = action?.icon;
              return (
                <Button
                  key={action?.id}
                  variant="outline"
                  size="sm"
                  onClick={() => handleNextStepAction(action)}
                  disabled={disabled}
                  className={`
                    flex flex-col items-center space-y-1 p-3 h-auto border-2 transition-all
                    ${action?.bgColor} ${action?.borderColor} ${action?.color}
                    hover:shadow-sm
                  `}
                >
                  <IconComponent className="w-4 h-4" />
                  <span className="text-xs font-medium">{action?.label}</span>
                </Button>
              );
            })}
          </div>
        </div>
      )}
      {/* Follow-up Section */}
      <div className="space-y-3">
        <div className="flex items-center space-x-2">
          <Calendar className="w-4 h-4 text-blue-600" />
          <h3 className="text-sm font-medium text-foreground">Follow-up</h3>
          <span className="text-xs text-muted-foreground">(Optional)</span>
        </div>

        <div className="flex items-center space-x-2">
          <Checkbox
            id="need-follow-up"
            checked={followUpEnabled}
            onChange={(e) => {
              const value = e?.target?.checked ?? e?.checked ?? e;
              setFollowUpEnabled(Boolean(value));
              if (!value) {
                setShowFollowUp(false);
                setFollowUpDate('');
              } else {
                setShowFollowUp(true);
              }
            }}
            disabled={disabled}
          />
          <label htmlFor="need-follow-up" className="text-sm text-foreground">
            Need another follow-up?
          </label>
        </div>
        
        {followUpEnabled && !showFollowUp ? (
          <div className="flex flex-wrap gap-2">
            {followUpPresets?.map((preset) => (
              <Button
                key={preset?.value}
                variant="outline"
                size="sm"
                onClick={() => handleFollowUpPreset(preset?.value)}
                disabled={disabled}
                className="flex items-center space-x-2 text-blue-600 border-blue-200 hover:bg-blue-50"
              >
                <Clock className="w-3 h-3" />
                <span>{preset?.label}</span>
              </Button>
            ))}
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowFollowUp(true)}
              disabled={disabled}
              className="flex items-center space-x-2"
            >
              <Calendar className="w-3 h-3" />
              <span>Custom Date</span>
            </Button>
          </div>
        ) : followUpEnabled && showFollowUp ? (
          <div className="space-y-3 p-3 border border-border rounded-lg bg-muted/20">
            <div className="flex items-center space-x-2">
              <Input
                type="date"
                value={followUpDate}
                onChange={(e) => {
                  setFollowUpDate(e?.target?.value);
                  setFollowUpEnabled(true);
                }}
                disabled={disabled}
                min={new Date()?.toISOString()?.split('T')?.[0]}
                className="flex-1"
              />
            </div>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                setShowFollowUp(false);
                setFollowUpDate('');
                setFollowUpEnabled(false);
              }}
              disabled={disabled}
              className="w-full"
            >
              Cancel
            </Button>
          </div>
        ) : null}
        {followUpError && (
          <p className="text-xs text-red-600">{followUpError}</p>
        )}
      </div>
      {/* Notes Section */}
      <div className="space-y-2">
        <div className="flex items-center space-x-2">
          <Icon name="FileText" size={18} className="text-secondary" />
          <h3 className="text-sm font-medium text-foreground">Notes</h3>
          <span className="text-xs text-muted-foreground">(Optional)</span>
        </div>
        <Input
          type="textarea"
          placeholder="Add notes about this activity..."
          value={notes}
          onChange={(e) => onNotesChange(e?.target?.value)}
          error={notesError}
          disabled={disabled}
          autoFocus={autoFocusNotes}
          className="min-h-[80px]"
        />
      </div>
    </div>
  );
};

export default OutcomeNotesSection;
