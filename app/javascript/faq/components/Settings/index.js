import React, { Component } from 'react';


export default class Settings extends Component {
	constructor(props) {
		super(props);
  }

	render() {
    const { kbId } = this.props;

		return (
      <div className="Settings">
        <h3>Settings</h3>
      <span>KB ID: { kbId }</span>
      <label>
        <span>Enabled?</span>
        <input type="checkbox" value="enabled" />
      </label>
      <button>Save</button>
      </div>
		)
	}
}

