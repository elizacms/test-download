import React, { Component } from 'react';
import './paging-control.scss';
import  ee from '../../EventEmitter';

export default class PagingControl extends Component {
  constructor(props) {
    super(props);
    this.handleForwardClick = this.handleForwardClick.bind(this);
    this.handleBackClick = this.handleBackClick.bind(this);
    this.handleNumberClick = this.handleNumberClick.bind(this);
    this.renderButtons = this.renderButtons.bind(this);
    this.ee = ee;
  }

  renderButtons(itemCount) {
    let pages = [];
    for(var i = 1; i <= itemCount; i++) {
      pages.push((
        <button onClick={this.handleNumberClick} key={i}>{i}</button>
      ));
    }
    return pages;
  }

    handleNumberClick(e) {
      console.log();
      this.ee.emit('changePageNumber', e.target.textContent);
    }

    handleForwardClick(e) {
      this.ee.emit('pageForward');
      console.log(e);
    }

    handleBackClick(e) {
      this.ee.emit('pageBack');
      console.log(e);
    }

  render() {
    const {itemCount} = this.props;

    return (
      <div className="PagingControl">
        <button onClick={this.handleBackClick}>{'<'}</button>
        {this.renderButtons(itemCount)}
        <button onClick={this.handleForwardClick}>{'>'}</button>
      </div>
    );
  }
}
