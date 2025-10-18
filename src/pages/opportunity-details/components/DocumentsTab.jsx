import React, { useState, useEffect } from 'react';
import { Plus, FileText, Download, Clock, User, AlertCircle } from 'lucide-react';
import documentsService from '../../../services/documentsService';

const DocumentsTab = ({ opportunity, onUploadDocument }) => {
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Load documents for this opportunity
  const loadDocuments = async () => {
    setLoading(true);
    setError('');

    try {
      const response = await documentsService?.listDocuments(
        { opportunity_id: opportunity?.id },
        { limit: 50, sort_by: 'uploaded_at', sort_order: 'desc' }
      );

      if (response?.success) {
        setDocuments(response?.data || []);
      } else {
        setError(response?.error || 'Failed to load documents');
      }
    } catch (err) {
      setError('Error loading documents');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (opportunity?.id) {
      loadDocuments();
    }
  }, [opportunity?.id]);

  // Handle document download
  const handleDownload = async (documentId, documentName) => {
    try {
      const response = await documentsService?.getSignedUrl(documentId);
      
      if (response?.success) {
        // Create temporary link to download
        const link = document.createElement('a');
        link.href = response?.data?.signedUrl;
        link.download = documentName;
        document.body?.appendChild(link);
        link?.click();
        document.body?.removeChild(link);
      } else {
        setError(response?.error || 'Failed to download document');
      }
    } catch (err) {
      setError('Error downloading document');
    }
  };

  const formatFileSize = (bytes) => {
    if (!bytes) return '0 bytes';
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes?.[i];
  };

  const formatDate = (dateString) => {
    if (!dateString) return '';
    return new Date(dateString)?.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const getDocumentTypeLabel = (type) => {
    const typeLabels = {
      'estimate_repair': 'Estimate: Repair',
      'estimate_replacement': 'Estimate: Replacement',
      'estimate_new_construction': 'Estimate: New Construction',
      'estimate_coating': 'Estimate: Coating',
      'plans_new_construction': 'Plans: New Construction',
      'inspection': 'Inspection',
      'coi': 'Certificate of Insurance',
      'w9': 'W-9 Form',
      'business_license': 'Business License',
      'other': 'Other Document'
    };
    return typeLabels?.[type] || type?.replace(/_/g, ' ')?.replace(/\b\w/g, l => l?.toUpperCase());
  };

  const getStatusColor = (status) => {
    const colors = {
      'valid': 'bg-green-100 text-green-800',
      'expiring': 'bg-yellow-100 text-yellow-800',
      'expired': 'bg-red-100 text-red-800',
      'pending': 'bg-blue-100 text-blue-800'
    };
    return colors?.[status] || 'bg-gray-100 text-gray-800';
  };

  if (loading) {
    return (
      <div className="animate-pulse space-y-4">
        {[...Array(3)]?.map((_, i) => (
          <div key={i} className="border border-gray-200 rounded-lg p-4">
            <div className="flex space-x-3">
              <div className="h-10 w-10 bg-gray-200 rounded"></div>
              <div className="flex-1">
                <div className="h-4 bg-gray-200 rounded w-1/3 mb-2"></div>
                <div className="h-3 bg-gray-200 rounded w-1/2 mb-1"></div>
                <div className="h-3 bg-gray-200 rounded w-2/3"></div>
              </div>
            </div>
          </div>
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header with Upload Button */}
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-medium text-gray-900">Documents</h3>
        <button
          onClick={() => onUploadDocument?.()}
          className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
          <Plus className="h-4 w-4 mr-2" />
          Upload Document
        </button>
      </div>

      {/* Error Message */}
      {error && (
        <div className="p-3 bg-red-50 border border-red-200 rounded-md">
          <div className="flex">
            <AlertCircle className="h-5 w-5 text-red-400 mr-2" />
            <p className="text-red-700 text-sm">{error}</p>
          </div>
        </div>
      )}

      {/* Documents List */}
      {documents?.length > 0 ? (
        <div className="space-y-4">
          {documents?.map((document) => (
            <div key={document?.id} className="border border-gray-200 rounded-lg p-4 hover:bg-gray-50 transition-colors">
              <div className="flex items-start space-x-3">
                {/* Document Icon */}
                <div className="flex-shrink-0">
                  <div className="p-2 bg-blue-50 rounded text-blue-600">
                    <FileText className="h-5 w-5" />
                  </div>
                </div>

                {/* Document Content */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h4 className="text-sm font-medium text-gray-900 truncate">
                        {document?.name}
                      </h4>
                      <p className="text-sm text-gray-600 mt-1">
                        {getDocumentTypeLabel(document?.type)}
                      </p>
                      
                      {/* Document metadata */}
                      <div className="flex items-center space-x-4 mt-2 text-xs text-gray-500">
                        <div className="flex items-center">
                          <Clock className="h-3 w-3 mr-1" />
                          {formatDate(document?.uploaded_at)}
                        </div>
                        <div className="flex items-center">
                          <User className="h-3 w-3 mr-1" />
                          {document?.uploader?.full_name || 'Unknown'}
                        </div>
                        <span>{formatFileSize(document?.size_bytes)}</span>
                      </div>

                      {/* Notes */}
                      {document?.notes && (
                        <p className="text-sm text-gray-600 mt-2 line-clamp-2">
                          {document?.notes}
                        </p>
                      )}

                      {/* Validity dates */}
                      {(document?.valid_from || document?.valid_to) && (
                        <div className="mt-2 text-xs text-gray-500">
                          {document?.valid_from && (
                            <span>Valid from: {formatDate(document?.valid_from)}</span>
                          )}
                          {document?.valid_from && document?.valid_to && ' | '}
                          {document?.valid_to && (
                            <span>Valid to: {formatDate(document?.valid_to)}</span>
                          )}
                        </div>
                      )}
                    </div>

                    {/* Actions and Status */}
                    <div className="flex items-center space-x-2 ml-4">
                      {/* Status badge */}
                      {document?.status && (
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(document?.status)}`}>
                          {document?.status?.replace(/_/g, ' ')?.replace(/\b\w/g, l => l?.toUpperCase())}
                        </span>
                      )}

                      {/* Download button */}
                      <button
                        onClick={() => handleDownload(document?.id, document?.name)}
                        className="inline-flex items-center px-3 py-1.5 border border-gray-300 shadow-sm text-xs font-medium rounded text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                      >
                        <Download className="h-3 w-3 mr-1" />
                        Download
                      </button>
                    </div>
                  </div>

                  {/* Tags */}
                  {document?.tags?.length > 0 && (
                    <div className="mt-2 flex flex-wrap gap-1">
                      {document?.tags?.map((tag, index) => (
                        <span
                          key={index}
                          className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800"
                        >
                          {tag}
                        </span>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="text-center py-12">
          <FileText className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">No documents yet</h3>
          <p className="mt-1 text-sm text-gray-500">
            Upload documents related to this opportunity such as estimates, plans, or inspection reports.
          </p>
          <div className="mt-6">
            <button
              onClick={() => onUploadDocument?.()}
              className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <Plus className="h-4 w-4 mr-2" />
              Upload First Document
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default DocumentsTab;