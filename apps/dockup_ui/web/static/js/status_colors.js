export const getStatusColorClass = (status) => {
  const statusColors = {
    'checking_urls': 'primary',
    'started': 'success',
    'deployment_deleted': 'muted',
    'deployment_failed': 'danger'
  }

  return(statusColors[status] || 'info');
}
