import React, { useState, useEffect, useMemo } from 'react';
import { Calendar, Clock, MapPin, Users, AlertCircle, CheckCircle2, Plus, Wrench, PartyPopper, GraduationCap, ChevronLeft, ChevronRight } from 'lucide-react';
import { addDays, addMonths, endOfMonth, endOfWeek, format, isSameDay, isSameMonth, startOfMonth, startOfWeek } from 'date-fns';
import { calendarService } from '../../../services/calendarService';
import { useAuth } from '../../../contexts/AuthContext';
import AddEventModal from '../../../components/ui/AddEventModal';

const WEEK_DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

const TenantCalendar = ({ className = '' }) => {
  const { userProfile } = useAuth();
  const [todayEvents, setTodayEvents] = useState([]);
  const [upcomingEvents, setUpcomingEvents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedView, setSelectedView] = useState('today');
  const [showAddEventModal, setShowAddEventModal] = useState(false);
  const [currentMonth, setCurrentMonth] = useState(() => new Date());

  const calendarDays = useMemo(() => {
    const start = startOfWeek(startOfMonth(currentMonth), { weekStartsOn: 0 });
    const end = endOfWeek(endOfMonth(currentMonth), { weekStartsOn: 0 });
    const days = [];
    let day = start;

    while (day <= end) {
      days.push(day);
      day = addDays(day, 1);
    }

    return days;
  }, [currentMonth]);

  const eventsByDate = useMemo(() => {
    const map = {};
    const seen = new Set();

    const registerEvent = (event) => {
      if (!event?.start_datetime) return;

      const eventDate = new Date(event.start_datetime);
      if (Number.isNaN(eventDate.getTime())) return;

      const identifier = event?.id ?? `${event?.title ?? 'event'}-${format(eventDate, 'yyyy-MM-dd-HHmm')}`;
      if (seen.has(identifier)) return;

      const key = format(eventDate, 'yyyy-MM-dd');
      if (!map[key]) {
        map[key] = [];
      }

      map[key].push(event);
      seen.add(identifier);
    };

    [...(todayEvents || []), ...(upcomingEvents || [])].forEach(registerEvent);

    return map;
  }, [todayEvents, upcomingEvents]);

  const handlePrevMonth = () => {
    setCurrentMonth((prev) => addMonths(prev, -1));
  };

  const handleNextMonth = () => {
    setCurrentMonth((prev) => addMonths(prev, 1));
  };

  // Load calendar events
  useEffect(() => {
    loadCalendarData();
  }, []);

  const loadCalendarData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Load both today's events and upcoming events
      const [todayData, upcomingData] = await Promise.all([
        calendarService?.getTodayEvents(),
        calendarService?.getUpcomingEvents(7)
      ]);
      
      setTodayEvents(todayData || []);
      setUpcomingEvents(upcomingData || []);
    } catch (err) {
      console.error('Error loading calendar data:', err);
      setError('Failed to load calendar events');
    } finally {
      setLoading(false);
    }
  };

  // Handle event creation
  const handleEventCreated = (newEvent) => {
    // Refresh calendar data to show the new event
    loadCalendarData();
  };

  // Format time for display
  const formatEventTime = (datetime, allDay) => {
    if (allDay) return 'All Day';
    
    try {
      const date = new Date(datetime);
      return date?.toLocaleTimeString('en-US', { 
        hour: 'numeric', 
        minute: '2-digit',
        hour12: true 
      });
    } catch {
      return 'Invalid time';
    }
  };

  // Format date for display
  const formatEventDate = (datetime) => {
    try {
      const date = new Date(datetime);
      return date?.toLocaleDateString('en-US', { 
        month: 'short', 
        day: 'numeric',
        weekday: 'short'
      });
    } catch {
      return 'Invalid date';
    }
  };

  // Get priority color
  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'critical': return 'text-red-600 bg-red-50';
      case 'high': return 'text-orange-600 bg-orange-50';
      case 'medium': return 'text-blue-600 bg-blue-50';
      case 'low': return 'text-gray-600 bg-gray-50';
      default: return 'text-blue-600 bg-blue-50';
    }
  };

  // Get event type icon
  const getEventTypeIcon = (eventType) => {
    switch (eventType) {
      case 'meeting':
        return <Users className="w-4 h-4" />;
      case 'deadline':
        return <AlertCircle className="w-4 h-4" />;
      case 'appointment':
        return <Clock className="w-4 h-4" />;
      case 'company_event':
        return <MapPin className="w-4 h-4" />;
      case 'training':
        return <GraduationCap className="w-4 h-4" />;
      case 'holiday':
        return <PartyPopper className="w-4 h-4" />;
      case 'maintenance':
        return <Wrench className="w-4 h-4" />;
      case 'inspection':
        return <CheckCircle2 className="w-4 h-4" />;
      default:
        return <Calendar className="w-4 h-4" />;
    }
  };

  // Mark event as completed
  const handleMarkCompleted = async (eventId) => {
    try {
      await calendarService?.markEventCompleted(eventId);
      loadCalendarData(); // Refresh data
    } catch (err) {
      console.error('Error marking event as completed:', err);
      setError('Failed to update event status');
    }
  };

  if (loading) {
    return (
      <div className={`bg-card rounded-lg border border-border p-6 ${className}`}>
        <div className="flex items-center space-x-3 mb-4">
          <Calendar className="w-5 h-5 text-primary" />
          <h3 className="text-lg font-semibold text-foreground">Company Calendar</h3>
        </div>
        <div className="animate-pulse space-y-3">
          <div className="h-4 bg-muted rounded w-3/4"></div>
          <div className="h-4 bg-muted rounded w-1/2"></div>
          <div className="h-4 bg-muted rounded w-5/6"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className={`bg-card rounded-lg border border-border p-6 ${className}`}>
        <div className="flex items-center space-x-3 mb-4">
          <Calendar className="w-5 h-5 text-primary" />
          <h3 className="text-lg font-semibold text-foreground">Company Calendar</h3>
        </div>
        <div className="text-center py-8">
          <AlertCircle className="w-12 h-12 text-destructive mx-auto mb-3" />
          <p className="text-destructive mb-4">{error}</p>
          <button 
            onClick={loadCalendarData}
            className="bg-primary text-primary-foreground px-4 py-2 rounded-md hover:bg-primary/90 transition-colors"
          >
            Try Again
          </button>
        </div>
      </div>
    );
  }

  const currentEvents = selectedView === 'today' ? todayEvents : upcomingEvents;
  const monthLabel = format(currentMonth, 'MMMM yyyy');
  const today = new Date();

  return (
    <>
      <div className={`bg-card rounded-lg border border-border p-6 ${className}`}>
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-3">
            <Calendar className="w-5 h-5 text-primary" />
            <h3 className="text-lg font-semibold text-foreground">Company Calendar</h3>
          </div>
          
          <div className="flex items-center space-x-3">
            {/* Add Event Button */}
            <button
              onClick={() => setShowAddEventModal(true)}
              className="flex items-center space-x-2 bg-primary text-primary-foreground px-3 py-1.5 rounded-md hover:bg-primary/90 transition-colors text-sm"
            >
              <Plus className="w-4 h-4" />
              <span>Add Event</span>
            </button>

            {/* View Toggle */}
            <div className="flex bg-muted rounded-md p-1">
              <button
                onClick={() => setSelectedView('today')}
                className={`px-3 py-1 text-sm rounded transition-colors ${
                  selectedView === 'today' ?'bg-background text-foreground shadow-sm' :'text-muted-foreground hover:text-foreground'
                }`}
              >
                Today ({todayEvents?.length || 0})
              </button>
              <button
                onClick={() => setSelectedView('upcoming')}
                className={`px-3 py-1 text-sm rounded transition-colors ${
                  selectedView === 'upcoming' ?'bg-background text-foreground shadow-sm' :'text-muted-foreground hover:text-foreground'
                }`}
              >
                This Week ({upcomingEvents?.length || 0})
              </button>
            </div>
          </div>
        </div>

        <div className="mt-6 grid gap-6 lg:grid-cols-[280px,1fr]">
          <div className="rounded-lg border border-border bg-muted/40 p-4">
            <div className="mb-4 flex items-center justify-between">
              <button
                type="button"
                onClick={handlePrevMonth}
                className="rounded-md p-1 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
                aria-label="Previous month"
              >
                <ChevronLeft className="h-4 w-4" />
              </button>
              <div className="text-center">
                <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Month</p>
                <p className="text-base font-semibold text-foreground">{monthLabel}</p>
              </div>
              <button
                type="button"
                onClick={handleNextMonth}
                className="rounded-md p-1 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
                aria-label="Next month"
              >
                <ChevronRight className="h-4 w-4" />
              </button>
            </div>
            <div className="grid grid-cols-7 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
              {WEEK_DAYS.map((dayLabel) => (
                <div key={dayLabel} className="pb-2 text-center">
                  {dayLabel}
                </div>
              ))}
            </div>
            <div className="grid grid-cols-7 gap-1 text-sm">
              {calendarDays.map((day) => {
                const dayKey = format(day, 'yyyy-MM-dd');
                const dayEvents = eventsByDate[dayKey] || [];
                const isCurrentMonthDay = isSameMonth(day, currentMonth);
                const isToday = isSameDay(day, today);

                return (
                  <div
                    key={dayKey}
                    className={`flex h-16 flex-col items-center justify-center rounded-md border border-transparent transition-colors ${
                      isToday ? 'border-primary bg-primary/10 shadow-sm' : ''
                    } ${isCurrentMonthDay ? 'text-foreground hover:border-border' : 'text-muted-foreground/60'}`}
                  >
                    <span className={`text-sm font-medium ${isToday ? 'text-primary' : ''}`}>
                      {format(day, 'd')}
                    </span>
                    {dayEvents.length > 0 && (
                      <div className="mt-1 flex items-center gap-1">
                        <span className="h-1.5 w-1.5 rounded-full bg-primary" />
                        {dayEvents.length > 1 && (
                          <span className="text-[10px] font-medium text-primary">
                            {dayEvents.length > 9 ? '9+' : dayEvents.length}
                          </span>
                        )}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>

          {/* Events List */}
          <div className="space-y-3 max-h-96 overflow-y-auto">
            {currentEvents?.length === 0 ? (
              <div className="py-8 text-center">
                <Calendar className="mx-auto mb-3 h-12 w-12 text-muted-foreground" />
                <p className="mb-2 text-muted-foreground">
                  {selectedView === 'today' ? 'No events scheduled for today' : 'No upcoming events this week'}
                </p>
                <p className="mb-4 text-sm text-muted-foreground">
                  Create your first event to get started
                </p>
                <button
                  onClick={() => setShowAddEventModal(true)}
                  className="rounded-md bg-primary px-4 py-2 text-sm text-primary-foreground transition-colors hover:bg-primary/90"
                >
                  Add Event
                </button>
              </div>
            ) : (
              currentEvents?.map((event) => (
                <div
                  key={event?.id}
                  className="flex items-start space-x-3 rounded-md border border-border p-3 transition-colors hover:bg-muted/50"
                >
                  {/* Event Type Icon */}
                  <div className={`rounded-md p-2 ${getPriorityColor(event?.priority)}`}>
                    {getEventTypeIcon(event?.event_type)}
                  </div>

                  {/* Event Details */}
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center justify-between">
                      <h4 className="truncate font-medium text-foreground">
                        {event?.title || 'Untitled Event'}
                      </h4>
                      <span className={`text-xs px-2 py-1 rounded-full ${getPriorityColor(event?.priority)}`}>
                        {event?.priority}
                      </span>
                    </div>

                    {/* Event Description */}
                    {event?.description && (
                      <p className="mt-1 line-clamp-2 text-sm text-muted-foreground">
                        {event?.description}
                      </p>
                    )}

                    {/* Event Metadata */}
                    <div className="mt-2 flex items-center space-x-4 text-xs text-muted-foreground">
                      <div className="flex items-center space-x-1">
                        <Clock className="h-3 w-3" />
                        <span>
                          {selectedView === 'today'
                            ? formatEventTime(event?.start_datetime, event?.all_day)
                            : `${formatEventDate(event?.start_datetime)} - ${formatEventTime(event?.start_datetime, event?.all_day)}`
                          }
                        </span>
                      </div>

                      {event?.location && (
                        <div className="flex items-center space-x-1">
                          <MapPin className="h-3 w-3" />
                          <span className="truncate">{event?.location}</span>
                        </div>
                      )}

                      {event?.assigned_to_name && (
                        <div className="flex items-center space-x-1">
                          <Users className="h-3 w-3" />
                          <span className="truncate">{event?.assigned_to_name}</span>
                        </div>
                      )}
                    </div>

                    {/* Action Buttons */}
                    <div className="mt-3 flex items-center space-x-2">
                      {event?.meeting_url && (
                        <a
                          href={event?.meeting_url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="rounded bg-primary px-2 py-1 text-xs text-primary-foreground transition-colors hover:bg-primary/90"
                        >
                          Join Meeting
                        </a>
                      )}
                      
                      {event?.status === 'scheduled' && event?.assigned_to_name === userProfile?.full_name && (
                        <button
                          onClick={() => handleMarkCompleted(event?.id)}
                          className="rounded bg-green-600 px-2 py-1 text-xs text-white transition-colors hover:bg-green-700"
                        >
                          Mark Complete
                        </button>
                      )}

                      <span className={`text-xs px-2 py-1 rounded ${
                        event?.status === 'completed' ? 'bg-green-100 text-green-800' :
                        event?.status === 'in_progress'? 'bg-yellow-100 text-yellow-800' : 'bg-blue-100 text-blue-800'
                      }`}>
                        {event?.status?.replace('_', ' ')}
                      </span>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Footer with Quick Actions */}
        {(todayEvents?.length > 0 || upcomingEvents?.length > 0) && (
          <div className="mt-4 pt-4 border-t border-border">
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">
                {selectedView === 'today' 
                  ? `${todayEvents?.length} events today`
                  : `${upcomingEvents?.length} upcoming events`
                }
              </span>
              <button 
                onClick={loadCalendarData}
                className="text-primary hover:text-primary/80 transition-colors"
              >
                Refresh
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Add Event Modal */}
      <AddEventModal
        isOpen={showAddEventModal}
        onClose={() => setShowAddEventModal(false)}
        onEventCreated={handleEventCreated}
      />
    </>
  );
};

export default TenantCalendar;
