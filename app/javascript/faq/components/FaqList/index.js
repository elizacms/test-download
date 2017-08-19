import React, { Component } from 'react';
import shortid from 'shortid';

import ee from '../../EventEmitter';

export default class FaqList extends Component {
	constructor(props) {
		super(props);
    this.handleEdit = this.handleEdit.bind(this);
    this.handleDelete = this.handleDelete.bind(this);
    this.ee = ee;
	}

  handleEdit(article) {
    return () => {
      this.ee.emit('editArticle', article)
    }
  }

  handleDelete(e) {
    console.log(e);
  }

  render() {
    const {articles, pagesTotal, articleTotal, currentPage} = this.props;
    if(!articles || articles.length === 0) return null;

    const pText = `Page ${currentPage} of ${pagesTotal} (${articleTotal} records total)`

		return (

      <div className="FaqList">
        <p>{pText}</p>
        <table>
          <thead>
            <tr>
              <th>KB ID</th>
              <th>Query</th>
              <th colSpan="2">Response</th>
            </tr>
          </thead>
          <tbody>
          {
            articles.map(article => (
              <tr key={shortid.generate()}>
                <td>{article.kbid}</td>
                <td>
                {
                  article.articles.map(item => (
                    <p key={shortid.generate()}>{item.query}</p>
                  ))
                }
                </td>
                <td>
                {
                  article.articles.map(item  => (
                    <p key={shortid.generate()}>{item.response}</p>
                  ))
                }
                </td>
                <td>
                  <button onClick={this.handleEdit(article)}>Edit</button>
                  <button onClick={this.handleDelete}>Delete</button>
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
