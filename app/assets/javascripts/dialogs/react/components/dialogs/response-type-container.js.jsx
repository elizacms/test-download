var ResponseTypeContainer = React.createClass({
  getInitialState() {
    return {
      responseType: 'text'
    };
  },

  componentDidMount() {
    if (this.props.inputValue) {
      this.setState({
        responseType: this.props.value
      })
    }
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      responseType: nextProps.value
    })
  },

  selectResponseTypeChange(event){
    this.setState({
      responseType: event.target.value
    });
  },

  addRow(e){
    e.preventDefault();
    this.props.addRow(this.props.name);
  },

  deleteInput(e){
    e.preventDefault();
    this.props.deleteInput();
  },

  responseTypeField(){
    switch(this.state.responseType){
      case "video": {
        return(
          <ResponseTypeVideo
            responseType={this.props.value}
          />
        );
        break;
      }
      case "card": {
        return(
          <ResponseTypeCard
            responseType={this.props.value}
          />
        );
        break;
      }
      case "3": {
        return(
          <div>
            type 3
          </div>
        );
        break;
      }
      case "4": {
        return(
          <div>
            type 4
          </div>
        );
        break;
      }
      default: {
        return(
          <ResponseTypeText
            index={this.props.index}
            inputValue={this.props.inputValue}
            responseType={this.props.value}
            updateState={this.props.updateState}
            response_trigger={this.props.response_trigger}
            response_id={this.props.response_id}
          />
        );
        break;
      }
    }
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

    return (
      <tr className={`response-type-row-${this.props.index}`}>
        <td className='row16'>
          <strong>Response Type</strong>
        </td>
        <td className='row40'>
          <select
            className='dialog-select'
            value={this.state.responseType}
            onChange={this.selectResponseTypeChange}
          >
            <option key="0" value="text">Text</option>
            <option key="1" value="video">Video</option>
            <option key="2" value="card">Card</option>
            <option key="3" value="3">3</option>
            <option key="4" value="4">4</option>
          </select>
          <br />
          { this.responseTypeField() } {/* Render different fields based on type */}
        </td>
        <td className='valign-top'>
          {hasCancel}
          {hasAdd}
        </td>
      </tr>
    );
  }
});
