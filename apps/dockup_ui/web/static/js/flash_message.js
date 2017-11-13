import {alert} from 'notie';

const FlashMessage = {
  // type is one of:
  // "success", "info", "warning", "danger"
  showMessage(type, message) {
    type = type == 'danger' ? 'error' : type;
    alert({type: type, text: message});
  }
}

export default FlashMessage;
