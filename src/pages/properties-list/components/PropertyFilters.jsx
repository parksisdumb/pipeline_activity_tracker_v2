import React, { useEffect, useState } from 'react';
import Select from '../../../components/ui/Select';
import Input from '../../../components/ui/Input';
import Button from '../../../components/ui/Button';
import { usersService } from '../../../services/usersService';


const PropertyFilters = ({
  buildingTypeFilter,
  setBuildingTypeFilter,
  roofTypeFilter,
  setRoofTypeFilter,
  stageFilter,
  setStageFilter,
  uploadedByFilter,
  setUploadedByFilter,
  searchQuery,
  setSearchQuery,
  onClearFilters,
  resultCount
}) => {
  const [users, setUsers] = useState([]);
  const [usersLoading, setUsersLoading] = useState(true);

  useEffect(() => {
    const loadUsers = async () => {
      setUsersLoading(true);
      const result = await usersService?.getActiveUsers();
      if (result?.success) {
        setUsers(result?.data || []);
      } else {
        console.error('Failed to load users for property filters:', result?.error);
        setUsers([]);
      }
      setUsersLoading(false);
    };

    loadUsers();
  }, []);
  const buildingTypeOptions = [
    { value: '', label: 'All Building Types' },
    { value: 'Industrial', label: 'Industrial' },
    { value: 'Warehouse', label: 'Warehouse' },
    { value: 'Manufacturing', label: 'Manufacturing' },
    { value: 'Hospitality', label: 'Hospitality' },
    { value: 'Multifamily', label: 'Multifamily' },
    { value: 'Commercial Office', label: 'Commercial Office' },
    { value: 'Retail', label: 'Retail' },
    { value: 'Education', label: 'Education' },
    { value: 'Healthcare', label: 'Healthcare' },
    { value: 'Mixed-Use', label: 'Mixed-Use' },
    { value: 'Other', label: 'Other' }
  ];

  const roofTypeOptions = [
    { value: '', label: 'All Roof Types' },
    { value: 'Shingle', label: 'Shingle' },
    { value: 'TPO', label: 'TPO' },
    { value: 'EPDM', label: 'EPDM' },
    { value: 'PVC', label: 'PVC' },
    { value: 'Modified Bitumen', label: 'Modified Bitumen' },
    { value: 'Metal', label: 'Metal' },
    { value: 'BUR', label: 'BUR' },
    { value: 'Coating', label: 'Coating' },
    { value: 'Green Roof', label: 'Green Roof' },
    { value: 'Other', label: 'Other' }
  ];

  const stageOptions = [
    { value: '', label: 'All Stages' },
    { value: 'Unassessed', label: 'Unassessed' },
    { value: 'Assessed', label: 'Assessed' },
    { value: 'Proposal Sent', label: 'Proposal Sent' },
    { value: 'In Negotiation', label: 'In Negotiation' },
    { value: 'Won', label: 'Won' },
    { value: 'Lost', label: 'Lost' }
  ];

  const uploaderOptions = [
    { value: '', label: 'All Uploaders' },
    ...users?.map(user => ({ value: user?.id, label: user?.full_name }))
  ];

  const hasActiveFilters = buildingTypeFilter || roofTypeFilter || stageFilter || uploadedByFilter || searchQuery;

  return (
    <div className="bg-card border border-border rounded-lg p-6 mb-6">
      <div className="flex flex-col lg:flex-row lg:items-center gap-4">
        {/* Search Input */}
        <div className="flex-1 lg:max-w-sm">
          <Input
            type="search"
            placeholder="Search properties..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e?.target?.value)}
            className="w-full"
          />
        </div>

        {/* Filters */}
        <div className="flex flex-col sm:flex-row sm:flex-wrap gap-4 lg:flex-1">
          <div className="flex-1 min-w-0">
            <Select
              placeholder="Building Type"
              options={buildingTypeOptions}
              value={buildingTypeFilter}
              onChange={setBuildingTypeFilter}
              onSearchChange={() => {}}
              searchable
              error=""
              id="building-type-filter"
              onOpenChange={() => {}}
              label=""
              name="buildingType"
              description=""
              ref={null}
            />
          </div>

          <div className="flex-1 min-w-0">
            <Select
              placeholder="Roof Type"
              options={roofTypeOptions}
              value={roofTypeFilter}
              onChange={setRoofTypeFilter}
              onSearchChange={() => {}}
              searchable
              error=""
              id="roof-type-filter"
              onOpenChange={() => {}}
              label=""
              name="roofType"
              description=""
              ref={null}
            />
          </div>

          <div className="flex-1 min-w-0">
            <Select
              placeholder="Stage"
              options={stageOptions}
              value={stageFilter}
              onChange={setStageFilter}
              onSearchChange={() => {}}
              error=""
              id="stage-filter"
              onOpenChange={() => {}}
              label=""
              name="stage"
              description=""
              ref={null}
            />
          </div>

          <div className="flex-1 min-w-0">
            <Select
              placeholder={usersLoading ? 'Loading uploaders...' : 'Uploaded By'}
              options={uploaderOptions}
              value={uploadedByFilter}
              onChange={setUploadedByFilter}
              searchable
              disabled={usersLoading}
              onSearchChange={() => {}}
              error=""
              id="uploaded-by-filter"
              onOpenChange={() => {}}
              label=""
              name="uploadedBy"
              description=""
              ref={null}
            />
          </div>
        </div>

        {/* Clear Filters Button */}
        {hasActiveFilters && (
          <Button
            variant="outline"
            size="sm"
            onClick={onClearFilters}
            iconName="X"
            iconPosition="left"
            className="shrink-0"
          >
            Clear
          </Button>
        )}
      </div>
      {/* Results Count */}
      {resultCount !== undefined && (
        <div className="mt-4 pt-4 border-t border-border">
          <p className="text-sm text-muted-foreground">
            {resultCount} {resultCount === 1 ? 'property' : 'properties'} found
            {hasActiveFilters && ' with current filters'}
          </p>
        </div>
      )}
      {uploadedByFilter && (
        <div className="mt-2 text-xs text-muted-foreground">
          Filtered to uploads by {users?.find(user => user?.id === uploadedByFilter)?.full_name || 'selected user'}
        </div>
      )}
    </div>
  );
};

export default PropertyFilters;
