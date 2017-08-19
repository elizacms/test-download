import React, { Component } from 'react';
import shortid from 'shortid';

import './responses.sass';

export default class Responses extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    let text="test";
    const { data } = this.props;

    return (
      <div className="Responses">
        <h3>Responses</h3>
        <button>+ Add New Response</button>
      <hr />
      {
        data.map(response => (
          <div key={shortid.generate()} className="responses-wrapper">
            <label>
              <span>Valid</span>
              <input type="checkbox" />
            </label>
            <h4>Recommened Wireless Lan Product</h4>
            <textarea defaultValue={response}>
            </textarea>
            <div className="buttonWrapper">
              <button>Edit Response</button>
              <button>Delete Response</button>
            </div>
          </div>
        ))
      }
      </div>
    )
  }
}

