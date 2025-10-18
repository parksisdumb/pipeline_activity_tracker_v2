import React from 'react';
import Icon from '../../../components/AppIcon';

const MetricsCard = ({ 
  title, 
  current, 
  target, 
  icon, 
  color = 'accent',
  trend = null,
  className = '' 
}) => {
  const percentage = target > 0 ? Math.min((current / target) * 100, 100) : 0;
  const isOnTrack = percentage >= 80;
  const isExceeded = percentage >= 100;

  const getColorClasses = () => {
    switch (color) {
      case 'success':
        return 'text-success bg-success/10 border-success/20';
      case 'warning':
        return 'text-warning bg-warning/10 border-warning/20';
      case 'error':
        return 'text-error bg-error/10 border-error/20';
      default:
        return 'text-accent bg-accent/10 border-accent/20';
    }
  };

  const getRingColor = () => {
    if (isExceeded) return 'text-success';
    if (isOnTrack) return 'text-accent';
    return 'text-warning';
  };

  // Get goal name based on title
  const getGoalName = (title) => {
    const goalNameMap = {
      'Pop-ins': 'Pop-ins',
      'DM Conversations': 'DM Convos',
      'Assessments Booked': 'Assessments', 
      'Proposals Sent': 'Proposals',
      'Accounts Added': 'Accounts',
      'This Week Activities': 'Activities',
      'Total Properties': 'Properties'
    };
    return goalNameMap?.[title] || title;
  };

  return (
    <div className={`bg-card border border-border rounded-lg p-4 sm:p-6 elevation-1 min-w-0 w-full ${className}`}>
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center space-x-2 sm:space-x-3 min-w-0 flex-1">
          <div className={`w-8 h-8 sm:w-10 sm:h-10 rounded-lg flex items-center justify-center flex-shrink-0 ${getColorClasses()}`}>
            <Icon name={icon} size={16} className="sm:w-5 sm:h-5" />
          </div>
          <div className="min-w-0 flex-1">
            <h3 className="text-xs sm:text-sm font-medium text-muted-foreground truncate">{title}</h3>
            <div className="flex items-center space-x-1 sm:space-x-2 mt-1">
              <span className="text-lg sm:text-2xl font-bold text-foreground">{current}</span>
              <span className="text-xs sm:text-sm text-muted-foreground">/ {target}</span>
            </div>
          </div>
        </div>
        
        {trend && (
          <div className={`flex items-center space-x-1 text-xs flex-shrink-0 ${
            trend > 0 ? 'text-success' : trend < 0 ? 'text-error' : 'text-muted-foreground'
          }`}>
            <Icon 
              name={trend > 0 ? 'TrendingUp' : trend < 0 ? 'TrendingDown' : 'Minus'} 
              size={12} 
            />
            <span>{Math.abs(trend)}%</span>
          </div>
        )}
      </div>

      {/* Progress Ring */}
      <div className="flex items-center justify-between">
        <div className="relative w-12 h-12 sm:w-16 sm:h-16">
          <svg className="w-12 h-12 sm:w-16 sm:h-16 transform -rotate-90" viewBox="0 0 64 64">
            <circle
              cx="32"
              cy="32"
              r="28"
              stroke="currentColor"
              strokeWidth="4"
              fill="none"
              className="text-muted/20"
            />
            <circle
              cx="32"
              cy="32"
              r="28"
              stroke="currentColor"
              strokeWidth="4"
              fill="none"
              strokeDasharray={`${2 * Math.PI * 28}`}
              strokeDashoffset={`${2 * Math.PI * 28 * (1 - percentage / 100)}`}
              className={`transition-all duration-500 ${getRingColor()}`}
              strokeLinecap="round"
            />
          </svg>
          {/* Replace unsightly percentage with goal name */}
          <div className="absolute inset-0 flex items-center justify-center">
            <span className={`text-xs sm:text-sm font-semibold ${getRingColor()} text-center leading-tight`}>
              {getGoalName(title)}
            </span>
          </div>
        </div>

        <div className="text-right ml-2 sm:ml-4">
          <div className={`text-xs font-medium ${
            isExceeded ? 'text-success' : isOnTrack ? 'text-accent' : 'text-warning'
          }`}>
            {isExceeded ? 'Exceeded' : isOnTrack ? 'On Track' : 'Behind'}
          </div>
          <div className="text-xs text-muted-foreground mt-1">
            {target - current > 0 ? `${target - current} to go` : 'Target met'}
          </div>
        </div>
      </div>
    </div>
  );
};

export default MetricsCard;