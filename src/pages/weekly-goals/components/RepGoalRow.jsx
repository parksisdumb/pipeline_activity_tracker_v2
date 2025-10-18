import React, { useState, useEffect, useRef } from 'react';
import Button from '../../../components/ui/Button';
import Input from '../../../components/ui/Input';

const RepGoalRow = ({ rep, goals, previousWeekPerformance, onGoalChange }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [localGoals, setLocalGoals] = useState({
    pop_ins: 0,
    dm_conversations: 0,
    assessments_booked: 0,
    proposals_sent: 0,
    wins: 0,
    phone_calls_made: 0,
    emails_sent: 0,
    follow_ups_completed: 0
  });
  const [isSaving, setIsSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);
  const [saveError, setSaveError] = useState('');
  
  // Add ref to track if component is mounted
  const mountedRef = useRef(true);
  const saveTimeoutRef = useRef(null);

  // Sync local state with props whenever goals change with better tracking
  useEffect(() => {
    if (goals && mountedRef?.current) {
      const newGoals = {
        pop_ins: goals?.pop_ins || 0,
        dm_conversations: goals?.dm_conversations || 0,
        assessments_booked: goals?.assessments_booked || 0,
        proposals_sent: goals?.proposals_sent || 0,
        wins: goals?.wins || 0,
        phone_calls_made: goals?.phone_calls_made || 0,
        emails_sent: goals?.emails_sent || 0,
        follow_ups_completed: goals?.follow_ups_completed || 0
      };
      
      // Only update if there's actually a change to prevent unnecessary re-renders
      setLocalGoals(prevGoals => {
        const hasChanged = Object.keys(newGoals)?.some(key => prevGoals?.[key] !== newGoals?.[key]);
        return hasChanged ? newGoals : prevGoals;
      });
      
      // Clear any previous save states when goals update from parent
      setSaveSuccess(false);
      setSaveError('');
    }
  }, [goals?.pop_ins, goals?.dm_conversations, goals?.assessments_booked, goals?.proposals_sent, goals?.wins, goals?.phone_calls_made, goals?.emails_sent, goals?.follow_ups_completed, rep?.id]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      mountedRef.current = false;
      if (saveTimeoutRef?.current) {
        clearTimeout(saveTimeoutRef?.current);
      }
    };
  }, []);

  const handleSave = async () => {
    if (!mountedRef?.current) return;
    
    setIsSaving(true);
    setSaveError('');
    setSaveSuccess(false);
    
    try {
      console.log(`RepGoalRow: Saving goals for rep ${rep?.name}:`, localGoals);
      
      await onGoalChange(rep?.id, localGoals);
      
      if (mountedRef?.current) {
        setSaveSuccess(true);
        setIsEditing(false);
        
        // Clear success message after 5 seconds instead of 3
        saveTimeoutRef.current = setTimeout(() => {
          if (mountedRef?.current) {
            setSaveSuccess(false);
          }
        }, 5000);
        
        console.log(`RepGoalRow: Goals saved successfully for ${rep?.name}`);
      }
      
    } catch (error) {
      console.error(`RepGoalRow: Failed to save goals for ${rep?.name}:`, error);
      if (mountedRef?.current) {
        setSaveError(`Failed to save goals: ${error?.message || 'Please try again'}`);
        // Don't exit editing mode on error so user can retry
      }
    } finally {
      if (mountedRef?.current) {
        setIsSaving(false);
      }
    }
  };

  const handleCancel = () => {
    if (!mountedRef?.current) return;
    
    // Reset to current props values
    setLocalGoals({
      pop_ins: goals?.pop_ins || 0,
      dm_conversations: goals?.dm_conversations || 0,
      assessments_booked: goals?.assessments_booked || 0,
      proposals_sent: goals?.proposals_sent || 0,
      wins: goals?.wins || 0,
      phone_calls_made: goals?.phone_calls_made || 0,
      emails_sent: goals?.emails_sent || 0,
      follow_ups_completed: goals?.follow_ups_completed || 0
    });
    setIsEditing(false);
    setSaveError('');
    setSaveSuccess(false);
  };

  const handleInputChange = (field, value) => {
    if (!mountedRef?.current) return;
    
    const numValue = parseInt(value) || 0;
    setLocalGoals(prev => ({
      ...prev,
      [field]: numValue
    }));
    // Clear any error messages when user starts editing again
    setSaveError('');
  };

  // Use props values when not editing, local values when editing
  // Add fallback to ensure values are always numbers
  const displayGoals = isEditing ? localGoals : {
    pop_ins: parseInt(goals?.pop_ins) || 0,
    dm_conversations: parseInt(goals?.dm_conversations) || 0,
    assessments_booked: parseInt(goals?.assessments_booked) || 0,
    proposals_sent: parseInt(goals?.proposals_sent) || 0,
    wins: parseInt(goals?.wins) || 0,
    phone_calls_made: parseInt(goals?.phone_calls_made) || 0,
    emails_sent: parseInt(goals?.emails_sent) || 0,
    follow_ups_completed: parseInt(goals?.follow_ups_completed) || 0
  };

  return (
    <div className="bg-card border border-border rounded-lg p-4 hover:shadow-sm transition-shadow">
      <div className="flex items-center justify-between min-w-0">
        {/* Representative Info */}
        <div className="flex items-center space-x-3 min-w-0 flex-shrink-0 w-48">
          <div className="flex-shrink-0 h-10 w-10">
            <div className="h-10 w-10 rounded-full bg-primary flex items-center justify-center">
              <span className="text-sm font-medium text-primary-foreground">
                {rep?.name?.charAt(0)?.toUpperCase() || 'U'}
              </span>
            </div>
          </div>
          <div className="min-w-0 flex-1">
            <div className="text-sm font-medium text-foreground truncate">
              {rep?.name || 'Unknown Rep'}
            </div>
            <div className="text-xs text-muted-foreground truncate">
              {rep?.email || ''}
            </div>
          </div>
        </div>

        {/* Goals Grid - Updated with better spacing */}
        <div className="grid grid-cols-8 gap-2 xl:gap-3 flex-1 max-w-4xl mx-6 min-w-0">
          {/* Pop-ins */}
          <div className="text-center min-w-0">
            <div className="text-xs text-muted-foreground mb-1 truncate">Pop-ins</div>
            {isEditing ? (
              <Input
                type="number"
                value={localGoals?.pop_ins}
                onChange={(e) => handleInputChange('pop_ins', e?.target?.value)}
                className="w-full h-8 text-center text-xs min-w-12"
                min="0"
              />
            ) : (
              <div className={`text-sm font-medium transition-colors duration-500 truncate ${saveSuccess ? 'text-green-600 bg-green-50 px-1 py-1 rounded' : 'text-foreground'}`}>
                {displayGoals?.pop_ins}
              </div>
            )}
            {previousWeekPerformance?.pop_ins !== undefined && (
              <div className="text-xs text-muted-foreground truncate">
                Prev: {previousWeekPerformance?.pop_ins}
              </div>
            )}
          </div>

          {/* DM Conversations */}
          <div className="text-center min-w-0">
            <div className="text-xs text-muted-foreground mb-1 truncate">DM Conv</div>
            {isEditing ? (
              <Input
                type="number"
                value={localGoals?.dm_conversations}
                onChange={(e) => handleInputChange('dm_conversations', e?.target?.value)}
                className="w-full h-8 text-center text-xs min-w-12"
                min="0"
              />
            ) : (
              <div className={`text-sm font-medium transition-colors duration-500 truncate ${saveSuccess ? 'text-green-600 bg-green-50 px-1 py-1 rounded' : 'text-foreground'}`}>
                {displayGoals?.dm_conversations}
              </div>
            )}
            {previousWeekPerformance?.dm_conversations !== undefined && (
              <div className="text-xs text-muted-foreground truncate">
                Prev: {previousWeekPerformance?.dm_conversations}
              </div>
            )}
          </div>

          {/* Assessments Booked */}
          <div className="text-center min-w-0">
            <div className="text-xs text-muted-foreground mb-1 truncate">Assess</div>
            {isEditing ? (
              <Input
                type="number"
                value={localGoals?.assessments_booked}
                onChange={(e) => handleInputChange('assessments_booked', e?.target?.value)}
                className="w-full h-8 text-center text-xs min-w-12"
                min="0"
              />
            ) : (
              <div className={`text-sm font-medium transition-colors duration-500 truncate ${saveSuccess ? 'text-green-600 bg-green-50 px-1 py-1 rounded' : 'text-foreground'}`}>
                {displayGoals?.assessments_booked}
              </div>
            )}
            {previousWeekPerformance?.assessments_booked !== undefined && (
              <div className="text-xs text-muted-foreground truncate">
                Prev: {previousWeekPerformance?.assessments_booked}
              </div>
            )}
          </div>

          {/* Proposals Sent */}
          <div className="text-center min-w-0">
            <div className="text-xs text-muted-foreground mb-1 truncate">Props</div>
            {isEditing ? (
              <Input
                type="number"
                value={localGoals?.proposals_sent}
                onChange={(e) => handleInputChange('proposals_sent', e?.target?.value)}
                className="w-full h-8 text-center text-xs min-w-12"
                min="0"
              />
            ) : (
              <div className={`text-sm font-medium transition-colors duration-500 truncate ${saveSuccess ? 'text-green-600 bg-green-50 px-1 py-1 rounded' : 'text-foreground'}`}>
                {displayGoals?.proposals_sent}
              </div>
            )}
            {previousWeekPerformance?.proposals_sent !== undefined && (
              <div className="text-xs text-muted-foreground truncate">
                Prev: {previousWeekPerformance?.proposals_sent}
              </div>
            )}
          </div>

          {/* Wins */}
          <div className="text-center min-w-0">
            <div className="text-xs text-muted-foreground mb-1 truncate">Wins</div>
            {isEditing ? (
              <Input
                type="number"
                value={localGoals?.wins}
                onChange={(e) => handleInputChange('wins', e?.target?.value)}
                className="w-full h-8 text-center text-xs min-w-12"
                min="0"
              />
            ) : (
              <div className={`text-sm font-medium transition-colors duration-500 truncate ${saveSuccess ? 'text-green-600 bg-green-50 px-1 py-1 rounded' : 'text-foreground'}`}>
                {displayGoals?.wins}
              </div>
            )}
            {previousWeekPerformance?.wins !== undefined && (
              <div className="text-xs text-muted-foreground truncate">
                Prev: {previousWeekPerformance?.wins}
              </div>
            )}
          </div>

          {/* Phone Calls Made */}
          <div className="text-center min-w-0">
            <div className="text-xs text-muted-foreground mb-1 truncate">Calls</div>
            {isEditing ? (
              <Input
                type="number"
                value={localGoals?.phone_calls_made}
                onChange={(e) => handleInputChange('phone_calls_made', e?.target?.value)}
                className="w-full h-8 text-center text-xs min-w-12"
                min="0"
              />
            ) : (
              <div className={`text-sm font-medium transition-colors duration-500 truncate ${saveSuccess ? 'text-green-600 bg-green-50 px-1 py-1 rounded' : 'text-foreground'}`}>
                {displayGoals?.phone_calls_made}
              </div>
            )}
            {previousWeekPerformance?.phone_calls_made !== undefined && (
              <div className="text-xs text-muted-foreground truncate">
                Prev: {previousWeekPerformance?.phone_calls_made}
              </div>
            )}
          </div>

          {/* Emails Sent */}
          <div className="text-center min-w-0">
            <div className="text-xs text-muted-foreground mb-1 truncate">Emails</div>
            {isEditing ? (
              <Input
                type="number"
                value={localGoals?.emails_sent}
                onChange={(e) => handleInputChange('emails_sent', e?.target?.value)}
                className="w-full h-8 text-center text-xs min-w-12"
                min="0"
              />
            ) : (
              <div className={`text-sm font-medium transition-colors duration-500 truncate ${saveSuccess ? 'text-green-600 bg-green-50 px-1 py-1 rounded' : 'text-foreground'}`}>
                {displayGoals?.emails_sent}
              </div>
            )}
            {previousWeekPerformance?.emails_sent !== undefined && (
              <div className="text-xs text-muted-foreground truncate">
                Prev: {previousWeekPerformance?.emails_sent}
              </div>
            )}
          </div>

          {/* Follow Ups Completed */}
          <div className="text-center min-w-0">
            <div className="text-xs text-muted-foreground mb-1 truncate">F-ups</div>
            {isEditing ? (
              <Input
                type="number"
                value={localGoals?.follow_ups_completed}
                onChange={(e) => handleInputChange('follow_ups_completed', e?.target?.value)}
                className="w-full h-8 text-center text-xs min-w-12"
                min="0"
              />
            ) : (
              <div className={`text-sm font-medium transition-colors duration-500 truncate ${saveSuccess ? 'text-green-600 bg-green-50 px-1 py-1 rounded' : 'text-foreground'}`}>
                {displayGoals?.follow_ups_completed}
              </div>
            )}
            {previousWeekPerformance?.follow_ups_completed !== undefined && (
              <div className="text-xs text-muted-foreground truncate">
                Prev: {previousWeekPerformance?.follow_ups_completed}
              </div>
            )}
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center space-x-2 flex-shrink-0 w-32 justify-end">
          {isEditing ? (
            <>
              <Button
                onClick={handleSave}
                disabled={isSaving}
                size="sm"
                className="bg-primary text-primary-foreground"
              >
                {isSaving ? 'Saving...' : 'Save'}
              </Button>
              <Button
                onClick={handleCancel}
                variant="outline"
                size="sm"
                disabled={isSaving}
              >
                Cancel
              </Button>
            </>
          ) : (
            <div className="flex items-center space-x-2">
              {saveSuccess && (
                <div className="flex items-center text-green-600 text-xs animate-pulse">
                  <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                  </svg>
                  Saved!
                </div>
              )}
              <Button
                onClick={() => setIsEditing(true)}
                variant="outline"
                size="sm"
                disabled={isSaving}
              >
                Edit
              </Button>
            </div>
          )}
        </div>
      </div>
      
      {/* Error Message */}
      {saveError && (
        <div className="mt-2 p-2 bg-red-50 border border-red-200 rounded text-sm text-red-700">
          {saveError}
          <Button
            onClick={handleSave}
            variant="outline"
            size="sm"
            className="ml-2"
            disabled={isSaving}
          >
            Retry
          </Button>
        </div>
      )}
      
      {/* Success persistence indicator */}
      {saveSuccess && (
        <div className="mt-2 p-2 bg-green-50 border border-green-200 rounded text-sm text-green-700">
          ✅ Goals successfully saved and synced with database
        </div>
      )}
    </div>
  );
};

export default RepGoalRow;