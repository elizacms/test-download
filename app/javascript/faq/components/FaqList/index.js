import React, { Component } from 'react';
import shortid from 'shortid';

export default class FaqList extends Component {
	constructor(props) {
		super(props);
	}

  render() {

    const {articles, pagesTotal, articleTotal} = this.props;
    if(!articles || articles.length === 0) return null;

    const maxPageCount = 50;
    const maxRecordCount = 500;
    const currentPageCount = 1;
    const pText = `Showing ${currentPageCount}-${pagesTotal} out of ${articleTotal} records`

		return (

      <div className="FaqList">
        <p>{pText}</p>
        <table>
          <thead>
            <tr>
              <th>KB ID</th>
              <th>Query</th>
              <th>Response</th>
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
              </tr>
            ))
          }
          </tbody>
        </table>
      </div>
		);
	}
}
