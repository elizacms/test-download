var DialogSelectBox = React.createClass({
  propTypes: {
  },

  getInitialState() {
    return {
      field1: '',
      field2: ''
    };
  },

  componentDidMount () {
    this.setState({
      field1: this.props.value,
      field2: ''
    });
  },

  componentWillReceiveProps(nextProps) {
    this.setState({
      field1: nextProps.value,
      field2: ''
    });
  },

  selectBoxHandleChange(event){
    this.setState({field1: event.target.value})
  },

  duplicateRow(e){
    e.preventDefault();
    this.props.addRow(this.props.name);
  },

  deleteRow(e){
    e.preventDefault();
    this.props.deleteRow();
  },

  render: function() {
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
          placeholder={this.props.inputPlaceholder}></input>
      );
    }

    var hasCancel = '';
    if (this.props.index > 0){
      hasCancel = (
        <a onClick={this.deleteRow} href='#'>
          <span className='icon-cancel-circled pull-right'></span>
        </a>
      );
    }

    var hasAdd = '';
    if ( this.props.index < 1){
      hasAdd = (
        <a onClick={this.duplicateRow} href='#'>
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
