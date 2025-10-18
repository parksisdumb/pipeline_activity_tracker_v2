import React, { useState, useEffect } from 'react';
import { Calendar, Clock, Users, MapPin, FileText, Link, Bell } from 'lucide-react';
import Modal from './Modal';
import Button from './Button';
import Input from './Input';
import Select from './Select';
import { calendarService } from '../../services/calendarService';
import { usersService } from '../../services/usersService';
import { useAuth } from '../../contexts/AuthContext';

const AddEventModal = ({ isOpen, onClose, onEventCreated }) => {
  const { userProfile } = useAuth();
  
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    event_type: 'meeting',
    priority: 'medium',
    start_datetime: '',
    end_datetime: '',
    all_day: false,
    location: '',
    meeting_url: '',
    notes: '',
    assigned_to: '',
    reminder_minutes: [15, 60]
  });

  const [availableUsers, setAvailableUsers] = useState([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  // Event type options
  const eventTypes = [
    { value: 'meeting', label: 'Meeting', icon: Users },
    { value: 'deadline', label: 'Deadline', icon: Clock },
    { value: 'appointment', label: 'Appointment', icon: Calendar },
    { value: 'inspection', label: 'Inspection', icon: FileText },
    { value: 'other', label: 'Other', icon: Calendar }
  ];

  // Priority options
  const priorityOptions = [
    { value: 'low', label: 'Low' },
    { value: 'medium', label: 'Medium' },
    { value: 'high', label: 'High' },
    { value: 'critical', label: 'Critical' }
  ];

  // Reminder options (in minutes)
  const reminderOptions = [
    { value: [15], label: '15 minutes before' },
    { value: [30], label: '30 minutes before' },
    { value: [60], label: '1 hour before' },
    { value: [15, 60], label: '15 min & 1 hour before' },
    { value: [60, 1440], label: '1 hour & 1 day before' },
    { value: [], label: 'No reminders' }
  ];

  // Load available users on mount
  useEffect(() => {
    loadUsers();
  }, []);

  // Reset form when modal opens/closes
  useEffect(() => {
    if (isOpen) {
      resetForm();
    }
  }, [isOpen]);

  const loadUsers = async () => {
    try {
      const result = await usersService?.getActiveUsers();
      if (result?.success) {
        setAvailableUsers(result?.data || []);
      }
    } catch (err) {
      console.error('Error loading users:', err);
    }
  };

  const resetForm = () => {
    const currentDate = new Date();
    const defaultStartTime = new Date(currentDate.getTime() + 60 * 60 * 1000); // 1 hour from now
    const defaultEndTime = new Date(defaultStartTime.getTime() + 60 * 60 * 1000); // 1 hour duration
    
    setFormData({
      title: '',
      description: '',
      event_type: 'meeting',
      priority: 'medium',
      start_datetime: defaultStartTime?.toISOString()?.slice(0, 16),
      end_datetime: defaultEndTime?.toISOString()?.slice(0, 16),
      all_day: false,
      location: '',
      meeting_url: '',
      notes: '',
      assigned_to: userProfile?.id || '',
      reminder_minutes: [15, 60]
    });
    setError('');
  };

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));

    // Auto-adjust end time when start time changes
    if (field === 'start_datetime' && value) {
      const startTime = new Date(value);
      const endTime = new Date(startTime.getTime() + 60 * 60 * 1000); // 1 hour default duration
      setFormData(prev => ({
        ...prev,
        end_datetime: endTime?.toISOString()?.slice(0, 16)
      }));
    }

    // Clear error when user starts typing
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e?.preventDefault();
    
    if (!formData?.title?.trim()) {
      setError('Event title is required');
      return;
    }

    if (!formData?.start_datetime) {
      setError('Start date and time is required');
      return;
    }

    if (!formData?.end_datetime) {
      setError('End date and time is required');
      return;
    }

    if (new Date(formData?.start_datetime) >= new Date(formData?.end_datetime)) {
      setError('End time must be after start time');
      return;
    }

    try {
      setIsSubmitting(true);
      setError('');

      const eventData = {
        ...formData,
        title: formData?.title?.trim(),
        description: formData?.description?.trim(),
        location: formData?.location?.trim(),
        meeting_url: formData?.meeting_url?.trim(),
        notes: formData?.notes?.trim(),
        assigned_to: formData?.assigned_to || userProfile?.id,
        start_datetime: new Date(formData?.start_datetime)?.toISOString(),
        end_datetime: new Date(formData?.end_datetime)?.toISOString()
      };

      const result = await calendarService?.createEvent(eventData);
      
      if (result) {
        onEventCreated?.(result);
        onClose?.();
      }
    } catch (err) {
      console.error('Error creating event:', err);
      setError(err?.message || 'Failed to create event. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isOpen) return null;

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title="Add New Event"
      size="lg"
      className="max-h-[90vh]"
    >
      <form onSubmit={handleSubmit} className="p-6 space-y-6">
        {/* Error Display */}
        {error && (
          <div className="bg-destructive/10 border border-destructive/20 rounded-md p-3">
            <p className="text-sm text-destructive">{error}</p>
          </div>
        )}

        {/* Event Title */}
        <div>
          <label className="block text-sm font-medium text-foreground mb-2">
            Event Title *
          </label>
          <Input
            type="text"
            value={formData?.title}
            onChange={(e) => handleInputChange('title', e?.target?.value)}
            placeholder="Enter event title"
            required
            className="w-full"
          />
        </div>

        {/* Event Type and Priority */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-foreground mb-2">
              Event Type
            </label>
            <Select
              value={formData?.event_type}
              onChange={(value) => handleInputChange('event_type', value)}
              onSearchChange={() => {}}
              error=""
              id="event_type"
              onOpenChange={() => {}}
              name="event_type"
              description=""
              label=""
              ref={null}
              options={eventTypes?.map(type => ({
                value: type?.value,
                label: (
                  <div className="flex items-center space-x-2">
                    <type.icon className="w-4 h-4" />
                    <span>{type?.label}</span>
                  </div>
                )
              }))}
              className="w-full"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-foreground mb-2">
              Priority
            </label>
            <Select
              value={formData?.priority}
              onChange={(value) => handleInputChange('priority', value)}
              onSearchChange={() => {}}
              error=""
              id="priority"
              onOpenChange={() => {}}
              name="priority"
              description=""
              label=""
              ref={null}
              options={priorityOptions}
              className="w-full"
            />
          </div>
        </div>

        {/* Date and Time */}
        <div className="space-y-4">
          <div className="flex items-center space-x-3">
            <input
              type="checkbox"
              id="all_day"
              checked={formData?.all_day}
              onChange={(e) => handleInputChange('all_day', e?.target?.checked)}
              className="rounded border-border"
            />
            <label htmlFor="all_day" className="text-sm text-foreground">
              All day event
            </label>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-foreground mb-2">
                Start Date & Time *
              </label>
              <Input
                type={formData?.all_day ? 'date' : 'datetime-local'}
                value={formData?.all_day ? formData?.start_datetime?.split('T')?.[0] : formData?.start_datetime}
                onChange={(e) => {
                  if (formData?.all_day) {
                    handleInputChange('start_datetime', `${e?.target?.value}T09:00`);
                  } else {
                    handleInputChange('start_datetime', e?.target?.value);
                  }
                }}
                required
                className="w-full"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-foreground mb-2">
                End Date & Time *
              </label>
              <Input
                type={formData?.all_day ? 'date' : 'datetime-local'}
                value={formData?.all_day ? formData?.end_datetime?.split('T')?.[0] : formData?.end_datetime}
                onChange={(e) => {
                  if (formData?.all_day) {
                    handleInputChange('end_datetime', `${e?.target?.value}T17:00`);
                  } else {
                    handleInputChange('end_datetime', e?.target?.value);
                  }
                }}
                required
                className="w-full"
              />
            </div>
          </div>
        </div>

        {/* Description */}
        <div>
          <label className="block text-sm font-medium text-foreground mb-2">
            Description
          </label>
          <textarea
            value={formData?.description}
            onChange={(e) => handleInputChange('description', e?.target?.value)}
            placeholder="Enter event description"
            rows={3}
            className="w-full px-3 py-2 border border-border rounded-md focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary resize-none"
          />
        </div>

        {/* Location and Meeting URL */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-foreground mb-2 flex items-center space-x-2">
              <MapPin className="w-4 h-4" />
              <span>Location</span>
            </label>
            <Input
              type="text"
              value={formData?.location}
              onChange={(e) => handleInputChange('location', e?.target?.value)}
              placeholder="Enter location"
              className="w-full"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-foreground mb-2 flex items-center space-x-2">
              <Link className="w-4 h-4" />
              <span>Meeting URL</span>
            </label>
            <Input
              type="url"
              value={formData?.meeting_url}
              onChange={(e) => handleInputChange('meeting_url', e?.target?.value)}
              placeholder="https://zoom.us/j/..."
              className="w-full"
            />
          </div>
        </div>

        {/* Assign To */}
        <div>
          <label className="block text-sm font-medium text-foreground mb-2 flex items-center space-x-2">
            <Users className="w-4 h-4" />
            <span>Assign To</span>
          </label>
          <Select
            value={formData?.assigned_to}
            onChange={(value) => handleInputChange('assigned_to', value)}
            onSearchChange={() => {}}
            error=""
            id="assigned_to"
            onOpenChange={() => {}}
            name="assigned_to"
            description=""
            label=""
            ref={null}
            options={availableUsers?.map(user => ({
              value: user?.id,
              label: `${user?.full_name} (${user?.role})`
            }))}
            placeholder="Select assignee"
            className="w-full"
          />
        </div>

        {/* Reminders */}
        <div>
          <label className="block text-sm font-medium text-foreground mb-2 flex items-center space-x-2">
            <Bell className="w-4 h-4" />
            <span>Reminders</span>
          </label>
          <Select
            value={JSON.stringify(formData?.reminder_minutes)}
            onChange={(value) => handleInputChange('reminder_minutes', JSON.parse(value))}
            onSearchChange={() => {}}
            error=""
            id="reminder_minutes"
            onOpenChange={() => {}}
            name="reminder_minutes"
            description=""
            label=""
            ref={null}
            options={reminderOptions?.map(option => ({
              value: JSON.stringify(option?.value),
              label: option?.label
            }))}
            className="w-full"
          />
        </div>

        {/* Notes */}
        <div>
          <label className="block text-sm font-medium text-foreground mb-2">
            Additional Notes
          </label>
          <textarea
            value={formData?.notes}
            onChange={(e) => handleInputChange('notes', e?.target?.value)}
            placeholder="Enter any additional notes"
            rows={3}
            className="w-full px-3 py-2 border border-border rounded-md focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary resize-none"
          />
        </div>

        {/* Form Actions */}
        <div className="flex items-center justify-end space-x-3 pt-4 border-t border-border">
          <Button
            type="button"
            variant="outline"
            onClick={onClose}
            disabled={isSubmitting}
          >
            Cancel
          </Button>
          <Button
            type="submit"
            loading={isSubmitting}
            disabled={isSubmitting || !formData?.title?.trim()}
            iconName="Calendar"
          >
            {isSubmitting ? 'Creating...' : 'Create Event'}
          </Button>
        </div>
      </form>
    </Modal>
  );
};

export default AddEventModal;