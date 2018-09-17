import toastr from 'toastr';

const FlashMessage = {
  // type is one of:
  // "success", "info", "warning", "danger"
  showMessage(type, message) {
    type = type == 'danger' ? 'error' : type;
    toastr[type](message);
  }
}

export default FlashMessage;
