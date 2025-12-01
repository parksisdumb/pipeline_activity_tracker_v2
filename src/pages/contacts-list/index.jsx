import React, { useState, useEffect, useMemo } from 'react';
import Header from '../../components/ui/Header';
import SidebarNavigation from '../../components/ui/SidebarNavigation';
import ContactsHeader from './components/ContactsHeader';
import ContactsStats from './components/ContactsStats';
import ContactsFilters from './components/ContactsFilters';
import ContactsTable from './components/ContactsTable';
import QuickActionButton from '../../components/ui/QuickActionButton';
import AddContactModal from '../../components/ui/AddContactModal';
import Pagination from '../accounts-list/components/Pagination';
import { contactsService } from '../../services/contactsService';

const ContactsList = () => {
  const [contacts, setContacts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isAddContactModalOpen, setIsAddContactModalOpen] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [userRole] = useState('rep'); // This would come from auth context
  const [filters, setFilters] = useState({
    search: '',
    role: '',
    stage: '',
    account: '',
    property: '',
    uploadedBy: ''
  });
  const resolveUploaderId = (contact) => (
    contact?.uploadedById ||
    contact?.created_by ||
    contact?.created_by?.id ||
    contact?.created_by_id ||
    contact?.createdBy ||
    contact?.createdById ||
    contact?.creator?.id ||
    contact?.created_by_profile?.id ||
    null
  );
  const [sortConfig, setSortConfig] = useState({
    field: 'name',
    direction: 'asc'
  });
  const [selectedContacts, setSelectedContacts] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(15);
  const [deleteInProgress, setDeleteInProgress] = useState(false);

  // Load contacts from database on component mount
  useEffect(() => {
    // Add debugging to track page load
    console.log('=== CONTACTS PAGE LOADED ===');
    console.log('Current URL:', window.location?.href);
    console.log('Current pathname:', window.location?.pathname);
    
    loadContacts();
    // Set page title
    document.title = 'Contacts - Pipeline Activity Tracker';
  }, []);

  const loadContacts = async () => {
    try {
      setLoading(true);
      console.log('Loading contacts from database...');
      
      const result = await contactsService?.getContacts();
      console.log('Contacts service result:', result);
      
      if (result?.success) {
        // Transform database data to match the expected format
        const transformedContacts = result?.data?.map(contact => ({
          id: contact?.id,
          name: `${contact?.first_name || ''} ${contact?.last_name || ''}`?.trim(),
          email: contact?.email || '',
          phone: contact?.phone || contact?.mobile_phone || '',
          role: contact?.title || 'Contact',
          account: contact?.account?.name || 'Unknown Account',
          property: null, // Properties are not directly linked to contacts in the current schema
          stage: contact?.stage || 'Identified',
          lastInteraction: contact?.updated_at ? new Date(contact?.updated_at) : new Date(contact?.created_at),
          createdAt: new Date(contact?.created_at),
          uploadedById: resolveUploaderId(contact)
        })) || [];
        
        console.log('Transformed contacts:', transformedContacts?.length);
        setContacts(transformedContacts);
      } else {
        console.error('Failed to load contacts:', result?.error);
        // If loading fails, fallback to empty array instead of mock data
        setContacts([]);
      }
    } catch (error) {
      console.error('Error loading contacts:', error);
      // If loading fails, fallback to empty array instead of mock data
      setContacts([]);
    } finally {
      setLoading(false);
      console.log('Contacts loading completed');
    }
  };

  // Filter and sort contacts
  const filteredContacts = useMemo(() => {
    let filtered = contacts?.filter(contact => {
      const matchesSearch = !filters?.search || 
        contact?.name?.toLowerCase()?.includes(filters?.search?.toLowerCase()) ||
        contact?.email?.toLowerCase()?.includes(filters?.search?.toLowerCase()) ||
        (contact?.phone && contact?.phone?.includes(filters?.search));
      
      const matchesRole = !filters?.role || contact?.role === filters?.role;
      const matchesStage = !filters?.stage || contact?.stage === filters?.stage;
      const matchesAccount = !filters?.account || 
        contact?.account?.toLowerCase()?.includes(filters?.account?.toLowerCase());
      const matchesProperty = !filters?.property || 
        (contact?.property && contact?.property?.toLowerCase()?.includes(filters?.property?.toLowerCase()));
      const uploaderId = resolveUploaderId(contact);
      const matchesUploader = !filters?.uploadedBy || (
        filters?.uploadedBy === 'none'
          ? !uploaderId
          : String(uploaderId) === String(filters?.uploadedBy)
      );

      return matchesSearch && matchesRole && matchesStage && matchesAccount && matchesProperty && matchesUploader;
    });

    // Sort contacts
    filtered?.sort((a, b) => {
      let aValue = a?.[sortConfig?.field];
      let bValue = b?.[sortConfig?.field];

      if (sortConfig?.field === 'lastInteraction') {
        aValue = new Date(aValue);
        bValue = new Date(bValue);
      }

      if (aValue < bValue) return sortConfig?.direction === 'asc' ? -1 : 1;
      if (aValue > bValue) return sortConfig?.direction === 'asc' ? 1 : -1;
      return 0;
    });

    return filtered;
  }, [contacts, filters, sortConfig]);

  const totalPages = Math.max(1, Math.ceil((filteredContacts?.length || 0) / itemsPerPage));

  useEffect(() => {
    if (currentPage > totalPages) {
      setCurrentPage(totalPages);
    }
  }, [currentPage, totalPages]);

  useEffect(() => {
    setCurrentPage(1);
  }, [filters, sortConfig, contacts]);

  // Keep selected contacts aligned with current filter results
  useEffect(() => {
    setSelectedContacts(prev => prev?.filter(id => filteredContacts?.some(contact => contact?.id === id)));
  }, [filteredContacts]);

  // Calculate stats
  const stats = useMemo(() => {
    const total = contacts?.length;
    const engaged = contacts?.filter(c => c?.stage === 'Engaged')?.length;
    const dmConfirmed = contacts?.filter(c => c?.stage === 'DM Confirmed')?.length;
    const dormant = contacts?.filter(c => c?.stage === 'Dormant')?.length;

    return { total, engaged, dmConfirmed, dormant };
  }, [contacts]);

  const handleToggleSidebar = () => {
    setSidebarCollapsed(!sidebarCollapsed);
  };

  const handleToggleMobileMenu = () => {
    setMobileMenuOpen(!mobileMenuOpen);
  };

  const handleSort = (field) => {
    setSortConfig(prev => ({
      field,
      direction: prev?.field === field && prev?.direction === 'asc' ? 'desc' : 'asc'
    }));
  };

  const handleFiltersChange = (newFilters) => {
    setFilters(newFilters);
  };

  const handlePageChange = (page) => {
    const nextPage = Math.min(Math.max(page, 1), totalPages || 1);
    setCurrentPage(nextPage);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleItemsPerPageChange = (value) => {
    const parsedValue = Number(value) || 15;
    setItemsPerPage(parsedValue);
    setCurrentPage(1);
  };

  const handleContactAction = (action, contactName) => {
    console.log(`${action} action for ${contactName}`);
    // In a real app, this would log the activity
  };

  const handleBulkAction = async (action) => {
    if (action === 'delete') {
      await handleDeleteContacts(selectedContacts);
      return;
    }
    console.log(`Bulk ${action} for selected contacts`);
    // In a real app, this would handle bulk actions
  };

  const handleDeleteContacts = async (contactIds = []) => {
    const idsToDelete = contactIds?.length ? contactIds : selectedContacts;
    if (!idsToDelete?.length) {
      return;
    }

    const confirmationMessage = idsToDelete?.length === 1
      ? 'Are you sure you want to delete this contact? This action cannot be undone.'
      : `Are you sure you want to delete ${idsToDelete?.length} contacts? This action cannot be undone.`;

    if (!window?.confirm(confirmationMessage)) {
      return;
    }

    setDeleteInProgress(true);

    try {
      const deleteResults = await Promise.all(
        idsToDelete?.map(async (contactId) => {
          try {
            const response = await contactsService?.deleteContact(contactId);
            return { contactId, success: response?.success, error: response?.error };
          } catch (error) {
            console.error('Error deleting contact:', contactId, error);
            return { contactId, success: false, error: error?.message || 'Unknown error' };
          }
        })
      );

      const successfulIds = deleteResults
        ?.filter(result => result?.success)
        ?.map(result => result?.contactId);

      const failedResults = deleteResults?.filter(result => !result?.success);

      if (successfulIds?.length) {
        setContacts(prev => prev?.filter(contact => !successfulIds?.includes(contact?.id)));
        setSelectedContacts(prev => prev?.filter(id => !successfulIds?.includes(id)));
      }

      if (failedResults?.length) {
        console.error('Failed to delete some contacts:', failedResults);
        window?.alert?.(`Failed to delete ${failedResults?.length} contact(s). Please try again.`);
      }
    } catch (error) {
      console.error('Unexpected error deleting contacts:', error);
      window?.alert?.('Failed to delete contacts. Please try again.');
    } finally {
      setDeleteInProgress(false);
    }
  };

  const handleSelectContact = (contactId, isSelected) => {
    setSelectedContacts(prev => {
      if (isSelected) {
        if (prev?.includes(contactId)) {
          return prev;
        }
        return [...prev, contactId];
      }
      return prev?.filter(id => id !== contactId);
    });
  };

  const handleSelectAllContacts = (isSelected) => {
    if (isSelected) {
      const allIds = filteredContacts?.map(contact => contact?.id) || [];
      setSelectedContacts(allIds);
    } else {
      setSelectedContacts([]);
    }
  };

  const handleExport = () => {
    console.log('Exporting contacts...');
    // In a real app, this would export the filtered contacts
  };

  const handleContactAdded = async (newContact) => {
    try {
      // Reload contacts from database to show the newly added contact
      await loadContacts();
      setIsAddContactModalOpen(false);
    } catch (error) {
      console.error('Error refreshing contacts:', error);
    }
  };

  const handleAddContact = () => {
    setIsAddContactModalOpen(true);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-background">
        <div className="flex items-center justify-center h-64">
          <div className="text-muted-foreground">
            Loading contacts...
            <div className="text-xs mt-2">
              Debug: Page URL - {window.location?.pathname}
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Add error boundary fallback
  if (!contacts && !loading) {
    return (
      <div className="min-h-screen bg-background">
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="text-red-600 mb-4">Error loading contacts page</div>
            <div className="text-xs text-muted-foreground mb-4">
              Debug info: {window.location?.pathname}
            </div>
            <button
              onClick={() => window.location?.reload()}
              className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90"
            >
              Refresh Page
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header - Show on all screen sizes for consistent profile access */}
      <Header 
        userRole={userRole}
        onMenuToggle={handleToggleMobileMenu}
        isMenuOpen={mobileMenuOpen}
      />
      {/* Desktop Sidebar */}
      <div className="hidden lg:block">
        <SidebarNavigation
          userRole={userRole}
          isCollapsed={sidebarCollapsed}
          onToggleCollapse={handleToggleSidebar}
        />
      </div>
      {/* Mobile Sidebar Overlay */}
      {mobileMenuOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div className="fixed inset-0 bg-black/50" onClick={handleToggleMobileMenu} />
          <SidebarNavigation
            userRole={userRole}
            isCollapsed={false}
            onToggleCollapse={handleToggleMobileMenu}
            className="relative z-10"
          />
        </div>
      )}
      {/* Main Content */}
      <main 
        className={`transition-all duration-200 ease-out pt-16 ${
          sidebarCollapsed ? 'lg:pl-16' : 'lg:pl-60'
        }`}
      >
        <div className="container mx-auto px-4 py-6 max-w-7xl">
          <ContactsHeader 
            totalCount={contacts?.length}
            selectedCount={selectedContacts?.length}
            onBulkAction={handleBulkAction}
            onAddContact={handleAddContact}
            isDeleting={deleteInProgress}
          />
          
          <ContactsStats stats={stats} />
          
          <ContactsFilters
            filters={filters}
            onFiltersChange={handleFiltersChange}
            totalCount={contacts?.length}
            filteredCount={filteredContacts?.length}
            onExport={handleExport}
            onBulkAction={handleBulkAction}
          />
          
          <ContactsTable
            contacts={filteredContacts}
            onSort={handleSort}
            sortConfig={sortConfig}
            onContactAction={handleContactAction}
            currentPage={currentPage}
            itemsPerPage={itemsPerPage}
            selectedContacts={selectedContacts}
            onSelectContact={handleSelectContact}
            onSelectAll={handleSelectAllContacts}
          />

          {filteredContacts?.length > 0 && (
            <Pagination
              currentPage={currentPage}
              totalPages={totalPages}
              itemsPerPage={itemsPerPage}
              totalItems={filteredContacts?.length}
              onPageChange={handlePageChange}
              onItemsPerPageChange={handleItemsPerPageChange}
              itemLabel="contacts"
            />
          )}
          
          {contacts?.length === 0 && !loading && (
            <div className="text-center py-8">
              <p className="text-muted-foreground mb-4">No contacts found</p>
              <button
                onClick={handleAddContact}
                className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90"
              >
                Add your first contact
              </button>
            </div>
          )}
          
          {/* Debug info in development */}
          {import.meta?.env?.DEV && (
            <div className="mt-8 p-4 bg-gray-100 rounded text-xs">
              <div>Debug Info:</div>
              <div>Route: {window.location?.pathname}</div>
              <div>Contacts loaded: {contacts?.length}</div>
              <div>Loading: {loading?.toString()}</div>
            </div>
          )}
        </div>
      </main>
      <QuickActionButton onClick={handleAddContact} />
      <AddContactModal
        isOpen={isAddContactModalOpen}
        onClose={() => setIsAddContactModalOpen(false)}
        onContactAdded={handleContactAdded}
      />
    </div>
  );
};

export default ContactsList;
