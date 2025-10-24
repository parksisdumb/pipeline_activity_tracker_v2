import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Icon from '../../../components/AppIcon';
import { contactsService } from '../../../services/contactsService';

const ContactsTab = ({ accountId, onAddContact = () => {} }) => {
  const navigate = useNavigate();
  const [contacts, setContacts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // CRITICAL FIX: Load actual contacts data for the account
  useEffect(() => {
    const loadAccountContacts = async () => {
      if (!accountId) {
        console.warn('⚠️ No account ID provided to ContactsTab');
        setLoading(false);
        return;
      }

      try {
        console.log('🔍 Loading contacts for account:', accountId);
        setLoading(true);
        setError(null);

        // FIXED: Use the proper service method to get contacts by account
        const result = await contactsService?.getContactsByAccount(accountId);

        if (result?.success) {
          console.log(`✅ Account contacts loaded: ${result?.data?.length} contacts`);
          setContacts(result?.data || []);
          
          // Log sample contact data for debugging
          if (result?.data?.length > 0) {
            console.log('📊 Sample contact:', {
              id: result?.data?.[0]?.id,
              name: `${result?.data?.[0]?.first_name} ${result?.data?.[0]?.last_name}`,
              email: result?.data?.[0]?.email,
              is_primary: result?.data?.[0]?.is_primary_contact
            });
          }
        } else {
          console.error('❌ Failed to load account contacts:', result?.error);
          setError(result?.error || 'Failed to load contacts');
          setContacts([]);
        }
      } catch (loadError) {
        console.error('❌ Error loading account contacts:', loadError);
        setError('Failed to load contacts');
        setContacts([]);
      } finally {
        setLoading(false);
      }
    };

    loadAccountContacts();
  }, [accountId]);

  if (loading) {
    return (
      <div className="p-6">
        <div className="flex items-center justify-center py-8">
          <div className="animate-spin w-6 h-6 border-2 border-primary border-t-transparent rounded-full" />
          <span className="ml-3 text-muted-foreground">Loading contacts...</span>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-6">
        <div className="bg-destructive/10 border border-destructive/20 rounded-lg p-4">
          <div className="flex items-center gap-2 text-destructive">
            <Icon name="AlertCircle" size={16} />
            <p className="font-medium">Error loading contacts</p>
          </div>
          <p className="text-sm text-muted-foreground mt-1">{error}</p>
          <button 
            onClick={() => window.location?.reload()} 
            className="text-sm underline mt-2 text-destructive hover:no-underline"
          >
            Try again
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-lg font-semibold text-foreground">Contacts</h3>
          <p className="text-sm text-muted-foreground">
            {contacts?.length || 0} {contacts?.length === 1 ? 'contact' : 'contacts'}
          </p>
        </div>
        <button
          onClick={onAddContact}
          className="flex items-center gap-2 bg-primary text-primary-foreground px-4 py-2 rounded-lg hover:bg-primary/90 transition-colors"
        >
          <Icon name="Plus" size={16} />
          Add Contact
        </button>
      </div>
      {contacts?.length === 0 ? (
        <div className="text-center py-8">
          <Icon name="UserPlus" size={48} className="text-muted-foreground/50 mx-auto mb-4" />
          <h4 className="text-lg font-medium text-foreground mb-2">No Contacts Yet</h4>
          <p className="text-muted-foreground mb-4">
            This account doesn't have any contacts assigned yet.
          </p>
          <button
            onClick={onAddContact}
            className="bg-primary text-primary-foreground px-4 py-2 rounded-lg hover:bg-primary/90 transition-colors"
          >
            Add First Contact
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {contacts?.map((contact) => (
            <div
              key={contact?.id}
              className="border border-border rounded-lg p-4 hover:bg-muted/30 transition-colors cursor-pointer"
              onClick={() => {
                if (!contact?.id) {
                  console.warn('Skipping contact navigation: missing contact ID', contact);
                  return;
                }
                navigate(`/contacts/${contact?.id}`);
              }}
            >
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <h4 className="font-medium text-foreground">
                      {`${contact?.first_name || ''} ${contact?.last_name || ''}`?.trim() || 'Unnamed Contact'}
                    </h4>
                    {contact?.is_primary_contact && (
                      <span className="bg-primary/10 text-primary px-2 py-1 rounded-full text-xs font-medium">
                        Primary
                      </span>
                    )}
                  </div>
                  
                  <div className="space-y-1 text-sm text-muted-foreground">
                    {contact?.title && (
                      <div className="flex items-center gap-2">
                        <Icon name="Briefcase" size={14} />
                        <span>{contact?.title}</span>
                      </div>
                    )}
                    
                    {contact?.email && (
                      <div className="flex items-center gap-2">
                        <Icon name="Mail" size={14} />
                        <span>{contact?.email}</span>
                      </div>
                    )}
                    
                    {(contact?.phone || contact?.mobile_phone) && (
                      <div className="flex items-center gap-2">
                        <Icon name="Phone" size={14} />
                        <span>{contact?.phone || contact?.mobile_phone}</span>
                      </div>
                    )}
                  </div>
                </div>
                
                <div className="flex items-center gap-3 ml-4">
                  {/* Contact stage badge */}
                  {contact?.stage && (
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                      contact?.stage === 'customer' ? 'bg-green-100 text-green-800' :
                      contact?.stage === 'opportunity' ? 'bg-yellow-100 text-yellow-800' :
                      contact?.stage === 'lead'? 'bg-blue-100 text-blue-800' : 'bg-gray-100 text-gray-800'
                    }`}>
                      {contact?.stage?.charAt(0)?.toUpperCase() + contact?.stage?.slice(1)}
                    </span>
                  )}
                  
                  {/* Contact activity indicators */}
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    {contact?.hasPhone && (
                      <Icon name="Phone" size={12} className="text-green-600" title="Has phone number" />
                    )}
                    {contact?.hasEmail && (
                      <Icon name="Mail" size={12} className="text-blue-600" title="Has email address" />
                    )}
                  </div>
                  
                  <Icon name="ChevronRight" size={16} className="text-muted-foreground" />
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
      {/* Debug info for development */}
      {import.meta?.env?.DEV && (
        <div className="mt-6 p-3 bg-muted/30 rounded text-xs text-muted-foreground">
          <div className="font-medium mb-1">Contacts Debug Info:</div>
          <div>Account ID: {accountId}</div>
          <div>Contacts loaded: {contacts?.length}</div>
          <div>Loading state: {loading ? 'true' : 'false'}</div>
          <div>Error: {error || 'none'}</div>
        </div>
      )}
    </div>
  );
};

export default ContactsTab;
