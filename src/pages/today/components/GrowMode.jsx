import React, { useEffect, useMemo, useState } from 'react';
import Modal from '../../../components/ui/Modal';
import Input from '../../../components/ui/Input';
import Select from '../../../components/ui/Select';
import Button from '../../../components/ui/Button';
import { useAuth } from '../../../contexts/AuthContext';
import { accountsService } from '../../../services/accountsService';
import { contactsService } from '../../../services/contactsService';
import { propertiesService } from '../../../services/propertiesService';
import { opportunitiesService } from '../../../services/opportunitiesService';
import { growService } from '../../../services/growService';

const COMPANY_TYPES = [
  'Property Management',
  'General Contractor',
  'Developer',
  'REIT/Institutional Investor',
  'Asset Manager',
  'Building Owner',
  'Facility Manager',
  'Roofing Contractor',
  'Insurance',
  'Architecture/Engineering',
  'Commercial Office',
  'Retail',
  'Healthcare',
  'Affiliate: Real Estate',
  'Affiliate: Manufacturer'
];

const BUILDING_TYPES = [
  'Industrial',
  'Warehouse',
  'Manufacturing',
  'Hospitality',
  'Multifamily',
  'Commercial Office',
  'Retail',
  'Healthcare'
];

const DAILY_TARGETS = {
  accounts: 2,
  contacts: 3,
  properties: 2,
  touches: 5,
  opportunities: 1
};

const MotionCard = ({ title, helper, current, target, onStart }) => {
  const cappedCurrent = Math.min(current, target);
  const isComplete = current >= target;

  return (
    <div className={`flex flex-col gap-4 rounded-xl border p-4 md:flex-row md:items-center md:justify-between ${
      isComplete ? 'border-success/40 bg-success/5' : 'border-border bg-card'
    }`}>
      <div>
        <h3 className="text-sm font-semibold text-foreground">{title}</h3>
        {helper && <p className="text-xs text-muted-foreground mt-1">{helper}</p>}
      </div>
      <div className="flex items-center gap-4">
        <div className="text-sm font-semibold text-foreground">
          {cappedCurrent} / {target}
        </div>
        {isComplete ? (
          <span className="text-xs font-semibold px-3 py-1 rounded-full bg-success/10 text-success">
            Complete
          </span>
        ) : (
          <Button size="sm" onClick={onStart}>
            Start
          </Button>
        )}
      </div>
    </div>
  );
};

const GrowAccountModal = ({ isOpen, onClose, onSaved }) => {
  const { userProfile, session } = useAuth();
  const userId = userProfile?.id || session?.user?.id || null;
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [formData, setFormData] = useState({
    name: '',
    company_type: 'Property Management'
  });

  const handleClose = () => {
    setFormData({ name: '', company_type: 'Property Management' });
    setError('');
    onClose?.();
  };

  const handleSubmit = async (e) => {
    e?.preventDefault();

    if (!formData?.name?.trim()) {
      setError('Account name is required');
      return;
    }

    setLoading(true);
    setError('');

    const result = await accountsService?.createAccount({
      name: formData?.name?.trim(),
      company_type: formData?.company_type || 'Property Management',
      source: 'outbound',
      created_from_grow: true,
      created_by: userId
    });

    if (result?.success) {
      onSaved?.(result?.data);
      handleClose();
    } else {
      setError(result?.error || 'Failed to create account');
    }

    setLoading(false);
  };

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Add New Account (Fast Mode)" size="md">
      <form onSubmit={handleSubmit} className="p-6 space-y-4">
        {error && (
          <div className="p-3 bg-destructive/10 border border-destructive/20 rounded-md text-sm text-destructive">
            {error}
          </div>
        )}

        <Input
          label="Account Name"
          value={formData?.name}
          onChange={(e) => setFormData(prev => ({ ...prev, name: e?.target?.value }))}
          placeholder="Enter account name"
          required
          disabled={loading}
        />

        <Select
          label="Company Type (optional)"
          value={formData?.company_type}
          onChange={(value) => setFormData(prev => ({ ...prev, company_type: value }))}
          onSearchChange={() => {}}
          onOpenChange={() => {}}
          options={COMPANY_TYPES?.map(type => ({ value: type, label: type }))}
          disabled={loading}
          searchable
          name="company_type"
        />

        <div className="flex justify-end gap-3 pt-2">
          <Button type="button" variant="outline" onClick={handleClose} disabled={loading}>
            Cancel
          </Button>
          <Button type="submit" loading={loading} disabled={loading}>
            Create Account
          </Button>
        </div>
      </form>
    </Modal>
  );
};

const GrowContactModal = ({ isOpen, onClose, onSaved }) => {
  const { userProfile, session } = useAuth();
  const userId = userProfile?.id || session?.user?.id || null;
  const [loading, setLoading] = useState(false);
  const [loadingAccounts, setLoadingAccounts] = useState(false);
  const [error, setError] = useState('');
  const [accounts, setAccounts] = useState([]);
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    account_id: ''
  });

  const loadAccounts = async () => {
    setLoadingAccounts(true);
    const result = await accountsService?.getAccounts({ limit: 200 });
    if (result?.success) {
      setAccounts(result?.data || []);
      if (!result?.data?.length) {
        setError('No accounts available. Add an account first.');
      }
    } else {
      setError(result?.error || 'Failed to load accounts');
    }
    setLoadingAccounts(false);
  };

  useEffect(() => {
    if (isOpen) {
      loadAccounts();
    }
  }, [isOpen]);

  const handleClose = () => {
    setFormData({ first_name: '', last_name: '', account_id: '' });
    setError('');
    onClose?.();
  };

  const handleSubmit = async (e) => {
    e?.preventDefault();

    if (!formData?.first_name?.trim() || !formData?.last_name?.trim()) {
      setError('First and last name are required');
      return;
    }
    if (!formData?.account_id) {
      setError('Please select an account');
      return;
    }

    setLoading(true);
    setError('');

    const result = await contactsService?.createContact({
      first_name: formData?.first_name?.trim(),
      last_name: formData?.last_name?.trim(),
      account_id: formData?.account_id,
      created_from_grow: true,
      created_by: userId
    });

    if (result?.success) {
      onSaved?.(result?.data);
      handleClose();
    } else {
      setError(result?.error || 'Failed to create contact');
    }

    setLoading(false);
  };

  const accountOptions = accounts?.map(account => ({
    value: account?.id,
    label: account?.name
  }));

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Add New Contact (Fast Mode)" size="md">
      <form onSubmit={handleSubmit} className="p-6 space-y-4">
        {error && (
          <div className="p-3 bg-destructive/10 border border-destructive/20 rounded-md text-sm text-destructive">
            {error}
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input
            label="First Name"
            value={formData?.first_name}
            onChange={(e) => setFormData(prev => ({ ...prev, first_name: e?.target?.value }))}
            placeholder="First name"
            required
            disabled={loading}
          />
          <Input
            label="Last Name"
            value={formData?.last_name}
            onChange={(e) => setFormData(prev => ({ ...prev, last_name: e?.target?.value }))}
            placeholder="Last name"
            required
            disabled={loading}
          />
        </div>

        <Select
          label="Account"
          value={formData?.account_id}
          onChange={(value) => setFormData(prev => ({ ...prev, account_id: value }))}
          onSearchChange={() => {}}
          onOpenChange={() => {}}
          options={accountOptions}
          placeholder={loadingAccounts ? 'Loading accounts...' : 'Select an account'}
          disabled={loading || loadingAccounts}
          searchable
          name="account_id"
        />

        <div className="flex justify-end gap-3 pt-2">
          <Button type="button" variant="outline" onClick={handleClose} disabled={loading}>
            Cancel
          </Button>
          <Button type="submit" loading={loading} disabled={loading || loadingAccounts}>
            Create Contact
          </Button>
        </div>
      </form>
    </Modal>
  );
};

const GrowPropertyModal = ({ isOpen, onClose, onSaved }) => {
  const { userProfile, session } = useAuth();
  const userId = userProfile?.id || session?.user?.id || null;
  const [loading, setLoading] = useState(false);
  const [loadingAccounts, setLoadingAccounts] = useState(false);
  const [error, setError] = useState('');
  const [accounts, setAccounts] = useState([]);
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    account_id: '',
    building_type: 'Industrial'
  });

  const loadAccounts = async () => {
    setLoadingAccounts(true);
    const result = await accountsService?.getAccounts({ limit: 200 });
    if (result?.success) {
      setAccounts(result?.data || []);
      if (!result?.data?.length) {
        setError('No accounts available. Add an account first.');
      }
    } else {
      setError(result?.error || 'Failed to load accounts');
    }
    setLoadingAccounts(false);
  };

  useEffect(() => {
    if (isOpen) {
      loadAccounts();
    }
  }, [isOpen]);

  const handleClose = () => {
    setFormData({ name: '', address: '', account_id: '', building_type: 'Industrial' });
    setError('');
    onClose?.();
  };

  const handleSubmit = async (e) => {
    e?.preventDefault();

    if (!formData?.name?.trim()) {
      setError('Property name is required');
      return;
    }
    if (!formData?.address?.trim()) {
      setError('Property address is required');
      return;
    }
    if (!formData?.account_id) {
      setError('Please select an account');
      return;
    }

    setLoading(true);
    setError('');

    const result = await propertiesService?.createProperty({
      name: formData?.name?.trim(),
      address: formData?.address?.trim(),
      account_id: formData?.account_id,
      building_type: formData?.building_type,
      created_from_grow: true,
      created_by: userId
    });

    if (result?.success) {
      onSaved?.(result?.data);
      handleClose();
    } else {
      setError(result?.error || 'Failed to create property');
    }

    setLoading(false);
  };

  const accountOptions = accounts?.map(account => ({
    value: account?.id,
    label: account?.name
  }));

  const buildingOptions = BUILDING_TYPES?.map(type => ({
    value: type,
    label: type
  }));

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Add New Property (Fast Mode)" size="md">
      <form onSubmit={handleSubmit} className="p-6 space-y-4">
        {error && (
          <div className="p-3 bg-destructive/10 border border-destructive/20 rounded-md text-sm text-destructive">
            {error}
          </div>
        )}

        <Input
          label="Property Name"
          value={formData?.name}
          onChange={(e) => setFormData(prev => ({ ...prev, name: e?.target?.value }))}
          placeholder="Enter property name"
          required
          disabled={loading}
        />

        <Input
          label="Address"
          value={formData?.address}
          onChange={(e) => setFormData(prev => ({ ...prev, address: e?.target?.value }))}
          placeholder="Street address"
          required
          disabled={loading}
        />

        <Select
          label="Account"
          value={formData?.account_id}
          onChange={(value) => setFormData(prev => ({ ...prev, account_id: value }))}
          onSearchChange={() => {}}
          onOpenChange={() => {}}
          options={accountOptions}
          placeholder={loadingAccounts ? 'Loading accounts...' : 'Select an account'}
          disabled={loading || loadingAccounts}
          searchable
          name="account_id"
        />

        <Select
          label="Building Type"
          value={formData?.building_type}
          onChange={(value) => setFormData(prev => ({ ...prev, building_type: value }))}
          onSearchChange={() => {}}
          onOpenChange={() => {}}
          options={buildingOptions}
          disabled={loading}
          searchable
          name="building_type"
        />

        <div className="flex justify-end gap-3 pt-2">
          <Button type="button" variant="outline" onClick={handleClose} disabled={loading}>
            Cancel
          </Button>
          <Button type="submit" loading={loading} disabled={loading || loadingAccounts}>
            Create Property
          </Button>
        </div>
      </form>
    </Modal>
  );
};

const GrowOpportunityModal = ({ isOpen, onClose, onSaved }) => {
  const { userProfile, session } = useAuth();
  const userId = userProfile?.id || session?.user?.id || null;
  const [loading, setLoading] = useState(false);
  const [loadingAccounts, setLoadingAccounts] = useState(false);
  const [error, setError] = useState('');
  const [accounts, setAccounts] = useState([]);
  const [formData, setFormData] = useState({
    name: '',
    account_id: '',
    opportunity_type: '',
    stage: 'qualified'
  });

  const loadAccounts = async () => {
    setLoadingAccounts(true);
    const result = await accountsService?.getAccounts({ limit: 200 });
    if (result?.success) {
      setAccounts(result?.data || []);
      if (!result?.data?.length) {
        setError('No accounts available. Add an account first.');
      }
    } else {
      setError(result?.error || 'Failed to load accounts');
    }
    setLoadingAccounts(false);
  };

  useEffect(() => {
    if (isOpen) {
      loadAccounts();
    }
  }, [isOpen]);

  const handleClose = () => {
    setFormData({ name: '', account_id: '', opportunity_type: '', stage: 'qualified' });
    setError('');
    onClose?.();
  };

  const handleSubmit = async (e) => {
    e?.preventDefault();

    if (!formData?.name?.trim()) {
      setError('Opportunity name is required');
      return;
    }
    if (!formData?.account_id) {
      setError('Please select an account');
      return;
    }
    if (!formData?.opportunity_type) {
      setError('Opportunity type is required');
      return;
    }

    setLoading(true);
    setError('');

    const result = await opportunitiesService?.createOpportunity({
      name: formData?.name?.trim(),
      account_id: formData?.account_id,
      opportunity_type: formData?.opportunity_type,
      stage: formData?.stage,
      assigned_to: userId,
      created_from_grow: true,
      created_by: userId
    });

    if (result?.success) {
      onSaved?.(result?.data);
      handleClose();
    } else {
      setError(result?.error || 'Failed to create opportunity');
    }

    setLoading(false);
  };

  const accountOptions = accounts?.map(account => ({
    value: account?.id,
    label: account?.name
  }));

  const opportunityOptions = opportunitiesService?.getOpportunityTypes()?.map(type => ({
    value: type?.value,
    label: type?.label
  }));

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Add New Opportunity (Fast Mode)" size="md">
      <form onSubmit={handleSubmit} className="p-6 space-y-4">
        {error && (
          <div className="p-3 bg-destructive/10 border border-destructive/20 rounded-md text-sm text-destructive">
            {error}
          </div>
        )}

        <Input
          label="Opportunity Name"
          value={formData?.name}
          onChange={(e) => setFormData(prev => ({ ...prev, name: e?.target?.value }))}
          placeholder="Enter opportunity name"
          required
          disabled={loading}
        />

        <Select
          label="Account"
          value={formData?.account_id}
          onChange={(value) => setFormData(prev => ({ ...prev, account_id: value }))}
          onSearchChange={() => {}}
          onOpenChange={() => {}}
          options={accountOptions}
          placeholder={loadingAccounts ? 'Loading accounts...' : 'Select an account'}
          disabled={loading || loadingAccounts}
          searchable
          name="account_id"
        />

        <Select
          label="Opportunity Type"
          value={formData?.opportunity_type}
          onChange={(value) => setFormData(prev => ({ ...prev, opportunity_type: value }))}
          onSearchChange={() => {}}
          onOpenChange={() => {}}
          options={opportunityOptions}
          placeholder="Select a type"
          disabled={loading}
          name="opportunity_type"
        />

        <Select
          label="Stage"
          value={formData?.stage}
          onChange={(value) => setFormData(prev => ({ ...prev, stage: value }))}
          onSearchChange={() => {}}
          onOpenChange={() => {}}
          options={[
            { value: 'identified', label: 'Identified' },
            { value: 'qualified', label: 'Qualified' }
          ]}
          disabled={loading}
          name="stage"
        />

        <div className="flex justify-end gap-3 pt-2">
          <Button type="button" variant="outline" onClick={handleClose} disabled={loading}>
            Cancel
          </Button>
          <Button type="submit" loading={loading} disabled={loading || loadingAccounts}>
            Create Opportunity
          </Button>
        </div>
      </form>
    </Modal>
  );
};

const GrowMode = ({ onLogTouch }) => {
  const { userProfile, session } = useAuth();
  const userId = userProfile?.id || session?.user?.id || null;
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [metrics, setMetrics] = useState({
    accounts: 0,
    contacts: 0,
    properties: 0,
    touches: 0,
    opportunities: 0
  });
  const [activeModal, setActiveModal] = useState(null);

  const loadMetrics = async () => {
    if (!userId) return;
    setLoading(true);
    setError('');

    const todayStart = new Date();
    todayStart?.setHours(0, 0, 0, 0);
    const todayEnd = new Date();
    todayEnd?.setHours(23, 59, 59, 999);

    const result = await growService?.getGrowthCounts({
      userId,
      dateFrom: todayStart?.toISOString(),
      dateTo: todayEnd?.toISOString()
    });

    if (result?.success) {
      setMetrics(result?.data || {});
    } else {
      setError(result?.error || 'Failed to load growth progress');
    }
    setLoading(false);
  };

  useEffect(() => {
    if (userId) {
      loadMetrics();
    } else {
      setLoading(false);
    }
  }, [userId]);

  const motions = useMemo(() => ([
    {
      id: 'accounts',
      title: 'Add 2 New Accounts',
      helper: 'Create new logos to sell into.',
      current: metrics?.accounts || 0,
      target: DAILY_TARGETS?.accounts,
      onStart: () => setActiveModal('account')
    },
    {
      id: 'contacts',
      title: 'Add 3 New Contacts',
      helper: 'Attach decision makers to accounts.',
      current: metrics?.contacts || 0,
      target: DAILY_TARGETS?.contacts,
      onStart: () => setActiveModal('contact')
    },
    {
      id: 'properties',
      title: 'Add 2 New Properties',
      helper: 'Expand surface area inside accounts.',
      current: metrics?.properties || 0,
      target: DAILY_TARGETS?.properties,
      onStart: () => setActiveModal('property')
    },
    {
      id: 'touches',
      title: 'Log 5 Outbound Touches',
      helper: 'Prospecting calls, emails, DMs, and pop-ins.',
      current: metrics?.touches || 0,
      target: DAILY_TARGETS?.touches,
      onStart: () => onLogTouch?.()
    },
    {
      id: 'opportunities',
      title: 'Create 1 New Opportunity',
      helper: 'Capture early-stage pipeline value.',
      current: metrics?.opportunities || 0,
      target: DAILY_TARGETS?.opportunities,
      onStart: () => setActiveModal('opportunity')
    }
  ]), [metrics, onLogTouch]);

  return (
    <div className="space-y-6">
      <div className="bg-card rounded-xl border border-border p-6">
        <div className="flex items-center justify-between gap-3">
          <div>
            <h2 className="text-lg font-semibold text-foreground">Grow Your Pipeline</h2>
            <p className="text-sm text-muted-foreground">
              Complete these motions to create new opportunities.
            </p>
          </div>
          {loading && (
            <div className="animate-spin w-4 h-4 border-2 border-primary border-t-transparent rounded-full" />
          )}
        </div>

        {error && (
          <div className="mt-4 p-3 bg-destructive/10 border border-destructive/20 rounded-md text-sm text-destructive">
            {error}
          </div>
        )}
      </div>

      <div className="space-y-3">
        {motions?.map(motion => (
          <MotionCard
            key={motion.id}
            title={motion.title}
            helper={motion.helper}
            current={motion.current}
            target={motion.target}
            onStart={motion.onStart}
          />
        ))}
      </div>

      <GrowAccountModal
        isOpen={activeModal === 'account'}
        onClose={() => setActiveModal(null)}
        onSaved={loadMetrics}
      />

      <GrowContactModal
        isOpen={activeModal === 'contact'}
        onClose={() => setActiveModal(null)}
        onSaved={loadMetrics}
      />

      <GrowPropertyModal
        isOpen={activeModal === 'property'}
        onClose={() => setActiveModal(null)}
        onSaved={loadMetrics}
      />

      <GrowOpportunityModal
        isOpen={activeModal === 'opportunity'}
        onClose={() => setActiveModal(null)}
        onSaved={loadMetrics}
      />
    </div>
  );
};

export default GrowMode;
