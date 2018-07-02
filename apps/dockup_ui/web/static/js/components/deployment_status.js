import React from 'react';
import {getStatusColorClass} from '../status_colors';

const statusToIcon = {
  "queued": "icon-queued",
  "processing": "icon-sync",
  "cloning_repo": "icon-cloning-repo",
  "starting": "icon-sync",
  "checking_urls": "icon-sync",
  "started": "icon-deployed",
  "hibernating": "icon-sync",
  "hibernated": "icon-hibernated",
  "waking_up": "icon-sync",
  "deleting": "icon-sync",
  "deleted": "icon-deleted",
  "failed": "icon-errored"
}

const DeploymentStatus = ({status}) => {
  console.log(status);
  let icon = statusToIcon[status] || "icon-sync";
  let spinClass = icon == "icon-sync" ? "is-run" : "";

  return(
    <span className="c-list--icon">
      <img className={"c-animation " + spinClass} src={"/icons/"+ icon +".svg"} width="40" height="40"/>
    </span>
  );
}

export default DeploymentStatus;
