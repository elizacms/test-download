import React, { Component } from 'react';
import shortid from 'shortid';

export default class Questions extends Component {
	constructor(props) {
		super(props);
  }

	render() {
    const { data } = this.props;
    if(!data) return null;
		return (
      <div className="Questions">
        <h3>Questions</h3>
        <input type="search" placeholder="Question" />
        <button>Add</button>
        {
          data.map(question => (
           <p key={ shortid.generate() }>{ question }</p>)
          )
        }
        <div>
          <button>Save Queries</button>
        </div>
      </div>
		)
	}
}

