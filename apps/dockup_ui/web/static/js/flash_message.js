import $ from 'jquery';

const FlashMessage = {
  // type is one of:
  // "success", "info", "warning", "danger"
  showMessage(type, message) {
    let content = `
    <div class="alert alert-${type}">
      <p>
        ${message}
      </p>
    </div>
    `
    $('.js-flash-message').append($(content));
  }
}

export default FlashMessage;
