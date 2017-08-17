import React, { Component } from 'react';


export default class Queries extends Component {
	constructor(props) {
		super(props);
  }

	render() {

		return (
      <div className="Queries">
        <h3>Queries</h3>
        <input type="search" placeholder="Query" />
        <button>Add</button>
      <div><button>Save Queries</button></div>
      </div>
		)
	}
}

