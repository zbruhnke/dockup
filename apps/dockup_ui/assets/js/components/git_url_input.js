import React, {Component} from 'react';
import {Typeahead} from 'react-bootstrap-typeahead';

class GitUrlInput extends Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange([url, ...rest]) {
    if(url) {
      this.props.onUrlChange(url);
    }
  }

  render() {
    return(
      <div>
        <Typeahead
          onChange={this.handleChange}
          options={this.props.urls}
        />
      </div>
    );
  }
}

export default GitUrlInput
