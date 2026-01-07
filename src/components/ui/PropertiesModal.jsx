import React, { useEffect, useMemo, useState } from 'react';
import Modal from './Modal';
import Button from './Button';
import Select from './Select';
import Icon from '../AppIcon';
import { propertiesService } from '../../services/propertiesService';
import { propertyContactsService } from '../../services/propertyContactsService';

const PropertiesModal = ({ isOpen, onClose, contact, onNavigateToProperty }) => {
  const [linkedProperties, setLinkedProperties] = useState([]);
  const [availableProperties, setAvailableProperties] = useState([]);
  const [loading, setLoading] = useState(false);
  const [loadingAvailable, setLoadingAvailable] = useState(false);
  const [saving, setSaving] = useState(false);
  const [removingId, setRemovingId] = useState(null);
  const [selectedPropertyId, setSelectedPropertyId] = useState('');
  const [error, setError] = useState(null);
  const [toast, setToast] = useState(null);

  useEffect(() => {
    if (isOpen && contact?.id) {
      loadLinkedProperties();
      loadAvailableProperties();
    }
  }, [isOpen, contact?.id, contact?.accountId, contact?.account_id]);

  useEffect(() => {
    if (!toast) return;
    const timeout = setTimeout(() => setToast(null), 4500);
    return () => clearTimeout(timeout);
  }, [toast]);

  const contactAccountId = contact?.accountId || contact?.account_id || null;

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

    setLoadingAvailable(true);
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
      setLoadingAvailable(false);
    }
  };

  const handleAddProperty = async () => {
    if (!selectedPropertyId) {
      setError('Please select a property');
      return;
    }

    setSaving(true);
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
      setSaving(false);
    }
  };

  const handleRemoveProperty = async (propertyId) => {
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

  const handlePropertyClick = (propertyId) => {
    if (propertyId) {
      onNavigateToProperty?.(propertyId);
      onClose();
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Linked Properties">
      <div className="space-y-6">
        {toast && (
          <div className="fixed top-4 right-4 z-[60] max-w-sm">
            <div className="flex items-start gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700 shadow-lg">
              <Icon name="AlertTriangle" size={16} className="mt-0.5 text-red-600" />
              <span>{toast?.message}</span>
            </div>
          </div>
        )}
        {/* Header Info */}
        <div className="flex items-center space-x-3">
          <Icon name="Building2" size={20} className="text-primary" />
          <div>
            <h3 className="font-semibold text-foreground">Properties for {contact?.name}</h3>
            <p className="text-sm text-muted-foreground">
              {loading ? 'Loading...' : `${linkedProperties?.length || 0} linked properties found`}
            </p>
          </div>
        </div>

        {contactAccountId ? (
          <div className="bg-muted/40 border border-border rounded-lg p-4 space-y-4">
            <div>
              <h4 className="text-sm font-semibold text-foreground">Add property</h4>
              <p className="text-xs text-muted-foreground mt-1">
                Link this contact to another property in the same account.
              </p>
            </div>
            <Select
              label="Property"
              placeholder={loadingAvailable ? 'Loading properties...' : 'Select a property'}
              value={selectedPropertyId}
              onChange={setSelectedPropertyId}
              options={propertyOptions}
              searchable
              disabled={loadingAvailable || saving || propertyOptions?.length === 0}
              loading={loadingAvailable}
              emptyMessage="No additional properties available"
            />
            <div className="flex justify-end">
              <Button
                onClick={handleAddProperty}
                disabled={!selectedPropertyId || saving || loadingAvailable}
                className="min-w-[150px]"
              >
                {saving ? (
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
        ) : (
          <div className="bg-muted/40 border border-border rounded-lg p-4 text-sm text-muted-foreground">
            Assign this contact to an account to link properties.
          </div>
        )}

        {/* Content */}
        {loading ? (
          <div className="flex items-center justify-center py-8">
            <div className="text-center">
              <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-3"></div>
              <p className="text-sm text-muted-foreground">Loading linked properties...</p>
            </div>
          </div>
        ) : error ? (
          <div className="bg-destructive/10 border border-destructive/20 rounded-lg p-4">
            <div className="flex items-center space-x-2">
              <Icon name="AlertCircle" size={16} className="text-destructive" />
              <p className="text-sm text-destructive">{error}</p>
            </div>
          </div>
        ) : linkedProperties?.length === 0 ? (
          <div className="text-center py-8">
            <div className="w-16 h-16 bg-muted rounded-full flex items-center justify-center mx-auto mb-4">
              <Icon name="Building2" size={24} className="text-muted-foreground" />
            </div>
            <h4 className="font-medium text-foreground mb-2">No Properties Linked</h4>
            <p className="text-sm text-muted-foreground mb-4">
              This contact is not currently linked to any properties.
            </p>
            <p className="text-xs text-muted-foreground">
              Use the Add Property panel above to link a property.
            </p>
          </div>
        ) : (
          <div className="space-y-3">
            {linkedProperties?.map((property) => (
              <div
                key={property?.id}
                className="bg-card border border-border rounded-lg p-4 hover:bg-muted/50 transition-colors cursor-pointer"
                onClick={() => handlePropertyClick(property?.id)}
              >
                <div className="flex items-start space-x-3">
                  <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center flex-shrink-0">
                    <Icon name="Building" size={16} className="text-primary" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between">
                      <div className="flex-1 min-w-0">
                        <h4 className="font-medium text-foreground truncate">
                          {property?.name || 'Unnamed Property'}
                        </h4>
                        <p className="text-sm text-muted-foreground truncate">
                          {property?.address || 'No address provided'}
                        </p>
                      </div>
                      <div className="flex items-center gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={(event) => {
                            event?.stopPropagation?.();
                            handleRemoveProperty(property?.id);
                          }}
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
                        <Icon name="ExternalLink" size={16} className="text-muted-foreground ml-2 flex-shrink-0" />
                      </div>
                    </div>
                    
                    <div className="flex items-center space-x-4 mt-2">
                      <div className="flex items-center space-x-1">
                        <Icon name="Tag" size={12} className="text-muted-foreground" />
                        <span className="text-xs text-muted-foreground">
                          {property?.building_type || 'Unknown Type'}
                        </span>
                      </div>
                      <div className="flex items-center space-x-1">
                        <Icon name="Activity" size={12} className="text-muted-foreground" />
                        <span className="text-xs text-muted-foreground">
                          {property?.stage || 'Unknown Stage'}
                        </span>
                      </div>
                    </div>
                    
                    {property?.description && (
                      <p className="text-xs text-muted-foreground mt-2 line-clamp-2">
                        {property?.description}
                      </p>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Actions */}
        <div className="flex justify-end space-x-3 pt-4 border-t border-border">
          <Button variant="outline" onClick={onClose}>
            Close
          </Button>
          {linkedProperties?.length > 0 && (
            <Button onClick={() => window.open('/properties', '_blank')}>
              <Icon name="Building2" size={16} className="mr-2" />
              View All Properties
            </Button>
          )}
        </div>
      </div>
    </Modal>
  );
};

export default PropertiesModal;
