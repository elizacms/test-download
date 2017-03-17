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
      // Text With Option
      response_text_with_option_text_input: '',
      response_text_with_option_option_input: '',
      response_text_with_option_entity_input: '',
      // Video Type
      response_video_text_input: '',
      response_video_thumbnail_input: '',
      response_video_entity_input: ''

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

  // Additional Options
  extraOption(){

  },

  // Text With Option Type Render //////////////////////////////////////////////////
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
          </label>
          <br />

          <label>
            Option &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_text_with_option_option_input'
              value={this.state.response_text_with_option_option_input}
              onChange={ (e) => this.handleInputChanges(e, 'response_text_with_option_option_input') }
            />
          </label>
          &nbsp;&nbsp;
          <label>
            Entity Value &nbsp;
            <input
              className='dialog-input response-input'
              type='text'
              name='response_text_with_option_entity_input'
              value={this.state.response_text_with_option_entity_input}
              onChange={ (e) => this.handleInputChanges(e, 'response_text_with_option_entity_input') }
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

  renderTypeContent() {
    return (
      <div>
        { this.renderTextType()  }
        { this.renderTextWithOptionType() }
        { this.renderVideoType() }
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
            <option key='1' value='text_with_option'>Text With Option</option>
            <option key='2' value='video'>Video</option>
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
