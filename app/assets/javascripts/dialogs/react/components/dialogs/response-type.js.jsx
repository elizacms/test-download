var ResponseType = React.createClass({
  getInitialState(){
    return {
      name: '',
      index: '',
      response_id: '',
      responseType: 'text',
      response_trigger: '',
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
    this.setState({
      response_trigger: this.props.response_trigger,
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
    this.setState({
      response_trigger: nextProps.response_trigger,
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

  handleInputChanges(event, field) {
    this.state[field] = event.target.value;
    this.setState({});

    const inputValueObj = {};
    this.props.updateState( 'responses_attributes', {
      id: this.props.index,
      value: this.state.responseType,
      inputValue: inputValueObj[field] = this.state[field],
      response_trigger: this.state.response_trigger,
      response_id: this.state.response_id
    });
  },

  responseTypeMenuChange(event){
    this.setState({ responseType: event.target.value });
  },

  // Type-0 Text Type //////////////////////////////////////////////////
  renderTextType() {
    if (this.state.responseType === 'text'){
      return(
        <div>
          <label>
            <span className='dialog-label'>Text &nbsp;</span>
          </label>
            <input
              className='dialog-input response-input'
              type='text'
              name='response_text_input'
              value={this.state.response_text_input}
              onChange={ (e) => this.handleInputChanges(e, 'response_text_input') }
            />
          <br />
          <label>
            <span className='dialog-label'>Spoken Text &nbsp;</span>
          </label>
            <input
              className='dialog-input response-input'
              type='text'
              name='response_text_spokentext'
              value={this.state.response_text_spokentext}
              onChange={ (e) => this.handleInputChanges(e, 'response_text_spokentext') }
            />
          </label>
          <br />
          <label>
            Response Trigger &nbsp;
            <input
              className='dialog-input response_trigger'
              name='response_trigger_input'
              type='text'
              value={this.state.response_trigger}
              onChange={ (e) => this.handleInputChanges(e, 'response_trigger') }
            />
          </label>
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
    });
  },
  optionInputChange(event, index) {
    // Update state for response_trigger
    if (event.target.name == 'response_trigger_input'){
      this.state.response_trigger = event.target.value;
      this.setState({});
    }
    // Create new options array state
    const newOptions = this.state.options.map((option, i) => {
      if (index !== i) return option;

      if (event.target.name == 'option_text') {
        option.text = event.target.value;
        return option;
      }

      if (event.target.name == 'option_entity') {
        option.entity = event.target.value;
        return option;
      }
    });
    this.setState({ options: newOptions });
    // New inputValue object for updateState
    const inputValueObj = {
      response_text_with_option_text_input: this.state.response_text_with_option_text_input,
      options: this.state.options
    };
    // updateState
    this.props.updateState( 'responses_attributes', {
      id: this.props.index,
      value: this.state.responseType,
      inputValue: inputValueObj,
      response_trigger: this.state.response_trigger,
      response_id: this.state.response_id
    });
  },

  renderTextWithOptionType() {
    if (this.state.responseType === 'text_with_option'){
      return(
        <div>
          <label>
            Text &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_text_with_option_text_input'
              value={this.state.response_text_with_option_text_input}
              onChange={ (e) => this.handleInputChanges(e, 'response_text_with_option_text_input') }
            />
            &nbsp;&nbsp;&nbsp;&nbsp;
            <a onClick={this.addOptions} href='#'>
              <span className='icon-plus add-option'>Option</span>
            </a>
          </label>
          <br />

          {this.state.options.map((option, index) => (
            <div key={index}>
              <label>
                Option &nbsp;
                <input
                  type='text'
                  name='option_text'
                  placeholder='Text'
                  className='dialog-input response-option-input'
                  value={option.text}
                  onChange={ (e) => this.optionInputChange(e, index) }
                />
                &nbsp;&nbsp;
                Entity &nbsp;
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
              </label>
            </div>
          ))}

          <br />
          <label>
            Response Trigger &nbsp;
            <input
              className='dialog-input response_trigger'
              name='response_trigger_input'
              type='text'
              value={this.state.response_trigger}
              onChange={ (e) => this.optionInputChange(e) }
            />
          </label>
        </div>
      );
    } else {
      return(<div />);
    }
  },

  // Type-2 Video Type /////////////////////////////////////////////////
  renderVideoType() {
    if (this.state.responseType === 'video'){
      return(
        <div>
          <label>
            Text &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_video_text_input'
              value={this.state.response_video_text_input}
              onChange={ (e) => this.handleInputChanges(e, 'response_video_text_input') }
            />
          </label>
          <br />
          <label>
            Video &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_video_thumbnail_input'
              placeholder='Thumbnail'
              value={this.state.response_video_thumbnail_input}
              onChange={ (e) => this.handleInputChanges(e, 'response_video_thumbnail_input') }
            />
          </label>
          &nbsp;&nbsp;
          <label>
            Entity Value &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_video_entity_input'
              placeholder='Link'
              value={this.state.response_video_entity_input}
              onChange={ (e) => this.handleInputChanges(e, 'response_video_entity_input') }
            />
          </label>
          <br />
          <label>
            Response Trigger &nbsp;
            <input
              className='dialog-input response_trigger'
              name='response_trigger_input'
              type='text'
              value={this.state.response_trigger}
              onChange={ (e) => this.handleInputChanges(e, 'response_trigger') }
            />
          </label>
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
    this.setState({});
  },
  cardInputChange(event, card_index, option_index) {
    switch(event && event.target.name) {
      case 'card_text':
        this.state.cards[card_index].text = event.target.value;
        break;
      case 'card_icon_url':
        this.state.cards[card_index].iconurl = event.target.value;
        break;
      case 'card_option_text':
        this.state.cards[card_index].options[option_index].text = event.target.value;
        break;
      case 'card_option_entity':
        this.state.cards[card_index].options[option_index].entity = event.target.value;
        break;
      case 'response_trigger_input':
        this.state.response_trigger = event.target.value;
      default:
        break;
    }
    this.setState({});

    const inputValueObj = { cards: this.state.cards };
    // updateState
    this.props.updateState( 'responses_attributes', {
      id: this.props.index,
      value: this.state.responseType,
      inputValue: inputValueObj,
      response_trigger: this.state.response_trigger,
      response_id: this.state.response_id
    });
  },

  renderCardType() {
    if (this.state.responseType === 'card'){
      return(
        <div>
          <label>
            Card &nbsp;
            <a onClick={this.addCard} href='#'>
              <span className='icon-plus add-card pull-right'>Card</span>
            </a>
          </label>
          <br />

          {this.state.cards.map((card, index) => (
            <div key={index} className="card-bg">
              <label>
                Text &nbsp;
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
                Icon URL &nbsp;
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
                { card.options.map((option, ind) => (
                  <div key={ind}>
                    <label>
                      Text &nbsp;
                      <input
                        type='text'
                        name='card_option_text'
                        className='dialog-input response-cards-input'
                        value={option.text}
                        onChange={ (e) => this.cardInputChange(e,index, ind) }
                      />
                      &nbsp;&nbsp;
                      Entity &nbsp;
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
                    </label>
                  </div>
                ))}
              </label>
            </div>
          ))}

          <br />
          <label>
            Response Trigger &nbsp;
            <input
              className='dialog-input response_trigger'
              name='response_trigger_input'
              type='text'
              value={this.state.response_trigger}
              onChange={ (e) => this.cardInputChange(e) }
            />
          </label>
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
    // event.try(target).try(name)
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
    this.props.updateState( 'responses_attributes', {
      id: this.props.index,
      value: this.state.responseType,
      inputValue: inputValueObj,
      response_trigger: this.state.response_trigger,
      response_id: this.state.response_id
    });
  },

  renderQnAType() {
    if (this.state.responseType === 'qna'){
      return(
        <div>
          <label>
            Question &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_qna_question'
              value={this.state.response_qna_question}
              onChange={ (e) => this.qnaInputChange(e) }
            />
          </label>
          <br />

          <label>
            Include in FAQ &nbsp;
            <input
              className='response-input'
              type="checkbox"
              name='response_qna_faq'
              checked={this.state.response_qna_faq}
              onChange={ (e) => this.qnaInputChange(e) }
            />
          </label>
          <br />

          <label>
            Answer &nbsp;
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
            Video Thumbnail &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_qna_video_thumbnail'
              value={this.state.response_qna_video_thumbnail}
              onChange={ (e) => this.qnaInputChange(e) }
            />
            &nbsp;&nbsp;&nbsp;&nbsp;
            Video Url &nbsp;
            <input
              className='dialog-input response-qna-faq'
              type='text'
              name='response_qna_video_url'
              value={this.state.response_qna_video_url}
              onChange={ (e) => this.qnaInputChange(e) }
            />
          </label>
          <br />

          <label>
            Image Thumbnail &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_qna_image_thumbnail'
              value={this.state.response_qna_image_thumbnail}
              onChange={ (e) => this.qnaInputChange(e) }
            />
            &nbsp;&nbsp;&nbsp;&nbsp;
            Image Url &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_qna_image_url'
              value={this.state.response_qna_image_url}
              onChange={ (e) => this.qnaInputChange(e) }
            />
          </label>
          <br />

          <label>
            Link Text &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_qna_link_text'
              value={this.state.response_qna_link_text}
              onChange={ (e) => this.qnaInputChange(e) }
            />
            &nbsp;&nbsp;&nbsp;&nbsp;
            Url &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_qna_url'
              value={this.state.response_qna_url}
              onChange={ (e) => this.qnaInputChange(e) }
            />
          </label>
        </div>
      )
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

        <td className='row40'>
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
          <br />
          { this.renderTypeContent() }
          <input
            className='dialog-input response_trigger'
            name='response_trigger_input'
            type='text'
            value={this.state.response_trigger}
            onChange={ (e) => this.cardInputChange(e) }
          />
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
