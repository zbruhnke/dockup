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
      return renderStatus('Queued', textClass, "fa-circle-o-notch fa-spin");
      break;
    case 'starting':
      return renderStatus('Starting', textClass, "fa-cog fa-spin");
      break;
    case 'waiting_for_urls':
      return renderStatus('Pinging', textClass, "fa-exchange");
      break;
    case 'started':
      return renderStatus('Deployed', textClass, "fa-check-circle");
      break;
    case 'hibernating':
      return renderStatus('Hibernating', textClass, "fa-cog fa-spin");
      break;
    case 'hibernated':
      return renderStatus('Hibernated', textClass, "fa-check-circle");
      break;
    case 'waking_up':
      return renderStatus('Waking', textClass, "fa-cog fa-spin");
      break;
    case 'deleted':
      return renderStatus('Deleted', textClass, "fa-trash");
      break;
    case 'deleting':
      return renderStatus('Deleting', textClass, "fa-cog fa-spin");
      break;
    case 'failed':
      return renderStatus('Error', textClass, "fa-times-circle");
      break;
    default:
      return renderStatus(status, "text-info", "fa-info-circle");
  }
}

export default DeploymentStatus;
