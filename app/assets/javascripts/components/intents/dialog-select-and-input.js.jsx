var DialogSelectAndInput = React.createClass({
  propTypes: {
  },

    render: function() {
      var field_options = (
        this.props.fields.map(function(field, index){
          return <option key={index}>{field}</option>;
        }.bind(this))
      );

      return (
        <tr>
          <td className='row16'>
            <strong>{this.props.title}</strong>
          </td>
          <td className='row40'>
            <select className='dialog-select' name={this.props.name}>
              <option></option>
              {field_options}
            </select>
          </td>
          <td>
            <input
              className='dialog-input'
              name={this.props.inputName}
              type='text'
              placeholder={this.props.inputPlaceholder}></input>

            <a href="#">
              <span className='icon-plus pull-right'></span>
            </a>
          </td>
        </tr>
      );
    }
});
