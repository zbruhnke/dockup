export const getStatusColorClass = (status) => {
  const statusColors = {
    'waiting_for_urls': 'primary',
    'started': 'success',
    'deleted': 'muted',
    'failed': 'danger'
  }

  return(statusColors[status] || 'info');
}
