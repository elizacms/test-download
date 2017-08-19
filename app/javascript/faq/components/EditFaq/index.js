import React, { Component } from 'react';

import Settings from '../Settings';
import Queries from '../Queries';
import Responses from '../Responses';

import './edit-faq.sass';

export default class EditFaq extends Component {
	constructor(props) {
		super(props);
  }

	render() {
    const {kbId, queries, responses} = this.props;

		return (
      <div className="EditFaq">
        <h2>Edit Faq</h2>
        <Settings kbId={kbId} />
        <Queries data={queries} />
        <Responses data={responses} />
      </div>
		)
	}
}

