import React, { Component } from 'react';

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
      articles,
      currentPage,
      pagesTotal,
      modalContent,
      articleTotal
    } = this.props;

    const testContent = <EditFaq />;

    return (
      <div className="App">
        {
          modalContent && (
            <Modal>{ modalContent }</Modal>
          )
        }
        <h2>{heading}</h2>

        <SearchBar />
        <button className="add-faq" onClick={ () => this.ee.emit('openModal', testContent) }>
        + Add New FAQ
        </button>
        <FaqListContainer />
      </div>
    )
  }
}
