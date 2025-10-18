import React, { useState, useEffect } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import documentsService from '../../services/documentsService';
import DocumentUploadModal from '../../components/ui/DocumentUploadModal';
import DocumentDetailsDrawer from '../../components/ui/DocumentDetailsDrawer';
import ExpirationStatusBadge from '../../components/ui/ExpirationStatusBadge';
import Header from '../../components/ui/Header';
import SidebarNavigation from '../../components/ui/SidebarNavigation';
import Button from '../../components/ui/Button';
import Input from '../../components/ui/Input';
import Select from '../../components/ui/Select';
import Icon from '../../components/AppIcon';

const DocumentsPage = () => {
  const { user, userProfile } = useAuth();
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [stats, setStats] = useState({});
  const [selectedDocument, setSelectedDocument] = useState(null);
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [showDetailsDrawer, setShowDetailsDrawer] = useState(false);
  const [selectedDocuments, setSelectedDocuments] = useState([]);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  // Filters
  const [filters, setFilters] = useState({
    search: '',
    type: [],
    status: [],
    tags: [],
    uploaded_by: '',
    uploaded_at_from: '',
    uploaded_at_to: ''
  });

  // Pagination
  const [pagination, setPagination] = useState({
    limit: 50,
    offset: 0,
    sort_by: 'uploaded_at',
    sort_order: 'desc'
  });

  const [hasMore, setHasMore] = useState(false);
  const [total, setTotal] = useState(0);

  const canManageDocuments = userProfile?.role === 'admin' || userProfile?.role === 'manager';

  // Document type options
  const typeOptions = [
    { value: 'coi', label: 'Certificate of Insurance' },
    { value: 'w9', label: 'W-9 Form' },
    { value: 'business_license', label: 'Business License' },
    { value: 'other', label: 'Other' }
  ];

  // Status options
  const statusOptions = [
    { value: 'valid', label: 'Valid' },
    { value: 'expiring', label: 'Expiring Soon' },
    { value: 'expired', label: 'Expired' },
    { value: 'missing', label: 'Missing' }
  ];

  useEffect(() => {
    if (user) {
      loadDocuments();
      loadStats();
    }
  }, [user, filters, pagination]);

  const loadDocuments = async () => {
    setLoading(true);
    try {
      const response = await documentsService?.listDocuments(filters, pagination);
      if (response?.success) {
        setDocuments(response?.data);
        setTotal(response?.total);
        setHasMore(response?.hasMore);
      } else {
        setError(response?.error);
      }
    } catch (err) {
      setError('Failed to load documents');
    } finally {
      setLoading(false);
    }
  };

  const loadStats = async () => {
    try {
      const response = await documentsService?.getDocumentStats();
      if (response?.success) {
        setStats(response?.data);
      }
    } catch (err) {
      console.error('Failed to load document stats:', err);
    }
  };

  const handleUploadSuccess = () => {
    setShowUploadModal(false);
    loadDocuments();
    loadStats();
  };

  const handleDeleteDocument = async (documentId) => {
    if (!window.confirm('Are you sure you want to delete this document?')) {
      return;
    }

    try {
      const response = await documentsService?.deleteDocument(documentId);
      if (response?.success) {
        loadDocuments();
        loadStats();
        if (selectedDocument?.id === documentId) {
          setShowDetailsDrawer(false);
          setSelectedDocument(null);
        }
      } else {
        setError(response?.error);
      }
    } catch (err) {
      setError('Failed to delete document');
    }
  };

  const handleDownloadDocument = async (document) => {
    try {
      const response = await documentsService?.getSignedUrl(document?.id, 3600);
      if (response?.success) {
        // Open download in new tab
        window.open(response?.data?.signedUrl, '_blank');
      } else {
        setError(response?.error);
      }
    } catch (err) {
      setError('Failed to download document');
    }
  };

  const handleFilterChange = (key, value) => {
    setFilters(prev => ({
      ...prev,
      [key]: value
    }));
    setPagination(prev => ({ ...prev, offset: 0 }));
  };

  const handleBulkDownload = async () => {
    try {
      const downloads = await Promise.all(
        selectedDocuments?.map(docId => documentsService?.getSignedUrl(docId, 3600))
      );

      downloads?.forEach((response, index) => {
        if (response?.success) {
          setTimeout(() => {
            window.open(response?.data?.signedUrl, '_blank');
          }, index * 500); // Stagger downloads
        }
      });

      setSelectedDocuments([]);
    } catch (err) {
      setError('Failed to download documents');
    }
  };

  const handleBulkDelete = async () => {
    if (!window.confirm(`Are you sure you want to delete ${selectedDocuments?.length} documents?`)) {
      return;
    }

    try {
      const promises = selectedDocuments?.map(docId => 
        documentsService?.deleteDocument(docId)
      );
      
      await Promise.all(promises);
      setSelectedDocuments([]);
      loadDocuments();
      loadStats();
    } catch (err) {
      setError('Failed to delete documents');
    }
  };

  const formatFileSize = (bytes) => {
    if (!bytes) return 'N/A';
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes?.[i];
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    return new Date(dateString)?.toLocaleDateString();
  };

  const clearFilters = () => {
    setFilters({
      search: '',
      type: [],
      status: [],
      tags: [],
      uploaded_by: '',
      uploaded_at_from: '',
      uploaded_at_to: ''
    });
  };

  if (loading && documents?.length === 0) {
    return (
      <div className="min-h-screen bg-background">
        <Header onMenuToggle={() => setSidebarCollapsed(!sidebarCollapsed)} />
        <div className="flex">
          <SidebarNavigation 
            isCollapsed={sidebarCollapsed}
            onToggleCollapse={() => setSidebarCollapsed(!sidebarCollapsed)}
          />
          <main className={`flex-1 transition-all duration-200 ${sidebarCollapsed ? 'ml-16' : 'ml-60'}`}>
            <div className="p-6">
              <div className="flex items-center justify-center h-64">
                <div className="text-center">
                  <Icon name="FileText" size={48} className="mx-auto mb-4 text-muted-foreground" />
                  <p className="text-muted-foreground">Loading documents...</p>
                </div>
              </div>
            </div>
          </main>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Header onMenuToggle={() => setSidebarCollapsed(!sidebarCollapsed)} />
      <div className="flex">
        <SidebarNavigation 
          isCollapsed={sidebarCollapsed}
          onToggleCollapse={() => setSidebarCollapsed(!sidebarCollapsed)}
        />
        <main className={`flex-1 transition-all duration-200 ${sidebarCollapsed ? 'ml-16' : 'ml-60'}`}>
          <div className="p-6">
            {/* Page Header */}
            <div className="mb-8">
              <div className="flex items-center justify-between">
                <div>
                  <h1 className="text-3xl font-bold text-foreground">Documents</h1>
                  <p className="mt-2 text-muted-foreground">
                    Manage tenant documents, certificates, and compliance files
                  </p>
                </div>
                {canManageDocuments && (
                  <Button
                    onClick={() => setShowUploadModal(true)}
                    className="flex items-center gap-2"
                  >
                    <Icon name="Upload" size={16} />
                    Upload Document
                  </Button>
                )}
              </div>
            </div>

            {/* Error Message */}
            {error && (
              <div className="mb-6 p-4 bg-destructive/10 border border-destructive/20 rounded-md">
                <p className="text-destructive text-sm">{error}</p>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setError('')}
                  className="mt-2"
                >
                  Dismiss
                </Button>
              </div>
            )}

            {/* KPI Tiles */}
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-2 sm:gap-4 mb-6 sm:mb-8">
              <div className="bg-card p-3 sm:p-4 rounded-lg border">
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
                  <div className="min-w-0 flex-1">
                    <p className="text-xs sm:text-sm text-muted-foreground truncate">Total Documents</p>
                    <p className="text-lg sm:text-2xl font-bold">{stats?.total || 0}</p>
                  </div>
                  <Icon name="FileText" className="text-blue-500 flex-shrink-0" size={20} />
                </div>
              </div>

              <div className="bg-card p-3 sm:p-4 rounded-lg border">
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
                  <div className="min-w-0 flex-1">
                    <p className="text-xs sm:text-sm text-muted-foreground truncate">Valid</p>
                    <p className="text-lg sm:text-2xl font-bold text-green-600">{stats?.valid || 0}</p>
                  </div>
                  <Icon name="CheckCircle" className="text-green-500 flex-shrink-0" size={20} />
                </div>
              </div>

              <div className="bg-card p-3 sm:p-4 rounded-lg border">
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
                  <div className="min-w-0 flex-1">
                    <p className="text-xs sm:text-sm text-muted-foreground truncate">Expiring (30d)</p>
                    <p className="text-lg sm:text-2xl font-bold text-yellow-600">{stats?.expiring30 || 0}</p>
                  </div>
                  <Icon name="Clock" className="text-yellow-500 flex-shrink-0" size={20} />
                </div>
              </div>

              <div className="bg-card p-3 sm:p-4 rounded-lg border">
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
                  <div className="min-w-0 flex-1">
                    <p className="text-xs sm:text-sm text-muted-foreground truncate">Expired</p>
                    <p className="text-lg sm:text-2xl font-bold text-red-600">{stats?.expired || 0}</p>
                  </div>
                  <Icon name="XCircle" className="text-red-500 flex-shrink-0" size={20} />
                </div>
              </div>

              <div className="bg-card p-3 sm:p-4 rounded-lg border">
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
                  <div className="min-w-0 flex-1">
                    <p className="text-xs sm:text-sm text-muted-foreground truncate">Expiring (60d)</p>
                    <p className="text-lg sm:text-2xl font-bold text-orange-600">{stats?.expiring60 || 0}</p>
                  </div>
                  <Icon name="AlertTriangle" className="text-orange-500 flex-shrink-0" size={20} />
                </div>
              </div>

              <div className="bg-card p-3 sm:p-4 rounded-lg border">
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
                  <div className="min-w-0 flex-1">
                    <p className="text-xs sm:text-sm text-muted-foreground truncate">Missing Required</p>
                    <p className="text-lg sm:text-2xl font-bold text-purple-600">{stats?.missingRequired || 0}</p>
                  </div>
                  <Icon name="AlertCircle" className="text-purple-500 flex-shrink-0" size={20} />
                </div>
              </div>
            </div>

            {/* Filters */}
            <div className="bg-card p-3 sm:p-4 rounded-lg border mb-4 sm:mb-6">
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 sm:gap-0 mb-4">
                <h3 className="font-medium">Filters</h3>
                <Button variant="ghost" size="sm" onClick={clearFilters}>
                  Clear All
                </Button>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
                <Input
                  placeholder="Search documents..."
                  value={filters?.search}
                  onChange={(e) => handleFilterChange('search', e?.target?.value)}
                  className="w-full"
                />

                <Select
                  id="type-filter"
                  name="type"
                  label="Document Types"
                  description="Select document types to filter"
                  value={filters?.type}
                  onChange={(value) => handleFilterChange('type', value)}
                  onSearchChange={() => {}}
                  onOpenChange={() => {}}
                  multiple
                  placeholder="Document Types"
                  options={typeOptions}
                  error=""
                  ref={null}
                />

                <Select
                  id="status-filter"
                  name="status"
                  label="Status"
                  description="Select status to filter"
                  value={filters?.status}
                  onChange={(value) => handleFilterChange('status', value)}
                  onSearchChange={() => {}}
                  onOpenChange={() => {}}
                  multiple
                  placeholder="Status"
                  options={statusOptions}
                  error=""
                  ref={null}
                />

                <Input
                  type="date"
                  placeholder="mm/dd/yyyy"
                  value={filters?.uploaded_at_from}
                  onChange={(e) => handleFilterChange('uploaded_at_from', e?.target?.value)}
                />
              </div>
            </div>

            {/* Bulk Actions */}
            {selectedDocuments?.length > 0 && (
              <div className="bg-blue-50 border border-blue-200 p-3 sm:p-4 rounded-lg mb-4 sm:mb-6">
                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
                  <p className="text-sm">
                    {selectedDocuments?.length} document{selectedDocuments?.length > 1 ? 's' : ''} selected
                  </p>
                  <div className="flex flex-wrap gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={handleBulkDownload}
                    >
                      <Icon name="Download" size={14} className="mr-2" />
                      Download All
                    </Button>
                    {canManageDocuments && (
                      <Button
                        variant="destructive"
                        size="sm"
                        onClick={handleBulkDelete}
                      >
                        <Icon name="Trash2" size={14} className="mr-2" />
                        Delete All
                      </Button>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* Documents Table */}
            <div className="bg-card rounded-lg border overflow-hidden">
              <div className="overflow-x-auto">
                <div className="min-w-full">
                  {/* Mobile Card View - Show on small screens */}
                  <div className="block md:hidden">
                    {documents?.map((document) => (
                      <div key={document?.id} className="border-b p-4 space-y-3">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2 min-w-0 flex-1">
                            <input
                              type="checkbox"
                              checked={selectedDocuments?.includes(document?.id)}
                              onChange={(e) => {
                                if (e?.target?.checked) {
                                  setSelectedDocuments(prev => [...prev, document?.id]);
                                } else {
                                  setSelectedDocuments(prev => prev?.filter(id => id !== document?.id));
                                }
                              }}
                              className="flex-shrink-0"
                            />
                            <Icon name="FileText" size={16} className="text-muted-foreground flex-shrink-0" />
                            <span className="font-medium truncate">{document?.name}</span>
                          </div>
                        </div>
                        
                        <div className="grid grid-cols-2 gap-2 text-sm">
                          <div>
                            <span className="text-muted-foreground">Type:</span>
                            <p className="font-medium truncate">
                              {typeOptions?.find(t => t?.value === document?.type)?.label || document?.type}
                            </p>
                          </div>
                          <div>
                            <span className="text-muted-foreground">Status:</span>
                            <div className="mt-1">
                              <ExpirationStatusBadge 
                                status={document?.status} 
                                expiryDate={document?.valid_to} 
                              />
                            </div>
                          </div>
                          <div>
                            <span className="text-muted-foreground">Expires:</span>
                            <p className="font-medium">{formatDate(document?.valid_to)}</p>
                          </div>
                          <div>
                            <span className="text-muted-foreground">Size:</span>
                            <p className="font-medium">{formatFileSize(document?.size_bytes)}</p>
                          </div>
                        </div>
                        
                        <div className="flex items-center justify-between pt-2 border-t">
                          <div className="text-xs text-muted-foreground">
                            By: {document?.uploader?.full_name || 'System'}
                          </div>
                          <div className="flex items-center gap-1">
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleDownloadDocument(document)}
                              title="Download"
                            >
                              <Icon name="Download" size={14} />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => {
                                setSelectedDocument(document);
                                setShowDetailsDrawer(true);
                              }}
                              title="View Details"
                            >
                              <Icon name="Eye" size={14} />
                            </Button>
                            {canManageDocuments && (
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleDeleteDocument(document?.id)}
                                title="Delete"
                              >
                                <Icon name="Trash2" size={14} className="text-destructive" />
                              </Button>
                            )}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>

                  {/* Desktop Table View - Show on medium screens and up */}
                  <table className="hidden md:table w-full">
                    <thead className="border-b bg-muted/50">
                      <tr>
                        <th className="p-2 lg:p-4 text-left w-12">
                          <input
                            type="checkbox"
                            checked={selectedDocuments?.length === documents?.length && documents?.length > 0}
                            onChange={(e) => {
                              if (e?.target?.checked) {
                                setSelectedDocuments(documents?.map(d => d?.id));
                              } else {
                                setSelectedDocuments([]);
                              }
                            }}
                          />
                        </th>
                        <th className="p-2 lg:p-4 text-left font-medium">Name</th>
                        <th className="p-2 lg:p-4 text-left font-medium">Type</th>
                        <th className="p-2 lg:p-4 text-left font-medium">Status</th>
                        <th className="p-2 lg:p-4 text-left font-medium hidden lg:table-cell">Expires</th>
                        <th className="p-2 lg:p-4 text-left font-medium hidden xl:table-cell">Uploaded By</th>
                        <th className="p-2 lg:p-4 text-left font-medium hidden xl:table-cell">Uploaded At</th>
                        <th className="p-2 lg:p-4 text-left font-medium hidden lg:table-cell">Size</th>
                        <th className="p-2 lg:p-4 text-left font-medium">Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {documents?.map((document) => (
                        <tr key={document?.id} className="border-b hover:bg-muted/50">
                          <td className="p-2 lg:p-4">
                            <input
                              type="checkbox"
                              checked={selectedDocuments?.includes(document?.id)}
                              onChange={(e) => {
                                if (e?.target?.checked) {
                                  setSelectedDocuments(prev => [...prev, document?.id]);
                                } else {
                                  setSelectedDocuments(prev => prev?.filter(id => id !== document?.id));
                                }
                              }}
                            />
                          </td>
                          <td className="p-2 lg:p-4 max-w-0">
                            <div className="flex items-center gap-2 min-w-0">
                              <Icon name="FileText" size={16} className="text-muted-foreground flex-shrink-0" />
                              <span className="font-medium truncate">{document?.name}</span>
                            </div>
                          </td>
                          <td className="p-2 lg:p-4">
                            <span className="px-2 py-1 bg-muted rounded text-sm whitespace-nowrap">
                              {typeOptions?.find(t => t?.value === document?.type)?.label || document?.type}
                            </span>
                          </td>
                          <td className="p-2 lg:p-4">
                            <ExpirationStatusBadge 
                              status={document?.status} 
                              expiryDate={document?.valid_to} 
                            />
                          </td>
                          <td className="p-2 lg:p-4 text-sm text-muted-foreground hidden lg:table-cell">
                            {formatDate(document?.valid_to)}
                          </td>
                          <td className="p-2 lg:p-4 text-sm text-muted-foreground hidden xl:table-cell max-w-32">
                            <div className="truncate">{document?.uploader?.full_name || 'System'}</div>
                          </td>
                          <td className="p-2 lg:p-4 text-sm text-muted-foreground hidden xl:table-cell">
                            {formatDate(document?.uploaded_at)}
                          </td>
                          <td className="p-2 lg:p-4 text-sm text-muted-foreground hidden lg:table-cell">
                            {formatFileSize(document?.size_bytes)}
                          </td>
                          <td className="p-2 lg:p-4">
                            <div className="flex items-center gap-1">
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleDownloadDocument(document)}
                                title="Download"
                              >
                                <Icon name="Download" size={14} />
                              </Button>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => {
                                  setSelectedDocument(document);
                                  setShowDetailsDrawer(true);
                                }}
                                title="View Details"
                              >
                                <Icon name="Eye" size={14} />
                              </Button>
                              {canManageDocuments && (
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  onClick={() => handleDeleteDocument(document?.id)}
                                  title="Delete"
                                >
                                  <Icon name="Trash2" size={14} className="text-destructive" />
                                </Button>
                              )}
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                {documents?.length === 0 && !loading && (
                  <div className="p-6 sm:p-8 text-center">
                    <Icon name="FileText" size={48} className="mx-auto mb-4 text-muted-foreground" />
                    <h3 className="text-lg font-medium mb-2">No documents found</h3>
                    <p className="text-muted-foreground mb-4 text-sm sm:text-base">
                      {Object.values(filters)?.some(f => f && (Array.isArray(f) ? f?.length > 0 : true))
                        ? 'Try adjusting your filters to see more results.' : 'Upload your first document to get started.'
                      }
                    </p>
                    {canManageDocuments && (
                      <Button onClick={() => setShowUploadModal(true)}>
                        Upload Document
                      </Button>
                    )}
                  </div>
                )}
              </div>
            </div>
          </div>
        </main>
      </div>
      {/* Upload Modal */}
      {showUploadModal && (
        <DocumentUploadModal
          isOpen={showUploadModal}
          onClose={() => setShowUploadModal(false)}
          onUploadSuccess={handleUploadSuccess}
        />
      )}
      {/* Details Drawer */}
      {showDetailsDrawer && selectedDocument && (
        <DocumentDetailsDrawer
          isOpen={showDetailsDrawer}
          onClose={() => {
            setShowDetailsDrawer(false);
            setSelectedDocument(null);
          }}
          document={selectedDocument}
          onDocumentUpdate={(updatedDoc) => {
            setDocuments(prev => 
              prev?.map(d => d?.id === updatedDoc?.id ? updatedDoc : d)
            );
            setSelectedDocument(updatedDoc);
          }}
          onDocumentDelete={() => {
            handleDeleteDocument(selectedDocument?.id);
          }}
        />
      )}
    </div>
  );
};

export default DocumentsPage;