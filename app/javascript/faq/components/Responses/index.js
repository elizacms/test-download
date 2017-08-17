import React, { Component } from 'react';

import './responses.sass';

export default class Responses extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    let text="test";

    return (
      <div className="Responses">
        <h3>Responses</h3>
        <button>+ Add New Response</button>
      <hr />
        <div className="responses-wrapper">
          <label>
            <span>Valid</span>
            <input type="checkbox" />
          </label>
          <h4>Recommened Wireless Lan Product</h4>
          <textarea>
            {text}
          </textarea>
          <div className="buttonWrapper">
            <button>Edit Response</button>
            <button>Delete Response</button>
          </div>
        </div>
      </div>
    )
  }
}

