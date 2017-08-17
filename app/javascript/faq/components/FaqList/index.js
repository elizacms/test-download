import React, { Component } from 'react';

export default class FaqList extends Component {
	constructor(props) {
		super(props);
	}

	render() {
    const {data} = this.props;
    const maxPageCount = 50;
    const maxRecordCount = 500;
    const currentPageCount = 1;
    const pText = `Showing ${currentPageCount}-${maxPageCount} out of ${maxRecordCount} records`

		return (
      <div className="FaqList">
        <p>{pText}</p>
        <table>
          <thead>
            <tr>
              <th>KB ID</th>
              <th>Query</th>
              <th>Response</th>
              <th>Type</th>
              <th>Enabled</th>
            </tr>
          </thead>
        </table>
      </div>
		);
	}
}
