import React, { Component } from 'react';
import './App.css';

import ee from './EventEmitter'
import Modal from './components/Modal';

export default class App extends Component {
  componentDidMount() {
    this.ee = ee;
  }

  render() {
    const {heading, modalContent} = this.props;
    const testContent = (<div key={0}>Test</div>);

    return (
      <div className="App">
        {
          modalContent && (
            <Modal>{ modalContent }</Modal>
          )
        }
        <h2>{heading}</h2>
        <button onClick={ () => this.ee.emit('openModal', testContent) }>
            open modal with fake content
        </button>
      </div>
    )
  }
}
