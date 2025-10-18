import { supabase } from '../lib/supabase';

class CalendarService {
  // Get today's events for the current user's tenant
  async getTodayEvents() {
    try {
      const { data, error } = await supabase?.rpc('get_today_events');
      
      if (error) {
        console.error('Error fetching today events:', error);
        throw error;
      }
      
      return data || [];
    } catch (error) {
      console.error('Calendar service error - getTodayEvents:', error);
      throw error;
    }
  }

  // Get upcoming events for the next N days
  async getUpcomingEvents(daysAhead = 7) {
    try {
      const { data, error } = await supabase?.rpc('get_upcoming_events', { 
        days_ahead: daysAhead 
      });
      
      if (error) {
        console.error('Error fetching upcoming events:', error);
        throw error;
      }
      
      return data || [];
    } catch (error) {
      console.error('Calendar service error - getUpcomingEvents:', error);
      throw error;
    }
  }

  // Get events for a specific date range
  async getEventsByDateRange(startDate, endDate) {
    try {
      const { data, error } = await supabase
        ?.from('calendar_events')
        ?.select(`
          id,
          title,
          description,
          event_type,
          priority,
          status,
          start_datetime,
          end_datetime,
          all_day,
          location,
          meeting_url,
          notes,
          created_by:user_profiles!created_by(id, full_name),
          assigned_to:user_profiles!assigned_to(id, full_name),
          related_account:accounts(id, name),
          related_property:properties(id, name),
          related_contact:contacts(id, first_name, last_name)
        `)
        ?.gte('start_datetime', startDate)
        ?.lte('end_datetime', endDate)
        ?.in('status', ['scheduled', 'in_progress'])
        ?.order('start_datetime', { ascending: true });

      if (error) {
        console.error('Error fetching events by date range:', error);
        throw error;
      }

      return data || [];
    } catch (error) {
      console.error('Calendar service error - getEventsByDateRange:', error);
      throw error;
    }
  }

  // Create a new calendar event
  async createEvent(eventData) {
    try {
      const { data, error } = await supabase
        ?.from('calendar_events')
        ?.insert({
          title: eventData?.title,
          description: eventData?.description,
          event_type: eventData?.event_type || 'meeting',
          priority: eventData?.priority || 'medium',
          start_datetime: eventData?.start_datetime,
          end_datetime: eventData?.end_datetime,
          all_day: eventData?.all_day || false,
          location: eventData?.location,
          meeting_url: eventData?.meeting_url,
          notes: eventData?.notes,
          assigned_to: eventData?.assigned_to,
          related_account_id: eventData?.related_account_id,
          related_property_id: eventData?.related_property_id,
          related_contact_id: eventData?.related_contact_id,
          is_private: eventData?.is_private || false,
          reminder_minutes: eventData?.reminder_minutes || [15, 60]
        })
        ?.select()
        ?.single();

      if (error) {
        console.error('Error creating calendar event:', error);
        throw error;
      }

      return data;
    } catch (error) {
      console.error('Calendar service error - createEvent:', error);
      throw error;
    }
  }

  // Update an existing calendar event
  async updateEvent(eventId, eventData) {
    try {
      const { data, error } = await supabase
        ?.from('calendar_events')
        ?.update({
          title: eventData?.title,
          description: eventData?.description,
          event_type: eventData?.event_type,
          priority: eventData?.priority,
          status: eventData?.status,
          start_datetime: eventData?.start_datetime,
          end_datetime: eventData?.end_datetime,
          all_day: eventData?.all_day,
          location: eventData?.location,
          meeting_url: eventData?.meeting_url,
          notes: eventData?.notes,
          assigned_to: eventData?.assigned_to,
          related_account_id: eventData?.related_account_id,
          related_property_id: eventData?.related_property_id,
          related_contact_id: eventData?.related_contact_id,
          is_private: eventData?.is_private,
          reminder_minutes: eventData?.reminder_minutes
        })
        ?.eq('id', eventId)
        ?.select()
        ?.single();

      if (error) {
        console.error('Error updating calendar event:', error);
        throw error;
      }

      return data;
    } catch (error) {
      console.error('Calendar service error - updateEvent:', error);
      throw error;
    }
  }

  // Delete a calendar event
  async deleteEvent(eventId) {
    try {
      const { error } = await supabase
        ?.from('calendar_events')
        ?.delete()
        ?.eq('id', eventId);

      if (error) {
        console.error('Error deleting calendar event:', error);
        throw error;
      }

      return true;
    } catch (error) {
      console.error('Calendar service error - deleteEvent:', error);
      throw error;
    }
  }

  // Get events assigned to current user
  async getMyAssignedEvents() {
    try {
      const { data: { user } } = await supabase?.auth?.getUser();
      
      if (!user) {
        throw new Error('User not authenticated');
      }

      const { data, error } = await supabase
        ?.from('calendar_events')
        ?.select(`
          id,
          title,
          description,
          event_type,
          priority,
          status,
          start_datetime,
          end_datetime,
          all_day,
          location,
          meeting_url,
          notes,
          created_by:user_profiles!created_by(id, full_name)
        `)
        ?.eq('assigned_to', user?.id)
        ?.in('status', ['scheduled', 'in_progress'])
        ?.order('start_datetime', { ascending: true });

      if (error) {
        console.error('Error fetching assigned events:', error);
        throw error;
      }

      return data || [];
    } catch (error) {
      console.error('Calendar service error - getMyAssignedEvents:', error);
      throw error;
    }
  }

  // Mark event as completed
  async markEventCompleted(eventId) {
    try {
      const { data, error } = await supabase
        ?.from('calendar_events')
        ?.update({ status: 'completed' })
        ?.eq('id', eventId)
        ?.select()
        ?.single();

      if (error) {
        console.error('Error marking event as completed:', error);
        throw error;
      }

      return data;
    } catch (error) {
      console.error('Calendar service error - markEventCompleted:', error);
      throw error;
    }
  }

  // Subscribe to real-time calendar events changes
  subscribeToEvents(callback) {
    try {
      const channel = supabase
        ?.channel('calendar_events')
        ?.on(
          'postgres_changes',
          { 
            event: '*', 
            schema: 'public', 
            table: 'calendar_events' 
          },
          (payload) => {
            callback?.(payload);
          }
        )
        ?.subscribe();

      return channel;
    } catch (error) {
      console.error('Calendar service error - subscribeToEvents:', error);
      return null;
    }
  }

  // Unsubscribe from real-time events
  unsubscribeFromEvents(channel) {
    try {
      if (channel) {
        supabase?.removeChannel(channel);
      }
    } catch (error) {
      console.error('Calendar service error - unsubscribeFromEvents:', error);
    }
  }
}

export const calendarService = new CalendarService();
export default calendarService;