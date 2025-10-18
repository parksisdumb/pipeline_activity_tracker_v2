import React, { useState, useEffect } from 'react';
import Icon from '../../../components/AppIcon';
import { propertiesService } from '../../../services/propertiesService';

const PropertiesTab = ({ accountId, onAddProperty = () => {} }) => {
  const [properties, setProperties] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // CRITICAL FIX: Load actual properties data for the account
  useEffect(() => {
    const loadAccountProperties = async () => {
      if (!accountId) {
        console.warn('⚠️ No account ID provided to PropertiesTab');
        setLoading(false);
        return;
      }

      try {
        console.log('🔍 Loading properties for account:', accountId);
        setLoading(true);
        setError(null);

        // FIXED: Use the proper service method to get properties by account
        const result = await propertiesService?.getPropertiesByAccount(accountId);

        if (result?.success) {
          console.log(`✅ Account properties loaded: ${result?.data?.length} properties`);
          setProperties(result?.data || []);
          
          // Log sample property data for debugging
          if (result?.data?.length > 0) {
            console.log('📊 Sample property:', {
              id: result?.data?.[0]?.id,
              name: result?.data?.[0]?.name,
              building_type: result?.data?.[0]?.building_type,
              address: result?.data?.[0]?.fullAddress || result?.data?.[0]?.address
            });
          }
        } else {
          console.error('❌ Failed to load account properties:', result?.error);
          setError(result?.error || 'Failed to load properties');
          setProperties([]);
        }
      } catch (loadError) {
        console.error('❌ Error loading account properties:', loadError);
        setError('Failed to load properties');
        setProperties([]);
      } finally {
        setLoading(false);
      }
    };

    loadAccountProperties();
  }, [accountId]);

  if (loading) {
    return (
      <div className="p-6">
        <div className="flex items-center justify-center py-8">
          <div className="animate-spin w-6 h-6 border-2 border-primary border-t-transparent rounded-full" />
          <span className="ml-3 text-muted-foreground">Loading properties...</span>
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
            <p className="font-medium">Error loading properties</p>
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
          <h3 className="text-lg font-semibold text-foreground">Properties</h3>
          <p className="text-sm text-muted-foreground">
            {properties?.length || 0} {properties?.length === 1 ? 'property' : 'properties'}
          </p>
        </div>
        <button
          onClick={onAddProperty}
          className="flex items-center gap-2 bg-primary text-primary-foreground px-4 py-2 rounded-lg hover:bg-primary/90 transition-colors"
        >
          <Icon name="Plus" size={16} />
          Add Property
        </button>
      </div>

      {properties?.length === 0 ? (
        <div className="text-center py-8">
          <Icon name="Building2" size={48} className="text-muted-foreground/50 mx-auto mb-4" />
          <h4 className="text-lg font-medium text-foreground mb-2">No Properties Yet</h4>
          <p className="text-muted-foreground mb-4">
            This account doesn't have any properties assigned yet.
          </p>
          <button
            onClick={onAddProperty}
            className="bg-primary text-primary-foreground px-4 py-2 rounded-lg hover:bg-primary/90 transition-colors"
          >
            Add First Property
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {properties?.map((property) => (
            <div
              key={property?.id}
              className="border border-border rounded-lg p-4 hover:bg-muted/30 transition-colors cursor-pointer"
              onClick={() => {
                // Navigate to property details page
                window.location.href = `/properties/${property?.id}`;
              }}
            >
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <h4 className="font-medium text-foreground mb-1">
                    {property?.name || 'Unnamed Property'}
                  </h4>
                  
                  <div className="space-y-1 text-sm text-muted-foreground">
                    {property?.building_type && (
                      <div className="flex items-center gap-2">
                        <Icon name="Building2" size={14} />
                        <span className="capitalize">
                          {property?.building_type?.replace(/_/g, ' ')}
                        </span>
                      </div>
                    )}
                    
                    {(property?.fullAddress || property?.address) && (
                      <div className="flex items-center gap-2">
                        <Icon name="MapPin" size={14} />
                        <span>{property?.fullAddress || property?.address}</span>
                      </div>
                    )}
                    
                    {property?.formattedSquareFootage && (
                      <div className="flex items-center gap-2">
                        <Icon name="Square" size={14} />
                        <span>{property?.formattedSquareFootage}</span>
                      </div>
                    )}
                  </div>
                </div>
                
                <div className="flex items-center gap-3 ml-4">
                  {/* Property stage badge */}
                  {property?.stage && (
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                      property?.stage === 'won' ? 'bg-green-100 text-green-800' :
                      property?.stage === 'proposal' ? 'bg-yellow-100 text-yellow-800' :
                      property?.stage === 'qualified'? 'bg-blue-100 text-blue-800' : 'bg-gray-100 text-gray-800'
                    }`}>
                      {property?.stage?.charAt(0)?.toUpperCase() + property?.stage?.slice(1)}
                    </span>
                  )}
                  
                  {/* Contacts and opportunities count */}
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    {property?.contactsCount > 0 && (
                      <div className="flex items-center gap-1">
                        <Icon name="Users" size={12} />
                        <span>{property?.contactsCount}</span>
                      </div>
                    )}
                    {property?.opportunitiesCount > 0 && (
                      <div className="flex items-center gap-1">
                        <Icon name="TrendingUp" size={12} />
                        <span>{property?.opportunitiesCount}</span>
                      </div>
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
      {process.env?.NODE_ENV === 'development' && (
        <div className="mt-6 p-3 bg-muted/30 rounded text-xs text-muted-foreground">
          <div className="font-medium mb-1">Properties Debug Info:</div>
          <div>Account ID: {accountId}</div>
          <div>Properties loaded: {properties?.length}</div>
          <div>Loading state: {loading ? 'true' : 'false'}</div>
          <div>Error: {error || 'none'}</div>
        </div>
      )}
    </div>
  );
};

export default PropertiesTab;