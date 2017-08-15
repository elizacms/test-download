// import React, { Component } from 'react';
// import { CSSTransitionGroup } from 'react-transition-group';

// import ee from '../../EventEmitter';

// services

class Modal extends React.Component {
  constructor(props) {
    super(props);

    this.ee = ee;
  }

  render() {
    const modalContentStyle = {
      background: 'white',
      width: '70%',
      margin: '13% auto',
      padding:'25px',
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
