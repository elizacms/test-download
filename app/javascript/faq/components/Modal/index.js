import React, { Component } from 'react';

import ee from '../../EventEmitter';

// services

export default class Modal extends Component {
	constructor(props) {
		super(props);

		this.ee = ee;
	}

	render() {
		const modalContentStyle = {
			background: 'white',
			margin: '3.14% auto',
      maxWidth: '95%',
			padding: '25px',
		}

		return (
			<div className="Modal" style={{ zIndex: 2 }}>
			<div style={modalContentStyle}>
			<button className="Modal-close-btn" onClick={()=>this.ee.emit('closeModal')}>Close</button>
			{this.props.children}
			</div>
			</div>
		);
	}
}
