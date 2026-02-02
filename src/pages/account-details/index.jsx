import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import EditAccountModal from '../../components/ui/EditAccountModal';
import AccountHeader from './components/AccountHeader';
import TabNavigation from './components/TabNavigation';
import PropertiesTab from './components/PropertiesTab';
import ContactsTab from './components/ContactsTab';
import Timeline from '../../components/Timeline';
import { useAuth } from '../../contexts/AuthContext';
import { accountsService } from '../../services/accountsService';
import { propertiesService } from '../../services/propertiesService';
import { contactsService } from '../../services/contactsService';
import { timelineService } from '../../services/timelineService';
import { AssignRepsModal } from '../manager-dashboard/components/AssignRepsModal';
import LinkPropertyModal from '../../components/ui/LinkPropertyModal';
import AddContactModal from '../../components/ui/AddContactModal';
import AddPropertyModal from '../../components/ui/AddPropertyModal';

const AccountDetails = () => {
  const navigate = useNavigate();
  const { id: accountId } = useParams();
  const [searchParams, setSearchParams] = useState(new URLSearchParams());
  const { session, userProfile, loading: authLoading, isAuthenticated } = useAuth();
  const authUser = session?.user || null;
  
  const [activeTab, setActiveTab] = useState(searchParams?.get('tab') || 'properties');
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [account, setAccount] = useState(null);
  const [properties, setProperties] = useState([]);
  const [contacts, setContacts] = useState([]);
  const [timelineItems, setTimelineItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [propertiesLoading, setPropertiesLoading] = useState(true);
  const [contactsLoading, setContactsLoading] = useState(true);
  const [timelineLoading, setTimelineLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [showAssignModal, setShowAssignModal] = useState(false);
  // Add missing state variables
  const [showLinkPropertyModal, setShowLinkPropertyModal] = useState(false);
  const [showAddContactModal, setShowAddContactModal] = useState(false);
  const [showAddPropertyModal, setShowAddPropertyModal] = useState(false);

  // Mock contacts data - replace with actual service call
  const mockContacts = [
    {
      id: '1',
      first_name: "Sarah",
      last_name: "Johnson",
      title: "Property Manager",
      email: "sarah.johnson@metroprop.com",
      phone: "(404) 555-0123",
      stage: "Engaged",
      last_contact: "2 days ago"
    },
    {
      id: '2',
      first_name: "Mike",
      last_name: "Chen",
      title: "Facilities Director",
      email: "mike.chen@metroprop.com",
      phone: "(404) 555-0124",
      stage: "DM Confirmed",
      last_contact: "1 week ago"
    }
  ];

  useEffect(() => {
    if (!accountId) {
      navigate('/accounts');
      return;
    }

    if (authLoading) return;

    if (!isAuthenticated || !authUser) {
      navigate('/login');
      return;
    }

    loadAccount();
    loadProperties();
    loadContacts();
    loadTimeline();
  }, [accountId, navigate, authLoading, isAuthenticated, authUser]);

  useEffect(() => {
    // Handle tab from URL params
    const urlParams = new URLSearchParams(window.location.search);
    const tabParam = urlParams?.get('tab');
    if (tabParam && ['properties', 'contacts', 'timeline']?.includes(tabParam)) {
      setActiveTab(tabParam);
    }
    setSearchParams(urlParams);
  }, []);

  const loadAccount = async () => {
    if (!accountId) return;

    setLoading(true);
    setError(null);

    try {
      const result = await accountsService?.getAccount(accountId);
      
      if (result?.success) {
        setAccount(result?.data);
      } else {
        setError('Account not found');
        // Navigate back to accounts list after a delay
        setTimeout(() => {
          navigate('/accounts');
        }, 2000);
      }
    } catch (err) {
      console.error('Error loading account:', err);
      setError('Failed to load account details');
    } finally {
      setLoading(false);
    }
  };

  const loadProperties = async () => {
    if (!accountId) return;

    setPropertiesLoading(true);

    try {
      const result = await propertiesService?.getPropertiesByAccount(accountId);
      
      if (result?.success) {
        // Map the database fields to match the component expectations
        const mappedProperties = result?.data?.map(property => ({
          id: property?.id,
          name: property?.name,
          address: property?.address,
          building_type: property?.building_type,
          buildingType: property?.building_type, // Keep both for compatibility
          roof_type: property?.roof_type,
          roofType: property?.roof_type, // Keep both for compatibility
          stage: property?.stage,
          square_footage: property?.square_footage,
          squareFootage: property?.square_footage, // Keep both for compatibility
          year_built: property?.year_built,
          city: property?.city,
          state: property?.state,
          zip_code: property?.zip_code,
          created_at: property?.created_at,
          updated_at: property?.updated_at,
          last_assessment: property?.last_assessment,
          notes: property?.notes
        }));
        
        setProperties(mappedProperties || []);
      } else {
        console.error('Failed to load properties:', result?.error);
        setProperties([]);
      }
    } catch (err) {
      console.error('Error loading properties:', err);
      setProperties([]);
    } finally {
      setPropertiesLoading(false);
    }
  };

  const loadContacts = async () => {
    if (!accountId) return;

    setContactsLoading(true);

    try {
      const result = await contactsService?.getContactsByAccount(accountId);
      
      if (result?.success) {
        // Map the database fields to match the component expectations
        const mappedContacts = result?.data?.map(contact => ({
          id: contact?.id,
          name: `${contact?.first_name} ${contact?.last_name}`,
          first_name: contact?.first_name,
          last_name: contact?.last_name,
          title: contact?.title,
          role: contact?.title, // Map title to role for component compatibility
          email: contact?.email,
          phone: contact?.phone,
          mobile_phone: contact?.mobile_phone,
          stage: contact?.stage,
          is_primary_contact: contact?.is_primary_contact,
          property_id: contact?.property_id,
          created_at: contact?.created_at,
          updated_at: contact?.updated_at,
          notes: contact?.notes,
          // Add any computed fields if needed
          lastContact: contact?.updated_at ? getRelativeTime(contact?.updated_at) : null
        }));
        
        setContacts(mappedContacts || []);
        console.log('Loaded contacts for account:', accountId, 'count:', mappedContacts?.length);
      } else {
        console.error('Failed to load contacts:', result?.error);
        setContacts([]);
        // Show error message to user if it's not just empty results
        if (result?.error && !result?.error?.includes('not found')) {
          setError(`Failed to load contacts: ${result?.error}`);
        }
      }
    } catch (err) {
      console.error('Error loading contacts:', err);
      setContacts([]);
      setError('Failed to load contacts');
    } finally {
      setContactsLoading(false);
    }
  };

  const loadTimeline = async () => {
    if (!accountId) return;

    setTimelineLoading(true);

    try {
      const result = await timelineService?.getTimelineForEntity('account', accountId);

      if (result?.success) {
        setTimelineItems(result?.data || []);
      } else {
        console.error('Failed to load timeline:', result?.error);
        setTimelineItems([]);
      }
    } catch (err) {
      console.error('Error loading timeline:', err);
      setTimelineItems([]);
    } finally {
      setTimelineLoading(false);
    }
  };

  // Helper function to get relative time (e.g., "2 days ago")
  const getRelativeTime = (dateString) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInMs = now - date;
    const diffInDays = Math.floor(diffInMs / (1000 * 60 * 60 * 24));
    
    if (diffInDays === 0) return 'Today';
    if (diffInDays === 1) return 'Yesterday';
    if (diffInDays < 7) return `${diffInDays} days ago`;
    if (diffInDays < 30) return `${Math.floor(diffInDays / 7)} week${Math.floor(diffInDays / 7) > 1 ? 's' : ''} ago`;
    return `${Math.floor(diffInDays / 30)} month${Math.floor(diffInDays / 30) > 1 ? 's' : ''} ago`;
  };

  const handleTabChange = (tabId) => {
    setActiveTab(tabId);
    // Fix: Update URL with correct path to match route definition
    const newParams = new URLSearchParams(searchParams);
    newParams?.set('tab', tabId);
    navigate(`/accounts/${accountId}?${newParams?.toString()}`, { replace: true });
    setSearchParams(newParams);
  };

  const handleEditAccount = () => {
    setIsEditModalOpen(true);
  };

  const handleAccountUpdated = (updatedAccount) => {
    // Update the account state with the new data
    setAccount(updatedAccount);
    // Optionally refresh the account data from server
    loadAccount();
  };

  const handleLogActivity = () => {
    navigate(`/log-activity?accountId=${accountId}`);
  };

  const handleAddProperty = () => {
    setShowAddPropertyModal(true);
  };

  const handleAddContact = () => {
    setShowAddContactModal(true);
  };

  const handleSidebarToggle = () => {
    setIsSidebarCollapsed(!isSidebarCollapsed);
  };

  const handleMobileMenuToggle = () => {
    setIsMobileMenuOpen(!isMobileMenuOpen);
  };

  const handleAssignReps = () => {
    setShowAssignModal(true);
  };

  const handleAssignSuccess = () => {
    loadAccount(); // Refresh account data to show updated assignments
  };

  // Add missing handler functions
  const handleLinkSuccess = () => {
    loadProperties(); // Refresh properties after linking
    setShowLinkPropertyModal(false);
  };

  const handleContactAdded = () => {
    loadContacts(); // Refresh contacts after adding
    setShowAddContactModal(false);
  };

  const handlePropertyAdded = () => {
    loadProperties(); // Refresh properties after adding
    setShowAddPropertyModal(false);
  };

  const renderTabContent = () => {
    switch (activeTab) {
      case 'properties':
        return (
          <PropertiesTab
            accountId={accountId}
            properties={properties}
            loading={propertiesLoading}
            onAddProperty={handleAddProperty}
            onRefreshProperties={loadProperties}
          />
        );
      case 'contacts':
        return (
          <ContactsTab
            accountId={accountId}
            contacts={contacts}
            loading={contactsLoading}
            onAddContact={handleAddContact}
            onRefreshContacts={loadContacts}
          />
        );
      case 'timeline':
        return (
          <Timeline
            title="Timeline"
            items={timelineItems}
            loading={timelineLoading}
            onLogActivity={handleLogActivity}
            onRefresh={loadTimeline}
          />
        );
      default:
        return null;
    }
  };

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div>Loading your session...</div>
      </div>
    );
  }

  if (!isAuthenticated || !session) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="text-center space-y-4">
          <p>Please sign in to view account details.</p>
          <button
            onClick={() => navigate('/login')}
            className="px-4 py-2 rounded-md bg-primary text-white"
          >
            Go to Login
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {error && (
        <div className="mb-4 bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg">
          {error}
        </div>
      )}

      {loading ? (
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          <span className="ml-3 text-lg text-gray-600">Loading account details...</span>
        </div>
      ) : account ? (
        <>
          <AccountHeader 
            account={account} 
            onEdit={() => setIsEditModalOpen(true)}
            onEditAccount={() => setIsEditModalOpen(true)}
            onAssignReps={handleAssignReps}
            onLogActivity={handleLogActivity}
            currentUser={userProfile || authUser}
          />

          {/* Tab Navigation */}
          <TabNavigation
            activeTab={activeTab}
            onTabChange={handleTabChange}
            propertiesCount={properties?.length}
            contactsCount={contacts?.length}
            timelineCount={timelineItems?.length}
          />

          {/* Tab Content */}
          <div className="p-6">
            {renderTabContent()}
          </div>

          {/* Existing Modals */}
          <EditAccountModal
            isOpen={isEditModalOpen}
            onClose={() => setIsEditModalOpen(false)}
            account={account}
            onAccountUpdated={handleAccountUpdated}
          />

          <LinkPropertyModal
            isOpen={showLinkPropertyModal}
            onClose={() => setShowLinkPropertyModal(false)}
            account={account}
            contact={null}
            onSuccess={handleLinkSuccess}
          />

          <AddContactModal
            isOpen={showAddContactModal}
            onClose={() => setShowAddContactModal(false)}
            account={account}
            onContactAdded={handleContactAdded}
            onSuccess={handleContactAdded}
          />

          <AddPropertyModal
            isOpen={showAddPropertyModal}
            onClose={() => setShowAddPropertyModal(false)}
            onPropertyAdded={handlePropertyAdded}
            preselectedAccountId={accountId}
          />

          {/* New Assign Reps Modal */}
          <AssignRepsModal
            isOpen={showAssignModal}
            onClose={() => setShowAssignModal(false)}
            account={account}
            onSuccess={handleAssignSuccess}
          />
        </>
      ) : (
        <div className="text-center py-12">
          <p className="text-gray-500 text-lg">Account not found</p>
        </div>
      )}
    </div>
  );
};

export default AccountDetails;
