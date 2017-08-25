import React, { Component } from 'react';
import shortid from 'shortid';

import ee from './EventEmitter'
import Modal from './components/Modal';
import SearchBar from './components/SearchBar';
import FaqListContainer from './components/FaqListContainer';
import EditFaq from './components/EditFaq';

export default class App extends Component {
  componentDidMount() {
    this.ee = ee;
  }

  render() {

    const {
      heading,
      modalContent,
    } = this.props;


    return (
      <div className="App">
        {
          modalContent && (
            <Modal>{ modalContent }</Modal>
          )
        }
        <h2>{heading}</h2>

        <SearchBar />
        <FaqListContainer />
      </div>
    )
  }
}
