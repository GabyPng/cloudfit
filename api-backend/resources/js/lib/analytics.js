const dl = () => {
  window.dataLayer = window.dataLayer || [];
  return window.dataLayer;
};

export const track = (event, params = {}) => {
  dl().push({ event, ...params });
};
