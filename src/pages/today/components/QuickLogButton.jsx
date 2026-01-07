import React from 'react';
import { useNavigate } from 'react-router-dom';
import Button from '../../../components/ui/Button';

const QuickLogButton = ({ className = '', onLogActivity }) => {
  const navigate = useNavigate();

  const handleLogActivity = () => {
    if (onLogActivity) {
      onLogActivity();
      return;
    }
    navigate('/log-activity');
  };

  return (
    <div className={`w-full ${className}`}>
      <Button
        onClick={handleLogActivity}
        className="w-full h-14 text-lg font-semibold"
        iconName="Plus"
        iconPosition="left"
        iconSize={22}
      >
        Quick Log
      </Button>
      <p className="text-sm text-muted-foreground mt-2 text-center">
        Capture a field activity in seconds
      </p>
    </div>
  );
};

export default QuickLogButton;
