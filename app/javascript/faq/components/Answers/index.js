import React, { Component } from 'react';
import shortid from 'shortid';

import './answers.sass';

export default class Answers extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    let text="test";
    const { data } = this.props;
    if(!data) return null;

    return (
      <div className="Answers">
        <h3>Answers</h3>
        <button>+ Add New Answer</button>
      <hr />
      {
        data.map(answer => (
          <div key={shortid.generate()} className="answers-wrapper">
            <label>
              <span>Valid</span>
              <input type="checkbox" defaultChecked={answer.active}/>
            </label>
            <h4>Recommened Wireless Lan Product</h4>
            <textarea defaultValue={answer.text}>
            </textarea>
            <div className="buttonWrapper">
              <button>Edit Answer</button>
              <button>Delete Answer</button>
            </div>
          </div>
        ))
      }
      </div>
    )
  }
}

