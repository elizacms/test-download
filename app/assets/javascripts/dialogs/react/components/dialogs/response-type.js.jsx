var ResponseType = React.createClass({
  getInitialState(){
    return {
      responseType: 'text',
      index: '',
      response_id: '',
      name: '',
      // Text Type
      response_text_input: '',
      // Response type fields
      // response_trigger: '',
      // input_option: '',
      // input_option_entity: '',
      // input_link: '',
      // input_link_entity: ''
    };
  },

  componentDidMount() {
    this.setState({
      response_trigger: this.props.response_trigger,
      index: this.props.index,
      response_id: this.props.response_id,
      name: this.props.name
    });

    const obj = {};
    if (this.props.inputValue) {
      objKey = Object.keys(this.props.inputValue);
      objVal = this.props.inputValue[objKey];
      obj[objKey] = objVal;
      this.setState( obj )
    };
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      response_trigger: nextProps.response_trigger,
      index: nextProps.index,
      response_id: nextProps.response_id,
      name: nextProps.name
    });

    const obj = {};
    if (nextProps.inputValue) {
      objKey = Object.keys(nextProps.inputValue);
      objVal = nextProps.inputValue[objKey];
      obj[objKey] = objVal;
      this.setState( obj )
    } else {
      this.setState( this.getInitialState() ) //Next props has no input value. reset state.
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
      // inputValue: { input_option: this.state.input_option,
      //               input_option_entity: this.state.input_option_entity,
      //               input_link: this.state.input_link,
      //               input_link_entity: this.state.input_link_entity },
      response_trigger: this.state.response_trigger,
      response_id: this.state.response_id
    });
  },

  responseTypeMenuChange(event){
    this.setState({
      responseType: event.target.value
    });
  },

  // Text Type Render //////////////////////////////////////////////////
  renderTextType() {
    if (this.state.responseType === 'text'){
      return(
        <div>
          <label>
            Text &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_text_input'
              value={this.state.response_text_input}
              onChange={ (e) => this.handleInputChanges(e, 'response_text_input') }
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

  // Video Type Render //////////////////////////////////////////////////
  renderVideoType() {
    if (this.state.responseType === 'video'){
      return(
        <div>
          <label>
            Thumbnail &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name={'input_option'}
              value={this.state.input_option}
              onChange={ (e) => this.handleInputChanges(e, 'input_option') }
            />
          </label>
          &nbsp;&nbsp;
          <label>
            Entity Value &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name={'input_option_entity'}
              value={this.state.input_option_entity}
              onChange={ (e) => this.handleInputChanges(e, 'input_option_entity') }
            />
          </label>
          <br />
          <label>
            Link &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name={'input_link'}
              value={this.state.input_link}
              onChange={ (e) => this.handleInputChanges(e, 'input_link') }
            />
          </label>
          &nbsp;&nbsp;
          <label>
            Entity Value &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name={'input_link_entity'}
              value={this.state.input_link_entity}
              onChange={ (e) => this.handleInputChanges(e, 'input_link_entity') }
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

  // Card Type Render //////////////////////////////////////////////////
  renderCardType() {
    if (this.state.responseType === 'card'){
      return(
        <div>
          <label>
            Card Option &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name={'input_option'}
              value={this.state.input_option}
              onChange={ (e) => this.handleInputChanges(e, 'input_option') }
            />
          </label>
          &nbsp;&nbsp;
          <label>
            Entity Value &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name={'input_option_entity'}
              value={this.state.input_option_entity}
              onChange={ (e) => this.handleInputChanges(e, 'input_option_entity') }
            />
          </label>
          <br />
          <label>
            Link &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name={'input_link'}
              value={this.state.input_link}
              onChange={ (e) => this.handleInputChanges(e, 'input_link') }
            />
          </label>
          &nbsp;&nbsp;
          <label>
            Entity Value &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name={'input_link_entity'}
              value={this.state.input_link_entity}
              onChange={ (e) => this.handleInputChanges(e, 'input_link_entity') }
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

  renderTypeContent() {
    return (
      <div>
        { this.renderTextType()  }
        { this.renderVideoType() }
        { this.renderCardType() }
      </div>
    );
  },

  // Main Render //////////////////////////////////////////////////
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
          <strong>{this.props.title}</strong>
        </td>

        <td className='row40'>
          <select
            className='dialog-select'
            name='response-type-select'
            value={this.state.responseType}
            onChange={this.responseTypeMenuChange}
          >
            <option key='0' value='text'>Text</option>
            <option key='1' value='video'>Video</option>
            <option key='2' value='card'>Card</option>
            <option key='3' value='3'>3</option>
            <option key='4' value='4'>4</option>
          </select>
          <br />
          { this.renderTypeContent() }
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
