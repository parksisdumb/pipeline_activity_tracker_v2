import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

import Icon from '../../../components/AppIcon';
import AddAccountModal from '../../../components/ui/AddAccountModal';
import AddContactModal from '../../../components/ui/AddContactModal';
import AddPropertyModal from '../../../components/ui/AddPropertyModal';

const QuickActions = ({ className = '' }) => {
  const navigate = useNavigate();
  const [showAddAccountModal, setShowAddAccountModal] = useState(false);
  const [showAddContactModal, setShowAddContactModal] = useState(false);
  const [showAddPropertyModal, setShowAddPropertyModal] = useState(false);

  const handleAccountAdded = (newAccount) => {
    console.log('New account added:', newAccount);
    // Optionally refresh data or show success message
    setShowAddAccountModal(false);
  };

  const handleContactAdded = (newContact) => {
    console.log('New contact added:', newContact);
    // Optionally refresh data or show success message
    setShowAddContactModal(false);
  };

  const handlePropertyAdded = (newProperty) => {
    console.log('New property added:', newProperty);
    // Optionally refresh data or show success message
    setShowAddPropertyModal(false);
  };

  const handleViewAccounts = (e) => {
    e?.preventDefault();
    e?.stopPropagation();
    console.log('Navigating to accounts page...');
    try {
      navigate('/accounts');
    } catch (error) {
      console.error('Navigation error:', error);
    }
  };

  const quickActions = [
    {
      id: 1,
      label: "Add Account",
      description: "Create new business account",
      icon: "Building2",
      action: (e) => {
        e?.preventDefault();
        e?.stopPropagation();
        setShowAddAccountModal(true);
      },
      color: "text-blue-600 bg-blue-100"
    },
    {
      id: 2,
      label: "Add Contact",
      description: "Add contact to account",
      icon: "UserPlus",
      action: (e) => {
        e?.preventDefault();
        e?.stopPropagation();
        setShowAddContactModal(true);
      },
      color: "text-green-600 bg-green-100"
    },
    {
      id: 3,
      label: "Add Property",
      description: "Register new property",
      icon: "MapPin",
      action: (e) => {
        e?.preventDefault();
        e?.stopPropagation();
        setShowAddPropertyModal(true);
      },
      color: "text-purple-600 bg-purple-100"
    },
    {
      id: 4,
      label: "View Accounts",
      description: "Browse all accounts",
      icon: "Search",
      action: handleViewAccounts,
      color: "text-orange-600 bg-orange-100"
    }
  ];

  return (
    <>
      <div className={`bg-card rounded-lg border border-border p-6 ${className}`}>
        <h2 className="text-lg font-semibold text-foreground mb-6">Quick Actions</h2>
        <div className="grid grid-cols-1 gap-3">
          {quickActions?.map((action) => (
            <button
              key={action?.id}
              onClick={action?.action}
              type="button"
              className="flex items-center p-3 rounded-lg bg-muted/30 hover:bg-muted/50 transition-colors duration-200 text-left group"
            >
              <div className={`w-10 h-10 rounded-full flex items-center justify-center mr-3 flex-shrink-0 ${action?.color} group-hover:scale-110 transition-transform duration-200`}>
                <Icon 
                  name={action?.icon} 
                  size={18}
                />
              </div>
              
              <div className="flex-1 min-w-0">
                <h3 className="text-sm font-medium text-foreground mb-1">
                  {action?.label}
                </h3>
                <p className="text-xs text-muted-foreground truncate">
                  {action?.description}
                </p>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Modals */}
      <AddAccountModal
        isOpen={showAddAccountModal}
        onClose={() => setShowAddAccountModal(false)}
        onAccountAdded={handleAccountAdded}
      />
      
      <AddContactModal
        isOpen={showAddContactModal}
        onClose={() => setShowAddContactModal(false)}
        onContactAdded={handleContactAdded}
      />
      
      <AddPropertyModal
        isOpen={showAddPropertyModal}
        onClose={() => setShowAddPropertyModal(false)}
        onPropertyAdded={handlePropertyAdded}
      />
    </>
  );
};

export default QuickActions;