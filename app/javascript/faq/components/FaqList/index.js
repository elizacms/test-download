import React, { Component } from 'react';
import shortid from 'shortid';

import ee from '../../EventEmitter';
import './faq-list.sass';
import angleDown from '../../images/angle-down.svg';
import angleUp from '../../images/angle-up.svg';

export default class FaqList extends Component {
	constructor(props) {
		super(props);
    this.state = {
      kbidSortDirection: true,
      enabledSortDirection: true,
    };
    this.handleEdit = this.handleEdit.bind(this);
    this.handleDelete = this.handleDelete.bind(this);
    this.handleSortByKbidClick= this.handleSortByKbidClick.bind(this);
    this.handleSortByEnabledClick= this.handleSortByEnabledClick.bind(this);
    this.ee = ee;
	}

  handleEdit(article) {
    return () => {
      this.ee.emit('editArticle', article)
    };
  }

  handleDelete(kbid, e) {
    console.log(e);
    return () => {
      this.ee.emit('deleteArticle', kbid);
    }
  }

  handleSortByKbidClick(e) {
    console.log(e);
    return () => {
      this.setState({
        kbidSortDirection: !this.state.kbidSortDirection
      }, () => this.ee.emit('sortByKbid', this.state.kbidSortDirection));

    }
  }

  handleSortByEnabledClick(e) {
    console.log(e);
    return () => {
      this.setState({
        enabledSortDirection: !this.state.enabledSortDirection
      }, () => this.ee.emit('sortByEnabled', this.state.enabledSortDirection));
    }
  }

  render() {
    const {articles, pagesTotal, articleTotal, currentPage} = this.props;
    if(!articles || articles.length === 0) return null;

    const pText = `Page ${currentPage} of ${pagesTotal} (${articleTotal} records total)`;

		return (

      <div className="FaqList">
        <table>
          <thead>
            <tr>
              <th>
                <span>KB ID </span>
                {
                  this.state.kbidSortDirection
                    ? <button className="btn-desc" onClick={this.handleSortByKbidClick(false)}><img src={angleUp} /></button>
                    : <button className="btn-asc" onClick={this.handleSortByKbidClick(true)}><img src={angleDown} /></button>
                }
              </th>
              <th>Questions</th>
              <th>Answers</th>
              <th colSpan="2">
                <span>Enabled </span>
                {
                  this.state.enabledSortDirection
                    ? <button className="btn-desc" onClick={this.handleSortByEnabledClick(false)}><img src={angleUp} /></button>
                    : <button className="btn-asc" onClick={this.handleSortByEnabledClick(true)}><img src={angleDown} /></button>
                }
              </th>
            </tr>
          </thead>
          <tbody>
          {
            articles.map(article => (
              <tr key={shortid.generate()}>
                <td>{article.kbid}</td>
                <td>
                {
                  article.questions.map(item => (
                    <p key={shortid.generate()}>{item}</p>
                  ))
                }
                </td>
                <td>
                {
                  article.answers.map(item  => (
                    <p key={shortid.generate()}>{item.text}</p>
                  ))
                }
                </td>
                <td>
                {
                  article.enabled ? 'Yes' : 'No'
                }
                </td>
                <td>
                  <button onClick={this.handleEdit(article)}>Edit</button>
                  <button onClick={this.handleDelete(article.kbid, event)}>Delete</button>
                </td>
              </tr>
            ))
          }
          </tbody>
        </table>
      </div>
		);
	}
}
