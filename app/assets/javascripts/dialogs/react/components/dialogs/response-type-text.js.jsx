var ResponseTypeText = React.createClass({

  getInitialState() {
    return {
      input_option: '',
      input_option_entity: '',
      input_link: '',
      input_link_entity: '',
      response_trigger: '',
      response_id: ''
    };
  },

  componentDidMount() {
    this.setState({
      response_trigger: this.props.response_trigger
    });

    if (this.props.inputValue) {
      this.setState({
        input_option: this.props.inputValue.input_option,
        input_option_entity: this.props.inputValue.input_option_entity,
        input_link: this.props.inputValue.input_link,
        input_link_entity: this.props.inputValue.input_link_entity
      });
    }
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      response_trigger: nextProps.response_trigger
    });

    if (nextProps.inputValue) {
      this.setState({
        input_option: nextProps.inputValue.input_option,
        input_option_entity: nextProps.inputValue.input_option_entity,
        input_link: nextProps.inputValue.input_link,
        input_link_entity: nextProps.inputValue.input_link_entity
      });
    }
  },

  inputHandleChange(event, field) {
    this.state[field] = event.target.value;
    this.setState({});

    this.props.updateState( 'responses_attributes', {
      id: this.props.index,
      value: this.props.responseType,
      inputValue: { input_option: this.state.input_option,
                    input_option_entity: this.state.input_option_entity,
                    input_link: this.state.input_link,
                    input_link_entity: this.state.input_link_entity },
      response_trigger: this.state.response_trigger,
      response_id: this.props.response_id
    });
  },

  render() {
    return(
      <div>
        <input type='hidden' className='response-id' value={this.props.response_id} />
        <label>
          Option &nbsp;
          <input
            className='dialog-input'
            type="text"
            name={'input_option'}
            value={this.state.input_option}
            onChange={ (e) => this.inputHandleChange(e, 'input_option') }
          />
        </label>
        &nbsp;&nbsp;
        <label>
          Entity Value &nbsp;
          <input
            className='dialog-input'
            type="text"
            name={'input_option_entity'}
            value={this.state.input_option_entity}
            onChange={ (e) => this.inputHandleChange(e, 'input_option_entity') }
          />
        </label>
        <br />
        <label>
          Link &nbsp;
          <input
            className='dialog-input'
            type="text"
            name={'input_link'}
            value={this.state.input_link}
            onChange={ (e) => this.inputHandleChange(e, 'input_link') }
          />
        </label>
        &nbsp;&nbsp;
        <label>
          Entity Value &nbsp;
          <input
            className='dialog-input'
            type="text"
            name={'input_link_entity'}
            value={this.state.input_link_entity}
            onChange={ (e) => this.inputHandleChange(e, 'input_link_entity') }
          />
        </label>
        <br />
        <label>
          Response Trigger &nbsp;
          <input
            className='dialog-input response_trigger'
            type="text"
            value={this.state.response_trigger}
            onChange={ (e) => this.inputHandleChange(e, 'response_trigger') }
          />
        </label>
      </div>
    );
  }
});
