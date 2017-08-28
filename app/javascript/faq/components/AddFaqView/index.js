import React, { Component } from 'react';
import shortid from 'shortid';

import Settings from '../Settings';
import Questions from '../Questions';
import Answers from '../Answers';

import './add-faq.sass';

export default class AddFaqView extends Component {
	constructor(props) {
		super(props);
    this.state = {
      kbId:null,
      questions: [],
      answers: [],
    }
  }

	render() {
    const {isEnabled, questions, answers} = this.props;

		return (
      <div className="AddFaqView">
        <h2>Add New Faq</h2>
        <br />
        <Settings kbId={this.state.kbId} isEnabled={isEnabled} />
        <br /><br />
        <Questions data={this.state.questions} />
        <br /><br />
        <Answers  data={this.state.answers}   />
      </div>
		)
	}
}

