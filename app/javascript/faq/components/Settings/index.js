import React, { Component } from 'react';

import ee from '../../EventEmitter';

export default class Settings extends Component {
	constructor(props) {
		super(props);
    this.ee = ee;
    this.state = {
      isEnabled: false
    }
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(e) {
    console.log(e.nativeEvent);
    this.ee.emit('setCurrentArticleEnabled', !this.state.isEnabled);
    this.setState({isEnabled: !this.state.isEnabled});
  }

	render() {
    const { kbId } = this.props;

		return (
      <div className="Settings">
        <h3>Settings</h3>
      <span>KB ID: { kbId }</span>
      <label>
        <span>Enabled?</span>
        <input type="checkbox" onChange={this.handleChange} checked={this.state.isEnabled} />
      </label>
      <button>Save</button>
      </div>
		)
	}
}

