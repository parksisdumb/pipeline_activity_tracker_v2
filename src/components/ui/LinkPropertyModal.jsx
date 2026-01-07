import React, { useEffect, useMemo, useState } from 'react';
import Modal from './Modal';
import Button from './Button';
import Select from './Select';
import Icon from '../AppIcon';
import { propertiesService } from '../../services/propertiesService';
import { propertyContactsService } from '../../services/propertyContactsService';

const LinkPropertyModal = ({ isOpen, onClose, contact, onSuccess }) => {
  const [linkedProperties, setLinkedProperties] = useState([]);
  const [availableProperties, setAvailableProperties] = useState([]);
  const [selectedPropertyId, setSelectedPropertyId] = useState('');
  const [loading, setLoading] = useState(false);
  const [loadingProperties, setLoadingProperties] = useState(false);
  const [removingId, setRemovingId] = useState(null);
  const [error, setError] = useState(null);
  const [toast, setToast] = useState(null);

  const contactAccountId = contact?.accountId || contact?.account_id || null;

  useEffect(() => {
    if (isOpen && contact?.id) {
      loadLinkedProperties();
      loadAvailableProperties();
      setSelectedPropertyId('');
      setError(null);
    }
  }, [isOpen, contact?.id, contactAccountId]);

  useEffect(() => {
    if (!toast) return;
    const timeout = setTimeout(() => setToast(null), 4500);
    return () => clearTimeout(timeout);
  }, [toast]);

  const availableOptions = useMemo(() => {
    const linkedIds = new Set(linkedProperties?.map((property) => property?.id));
    return (availableProperties || [])?.filter((property) => property?.id && !linkedIds?.has(property?.id));
  }, [availableProperties, linkedProperties]);

  const propertyOptions = useMemo(() => (
    availableOptions?.map((property) => ({
      value: property?.id,
      label: property?.name || 'Unnamed Property',
      description: [property?.address, property?.city, property?.state]?.filter(Boolean)?.join(', ')
    })) || []
  ), [availableOptions]);

  const loadLinkedProperties = async () => {
    setLoading(true);
    setError(null);

    try {
      const result = await propertyContactsService?.getPropertiesForContact(contact?.id);
      if (result?.success) {
        setLinkedProperties(result?.data || []);
      } else {
        const errorMsg = result?.error || 'Failed to load linked properties';
        setError(errorMsg);
        console.error('Failed to load linked properties:', errorMsg);
      }
    } catch (err) {
      console.error('Error loading linked properties:', err);
      setError('Failed to load linked properties');
    } finally {
      setLoading(false);
    }
  };

  const loadAvailableProperties = async () => {
    if (!contactAccountId) {
      setAvailableProperties([]);
      return;
    }

    setLoadingProperties(true);
    setError(null);

    try {
      const result = await propertiesService?.getPropertiesByAccount(contactAccountId);
      if (result?.success) {
        setAvailableProperties(result?.data || []);
      } else {
        const errorMsg = result?.error || 'Failed to load available properties';
        setError(errorMsg);
        console.error('Failed to load available properties:', errorMsg);
      }
    } catch (err) {
      console.error('Error loading available properties:', err);
      setError('Failed to load available properties');
    } finally {
      setLoadingProperties(false);
    }
  };

  const handleLinkProperty = async () => {
    if (!selectedPropertyId) {
      setError('Please select a property');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const result = await propertyContactsService?.addContactToProperty({
        propertyId: selectedPropertyId,
        contactId: contact?.id
      });

      if (result?.success) {
        setSelectedPropertyId('');
        await loadLinkedProperties();
        await loadAvailableProperties();
        onSuccess?.();
      } else {
        const errorMsg = result?.error || 'Failed to link property';
        setError(errorMsg);
        setToast({ type: 'error', message: errorMsg });
      }
    } catch (err) {
      console.error('Error linking property:', err);
      const errorMsg = err?.message || 'Failed to link property';
      setError(errorMsg);
      setToast({ type: 'error', message: errorMsg });
    } finally {
      setLoading(false);
    }
  };

  const handleUnlinkProperty = async (propertyId) => {
    if (!propertyId) return;

    setRemovingId(propertyId);
    setError(null);

    try {
      const result = await propertyContactsService?.removeContactFromProperty({
        propertyId,
        contactId: contact?.id
      });

      if (result?.success) {
        await loadLinkedProperties();
        await loadAvailableProperties();
        onSuccess?.();
      } else {
        const errorMsg = result?.error || 'Failed to unlink property';
        setError(errorMsg);
        setToast({ type: 'error', message: errorMsg });
      }
    } catch (err) {
      console.error('Error unlinking property:', err);
      const errorMsg = err?.message || 'Failed to unlink property';
      setError(errorMsg);
      setToast({ type: 'error', message: errorMsg });
    } finally {
      setRemovingId(null);
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Link Property">
      <div className="space-y-6">
        {toast && (
          <div className="fixed top-4 right-4 z-[60] max-w-sm">
            <div className="flex items-start gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700 shadow-lg">
              <Icon name="AlertTriangle" size={16} className="mt-0.5 text-red-600" />
              <span>{toast?.message}</span>
            </div>
          </div>
        )}

        <div className="bg-muted/50 rounded-lg p-4 space-y-3">
          <div className="flex items-center space-x-3">
            <Icon name="MapPin" size={16} className="text-muted-foreground" />
            <h3 className="font-medium text-foreground">Linked Properties</h3>
          </div>
          {loading ? (
            <p className="text-sm text-muted-foreground">Loading linked properties...</p>
          ) : linkedProperties?.length === 0 ? (
            <p className="text-sm text-muted-foreground">No properties linked yet.</p>
          ) : (
            <div className="space-y-2">
              {linkedProperties?.map((property) => (
                <div
                  key={property?.id}
                  className="flex items-center justify-between rounded-md border border-border bg-background px-3 py-2"
                >
                  <div>
                    <p className="text-sm font-medium text-foreground">
                      {property?.name || 'Unnamed Property'}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {property?.address || 'No address provided'}
                    </p>
                  </div>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleUnlinkProperty(property?.id)}
                    disabled={removingId === property?.id}
                    className="text-destructive border-destructive hover:bg-destructive/10"
                  >
                    {removingId === property?.id ? (
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
              ))}
            </div>
          )}
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-foreground mb-2">
              Select Property to Link
            </label>
            <Select
              value={selectedPropertyId}
              onChange={setSelectedPropertyId}
              options={propertyOptions}
              placeholder={
                loadingProperties
                  ? 'Loading properties...'
                  : propertyOptions?.length === 0
                    ? 'No properties available'
                    : 'Choose a property'
              }
              disabled={loadingProperties || loading || propertyOptions?.length === 0 || !contactAccountId}
              loading={loadingProperties}
              emptyMessage="No properties found"
            />

            <div className="mt-2 text-xs text-muted-foreground">
              {!contactAccountId && (
                <p>Assign this contact to an account to link properties.</p>
              )}
              {contactAccountId && loadingProperties && (
                <p>Loading properties from the same account...</p>
              )}
              {contactAccountId && !loadingProperties && propertyOptions?.length === 0 && !error && (
                <p>No available properties found in this contact&apos;s account.</p>
              )}
              {contactAccountId && !loadingProperties && propertyOptions?.length > 0 && (
                <p>Showing {propertyOptions?.length} available properties from the same account.</p>
              )}
            </div>
          </div>
        </div>

        {error && (
          <div className="bg-destructive/10 border border-destructive/20 rounded-lg p-3">
            <div className="flex items-center space-x-2">
              <Icon name="AlertCircle" size={16} className="text-destructive" />
              <p className="text-sm text-destructive">{error}</p>
            </div>
          </div>
        )}

        <div className="flex justify-end space-x-3 pt-4 border-t border-border">
          <Button variant="outline" onClick={onClose} disabled={loading}>
            Cancel
          </Button>
          <Button
            onClick={handleLinkProperty}
            disabled={!selectedPropertyId || loading || loadingProperties || !contactAccountId}
            className="min-w-[120px]"
          >
            {loading ? (
              <>
                <div className="w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin mr-2" />
                Linking...
              </>
            ) : (
              <>
                <Icon name="Link" size={16} className="mr-2" />
                Link Property
              </>
            )}
          </Button>
        </div>
      </div>
    </Modal>
  );
};

export default LinkPropertyModal;
