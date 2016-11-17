var DialogSelectbox = React.createClass({
  propTypes: {
  },

  getInitialState() {
    return {
      field1: '',
      field2: ''
    };
  },

  componentDidMount() {
    this.setState({
      field1: this.props.value,
      field2: this.props.inputValue
    });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      field1: nextProps.value,
      field2: nextProps.inputValue
    });
  },

  selectBoxHandleChange(event){
    this.state.field1 = event.target.value;
    this.setState({});

    this.props.updateState( this.props.name, {
      id: this.props.index,
      value: this.state.field1,
      inputValue: this.state.field2
    });
  },

  inputHandleChange(event){
    this.state.field2 = event.target.value;
    this.setState({});

    this.props.updateState( this.props.name, {
      id: this.props.index,
      value: this.state.field1,
      inputValue: this.state.field2
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

  render() {
    var field_options = (
      this.props.fields.map(function(field, index){
        return <option key={index}>{field}</option>;
      }.bind(this))
    );

    var hasInput = '';
    if (this.props.hasInput) {
      hasInput = (
        <input
          className='dialog-input'
          name={this.props.inputName}
          type='text'
          value={this.state.field2}
          placeholder={this.props.inputPlaceholder}
          onChange={this.inputHandleChange}></input>
      );
    }

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
          <span className='icon-plus pull-right'></span>
        </a>
      );
    }

    return (
      <tr>
        <td className='row16'>
          <strong>{this.props.title}</strong>
        </td>
        <td className='row40'>
          <select
            className='dialog-select'
            name={this.props.name}
            value={this.state.field1}
            onChange={this.selectBoxHandleChange}
          >
            <option></option>
            {field_options}
          </select>
        </td>
        <td>
          {hasInput}
          {hasCancel}
          {hasAdd}
        </td>
      </tr>
    );
  }
});
