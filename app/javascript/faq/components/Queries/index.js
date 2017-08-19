import React, { Component } from 'react';
import shortid from 'shortid';


export default class Queries extends Component {
	constructor(props) {
		super(props);
  }

	render() {

    const { data } = this.props;
		return (
      <div className="Queries">
        <h3>Queries</h3>
        <input type="search" placeholder="Query" />
        <button>Add</button>
      {data.map(query => <p key={shortid.generate()}>{query}</p>)}
      <div><button>Save Queries</button></div>
      </div>
		)
	}
}

