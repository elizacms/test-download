import React, { Component } from 'react';

import ee from '../../EventEmitter';
import './settings.sass';

export default class Settings extends Component {
	constructor(props) {
		super(props);
    this.ee = ee;
    this.state = {
      isEnabled: props.isEnabled
    }
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(e) {
    console.log(e.nativeEvent);
    this.ee.emit('setCurrentArticleEnabled', !this.state.isEnabled);
    this.setState({isEnabled: !this.state.isEnabled});
  }

	render() {
    const { kbId, isEnabled } = this.props;

		return (
      <div className="Settings">
        <h3>Settings</h3>
        <div className="flex-container well">
          <span className="flex-left">KB ID: { kbId }</span>
          <div className="flex-center">
            <span>Enabled?&nbsp;&nbsp;</span>
            <input type="checkbox" onChange={this.handleChange} checked={this.state.isEnabled} />
          </div>
          <div className="flex-right">
            <button className="btn md black">Save</button>
          </div>
        </div>
      </div>
		)
	}
}

