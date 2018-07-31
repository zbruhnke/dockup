export const request = options => fetch(
  `${options.url}`, {
  method: options.method,
  headers: {
    'Content-Type': 'application/json',
  },
  credentials: options.credentials || 'include',
  body: options.body || {},
}).then(response => {
  if (response.ok) {
    return Promise.resolve(response);
  }
  return response.text()
    .then(error => Promise.reject(error));
});
