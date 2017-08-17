import React, { Component } from 'react';

import Queries from '../Queries';
import Settings from '../Settings';
import Responses from '../Responses';

import './edit-faq.sass';

export default class EditFaq extends Component {
	constructor(props) {
		super(props);
  }

	render() {

		return (
      <div className="EditFaq">
        <h2>Edit Faq</h2>
        <Settings />
        <Queries />
        <Responses />
      </div>
		)
	}
}

