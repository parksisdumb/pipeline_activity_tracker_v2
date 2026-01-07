import React, { useEffect, useMemo, useState } from 'react';
import Button from '../../../components/ui/Button';
import Select from '../../../components/ui/Select';
import Icon from '../../../components/AppIcon';
import { contactsService } from '../../../services/contactsService';
import { propertyContactsService } from '../../../services/propertyContactsService';

const AddContactTab = ({ property, linkedContacts = [], onContactsRefresh }) => {
  const [accountContacts, setAccountContacts] = useState([]);
  const [selectedContactId, setSelectedContactId] = useState('');
  const [loadingContacts, setLoadingContacts] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [unlinkingId, setUnlinkingId] = useState(null);
  const [error, setError] = useState(null);
  const [statusMessage, setStatusMessage] = useState('');
  const [toast, setToast] = useState(null);

  const propertyId = property?.id;
  const accountId = property?.account_id;

  const resolvedLinkedContacts = useMemo(() => linkedContacts || [], [linkedContacts]);

  useEffect(() => {
    if (accountId) {
      loadAccountContacts();
    } else {
      setAccountContacts([]);
    }
  }, [accountId]);

  useEffect(() => {
    if (!toast) return;
    const timeout = setTimeout(() => setToast(null), 4500);
    return () => clearTimeout(timeout);
  }, [toast]);

  const loadAccountContacts = async () => {
    if (!accountId) return;

    setLoadingContacts(true);
    setError(null);

    try {
      const result = await contactsService?.getContactsByAccount(accountId);
      if (result?.success) {
        setAccountContacts(result?.data || []);
      } else {
        setError(result?.error || 'Failed to load account contacts');
        setAccountContacts([]);
      }
    } catch (err) {
      console.error('Failed to load account contacts:', err);
      setError('Failed to load account contacts');
      setAccountContacts([]);
    } finally {
      setLoadingContacts(false);
    }
  };

  const availableContactOptions = useMemo(() => {
    if (!accountContacts?.length) return [];

    const linkedIds = new Set(resolvedLinkedContacts?.map(contact => contact?.id));

    return accountContacts
      ?.filter(contact => !!contact?.id)
      ?.map(contact => {
        const name = [contact?.first_name, contact?.last_name]?.filter(Boolean)?.join(' ') || contact?.email || 'Unnamed Contact';
        const descriptionParts = [contact?.title, contact?.email]?.filter(Boolean);

        return {
          value: contact?.id,
          label: name,
          description: descriptionParts?.length ? descriptionParts?.join(' - ') : undefined,
          isLinkedToThisProperty: linkedIds?.has(contact?.id),
          raw: contact
        };
      })
      ?.filter(option => !option?.isLinkedToThisProperty);
  }, [accountContacts, resolvedLinkedContacts]);

  const handleLinkContact = async () => {
    if (!selectedContactId || !propertyId) {
      setError('Please choose a contact to link');
      return;
    }

    setSubmitting(true);
    setError(null);
    setStatusMessage('');

    try {
      const result = await propertyContactsService?.addContactToProperty({
        propertyId,
        contactId: selectedContactId
      });
      if (result?.success) {
        setSelectedContactId('');
        setStatusMessage('Contact linked to property');
        await onContactsRefresh?.();
        await loadAccountContacts();
      } else {
        setError(result?.error || 'Failed to link contact to property');
        setToast({
          type: 'error',
          message: result?.error || 'Failed to link contact to property'
        });
      }
    } catch (err) {
      console.error('Failed to link contact:', err);
      setError('Failed to link contact to property');
      setToast({
        type: 'error',
        message: err?.message || 'Failed to link contact to property'
      });
    } finally {
      setSubmitting(false);
    }
  };

  const handleUnlinkContact = async (contactId) => {
    if (!contactId) return;

    setUnlinkingId(contactId);
    setError(null);
    setStatusMessage('');

    try {
      const result = await propertyContactsService?.removeContactFromProperty({
        propertyId,
        contactId
      });
      if (result?.success) {
        setStatusMessage('Contact unlinked from property');
        await onContactsRefresh?.();
        await loadAccountContacts();
      } else {
        setError(result?.error || 'Failed to unlink contact');
        setToast({
          type: 'error',
          message: result?.error || 'Failed to unlink contact from property'
        });
      }
    } catch (err) {
      console.error('Failed to unlink contact:', err);
      setError('Failed to unlink contact from property');
      setToast({
        type: 'error',
        message: err?.message || 'Failed to unlink contact from property'
      });
    } finally {
      setUnlinkingId(null);
    }
  };

  if (!accountId) {
    return (
      <div className="text-center py-12">
        <Icon name="Info" size={48} className="mx-auto text-muted-foreground mb-4" />
        <h3 className="text-lg font-medium text-foreground mb-2">No account assigned</h3>
        <p className="text-muted-foreground">
          This property must be associated with an account before contacts can be linked.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {toast && (
        <div className="fixed top-4 right-4 z-[70] max-w-sm">
          <div className="flex items-start gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700 shadow-lg">
            <Icon name="AlertTriangle" size={16} className="mt-0.5 text-red-600" />
            <span>{toast?.message}</span>
          </div>
        </div>
      )}
      <div className="bg-muted/40 border border-border rounded-lg p-6">
        <div className="mb-4">
          <h4 className="text-base font-semibold text-foreground">Link an account contact</h4>
          <p className="text-sm text-muted-foreground mt-1">
            Choose an existing contact from this property&apos;s account to link directly to the property.
          </p>
        </div>

        <div className="space-y-4">
          <Select
            label="Contact"
            placeholder={loadingContacts ? 'Loading contacts...' : 'Select a contact'}
            value={selectedContactId}
            onChange={setSelectedContactId}
            options={availableContactOptions?.map(option => ({
              value: option?.value,
              label: option?.label,
              description: option?.description
            }))}
            searchable
            disabled={loadingContacts || submitting || !availableContactOptions?.length}
            loading={loadingContacts}
            emptyMessage="No additional contacts available"
            description={
              !loadingContacts && availableContactOptions?.length === 0
                ? 'All account contacts are already linked to this property.'
                : undefined
            }
          />

          {error && (
            <div className="flex items-center gap-2 text-sm text-destructive bg-destructive/10 border border-destructive/20 rounded-md px-3 py-2">
              <Icon name="AlertCircle" size={16} />
              <span>{error}</span>
            </div>
          )}

          {statusMessage && !error && (
            <div className="flex items-center gap-2 text-sm text-green-700 bg-green-50 border border-green-200 rounded-md px-3 py-2">
              <Icon name="CheckCircle" size={16} className="text-green-600" />
              <span>{statusMessage}</span>
            </div>
          )}

          <div className="flex justify-end">
            <Button
              onClick={handleLinkContact}
              disabled={!selectedContactId || submitting || loadingContacts}
              className="min-w-[150px]"
            >
              {submitting ? (
                <>
                  <div className="w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin mr-2" />
                  Linking...
                </>
              ) : (
                <>
                  <Icon name="Link" size={16} className="mr-2" />
                  Link Contact
                </>
              )}
            </Button>
          </div>
        </div>
      </div>

      <div className="bg-card border border-border rounded-lg">
        <div className="px-6 py-4 border-b border-border flex items-center justify-between">
          <div>
            <h4 className="text-base font-semibold text-foreground">Linked contacts</h4>
            <p className="text-sm text-muted-foreground">
              Contacts linked directly to this property ({resolvedLinkedContacts?.length || 0})
            </p>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={loadAccountContacts}
            disabled={loadingContacts}
            title="Refresh contacts"
          >
            <Icon name="RefreshCw" size={16} className={loadingContacts ? 'animate-spin' : ''} />
          </Button>
        </div>

        <div className="p-6 space-y-4">
          {resolvedLinkedContacts?.length === 0 ? (
            <div className="text-center py-10">
              <Icon name="Users" size={40} className="mx-auto text-muted-foreground mb-3" />
              <p className="text-sm text-muted-foreground">
                No contacts are currently linked to this property.
              </p>
            </div>
          ) : (
            resolvedLinkedContacts?.map((contact) => (
              <div
                key={contact?.id}
                className="border border-border rounded-lg p-4 flex flex-col gap-2 md:flex-row md:items-center md:justify-between"
              >
                <div className="flex items-start gap-3">
                  <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-semibold">
                    {(contact?.first_name?.[0] || '') + (contact?.last_name?.[0] || '') || 'C'}
                  </div>
                  <div>
                    <h5 className="font-medium text-foreground">
                      {[contact?.first_name, contact?.last_name]?.filter(Boolean)?.join(' ') || contact?.email || 'Unnamed Contact'}
                    </h5>
                    {contact?.title && (
                      <p className="text-sm text-muted-foreground">{contact?.title}</p>
                    )}
                    {(contact?.email || contact?.phone) && (
                      <p className="text-xs text-muted-foreground mt-1">
                        {[contact?.email, contact?.phone]?.filter(Boolean)?.join(' • ')}
                      </p>
                    )}
                    {(contact?.is_primary ?? contact?.is_primary_contact) && (
                      <span className="inline-flex items-center text-xs font-medium text-amber-700 bg-amber-100 rounded-full px-2 py-0.5 mt-2">
                        <Icon name="Star" size={12} className="mr-1" />
                        Primary contact
                      </span>
                    )}
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleUnlinkContact(contact?.id)}
                    disabled={unlinkingId === contact?.id}
                    className="text-destructive border-destructive hover:bg-destructive/10"
                  >
                    {unlinkingId === contact?.id ? (
                      <>
                        <div className="w-3.5 h-3.5 border-2 border-current border-t-transparent rounded-full animate-spin mr-2" />
                        Removing...
                      </>
                    ) : (
                      <>
                        <Icon name="Unlink" size={14} className="mr-2" />
                        Remove
                      </>
                    )}
                  </Button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default AddContactTab;
