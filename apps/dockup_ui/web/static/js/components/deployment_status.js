import React from 'react';
import {getStatusColorClass} from '../status_colors';

const renderStatus = (text, textClass, iconClass) => {
  return(
    <div className={`col text-right ${textClass} dockup-card-status`}>
      <div>
        {text}
      </div>

      <div>
        <i className={`fa ${iconClass} dockup-card-icon`} aria-hidden="true"></i>
      </div>
    </div>
  );
}

const DeploymentStatus = ({status}) => {
  let textClass = `text-${getStatusColorClass(status)}`;

  switch (status) {
    case 'queued':
      return renderStatus('Queued', textClass, "fa-hourglass-start");
      break;
    case 'cloning_repo':
      return renderStatus('Cloning', textClass, "fa-download");
      break;
    case 'starting':
      return renderStatus('Starting', textClass, "fa-cogs");
      break;
    case 'checking_urls':
      return renderStatus('Pinging', textClass, "fa-exchange");
      break;
    case 'started':
      return renderStatus('Deployed', textClass, "fa-check-circle");
      break;
    case 'deployment_deleted':
      return renderStatus('Deleted', textClass, "fa-trash");
      break;
    case 'deployment_failed':
      return renderStatus('Error', textClass, "fa-times-circle");
      break;
    default:
      return renderStatus(status, "text-info", "fa-info-circle");
  }
}

export default DeploymentStatus;
