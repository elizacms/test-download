import React, { Component } from 'react';

import ee from './EventEmitter'
import Modal from './components/Modal';
import SearchBar from './components/SearchBar';
import PagingControl from './components/PagingControl';
import FaqList from './components/FaqList';
import EditFaq from './components/EditFaq';

export default class App extends Component {
  componentDidMount() {
    this.ee = ee;
  }

  render() {
    const { pagesTotal, articleTotal, articles, heading, modalContent } = this.props;
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
        <FaqList key={9} articles={articles} pagesTotal={pagesTotal} articleTotal={articleTotal}/>
        <PagingControl itemCount={ 3 } />
      </div>
    )
  }
}
