var ResponseType = React.createClass({
  getInitialState(){
    return {
      name: '',
      index: '',
      response_id: '',
      responseType: 'text',
      response_trigger: '',
      trigger_type: 'null',
      newInputValues: {},
    };
  },

  componentDidMount() {
    const response_trigger_key = Object.keys(this.props.response_trigger)[0] || '';

    this.setState({
      name: this.props.name,
      index: this.props.index,
      response_id: this.props.response_id,
      response_trigger: this.props.response_trigger,
      trigger_type: response_trigger_key
    });

    if (this.props.inputValue) {
      this.setState({
        responseType: this.props.value,
        newInputValues: this.props.inputValue
      });
    };
  },

  componentWillReceiveProps(nextProps) {
    const response_trigger_key = Object.keys(nextProps.response_trigger)[0] || '';

    this.setState({
      name: nextProps.name,
      index: nextProps.index,
      response_id: nextProps.response_id,
      response_trigger: nextProps.response_trigger,
      trigger_type: response_trigger_key
    });

    if (nextProps.inputValue) {
      this.setState({
        responseType: nextProps.value,
        newInputValues: nextProps.inputValue
      });
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
    this.setState({ 
      responseType: event.target.value,
      newInputValues: {}
    }, () => {
      this.updateParentState({});
    });
  },

  triggerMenuChange(event){
    const ttype = event.target.value;

    this.setState({ trigger_type: ttype });

    if (ttype === 'videoClosed' || ttype === 'customerService') {
      this.state.response_trigger = { [ttype]: 'false' };
    } else if ( ttype === 'timeDelayInSecs') {
      this.state.response_trigger = { [ttype]: '' };
    } else {
      this.state.response_trigger = '';
    }
    this.setState({});

    this.updateParentState({});
  },

  responseTriggerChange(event){
    let ttype = event.target.name;

    if ( this.state.trigger_type == 'null' ) {
      this.state.response_trigger = '';
    } else {
      this.state.response_trigger = { [ttype]: event.target.value };
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

  handleDataFromChild(newValue) {
    const tmpStateValues = this.state.newInputValues;

    for (var prop in newValue) {
      tmpStateValues[prop] = newValue[prop];
    }

    this.setState({
      newInputValues: tmpStateValues
    }, () => {
      this.updateParentState( tmpStateValues );
    });
  },

  renderComponents(){
    const selectedType = this.state.responseType;
    let attachment = "";

    switch(selectedType) {
      case 'text':
        attachment = <Text
                      value={this.state.newInputValues}
                      componentData={this.handleDataFromChild}
                    />
        break;
      case 'textWithOption':
        attachment = <div>
                    <Text
                      value={this.state.newInputValues}
                      componentData={this.handleDataFromChild}
                    />
                    <Template
                      templateType="options"
                      value={this.state.newInputValues}
                      componentData={this.handleDataFromChild}
                    />
                    </div>
        break;
      case 'video':
        attachment = <div>
                    <Text
                      value={this.state.newInputValues}
                      componentData={this.handleDataFromChild}
                    />
                    <Video
                      value={this.state.newInputValues}
                      componentData={this.handleDataFromChild}
                    />
                    </div>
        break;
      case 'card':
        attachment = <Template
                      templateType="cards"
                      value={this.state.newInputValues}
                      componentData={this.handleDataFromChild}
                    />
        break;
      case 'qna':
        attachment = <Qna
                      value={this.state.newInputValues}
                      componentData={this.handleDataFromChild}
                    />
        break
      default:
        break;
    };

    return(
      <div>
        {attachment}
      </div>
    );
  },

  // Render Response Trigger type ////////////////////////////////////////
  renderTriggerType() {
    if (this.state.trigger_type === 'timeDelayInSecs') {
      return(
        <input
          className='dialog-input response_trigger abs-position'
          name='timeDelayInSecs'
          type='number'
          placeholder="seconds"
          value={this.state.response_trigger.timeDelayInSecs}
          onChange={this.responseTriggerChange}
        />
      );
    } else if (this.state.trigger_type === 'videoClosed') {
      return(
        <form
          className="top-margin-21"
        >
        &nbsp;&nbsp;&nbsp;&nbsp;
          <label>
            <input
              className='dialog-input response_trigger'
              name='videoClosed'
              type='radio'
              value='true'
              checked={this.state.response_trigger.videoClosed == 'true'}
              onChange={this.responseTriggerChange}
            />&nbsp;
            True
          </label>
          <label>
            <input
              className='dialog-input response_trigger'
              name='videoClosed'
              type='radio'
              value='false'
              checked={this.state.response_trigger.videoClosed == 'true' ? false : true}
              onChange={this.responseTriggerChange}
            />&nbsp;
            False
          </label>
        </form>
      );
    } else if (this.state.trigger_type === 'customerService'){
      return(
        <form
          className="top-margin-21"
        >
        &nbsp;&nbsp;&nbsp;&nbsp;
          <label>
            <input
              className='dialog-input response_trigger'
              name='customerService'
              type='radio'
              value='true'
              checked={this.state.response_trigger.customerService == 'true'}
              onChange={this.responseTriggerChange}
            />&nbsp;
            True
          </label>
          <label>
            <input
              className='dialog-input response_trigger'
              name='customerService'
              type='radio'
              value='false'
              checked={this.state.response_trigger.customerService == 'true' ? false : true}
              onChange={this.responseTriggerChange}
            />&nbsp;
            False
          </label>
        </form>
      );
    } else {
      return(
        <div></div>
      );
    }
  },

  // Main Render ///////////////////////////////////////////////////////
  render() {
    var hasCancel = '';
    if (this.props.index > 0){
      hasCancel = (
        <a onClick={this.deleteInput} href='#'>
          <span className='fa fa-trash add-remove-response'></span>
        </a>
      );
    }

    var hasAdd = '';
    if ( this.props.index < 1){
      hasAdd = (
        <a onClick={this.addRow} href='#'>
          <span className='add-remove-response'>Add Response</span>
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
            <option key='1' value='textWithOption'>Text With Option</option>
            <option key='2' value='video'>Video</option>
            <option key='3' value='card'>Card</option>
            <option key='4' value='qna'>Q & A</option>
          </select>
          <br /><br />
          { this.renderComponents() }
          <br />

          <select
            className='float-left'
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
          {hasCancel}
          {hasAdd}
        </td>
      </tr>
    );
  }
});
