var ResponseType = React.createClass({
  getInitialState(){
    return {
      name: '',
      index: '',
      response_id: '',
      responseType: 'text',
      response_trigger: '',
      trigger_type: 'null',
      // Text Type
      response_text_input: '',
      response_text_spokentext: '',
      // Text With Option
      response_text_with_option_text_input: '',
      options: [ {text:'', entity:''} ],
      // Card Type
      cards:[{ text:'', iconurl:'', options:[{text:'', entity:''}] }],
      // Video Type
      response_video_text_input: '',
      response_video_thumbnail_input: '',
      response_video_entity_input: '',
      // Q&A Type
      response_qna_question: '',
      response_qna_faq: false,
      response_qna_answers: [ {answer: ''} ],
      response_qna_video_thumbnail: '',
      response_qna_video_url: '',
      response_qna_image_thumbnail: '',
      response_qna_image_url: '',
      response_qna_link_text: '',
      response_qna_url: ''
    };
  },

  componentDidMount() {
    const response_trigger_key = Object.keys(this.props.response_trigger)[0] || 'null';
    const response_trigger_value = Object.values(this.props.response_trigger)[0] || '';

    this.setState({
      trigger_type: response_trigger_key,
      response_trigger: response_trigger_value,
      index: this.props.index,
      response_id: this.props.response_id,
      name: this.props.name
    });

    const this_props_inputValue = this.props.inputValue;
    if (this_props_inputValue) {
      const obj = {};  //New object for setState

      Object.keys(this_props_inputValue).forEach(function(k, i){
        obj[k] = this_props_inputValue[k];
      });

      this.setState( obj );
      this.setState({ responseType: this.props.value });
    };
  },

  componentWillReceiveProps(nextProps) {
    const response_trigger_key = Object.keys(nextProps.response_trigger)[0] || '';
    const response_trigger_value = Object.values(nextProps.response_trigger)[0] || '';

    this.setState({
      trigger_type: response_trigger_key,
      response_trigger: response_trigger_value,
      index: nextProps.index,
      response_id: nextProps.response_id,
      name: nextProps.name
    });

    if (nextProps.inputValue) {
      const obj = {};

      Object.keys(nextProps.inputValue).forEach(function(k, i){
        obj[k] = nextProps.inputValue[k];
      });

      this.setState( obj );
      this.setState({ responseType: nextProps.value });
    } else {
      this.setState( this.getInitialState() ); //Next props has no input value. reset state.
    }
  },

  addRow(e){
    e.preventDefault();
    this.props.addRow(this.props.name);
  },

  deleteInput(e){
    e.preventDefault();
    this.props.deleteInput();
  },

  responseTypeMenuChange(event){
    this.setState({ responseType: event.target.value });
  },

  triggerMenuChange(event){
    const ttype = event.target.value;

    this.setState({ trigger_type: ttype });

    if (ttype === 'videoClosed' || ttype === 'customerService') {
      this.state.response_trigger = { [ttype]: false };
    } else if ( ttype === 'timeDelayInSecs') {
      this.state.response_trigger = { [ttype]: '' };
    } else {
      this.state.response_trigger = 'null';
    }
    this.setState({});

    this.updateParentState({});
  },

  responseTriggerChange(event){
    let ttype = event.target.name;
    if (this.state.trigger_type === 'null') {
      ttype = 'null';
    }

    if (ttype === 'videoClosed' || ttype === 'customerService') {
      this.state.response_trigger = { [ttype]: event.target.checked };
    } else if ( ttype === 'timeDelayInSecs') {
      this.state.response_trigger = { [ttype]: event.target.value };
    } else {
      this.state.response_trigger = 'null';
    }
    this.setState({});

    this.updateParentState({});
  },

  updateParentState(newInputValue) {
    this.props.updateState( 'responses_attributes', {
      id: this.props.index,
      value: this.state.responseType,
      inputValue: newInputValue,
      response_trigger: this.state.response_trigger,
      response_id: this.state.response_id
    });
  },

  // Type-0 Text Type //////////////////////////////////////////////////
  textTypeInputChange(event){
    const field = event.target.name;

    // Update component state, then update dialog-form state.
    this.setState({
      [field]: event.target.value
    }, () => {
      const updatedInputValue = {[field]: this.state[field]};
      this.updateParentState(updatedInputValue);
    });

  },
  renderTextType() {
    if (this.state.responseType === 'text'){
      return(
        <div>
          <label>
            <span className='dialog-label'>Text</span>
          </label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_text_input'
            value={this.state.response_text_input}
            // onChange={ (e) => this.handleInputChanges(e, 'response_text_input') }
            onChange={this.textTypeInputChange}
          />
          <br />
          <label>
            <span className='dialog-label'>Spoken Text</span>
          </label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_text_spokentext'
            value={this.state.response_text_spokentext}
            onChange={this.textTypeInputChange}
          />
        </div>
      );
    } else {
      return(<div />);
    }
  },

  // Type-1 Text With Option Type //////////////////////////////////////
  addOptions(e) {
    e.preventDefault();

    this.setState({
      options: this.state.options.concat([{ text: '', entity: '' }])
    });
  },
  deleteOptions(index, e) {
    e.preventDefault();

    this.setState({
      options: this.state.options.filter((o, i) => index !== i)
    }, this.optionInputChange );
  },
  optionInputChange(event, index) {
    // event.try(target).try(name)
    const field = (( event || {} ).target || {}).name;
    const value = (( event || {} ).target || {}).value;

    // Create new options array state
    const newOptions = this.state.options.map((option, i) => {
      if (index !== i) return option;

      if (event.target.name == 'option_text') {
        option.text = value;
        return option;
      }

      if (event.target.name == 'option_entity') {
        option.entity = value;
        return option;
      }
    });

    // Update component state, then update dialog-form state.
    this.setState({
      options: newOptions,
      [field]: value
    }, () => {
      // New inputValue object for updateState
      const updatedInputValue = {
        response_text_with_option_text_input: this.state.response_text_with_option_text_input,
        options: this.state.options
      };
      this.updateParentState(updatedInputValue);
    });
  },
  renderTextWithOptionType() {
    if (this.state.responseType === 'text_with_option'){
      return(
        <div>
          <label>
            <span className='dialog-label'>Text</span>
          </label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_text_with_option_text_input'
            value={this.state.response_text_with_option_text_input}
            onChange={this.optionInputChange}
          />
          &nbsp;&nbsp;&nbsp;&nbsp;
          <a onClick={this.addOptions} href='#'>
            <span className='icon-plus add-option'>Option</span>
          </a>
          <br />
          {this.state.options.map((option, index) => (
            <div key={index}>
              <label>
                <span className='dialog-label'>Option</span>
              </label>
              <input
                type='text'
                name='option_text'
                placeholder='Text'
                className='dialog-input response-option-input'
                value={option.text}
                onChange={ (e) => this.optionInputChange(e, index) }
              />
              &nbsp;&nbsp;&nbsp;&nbsp;
              <label><span className='dialog-label'>Entity</span></label>
              <input
                type='text'
                name='option_entity'
                placeholder='Entity Value'
                className='dialog-input response-option-input'
                value={option.entity}
                onChange={ (e) => this.optionInputChange(e, index) }
              />
              &nbsp;&nbsp;
              <a onClick={this.deleteOptions.bind(this, index)} href='#'>
                <span className='icon-cancel-circled'></span>
              </a>
            </div>
          ))}
        </div>
      );
    } else {
      return(<div />);
    }
  },

  // Type-2 Video Type /////////////////////////////////////////////////
  videoInputChange(event){
    const field = event.target.name;
    const value = event.target.value;

    // Update component state, then update dialog-form state.
    this.setState({
      [field]: value
    }, () => {
      const updatedInputValue = {
        response_video_text_input: this.state.response_video_text_input,
        response_video_thumbnail_input: this.state.response_video_thumbnail_input,
        response_video_entity_input: this.state.response_video_entity_input
      };
      this.updateParentState(updatedInputValue);
    });
  },
  renderVideoType() {
    if (this.state.responseType === 'video'){
      return(
        <div>
          <label><span className='dialog-label'>Text</span></label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_video_text_input'
            value={this.state.response_video_text_input}
            onChange={this.videoInputChange}
          />
          <br />
          <label><span className='dialog-label'>Video</span></label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_video_thumbnail_input'
            placeholder='Thumbnail'
            value={this.state.response_video_thumbnail_input}
            onChange={this.videoInputChange}
          />
          &nbsp;&nbsp;&nbsp;&nbsp;
          <label><span className='dialog-label'>Entity Value</span></label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_video_entity_input'
            placeholder='Link'
            value={this.state.response_video_entity_input}
            onChange={this.videoInputChange}
          />
        </div>
      );
    } else {
      return(<div />);
    }
  },

  // Type-3 Card Type //////////////////////////////////////////////////
  addCard(e) {
    e.preventDefault();

    this.setState({
      cards: this.state.cards.concat( [{ text:'', iconurl:'', options:[{text:'', entity:''}] }] )
    });
  },
  deleteCard(index, e) {
    e.preventDefault();

    this.state.cards = this.state.cards.filter((c, i) => index !== i);

    this.cardInputChange();
  },
  addCardOption(index, e) {
    e.preventDefault();

    this.state.cards[index].options.push( {text:'', entity:''} );
    this.setState({});
  },
  deleteCardOption(card_index, option_index, e) {
    e.preventDefault();

    this.state.cards[card_index].options = this.state.cards[card_index].options.filter((o, i) => option_index !== i);

    this.cardInputChange();
  },
  cardInputChange(event, card_index, option_index) {
    const field = (( event || {} ).target || {}).name;
    const value = (( event || {} ).target || {}).value;

    switch(field) {
      case 'card_text':
        this.state.cards[card_index].text = value;
        break;
      case 'card_icon_url':
        this.state.cards[card_index].iconurl = value;
        break;
      case 'card_option_text':
        this.state.cards[card_index].options[option_index].text = value;
        break;
      case 'card_option_entity':
        this.state.cards[card_index].options[option_index].entity = value;
        break;
      case 'response_trigger':
        this.state.response_trigger = value;
      default:
        break;
    }

    // Update component state, then update dialog-form state.
    this.setState({
      cards: this.state.cards,
    }, () => {
      // New inputValue object for updateState
      const updatedInputValue = { cards: this.state.cards };
      this.updateParentState(updatedInputValue);
    });

  },
  renderCardType() {
    if (this.state.responseType === 'card'){
      return(
        <div>
          <label><span className='dialog-label'>Card</span></label>
          <a onClick={this.addCard} href='#'>
            <span className='icon-plus add-card pull-right'>Card</span>
          </a>
          <br />
          {this.state.cards.map((card, index) => (
            <div key={index} className="card-bg">
              <label><span className='dialog-label'>Text</span></label>
              <input
                type='text'
                name='card_text'
                className='dialog-input response-card-text-input'
                value={card.text}
                onChange={ (e) => this.cardInputChange(e, index) }
              />
              <a onClick={this.deleteCard.bind(this, index)} href='#'>
                <span className='icon-cancel-circled pull-right'>Card</span>
              </a>
              <br />
              <label><span className='dialog-label'>Icon URL</span></label>
              <input
                type='text'
                name='card_icon_url'
                className='dialog-input response-card-icon-url-input'
                value={card.iconurl}
                onChange={ (e) => this.cardInputChange(e, index) }
              />
              <br />
              Options:
              <a onClick={this.addCardOption.bind(this, index)} href='#'>
                <span className='icon-plus add-option'>Option</span>
              </a>
              {card.options.map((option, ind) => (
                <div key={ind}>
                  <label><span className='dialog-label'>Text</span></label>
                  <input
                    type='text'
                    name='card_option_text'
                    className='dialog-input response-cards-input'
                    value={option.text}
                    onChange={ (e) => this.cardInputChange(e,index, ind) }
                  />
                  &nbsp;&nbsp;&nbsp;&nbsp;
                  <label><span className='dialog-label'>Entity</span></label>
                  <input
                    type='text'
                    name='card_option_entity'
                    className='dialog-input response-cards-input'
                    value={option.entity}
                    onChange={ (e) => this.cardInputChange(e,index, ind) }
                  />
                  &nbsp;&nbsp;
                  <a onClick={this.deleteCardOption.bind(this, index, ind)} href='#'>
                    <span className='icon-cancel-circled'></span>
                  </a>
                </div>
              ))}
            </div>
          ))}
        </div>
      );
    } else {
      return(<div />);
    }
  },

  // Type-4 Q&A Type ///////////////////////////////////////////////////
  addAnswer(e) {
    e.preventDefault();

    this.setState({
      response_qna_answers: this.state.response_qna_answers.concat( [{answer:''}] )
    });
  },
  deleteAnswer(index, e) {
    e.preventDefault();

    this.state.response_qna_answers = this.state.response_qna_answers.filter((a, i) => index !== i);

    this.qnaInputChange();
  },
  qnaInputChange(event, index) {
    const name = (( event || {} ).target || {} ).name;

    if (name === 'response_qna_answers') {
      this.state[name][index].answer = event.target.value;
    } else if (name === 'response_qna_faq') {
      this.state[name] = event.target.checked;
    } else if (name) {
      this.state[name] = event.target.value;
    }

    this.setState({});

    // Create a new data object for update state
    const inputValueObj = {
      response_qna_question: this.state.response_qna_question,
      response_qna_faq: this.state.response_qna_faq,
      response_qna_answers: this.state.response_qna_answers,
      response_qna_video_thumbnail: this.state.response_qna_video_thumbnail,
      response_qna_video_url: this.state.response_qna_video_url,
      response_qna_image_thumbnail: this.state.response_qna_image_thumbnail,
      response_qna_image_url: this.state.response_qna_image_url,
      response_qna_link_text: this.state.response_qna_link_text,
      response_qna_url: this.state.response_qna_url
    };

    // updateState
    this.updateParentState(inputValueObj);
  },

  renderQnAType() {
    if (this.state.responseType === 'qna'){
      return(
        <div>
          <label><span className='dialog-label'>Question</span></label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_qna_question'
            value={this.state.response_qna_question}
            onChange={ (e) => this.qnaInputChange(e) }
          />
          <br />

          <label>
            <span className='dialog-label'>Include in FAQ</span>
          </label>
          <input
            className='response-qna-faq'
            type="checkbox"
            name='response_qna_faq'
            checked={this.state.response_qna_faq}
            onChange={ (e) => this.qnaInputChange(e) }
          />
          <br />

          <label>
            <span className='dialog-label'>Answer</span>
            <a onClick={this.addAnswer} href='#' className='pull-right'>
              <span className='icon-plus add-answer'>Answer</span>
            </a>
          </label>
          <br />
          {this.state.response_qna_answers.map((answer, index) => (
            <div key={index}>
              <label>
                <textarea
                  name='response_qna_answers'
                  className='response-qna-answer-input'
                  value={answer.answer}
                  onChange={ (e) => this.qnaInputChange(e, index) }
                />
                &nbsp;&nbsp;
                <a onClick={this.deleteAnswer.bind(this, index)} href='#'>
                  <span className='icon-cancel-circled'></span>
                </a>
              </label>
            </div>
          ))}
          <br />

          <label>
            <span className='dialog-label'>Video Thumbnail</span>
          </label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_qna_video_thumbnail'
            value={this.state.response_qna_video_thumbnail}
            onChange={ (e) => this.qnaInputChange(e) }
          />
          &nbsp;&nbsp;&nbsp;&nbsp;
          <label><span className='dialog-label'>Video Url</span></label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_qna_video_url'
            value={this.state.response_qna_video_url}
            onChange={ (e) => this.qnaInputChange(e) }
          />
          <br />

          <label><span className='dialog-label'>Image Thumbnail</span></label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_qna_image_thumbnail'
            value={this.state.response_qna_image_thumbnail}
            onChange={ (e) => this.qnaInputChange(e) }
          />
          &nbsp;&nbsp;&nbsp;&nbsp;
          <label><span className='dialog-label'>Image Url</span></label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_qna_image_url'
            value={this.state.response_qna_image_url}
            onChange={ (e) => this.qnaInputChange(e) }
          />
          <br />

          <label><span className='dialog-label'>Link Text</span></label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_qna_link_text'
            value={this.state.response_qna_link_text}
            onChange={ (e) => this.qnaInputChange(e) }
          />
          &nbsp;&nbsp;&nbsp;&nbsp;
          <label><span className='dialog-label'>Url</span></label>
          <input
            className='dialog-input response-input'
            type='text'
            name='response_qna_url'
            value={this.state.response_qna_url}
            onChange={ (e) => this.qnaInputChange(e) }
          />
        </div>
      )
    }
  },

  // Render Response Trigger type ////////////////////////////////////////
  renderTriggerType() {
    if (this.state.trigger_type === 'timeDelayInSecs') {
      return(
        <input
          className='dialog-input response_trigger'
          name='timeDelayInSecs'
          type='number'
          placeholder="seconds"
          value={this.state.response_trigger}
          onChange={this.responseTriggerChange}
        />
      );
    } else if (this.state.trigger_type === 'videoClosed') {
      return(
        <input
          className='dialog-input response_trigger'
          name='videoClosed'
          type='checkbox'
          checked={this.state.response_trigger}
          onChange={this.responseTriggerChange}
        />
      );
    } else if (this.state.trigger_type === 'customerService'){
      return(
        <input
          className='dialog-input response_trigger'
          name='customerService'
          type='checkbox'
          value={this.state.response_trigger}
          checked={this.state.response_trigger}
          onChange={this.responseTriggerChange}
        />
      );
    } else {
      return(
        <div></div>
      );
    }
  },

  // Main Render ///////////////////////////////////////////////////////
  renderTypeContent() {
    return (
      <div>
        { this.renderTextType()  }
        { this.renderTextWithOptionType() }
        { this.renderVideoType() }
        { this.renderCardType() }
        { this.renderQnAType() }
      </div>
    );
  },

  render() {
    var hasCancel = '';
    if (this.props.index > 0){
      hasCancel = (
        <a onClick={this.deleteInput} href='#'>
          <span className='icon-cancel-circled pull-right'></span>
        </a>
      );
    }

    var hasAdd = '';
    if ( this.props.index < 1){
      hasAdd = (
        <a onClick={this.addRow} href='#'>
          <span className='icon-plus pull-right'>Response</span>
        </a>
      );
    }

    return(
      <tr className={`response-type-row-${this.props.index}`}>
        <td className='row16'>
          <span className='responseTypeLabel'>
            <strong>Response type</strong>
          </span>
          <br />
          <span className='responseValueLabel'>
            <strong>Response value</strong>
          </span>
          <br />
          <span className='responseTriggerLabel'>
            <strong>Response trigger</strong>
          </span>
        </td>

        <td className='row44_5'>
          <select
            className='dialog-select'
            name='response-type-select'
            value={this.state.responseType}
            onChange={this.responseTypeMenuChange}
          >
            <option key='0' value='text'>Text</option>
            <option key='1' value='text_with_option'>Text With Option</option>
            <option key='2' value='video'>Video</option>
            <option key='3' value='card'>Card</option>
            <option key='4' value='qna'>Q & A</option>
          </select>
          <br /><br />
          { this.renderTypeContent() }
          <br />

          <select
            name='trigger_type'
            value={ this.state.trigger_type }
            onChange={(e) => this.triggerMenuChange(e)}
          >
            <option key='0' value='null'>Null</option>
            <option key='1' value='timeDelayInSecs'>Time delay in seconds</option>
            <option key='2' value='videoClosed'>Video closed</option>
            <option key='3' value='customerService'>Customer service</option>
          </select>
          &nbsp;&nbsp;&nbsp;&nbsp;
          { this.renderTriggerType() }
        </td>

        <td className='valign-top'>
          <input type='hidden' className='response-id' value={this.props.response_id} />
          {hasCancel}
          {hasAdd}
        </td>
      </tr>
    );
  }

});
