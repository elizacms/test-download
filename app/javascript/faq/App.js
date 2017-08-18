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
    const {heading, articles, pagesTotal, modalContent, articleTotal} = this.props;
    const testContent = <EditFaq />;
    const data = {
      kb_id:22,
      queries: ['w-lan','w lan', 'wireless'],
      responses: ['Da emmphaj'],
      type: 'FAQ',
      enabled: true,
    }

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
        <FaqList
          articles={ articles }
          articleTotal={ articleTotal }
          pagesTotal={ pagesTotal }
        />
        <PagingControl itemCount={ pagesTotal } />
      </div>
    )
  }
}
