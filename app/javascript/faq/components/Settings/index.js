import React, { Component } from 'react';

import ee from '../../EventEmitter';
import './settings.sass';

export default class Settings extends Component {
	constructor(props) {
		super(props);
    this.ee = ee;
    this.state = {
      isEnabled: props.isEnabled
    };
    this.handleChange = this.handleChange.bind(this);
    this.handleClick = this.handleClick.bind(this);
  }

  handleChange(e) {
    this.setState({isEnabled: !this.state.isEnabled});
  }

  handleClick(e){

    this.ee.emit('setCurrentArticleEnabled', this.state.isEnabled);
    //this.setState({isSaved: true});
  }

	render() {
    const { kbId, isEnabled } = this.props;

		return (
      <div className="Settings">
        <h3>Settings</h3>
        <div className="flex-container well">
          {
            kbId && (
              <span className="flex-left">KB ID: { kbId }</span>
            )
          }
          <div className="flex-center">
            <span>Enabled?&nbsp;&nbsp;</span>
            <input type="checkbox" onChange={this.handleChange} checked={this.state.isEnabled} />
          </div>
          <div className="flex-right">
            <button onClick={this.handleClick} className="btn md black">Save</button>
          </div>
        </div>
      </div>
		)
	}
}

